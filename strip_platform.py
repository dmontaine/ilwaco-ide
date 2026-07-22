#!/usr/bin/env python3
"""
Strip Windows-only and GTK2/GTK4 preprocessor branches from FreeBASIC source,
keeping only the Linux/GTK3 path. Processes src/ and Controls/MyFbFramework/mff/.

Preserves UTF-8 BOM and original line endings.
"""

import os
import re
import sys
from pathlib import Path

ROOTS = [Path('/home/don/Projects/ilwaco-ide/src'),
         Path('/home/don/Projects/ilwaco-ide/Controls/MyFbFramework/mff')]

PLATFORM_MACROS = {
    '__USE_GTK__': True,
    '__USE_GTK3__': True,
    '__USE_GTK2__': False,
    '__USE_GTK4__': False,
    '__USE_CAIRO__': True,
    '__USE_WINAPI__': False,
    '__FB_WIN32__': False,
    '__FB_LINUX__': True,
    '__FB_64BIT__': True,
}

PLATFORM_RE = re.compile(r'|'.join(re.escape(m) for m in PLATFORM_MACROS))

DIRECTIVE_RE = re.compile(r'^(\s*)#\s*(\w+)(.*)$')


class EvalError(Exception):
    pass


def tokenize_expr(expr):
    tokens = []
    i = 0
    n = len(expr)
    while i < n:
        c = expr[i]
        if c.isspace():
            i += 1
            continue
        if c == '"':
            j = i + 1
            while j < n and expr[j] != '"':
                if expr[j] == '\\' and j + 1 < n:
                    j += 2
                else:
                    j += 1
            if j < n:
                j += 1
            tokens.append(('STRING', expr[i:j]))
            i = j
            continue
        if c.isdigit() or (c == '&' and i + 1 < n and expr[i+1].upper() in 'H'):
            j = i
            if c == '&':
                j += 2
                while j < n and expr[j].upper() in '0123456789ABCDEF':
                    j += 1
            else:
                while j < n and (expr[j].isdigit() or expr[j] in '.&HhABCFabcf'):
                    if expr[j] in "'\"":
                        break
                    j += 1
            tokens.append(('NUMBER', expr[i:j]))
            i = j
            continue
        if c.isalpha() or c == '_':
            j = i
            while j < n and (expr[j].isalnum() or expr[j] == '_'):
                j += 1
            word = expr[i:j]
            tokens.append(('IDENT', word))
            i = j
            continue
        two = expr[i:i+2]
        if two in ('<=', '>=', '<>', '=>'):
            tokens.append(('OP', two))
            i += 2
            continue
        if c in '()=<>+-*/\\^':
            tokens.append(('OP', c))
            i += 1
            continue
        tokens.append(('OP', c))
        i += 1
    return tokens


class Node:
    pass


class Const(Node):
    def __init__(self, value):
        self.value = value


class Defined(Node):
    def __init__(self, name):
        self.name = name


class Ident(Node):
    def __init__(self, name):
        self.name = name


class Number(Node):
    def __init__(self, value):
        self.value = value


class NotOp(Node):
    def __init__(self, expr):
        self.expr = expr


class Binary(Node):
    def __init__(self, op, left, right):
        self.op = op
        self.left = left
        self.right = right


class UnknownRaw(Node):
    def __init__(self, text):
        self.text = text


OPERATORS = ['OrElse', 'AndAlso', 'Imp', 'Eqv', 'Xor', 'Or', 'And']


def parse_expr(expr):
    tokens = tokenize_expr(expr)
    if not tokens:
        raise SyntaxError("empty expression")
    parser = Parser(tokens)
    return parser.parse()


