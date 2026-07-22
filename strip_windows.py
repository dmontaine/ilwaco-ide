#!/usr/bin/env python3
"""
Strip __USE_WINAPI__ and __FB_WIN32__ preprocessor branches from FreeBASIC source.

Evaluates conditional expressions assuming a Linux/GTK3 target:
  __USE_GTK__      = True
  __USE_GTK3__     = True
  __USE_GTK4__     = False
  __USE_GTK2__     = False
  __USE_WINAPI__   = False
  __FB_WIN32__     = False
  __FB_LINUX__     = True
  __FB_64BIT__     = True

For any block whose condition involves __USE_WINAPI__ or __FB_WIN32__, keeps the
branch that evaluates to True under these assumptions.
"""

import re
import sys
from pathlib import Path

PLATFORM_RE = re.compile(r'__USE_GTK__|__USE_GTK3__|__USE_GTK4__|__USE_GTK2__|__USE_CAIRO__|__USE_WINAPI__|__FB_WIN32__')

KNOWN_DEFS = {
    '__USE_GTK__': True,
    '__USE_GTK3__': True,
    '__USE_GTK4__': False,
    '__USE_GTK2__': False,
    '__USE_CAIRO__': True,
    '__USE_WINAPI__': False,
    '__FB_WIN32__': False,
    '__FB_LINUX__': True,
    '__FB_64BIT__': True,
}


def is_platform_condition(expr):
    return PLATFORM_RE.search(expr) is not None


class EvalError(Exception):
    pass


_TOKEN_RE = re.compile(r'defined\s*\(\s*(\w+)\s*\)|Not\b|AndAlso\b|OrElse\b|\(|\)')


def tokenize(expr):
    """Very small tokenizer for the subset of FB expressions we care about."""
    tokens = []
    pos = 0
    while pos < len(expr):
        m = _TOKEN_RE.match(expr, pos)
        if m:
            if m.group(1):
                tokens.append(('DEFINED', m.group(1)))
            else:
                tokens.append(('OP', m.group(0).strip()))
            pos = m.end()
        elif expr[pos].isspace():
            pos += 1
        else:
            raise EvalError(f"Unexpected token at {pos!r} in {expr!r}")
    return tokens


def parse_expr(tokens, idx=0):
    """Parse OrElse chain. Returns (value, next_idx)."""
    value, idx = parse_and(tokens, idx)
    while idx < len(tokens) and tokens[idx] == ('OP', 'OrElse'):
        rhs, idx = parse_and(tokens, idx + 1)
        value = value or rhs
    return value, idx


def parse_and(tokens, idx=0):
    value, idx = parse_not(tokens, idx)
    while idx < len(tokens) and tokens[idx] == ('OP', 'AndAlso'):
        rhs, idx = parse_not(tokens, idx + 1)
        value = value and rhs
    return value, idx


def parse_not(tokens, idx=0):
    if idx < len(tokens) and tokens[idx] == ('OP', 'Not'):
        value, idx = parse_not(tokens, idx + 1)
        return not value, idx
    return parse_atom(tokens, idx)


def parse_atom(tokens, idx=0):
    if idx >= len(tokens):
        raise EvalError('Unexpected end of expression')
    tok = tokens[idx]
    if tok[0] == 'DEFINED':
        return KNOWN_DEFS.get(tok[1], False), idx + 1
    if tok == ('OP', '('):
        value, idx = parse_expr(tokens, idx + 1)
        if idx >= len(tokens) or tokens[idx] != ('OP', ')'):
            raise EvalError('Missing closing parenthesis')
        return value, idx + 1
    raise EvalError(f'Unexpected token {tok!r}')


def eval_condition(expr):
    """Evaluate a FB #if expression under Linux/GTK3 assumptions."""
    if not expr:
        return True
    tokens = tokenize(expr)
    value, idx = parse_expr(tokens)
    if idx != len(tokens):
        raise EvalError(f'Unconsumed tokens: {tokens[idx:]!r}')
    return value


class Block:
    def __init__(self, directive, condition, indent):
        self.directive = directive
        self.condition = condition
        self.indent = indent
        self.branches = []
        self.current_body = []
        self._current_branch_cond = condition

    def start_branch(self, condition):
        self.branches.append((self._current_branch_cond, self.current_body))
        self.current_body = []
        self._current_branch_cond = condition

    def finalize(self):
        self.branches.append((self._current_branch_cond, self.current_body))
        self.current_body = None


def parse_condition(line):
    stripped = line.lstrip()
    low = stripped.lower()
    if low.startswith('#elseif'):
        return '#elseif', stripped[7:].strip()
    if low.startswith('#ifdef'):
        return '#ifdef', stripped[6:].strip()
    if low.startswith('#ifndef'):
        return '#ifndef', stripped[7:].strip()
    if low.startswith('#if'):
        return '#if', stripped[3:].strip()
    return None, None


