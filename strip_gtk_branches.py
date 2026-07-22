#!/usr/bin/env python3
"""Strip __USE_GTK4__ and __USE_GTK2__ preprocessor branches from MyFbFramework sources.

Under the GTK3-only build:
    __USE_GTK4__ is undefined (0)
    __USE_GTK2__ is undefined (0)
    __USE_GTK3__ and __USE_GTK__ are left untouched.

The script preserves GTK3 behavior by keeping the branch that would execute when
__USE_GTK3__ is defined and the other two are not, and removes/simplifies the
conditional wrappers related to GTK4/GTK2.
"""

import os
import re
import sys
from dataclasses import dataclass
from typing import Optional, List, Tuple

ROOT = "/home/don/Projects/ilwaco-ide/Controls/MyFbFramework"
TARGET_MACROS = {"__USE_GTK4__", "__USE_GTK2__"}


# ---------------------------------------------------------------------------
# Expression AST and simplification
# ---------------------------------------------------------------------------

class Node:
    pass


class Const(Node):
    def __init__(self, value: int):
        self.value = value


class Defined(Node):
    def __init__(self, name: str):
        self.name = name


class Ident(Node):
    def __init__(self, name: str):
        self.name = name


class Number(Node):
    def __init__(self, value: str):
        self.value = value


class Not(Node):
    def __init__(self, expr: Node):
        self.expr = expr


class Binary(Node):
    def __init__(self, op: str, left: Node, right: Node):
        self.op = op
        self.left = left
        self.right = right


class UnknownRaw(Node):
    """Fallback for unparsable expressions."""
    def __init__(self, text: str):
        self.text = text


INT_OPERATORS = {"And", "Or", "Xor", "Eqv", "Imp"}
BOOL_OPERATORS = {"AndAlso", "OrElse"}
CMP_OPERATORS = {"=", "<>", "<=", ">=", "<", ">"}
ALL_OPERATORS = ["OrElse", "AndAlso", "Imp", "Eqv", "Xor", "Or", "And"]


def tokenize(expr: str) -> List[Tuple[str, str]]:
    """Return list of (type, value) tokens for a preprocessor expression."""
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
            tokens.append(("STRING", expr[i:j]))
            i = j
            continue
        if c.isdigit():
            j = i
            while j < n and (expr[j].isdigit() or expr[j] in ".&HhABCFabcf"):
                # keep it simple: digits and hex prefix
                if expr[j] in "'\"":
                    break
                j += 1
            tokens.append(("NUMBER", expr[i:j]))
            i = j
            continue
        if c.isalpha() or c == "_":
            j = i
            while j < n and (expr[j].isalnum() or expr[j] == "_"):
                j += 1
            word = expr[i:j]
            tokens.append(("IDENT", word))
            i = j
            continue
        # multi-char operators
        two = expr[i:i+2]
        if two in ("<=", ">=", "<>"):
            tokens.append(("OP", two))
            i += 2
            continue
        if c in "()=<>+-*/\\^":
            tokens.append(("OP", c))
            i += 1
            continue
        # unknown char, treat as OP
        tokens.append(("OP", c))
        i += 1
    return tokens