class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos = 0

    def peek(self, offset=0):
        idx = self.pos + offset
        if idx < len(self.tokens):
            return self.tokens[idx]
        return None

    def consume(self):
        tok = self.peek()
        if tok is not None:
            self.pos += 1
        return tok

    def parse(self):
        node = self.parse_or_else()
        if self.peek() is not None:
            raise SyntaxError("unexpected tokens after expression")
        return node

    def parse_or_else(self):
        node = self.parse_and_then()
        while self.peek() and self.peek()[1] == 'OrElse':
            self.consume()
            right = self.parse_and_then()
            node = Binary('OrElse', node, right)
        return node

    def parse_and_then(self):
        node = self.parse_imp()
        while self.peek() and self.peek()[1] == 'AndAlso':
            self.consume()
            right = self.parse_imp()
            node = Binary('AndAlso', node, right)
        return node

    def parse_imp(self):
        node = self.parse_eqv()
        while self.peek() and self.peek()[1] == 'Imp':
            self.consume()
            right = self.parse_eqv()
            node = Binary('Imp', node, right)
        return node

    def parse_eqv(self):
        node = self.parse_xor()
        while self.peek() and self.peek()[1] == 'Eqv':
            self.consume()
            right = self.parse_xor()
            node = Binary('Eqv', node, right)
        return node

    def parse_xor(self):
        node = self.parse_or()
        while self.peek() and self.peek()[1] == 'Xor':
            self.consume()
            right = self.parse_or()
            node = Binary('Xor', node, right)
        return node

    def parse_or(self):
        node = self.parse_and_bit()
        while self.peek() and self.peek()[1] == 'Or':
            self.consume()
            right = self.parse_and_bit()
            node = Binary('Or', node, right)
        return node

    def parse_and_bit(self):
        node = self.parse_not()
        while self.peek() and self.peek()[1] == 'And':
            self.consume()
            right = self.parse_not()
            node = Binary('And', node, right)
        return node

    def parse_not(self):
        if self.peek() and self.peek()[1] == 'Not':
            self.consume()
            return NotOp(self.parse_not())
        return self.parse_comparison()

    def parse_comparison(self):
        node = self.parse_add()
        while self.peek() and self.peek()[1] in ('=', '<>', '<=', '>=', '<', '>'):
            op = self.consume()[1]
            right = self.parse_add()
            node = Binary(op, node, right)
        return node

    def parse_add(self):
        node = self.parse_mul()
        while self.peek() and self.peek()[1] in ('+', '-'):
            op = self.consume()[1]
            right = self.parse_mul()
            node = Binary(op, node, right)
        return node

    def parse_mul(self):
        node = self.parse_unary()
        while self.peek() and self.peek()[1] in ('*', '/', '\\', 'Mod'):
            op = self.consume()[1]
            right = self.parse_unary()
            node = Binary(op, node, right)
        return node

    def parse_unary(self):
        if self.peek() and self.peek()[1] in ('+', '-'):
            op = self.consume()[1]
            return Binary(op, Number('0'), self.parse_unary())
        return self.parse_primary()

    def parse_primary(self):
        tok = self.peek()
        if tok is None:
            raise SyntaxError('unexpected end of expression')
        if tok[1] == '(':
            self.consume()
            node = self.parse_or_else()
            if not self.peek() or self.peek()[1] != ')':
                raise SyntaxError('expected )')
            self.consume()
            return node
        if tok[0] == 'IDENT' and tok[1] == 'defined':
            self.consume()
            if not self.peek() or self.peek()[1] != '(':
                raise SyntaxError('expected ( after defined')
            self.consume()
            name = ''
            if self.peek() and self.peek()[0] == 'IDENT':
                name = self.consume()[1]
            else:
                raise SyntaxError('expected identifier in defined()')
            if not self.peek() or self.peek()[1] != ')':
                raise SyntaxError('expected ) after defined name')
            self.consume()
            return Defined(name)
        if tok[0] == 'IDENT':
            self.consume()
            return Ident(tok[1])
        if tok[0] == 'NUMBER':
            self.consume()
            return Number(tok[1])
        if tok[0] == 'STRING':
            self.consume()
            return Ident(tok[1])
        raise SyntaxError(f'unexpected token {tok}')


def is_const(node):
    return isinstance(node, Const)


def const_value(node):
    if isinstance(node, Const):
        return node.value
    return None