def parse_file(lines):
    root = []
    stack = []
    current_body = root

    for line in lines:
        stripped = line.lstrip()
        indent = line[:len(line) - len(stripped)]
        low = stripped.lower()

        if low.startswith('#endif'):
            if not stack:
                current_body.append(('plain', line))
                continue
            block = stack.pop()
            block.finalize()
            current_body = stack[-1].current_body if stack else root
            current_body.append(('block', block))
        elif low.startswith('#elseif'):
            _, cond = parse_condition(line)
            if not stack:
                current_body.append(('plain', line))
                continue
            stack[-1].start_branch(cond)
            current_body = stack[-1].current_body
        elif low.startswith('#else'):
            if not stack:
                current_body.append(('plain', line))
                continue
            stack[-1].start_branch('else')
            current_body = stack[-1].current_body
        else:
            directive, cond = parse_condition(line)
            if directive:
                block = Block(directive, cond, indent)
                stack.append(block)
                current_body = block.current_body
            else:
                current_body.append(('plain', line))

    while stack:
        block = stack.pop()
        block.finalize()
        current_body = stack[-1].current_body if stack else root
        current_body.append(('block', block))

    return root


def condition_to_expr(directive, cond):
    if directive == '#ifdef':
        return f'defined({cond})'
    if directive == '#ifndef':
        return f'Not defined({cond})'
    return cond


def evaluate_platform_block(block):
    """
    If block is platform-related, return the body nodes to keep.
    Otherwise return None.
    """
    # Preserve GTK-definition/guard blocks; the compiler will resolve them.
    if block.directive == '#ifdef' and block.condition in ('__USE_GTK__', '__USE_GTK3__', '__USE_GTK4__', '__USE_GTK2__', '__USE_CAIRO__'):
        return None

    # Preserve #ifndef __USE_GTK__ definition blocks (they define the macro).
    if block.directive == '#ifndef' and block.condition == '__USE_GTK__' and len(block.branches) == 1:
        return None

    if not is_platform_condition(block.condition):
        # Also check branch conditions for cases like #if ... #elseif __USE_WINAPI__
        branch_conds = [c for c, _ in block.branches if c != 'else']
        if not any(is_platform_condition(c) for c in branch_conds):
            return None

    # Try to find a branch that evaluates to True.
    for branch_cond, body in block.branches:
        if branch_cond == 'else':
            continue
        expr = condition_to_expr(block.directive if branch_cond == block.condition else '#if', branch_cond)
        try:
            if eval_condition(expr):
                return body
        except EvalError:
            # Fall back to keeping the block with simplified condition
            return None

    # No true branch; keep else if present.
    for branch_cond, body in block.branches:
        if branch_cond == 'else':
            return body

    return []


def simplify_condition(cond):
    """Remove False terms from simple AndAlso chains if possible."""
    try:
        tokens = tokenize(cond)
        value, _ = parse_expr(tokens)
        if value is True:
            return '1'
        if value is False:
            return '0'
    except EvalError:
        pass
    return cond


def process_nodes(nodes):
    out = []
    for node in nodes:
        kind, value = node
        if kind == 'plain':
            out.append(value)
        elif kind == 'block':
            block = value
            kept = evaluate_platform_block(block)
            if kept is not None:
                out.extend(process_nodes(kept))
            else:
                new_cond = simplify_condition(block.condition)
                out.append(f"{block.indent}{block.directive} {new_cond}\n")
                first = True
                for branch_cond, body in block.branches:
                    if not first:
                        if branch_cond == 'else':
                            out.append(f"{block.indent}#else\n")
                        elif branch_cond is not None:
                            simplified = simplify_condition(branch_cond)
                            out.append(f"{block.indent}#elseif {simplified}\n")
                    first = False
                    out.extend(process_nodes(body))
                out.append(f"{block.indent}#endif\n")
    return out


def strip_file(path):
    text = path.read_text(encoding='utf-8', errors='surrogateescape')
    lines = text.splitlines(keepends=True)
    if not lines:
        return False

    if not any(PLATFORM_RE.search(line) for line in lines):
        return False

    nodes = parse_file(lines)
    out_lines = process_nodes(nodes)

    while out_lines and out_lines[-1].strip() == '':
        out_lines.pop()
    if out_lines and not out_lines[-1].endswith('\n'):
        out_lines[-1] += '\n'

    new_text = ''.join(out_lines)
    if new_text != text:
        path.write_text(new_text, encoding='utf-8', errors='surrogateescape')
        return True
    return False


def main():
    root = Path('/home/don/Projects/ilwaco-ide')
    files = []
    for pat in ['*.bas', '*.bi', '*.frm']:
        files.extend(root.rglob(pat))

    modified = []
    for f in files:
        try:
            if strip_file(f):
                modified.append(f)
        except Exception as e:
            print(f"Error processing {f}: {e}", file=sys.stderr)

    print(f"Modified {len(modified)} files")
    for f in modified:
        print(f"  {f.relative_to(root)}")


if __name__ == '__main__':
    main()