class Parser:
    def __init__(self, tokens: List[Tuple[str, str]]):
        self.tokens = tokens
        self.pos = 0

    def peek(self, offset: int = 0) -> Optional[Tuple[str, str]]:
        idx = self.pos + offset
        if idx < len(self.tokens):
            return self.tokens[idx]
        return None

    def consume(self) -> Optional[Tuple[str, str]]:
        tok = self.peek()
        if tok is not None:
            self.pos += 1
        return tok

    def expect_ident(self) -> str:
        tok = self.consume()
        if tok is None or tok[0] != "IDENT":
            raise SyntaxError("expected identifier")
        return tok[1]

    def parse(self) -> Node:
        node = self.parse_or_else()
        if self.peek() is not None:
            raise SyntaxError("unexpected tokens after expression")
        return node

    def parse_or_else(self) -> Node:
        node = self.parse_and_then()
        while self.peek() and self.peek()[1] == "OrElse":
            self.consume()
            right = self.parse_and_then()
            node = Binary("OrElse", node, right)
        return node

    def parse_and_then(self) -> Node:
        node = self.parse_imp()
        while self.peek() and self.peek()[1] == "AndAlso":
            self.consume()
            right = self.parse_imp()
            node = Binary("AndAlso", node, right)
        return node

    def parse_imp(self) -> Node:
        node = self.parse_eqv()
        while self.peek() and self.peek()[1] == "Imp":
            self.consume()
            right = self.parse_eqv()
            node = Binary("Imp", node, right)
        return node

    def parse_eqv(self) -> Node:
        node = self.parse_xor()
        while self.peek() and self.peek()[1] == "Eqv":
            self.consume()
            right = self.parse_xor()
            node = Binary("Eqv", node, right)
        return node

    def parse_xor(self) -> Node:
        node = self.parse_or()
        while self.peek() and self.peek()[1] == "Xor":
            self.consume()
            right = self.parse_or()
            node = Binary("Xor", node, right)
        return node

    def parse_or(self) -> Node:
        node = self.parse_and_bit()
        while self.peek() and self.peek()[1] == "Or":
            self.consume()
            right = self.parse_and_bit()
            node = Binary("Or", node, right)
        return node

    def parse_and_bit(self) -> Node:
        node = self.parse_not()
        while self.peek() and self.peek()[1] == "And":
            self.consume()
            right = self.parse_not()
            node = Binary("And", node, right)
        return node

    def parse_not(self) -> Node:
        if self.peek() and self.peek()[1] == "Not":
            self.consume()
            return Not(self.parse_not())
        return self.parse_comparison()

    def parse_comparison(self) -> Node:
        node = self.parse_add()
        while self.peek() and self.peek()[1] in CMP_OPERATORS:
            op = self.consume()[1]
            right = self.parse_add()
            node = Binary(op, node, right)
        return node

    def parse_add(self) -> Node:
        node = self.parse_mul()
        while self.peek() and self.peek()[1] in ("+", "-"):
            op = self.consume()[1]
            right = self.parse_mul()
            node = Binary(op, node, right)
        return node

    def parse_mul(self) -> Node:
        node = self.parse_unary()
        while self.peek() and self.peek()[1] in ("*", "/", "\\", "Mod"):
            op = self.consume()[1]
            right = self.parse_unary()
            node = Binary(op, node, right)
        return node

    def parse_unary(self) -> Node:
        if self.peek() and self.peek()[1] in ("+", "-"):
            op = self.consume()[1]
            return Binary(op, Number("0"), self.parse_unary())
        return self.parse_primary()

    def parse_primary(self) -> Node:
        tok = self.peek()
        if tok is None:
            raise SyntaxError("unexpected end of expression")
        if tok[1] == "(":
            self.consume()
            node = self.parse_or_else()
            if not self.peek() or self.peek()[1] != ")":
                raise SyntaxError("expected )")
            self.consume()
            return node
        if tok[0] == "IDENT" and tok[1] == "defined":
            self.consume()
            if not self.peek() or self.peek()[1] != "(":
                raise SyntaxError("expected ( after defined")
            self.consume()
            name = self.expect_ident()
            if not self.peek() or self.peek()[1] != ")":
                raise SyntaxError("expected ) after defined name")
            self.consume()
            return Defined(name)
        if tok[0] == "IDENT":
            self.consume()
            return Ident(tok[1])
        if tok[0] == "NUMBER":
            self.consume()
            return Number(tok[1])
        if tok[0] == "STRING":
            self.consume()
            return Ident(tok[1])  # preserve literal as raw atom
        raise SyntaxError(f"unexpected token {tok}")


def parse_expr(expr: str) -> Node:
    tokens = tokenize(expr)
    if not tokens:
        raise SyntaxError("empty expression")
    return Parser(tokens).parse()


def is_const(node: Node) -> Optional[int]:
    if isinstance(node, Const):
        return node.value
    return None


