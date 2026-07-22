#!/usr/bin/env python3
"""
Strip __USE_GTK4__ and __USE_GTK2__ preprocessor branches from FreeBASIC source.

Builds a tree of conditional blocks, then collapses any block whose condition
involves __USE_GTK4__ or __USE_GTK2__ by keeping only the GTK3 branch.
"""

import re
import sys
from pathlib import Path

GTK_RE = re.compile(r'__USE_GTK4__|__USE_GTK2__')


def is_gtk_condition(expr):
    return GTK_RE.search(expr) is not None


class Block:
    def __init__(self, directive, condition, indent):
        self.directive = directive
        self.condition = condition
        self.indent = indent
        self.branches = []  # list of (branch_condition, body_nodes)
        self.current_body = []
        self._current_branch_cond = condition

    def start_branch(self, condition):
        """Finish current branch and start a new one (#else or #elseif)."""
        self.branches.append((self._current_branch_cond, self.current_body))
        self.current_body = []
        self._current_branch_cond = condition

    def finalize(self):
        """Call at #endif."""
        self.branches.append((self._current_branch_cond, self.current_body))
        self.current_body = None


def parse_condition(line):
    stripped = line.lstrip()
    if stripped.startswith('#elseif'):
        return '#elseif', stripped[7:].strip()
    if stripped.startswith('#ifdef'):
        return '#ifdef', stripped[6:].strip()
    if stripped.startswith('#ifndef'):
        return '#ifndef', stripped[7:].strip()
    if stripped.startswith('#if'):
        return '#if', stripped[3:].strip()
    return None, None


def parse_file(lines):
    root = []
    stack = []
    current_body = root

    for line in lines:
        stripped = line.lstrip()
        indent = line[:len(line) - len(stripped)]

        if stripped.startswith('#endif'):
            if not stack:
                current_body.append(('plain', line))
                continue
            block = stack.pop()
            block.finalize()
            current_body = stack[-1].current_body if stack else root
            current_body.append(('block', block))
        elif stripped.startswith('#elseif'):
            _, cond = parse_condition(line)
            if not stack:
                current_body.append(('plain', line))
                continue
            stack[-1].start_branch(cond)
            current_body = stack[-1].current_body
        elif stripped.startswith('#else'):
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

    # Unclosed blocks - unlikely but handle gracefully
    while stack:
        block = stack.pop()
        block.finalize()
        current_body = stack[-1].current_body if stack else root
        current_body.append(('block', block))

    return root


def evaluate_gtk_block(block):
    """
    If block is GTK4/GTK2 related, return the body nodes to keep.
    Otherwise return None.
    """
    if not is_gtk_condition(block.condition):
        return None

    directive = block.directive
    cond = block.condition.strip()

    if directive == '#ifdef':
        if cond in ('__USE_GTK4__', '__USE_GTK2__'):
            # Keep else branch if present, else nothing
            for branch_cond, body in block.branches:
                if branch_cond == 'else':
                    return body
            return []
    elif directive == '#ifndef':
        if cond in ('__USE_GTK4__', '__USE_GTK2__'):
            # Keep first (then) branch
            if block.branches:
                return block.branches[0][1]
            return []
    elif directive == '#if':
        # Not defined(__USE_GTK4__) -> keep first branch
        m = re.match(r'Not\s+defined\s*\(\s*(__USE_GTK4__|__USE_GTK2__)\s*\)', cond)
        if m:
            if block.branches:
                return block.branches[0][1]
            return []
        # defined(__USE_GTK4__) -> keep else branch
        m = re.match(r'defined\s*\(\s*(__USE_GTK4__|__USE_GTK2__)\s*\)', cond)
        if m:
            for branch_cond, body in block.branches:
                if branch_cond == 'else':
                    return body
            return []
        # defined(X) AndAlso Not defined(__USE_GTK4__) -> simplify condition and keep block
        m = re.match(
            r'defined\s*\(\s*(\w+)\s*\)\s+AndAlso\s+Not\s+defined\s*\(\s*(__USE_GTK4__|__USE_GTK2__)\s*\)',
            cond
        )
        if m:
            other = m.group(1)
            block.condition = f'defined({other})'
            return None  # keep block with simplified condition

    return None


def process_nodes(nodes):
    """Return list of output lines for the given nodes."""
    out = []
    for node in nodes:
        kind, value = node
        if kind == 'plain':
            out.append(value)
        elif kind == 'block':
            block = value
            kept = evaluate_gtk_block(block)
            if kept is not None:
                out.extend(process_nodes(kept))
            else:
                out.append(f"{block.indent}{block.directive} {block.condition}\n")
                first = True
                for branch_cond, body in block.branches:
                    if not first:
                        if branch_cond == 'else':
                            out.append(f"{block.indent}#else\n")
                        elif branch_cond is not None:
                            out.append(f"{block.indent}#elseif {branch_cond}\n")
                    first = False
                    out.extend(process_nodes(body))
                out.append(f"{block.indent}#endif\n")
    return out


def strip_file(path):
    text = path.read_text(encoding='utf-8', errors='surrogateescape')
    lines = text.splitlines(keepends=True)
    if not lines:
        return False

    if not any(GTK_RE.search(line) for line in lines):
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