def simplify(node):
    if isinstance(node, Const):
        return node
    if isinstance(node, Defined):
        val = PLATFORM_MACROS.get(node.name)
        if val is not None:
            return Const(-1 if val else 0)
        return node
    if isinstance(node, (Ident, Number, UnknownRaw)):
        return node
    if isinstance(node, NotOp):
        e = simplify(node.expr)
        c = const_value(e)
        if c is not None:
            return Const(0 if c != 0 else -1)
        if isinstance(e, NotOp):
            return e.expr
        return NotOp(e)
    if isinstance(node, Binary):
        left = simplify(node.left)
        right = simplify(node.right)
        op = node.op
        l = const_value(left)
        r = const_value(right)
        if l is not None and r is not None:
            if op == 'AndAlso':
                return Const(-1 if (l != 0 and r != 0) else 0)
            if op == 'OrElse':
                return Const(-1 if (l != 0 or r != 0) else 0)
            if op == 'And':
                return Const(l & r)
            if op == 'Or':
                return Const(l | r)
            if op == 'Xor':
                return Const(l ^ r)
            if op == 'Eqv':
                return Const(-1 if l == r else 0)
            if op == 'Imp':
                return Const(-1 if (l == 0 or r != 0) else 0)
            if op == '=':
                return Const(-1 if l == r else 0)
            if op == '<>':
                return Const(-1 if l != r else 0)
            if op == '<=':
                return Const(-1 if l <= r else 0)
            if op == '>=':
                return Const(-1 if l >= r else 0)
            if op == '<':
                return Const(-1 if l < r else 0)
            if op == '>':
                return Const(-1 if l > r else 0)
            if op == '+':
                return Const(l + r)
            if op == '-':
                return Const(l - r)
            if op == '*':
                return Const(l * r)
            if op == '/':
                return Const(int(l / r) if r != 0 else 0)
            if op == '\\':
                return Const(l // r if r != 0 else 0)
            return Binary(op, left, right)
        if op in ('AndAlso', 'And'):
            if l == 0 or r == 0:
                return Const(0)
            if l is not None and l != 0:
                return right
            if r is not None and r != 0:
                return left
            return Binary(op, left, right)
        if op in ('OrElse', 'Or'):
            if (l is not None and l != 0) or (r is not None and r != 0):
                return Const(-1)
            if l == 0:
                return right
            if r == 0:
                return left
            return Binary(op, left, right)
        if op == 'Xor':
            if l == 0:
                return right
            if r == 0:
                return left
            if l is not None and l == -1:
                return NotOp(right)
            if r is not None and r == -1:
                return NotOp(left)
            return Binary(op, left, right)
        if op == 'Eqv':
            if l == 0:
                return NotOp(right)
            if r == 0:
                return NotOp(left)
            return Binary(op, left, right)
        if op == 'Imp':
            if l == 0:
                return Const(-1)
            if l is not None and l != 0:
                return right
            if r is not None and r != 0:
                return Binary('OrElse', Const(-1), left)
            return Binary(op, left, right)
        return Binary(op, left, right)
    return node


def truth_value(node):
    c = const_value(node)
    if c is None:
        return None
    return c != 0


def node_to_str(node):
    if isinstance(node, Const):
        return str(node.value)
    if isinstance(node, Defined):
        return f'defined({node.name})'
    if isinstance(node, Ident):
        return node.name
    if isinstance(node, Number):
        return node.value
    if isinstance(node, UnknownRaw):
        return node.text
    if isinstance(node, NotOp):
        return f'Not ({node_to_str(node.expr)})'
    if isinstance(node, Binary):
        return f'({node_to_str(node.left)} {node.op} {node_to_str(node.right)})'
    return ''


def split_trailing_comment(text):
    in_str = False
    for i, ch in enumerate(text):
        if ch == '"':
            in_str = not in_str
        elif ch == "'" and not in_str:
            return text[:i], text[i:]
    return text, ''


class Directive:
    __slots__ = ('indent', 'keyword', 'raw_keyword', 'condition', 'trailing')

    def __init__(self, indent, keyword, raw_keyword, condition, trailing):
        self.indent = indent
        self.keyword = keyword
        self.raw_keyword = raw_keyword
        self.condition = condition
        self.trailing = trailing


def parse_directive(line):
    m = DIRECTIVE_RE.match(line)
    if not m:
        return None
    indent, raw_kw, rest = m.group(1), m.group(2), m.group(3)
    kw = raw_kw.lower()
    if kw not in {'ifdef', 'ifndef', 'if', 'elseif', 'else', 'endif'}:
        return None
    cond = ''
    trailing = ''
    if kw in {'ifdef', 'ifndef'}:
        rest_body, trailing = split_trailing_comment(rest)
        parts = rest_body.strip().split(None, 1)
        if parts:
            cond = parts[0]
    elif kw in {'if', 'elseif'}:
        cond, trailing = split_trailing_comment(rest)
        cond = cond.strip()
    else:
        _, trailing = split_trailing_comment(rest)
    return Directive(indent, kw, raw_kw, cond, trailing)


def condition_to_expr(directive, cond):
    if directive == 'ifdef':
        return f'defined({cond})'
    if directive == 'ifndef':
        return f'Not defined({cond})'
    return cond


def evaluate_condition(cond):
    try:
        node = parse_expr(cond)
        node = simplify(node)
        return truth_value(node), node
    except Exception:
        return None, UnknownRaw(cond)


def rewrite_unknown_directive(d, node):
    """Rewrite a directive whose condition could not be fully evaluated.

    For #ifdef/#ifndef keep the original keyword form when the condition is a
    single defined(name) / Not defined(name). Otherwise fall back to expression form.
    """
    if d.keyword == 'ifdef':
        if isinstance(node, Defined):
            return f"{d.indent}#ifdef {node.name}{d.trailing}"
    elif d.keyword == 'ifndef':
        if isinstance(node, NotOp) and isinstance(node.expr, Defined):
            return f"{d.indent}#ifndef {node.expr.name}{d.trailing}"
    # For #if / #elseif / complicated cases use the expression form.
    expr = node_to_str(node)
    if d.keyword == 'elseif':
        return f"{d.indent}#elseif {expr}{d.trailing}"
    return f"{d.indent}#{d.raw_keyword} {expr}{d.trailing}"


def is_platform_condition(cond):
    return PLATFORM_RE.search(cond) is not None


class Frame:
    __slots__ = ('state', 'branch_emit', 'output_active')

    def __init__(self, state, branch_emit, output_active):
        self.state = state
        self.branch_emit = branch_emit
        self.output_active = output_active


def process_lines(lines):
    out = []
    stack = []
    skip_depth = 0

    for raw_line in lines:
        line = raw_line.rstrip('\n\r')
        d = parse_directive(line)

        if skip_depth > 0:
            if d is not None and d.keyword in ('ifdef', 'ifndef', 'if'):
                skip_depth += 1
            elif d is not None and d.keyword == 'endif':
                skip_depth -= 1
            continue

        if stack and not stack[-1].branch_emit:
            if d is None:
                continue
            if d.keyword in ('ifdef', 'ifndef', 'if'):
                skip_depth = 1
                continue
            if d.keyword == 'elseif':
                truth, node = evaluate_condition(d.condition) if d.condition else (None, UnknownRaw(''))
                frame = stack[-1]
                if frame.state == 'seeking':
                    if truth is True:
                        frame.state = 'taken'
                        frame.branch_emit = True
                    elif truth is False:
                        frame.branch_emit = False
                    else:
                        frame.state = 'active'
                        frame.branch_emit = True
                        frame.output_active = True
                        rewritten = rewrite_unknown_directive(Directive(d.indent, 'if', 'if', d.condition, d.trailing), node)
                        if rewritten is not None:
                            out.append(rewritten)
                elif frame.state == 'taken':
                    frame.branch_emit = False
                elif frame.state == 'active':
                    if truth is True:
                        out.append(f"{d.indent}#else{d.trailing}")
                        frame.state = 'taken'
                        frame.branch_emit = True
                        frame.output_active = True
                    elif truth is False:
                        frame.branch_emit = False
                    else:
                        rewritten = rewrite_unknown_directive(d, node)
                        if rewritten is not None:
                            out.append(rewritten)
                        frame.output_active = True
                        frame.branch_emit = True
                continue
            if d.keyword == 'else':
                frame = stack[-1]
                if frame.state == 'seeking':
                    frame.state = 'taken'
                    frame.branch_emit = True
                elif frame.state == 'taken':
                    frame.branch_emit = False
                elif frame.state == 'active':
                    out.append(f"{d.indent}#else{d.trailing}")
                    frame.branch_emit = True
                    frame.output_active = True
                continue
            if d.keyword == 'endif':
                frame = stack.pop()
                if frame.output_active:
                    out.append(f"{d.indent}#endif{d.trailing}")
                continue
            continue

        if d is None:
            out.append(raw_line.rstrip('\n\r'))
            continue

        if d.keyword in ('ifdef', 'ifndef', 'if'):
            cond = condition_to_expr(d.keyword, d.condition)
            truth, node = evaluate_condition(cond)
            if truth is True:
                stack.append(Frame('taken', True, False))
            elif truth is False:
                stack.append(Frame('seeking', False, False))
            else:
                rewritten = rewrite_unknown_directive(d, node)
                if rewritten is not None:
                    out.append(rewritten)
                stack.append(Frame('active', True, True))
            continue

        if d.keyword == 'elseif':
            if not stack:
                out.append(raw_line.rstrip('\n\r'))
                continue
            truth, node = evaluate_condition(d.condition) if d.condition else (None, UnknownRaw(''))
            frame = stack[-1]
            if frame.state == 'taken':
                frame.branch_emit = False
            elif frame.state == 'seeking':
                if truth is True:
                    frame.state = 'taken'
                    frame.branch_emit = True
                elif truth is False:
                    frame.branch_emit = False
                else:
                    frame.state = 'active'
                    frame.branch_emit = True
                    frame.output_active = True
                    rewritten = rewrite_unknown_directive(Directive(d.indent, 'if', 'if', d.condition, d.trailing), node)
                    if rewritten is not None:
                        out.append(rewritten)
            elif frame.state == 'active':
                if truth is True:
                    out.append(f"{d.indent}#else{d.trailing}")
                    frame.state = 'taken'
                    frame.branch_emit = True
                    frame.output_active = True
                elif truth is False:
                    frame.branch_emit = False
                else:
                    rewritten = rewrite_unknown_directive(d, node)
                    if rewritten is not None:
                        out.append(rewritten)
                    frame.output_active = True
                    frame.branch_emit = True
            continue

        if d.keyword == 'else':
            if not stack:
                out.append(raw_line.rstrip('\n\r'))
                continue
            frame = stack[-1]
            if frame.state == 'taken':
                frame.branch_emit = False
            elif frame.state == 'seeking':
                frame.state = 'taken'
                frame.branch_emit = True
            elif frame.state == 'active':
                out.append(f"{d.indent}#else{d.trailing}")
                frame.branch_emit = True
                frame.output_active = True
            continue

        if d.keyword == 'endif':
            if not stack:
                out.append(raw_line.rstrip('\n\r'))
                continue
            frame = stack.pop()
            if frame.output_active:
                out.append(f"{d.indent}#endif{d.trailing}")
            continue

        out.append(raw_line.rstrip('\n\r'))

    return out


def has_platform_macro(text):
    return PLATFORM_RE.search(text) is not None


def transform_file(path):
    with open(path, 'rb') as fh:
        original_bytes = fh.read()
    if not original_bytes:
        return False

    has_bom = original_bytes.startswith(b'\xef\xbb\xbf')
    if has_bom:
        data = original_bytes[3:]
    else:
        data = original_bytes

    # Detect line endings
    has_crlf = b'\r\n' in data
    if has_crlf:
        text = data.decode('utf-8', errors='surrogateescape')
        lines = text.split('\r\n')
        # If trailing empty due to final \r\n, remove it to avoid extra empty line
        if lines and lines[-1] == '':
            lines.pop()
    else:
        text = data.decode('utf-8', errors='surrogateescape')
        lines = text.split('\n')
        if lines and lines[-1] == '':
            lines.pop()

    if not has_platform_macro(text):
        return False

    new_lines = process_lines(lines)

    # Re-join with original line endings
    if has_crlf:
        new_text = '\r\n'.join(new_lines)
        if original_bytes.endswith(b'\r\n') or original_bytes.endswith(b'\n'):
            new_text += '\r\n'
    else:
        new_text = '\n'.join(new_lines)
        if original_bytes.endswith(b'\n'):
            new_text += '\n'

    if has_bom:
        new_bytes = b'\xef\xbb\xbf' + new_text.encode('utf-8', errors='surrogateescape')
    else:
        new_bytes = new_text.encode('utf-8', errors='surrogateescape')

    if new_bytes != original_bytes:
        with open(path, 'wb') as fh:
            fh.write(new_bytes)
        return True
    return False


def files_to_process():
    for root in ROOTS:
        for dirpath, dirs, files in os.walk(root):
            # Skip D2D1 which is already deleted
            if 'D2D1' in dirs:
                dirs.remove('D2D1')
            for f in files:
                if f.lower().endswith(('.bas', '.bi', '.frm')):
                    yield Path(dirpath) / f


def main():
    modified = []
    errors = []
    for path in files_to_process():
        try:
            if transform_file(path):
                modified.append(path)
        except Exception as e:
            errors.append((path, e))
    print(f"Modified {len(modified)} files")
    if errors:
        print(f"Errors in {len(errors)} files")
        for p, e in errors:
            print(f"  {p}: {e}")


if __name__ == '__main__':
    main()