def simplify(node: Node) -> Node:
    if isinstance(node, Const):
        return node
    if isinstance(node, Defined):
        if node.name in TARGET_MACROS:
            return Const(0)
        return node
    if isinstance(node, (Ident, Number, UnknownRaw)):
        return node
    if isinstance(node, Not):
        e = simplify(node.expr)
        c = is_const(e)
        if c is not None:
            return Const(0 if c != 0 else -1)
        if isinstance(e, Not):
            return e.expr
        return Not(e)
    if isinstance(node, Binary):
        left = simplify(node.left)
        right = simplify(node.right)
        op = node.op
        l = is_const(left)
        r = is_const(right)

        # both constant -> fold
        if l is not None and r is not None:
            if op == "AndAlso":
                return Const(-1 if (l != 0 and r != 0) else 0)
            if op == "OrElse":
                return Const(-1 if (l != 0 or r != 0) else 0)
            if op == "And":
                return Const(l & r)
            if op == "Or":
                return Const(l | r)
            if op == "Xor":
                return Const(l ^ r)
            if op == "Eqv":
                return Const(-1 if l == r else 0)
            if op == "Imp":
                return Const(-1 if (l == 0 or r != 0) else 0)
            # arithmetic/comparison
            if op == "=":
                return Const(-1 if l == r else 0)
            if op == "<>":
                return Const(-1 if l != r else 0)
            if op == "<=":
                return Const(-1 if l <= r else 0)
            if op == ">=":
                return Const(-1 if l >= r else 0)
            if op == "<":
                return Const(-1 if l < r else 0)
            if op == ">":
                return Const(-1 if l > r else 0)
            return Binary(op, left, right)

        if op in ("AndAlso", "And"):
            if (l == 0) or (r == 0):
                return Const(0)
            if l is not None and l != 0:
                return right
            if r is not None and r != 0:
                return left
            return Binary(op, left, right)
        if op in ("OrElse", "Or"):
            if (l is not None and l != 0) or (r is not None and r != 0):
                # For OrElse/Or, any nonzero makes whole expression true.
                # (Constants are always 0 or -1 here.)
                return Const(-1)
            if l == 0:
                return right
            if r == 0:
                return left
            return Binary(op, left, right)
        if op == "Xor":
            if l == 0:
                return right
            if r == 0:
                return left
            if l is not None and l == -1:
                return Not(right)
            if r is not None and r == -1:
                return Not(left)
            return Binary(op, left, right)
        if op == "Eqv":
            if l == 0:
                return Not(right)
            if r == 0:
                return Not(left)
            return Binary(op, left, right)
        if op == "Imp":
            if l == 0:
                return Const(-1)
            if l is not None and l != 0:
                return right
            if r is not None and r != 0:
                return Binary("OrElse", Const(-1), left)  # not simplifiable, keep
            return Binary(op, left, right)
        # For comparisons / arithmetic we don't simplify across unknowns.
        return Binary(op, left, right)
    return node


def truth_value(node: Node) -> Optional[bool]:
    c = is_const(node)
    if c is None:
        return None
    return c != 0


def node_to_str(node: Node) -> str:
    if isinstance(node, Const):
        return str(node.value)
    if isinstance(node, Defined):
        return f"defined({node.name})"
    if isinstance(node, Ident):
        return node.name
    if isinstance(node, Number):
        return node.value
    if isinstance(node, UnknownRaw):
        return node.text
    if isinstance(node, Not):
        return f"Not ({node_to_str(node.expr)})"
    if isinstance(node, Binary):
        return f"({node_to_str(node.left)} {node.op} {node_to_str(node.right)})"
    return ""


# ---------------------------------------------------------------------------
# Directive line handling
# ---------------------------------------------------------------------------

DIRECTIVE_RE = re.compile(r"^(\s*)#\s*(\w+)(.*)$")


def split_trailing_comment(text: str) -> Tuple[str, str]:
    """Split off a FreeBASIC trailing comment starting with '."""
    in_str = False
    for i, ch in enumerate(text):
        if ch == '"':
            in_str = not in_str
        elif ch == "'" and not in_str:
            return text[:i], text[i:]
    return text, ""


@dataclass
class Directive:
    indent: str
    keyword: str          # lowercased: ifdef, ifndef, if, elseif, else, endif
    raw_keyword: str      # original casing after #
    condition: str        # raw condition text (for if/elseif/ifdef/indef)
    trailing: str         # trailing comment


def parse_directive(line: str) -> Optional[Directive]:
    m = DIRECTIVE_RE.match(line)
    if not m:
        return None
    indent, raw_kw, rest = m.group(1), m.group(2), m.group(3)
    kw = raw_kw.lower()
    if kw not in {"ifdef", "ifndef", "if", "elseif", "else", "endif"}:
        return None
    cond = ""
    trailing = ""
    if kw in {"ifdef", "ifndef"}:
        # condition is the first identifier, rest may be comment
        rest_body, trailing = split_trailing_comment(rest)
        parts = rest_body.strip().split(None, 1)
        if parts:
            cond = parts[0]
    elif kw in {"if", "elseif"}:
        cond, trailing = split_trailing_comment(rest)
        cond = cond.strip()
    else:
        _, trailing = split_trailing_comment(rest)
    return Directive(indent, kw, raw_kw, cond, trailing)


def evaluate_condition(cond: str) -> Tuple[Optional[bool], Node]:
    """Parse and simplify a condition. Returns (truth, simplified_node)."""
    try:
        node = parse_expr(cond)
        node = simplify(node)
        return truth_value(node), node
    except Exception:
        return None, UnknownRaw(cond)


def rewrite_ifdef(d: Directive, node: Node) -> Optional[str]:
    """Return rewritten line for an #if/#ifdef/#ifndef/#elseif that stays in source.
    Returns None if the directive should be dropped/converted to #else."""
    if isinstance(node, UnknownRaw):
        # keep original condition text unchanged
        return f"{d.indent}#{d.raw_keyword} {d.condition}{d.trailing}"

    # If simplified to a single defined(name), prefer #ifdef / #ifndef when original used them.
    if isinstance(node, Defined):
        if d.keyword in ("ifdef", "if", "elseif"):
            if d.keyword == "elseif":
                return f"{d.indent}#elseif defined({node.name}){d.trailing}"
            return f"{d.indent}#ifdef {node.name}{d.trailing}"
        if d.keyword == "ifndef":
            return f"{d.indent}#ifndef {node.name}{d.trailing}"

    if isinstance(node, Not) and isinstance(node.expr, Defined):
        if d.keyword in ("ifndef", "if", "elseif"):
            if d.keyword == "elseif":
                return f"{d.indent}#elseif Not defined({node.expr.name}){d.trailing}"
            return f"{d.indent}#ifndef {node.expr.name}{d.trailing}"

    expr = node_to_str(node)
    if d.keyword == "elseif":
        return f"{d.indent}#elseif {expr}{d.trailing}"
    return f"{d.indent}#{d.raw_keyword} {expr}{d.trailing}"


# ---------------------------------------------------------------------------
# State-machine transformation
# ---------------------------------------------------------------------------

@dataclass
class Frame:
    state: str          # 'active', 'taken', 'seeking'
    branch_emit: bool   # whether current branch body is emitted
    output_active: bool # whether any conditional wrapper for this block has been emitted


def process_lines(lines: List[str]) -> List[str]:
    out: List[str] = []
    stack: List[Frame] = []
    skip_depth = 0  # nested blocks inside a skipped current branch

    for raw_line in lines:
        line = raw_line.rstrip("\n\r")
        d = parse_directive(line)

        if skip_depth > 0:
            if d is not None and d.keyword in ("ifdef", "ifndef", "if"):
                skip_depth += 1
            elif d is not None and d.keyword == "endif":
                skip_depth -= 1
            # never emit while inside a nested skipped block
            continue

        # Are we currently in a branch whose body is being skipped?
        if stack and not stack[-1].branch_emit:
            if d is None:
                continue
            if d.keyword in ("ifdef", "ifndef", "if"):
                # nested block inside skipped branch - ignore it
                skip_depth = 1
                continue
            if d.keyword == "elseif":
                truth, node = evaluate_condition(d.condition) if d.condition else (None, UnknownRaw(""))
                frame = stack[-1]
                if frame.state == "seeking":
                    if truth is True:
                        frame.state = "taken"
                        frame.branch_emit = True
                        # do not output #elseif
                    elif truth is False:
                        frame.branch_emit = False
                    else:  # unknown
                        frame.state = "active"
                        frame.branch_emit = True
                        frame.output_active = True
                        rewritten = rewrite_ifdef(Directive(d.indent, "if", "if", d.condition, d.trailing), node)
                        if rewritten is not None:
                            out.append(rewritten)
                elif frame.state == "taken":
                    frame.branch_emit = False
                elif frame.state == "active":
                    if truth is True:
                        out.append(f"{d.indent}#else{d.trailing}")
                        frame.state = "taken"
                        frame.branch_emit = True
                        frame.output_active = True
                    elif truth is False:
                        frame.branch_emit = False
                    else:
                        rewritten = rewrite_ifdef(d, node)
                        if rewritten is not None:
                            out.append(rewritten)
                            frame.output_active = True
                        frame.branch_emit = True
                continue
            if d.keyword == "else":
                frame = stack[-1]
                if frame.state == "seeking":
                    frame.state = "taken"
                    frame.branch_emit = True
                    # do not output #else
                elif frame.state == "taken":
                    frame.branch_emit = False
                elif frame.state == "active":
                    out.append(f"{d.indent}#else{d.trailing}")
                    frame.branch_emit = True
                    frame.output_active = True
                continue
            if d.keyword == "endif":
                frame = stack.pop()
                if frame.output_active:
                    out.append(f"{d.indent}#endif{d.trailing}")
                continue
            # other directives inside skipped branch should not happen here
            continue

        # Body is being emitted (or top level)
        if d is None:
            out.append(raw_line.rstrip("\n\r"))
            continue

        if d.keyword in ("ifdef", "ifndef", "if"):
            if d.keyword == "ifdef":
                eval_cond = f"defined({d.condition})" if d.condition else ""
            elif d.keyword == "ifndef":
                eval_cond = f"Not defined({d.condition})" if d.condition else ""
            else:
                eval_cond = d.condition
            truth, node = evaluate_condition(eval_cond)
            if truth is True:
                stack.append(Frame("taken", True, False))
                # do not output the #if directive
            elif truth is False:
                stack.append(Frame("seeking", False, False))
                # do not output the #if directive
            else:
                # unknown -> keep the directive, possibly rewritten
                rewritten = rewrite_ifdef(d, node)
                if rewritten is not None:
                    out.append(rewritten)
                stack.append(Frame("active", True, True))
            continue

        if d.keyword == "elseif":
            if not stack:
                out.append(raw_line.rstrip("\n\r"))
                continue
            truth, node = evaluate_condition(d.condition) if d.condition else (None, UnknownRaw(""))
            frame = stack[-1]
            if frame.state == "taken":
                frame.branch_emit = False
            elif frame.state == "seeking":
                if truth is True:
                    frame.state = "taken"
                    frame.branch_emit = True
                elif truth is False:
                    frame.branch_emit = False
                else:
                    frame.state = "active"
                    frame.branch_emit = True
                    frame.output_active = True
                    rewritten = rewrite_ifdef(Directive(d.indent, "if", "if", d.condition, d.trailing), node)
                    if rewritten is not None:
                        out.append(rewritten)
            elif frame.state == "active":
                if truth is True:
                    out.append(f"{d.indent}#else{d.trailing}")
                    frame.state = "taken"
                    frame.branch_emit = True
                    frame.output_active = True
                elif truth is False:
                    frame.branch_emit = False
                else:
                    rewritten = rewrite_ifdef(d, node)
                    if rewritten is not None:
                        out.append(rewritten)
                        frame.output_active = True
                    frame.branch_emit = True
            continue

        if d.keyword == "else":
            if not stack:
                out.append(raw_line.rstrip("\n\r"))
                continue
            frame = stack[-1]
            if frame.state == "taken":
                frame.branch_emit = False
            elif frame.state == "seeking":
                frame.state = "taken"
                frame.branch_emit = True
                # no #else output
            elif frame.state == "active":
                out.append(f"{d.indent}#else{d.trailing}")
                frame.branch_emit = True
                frame.output_active = True
            continue

        if d.keyword == "endif":
            if not stack:
                out.append(raw_line.rstrip("\n\r"))
                continue
            frame = stack.pop()
            if frame.output_active:
                out.append(f"{d.indent}#endif{d.trailing}")
            continue

        # non-conditional directive inside emitted body
        out.append(raw_line.rstrip("\n\r"))

    return out


# ---------------------------------------------------------------------------
# File discovery and processing
# ---------------------------------------------------------------------------

def files_to_process(root: str) -> List[str]:
    result = []
    for dirpath, _dirs, files in os.walk(root):
        for f in files:
            if f.lower().endswith((".bas", ".bi", ".frm")):
                path = os.path.join(dirpath, f)
                try:
                    with open(path, "r", encoding="utf-8", errors="surrogateescape") as fh:
                        text = fh.read()
                except Exception:
                    continue
                if "__USE_GTK4__" in text or "__USE_GTK2__" in text:
                    result.append(path)
    return sorted(result)


def transform_file(path: str) -> bool:
    with open(path, "r", encoding="utf-8", errors="surrogateescape") as fh:
        original = fh.read()
    lines = original.splitlines()
    new_lines = process_lines(lines)
    new_text = "\n".join(new_lines)
    # preserve trailing newline if original had one
    if original.endswith("\n"):
        new_text += "\n"
    if new_text == original:
        return False
    with open(path, "w", encoding="utf-8", errors="surrogateescape") as fh:
        fh.write(new_text)
    return True


def main():
    paths = files_to_process(ROOT)
    modified = []
    for path in paths:
        if transform_file(path):
            modified.append(path)
    print(f"Processed {len(paths)} files, modified {len(modified)}:")
    for p in modified:
        print(p)


if __name__ == "__main__":
    main()
