#!/usr/bin/env python3
"""Merge `brew bundle dump` output into split Brewfiles.

Writes only:
  - Brewfile.taps   (from `brew bundle dump --tap`)
  - Brewfile.essential (brew formulae only; order preserved; comments from dump)
  - Brewfile.dev     (brew + vscode; split at the first line '# VS Code Extensions')

Does not modify:
  - brew/Brewfile (main / legacy)
  - brew/casks.zsh (casks + mas:<id> catalog — maintain by hand or a separate workflow)

Prerequisite (run from any directory):

  brew bundle dump --describe --force --formula --no-vscode --file /tmp/hb-formulae.txt
  brew bundle dump --describe --force --vscode --file /tmp/hb-vscode.txt
  brew bundle dump --describe --force --tap --file /tmp/hb-taps.txt
  python3 brew/_sync_brewfiles_from_dump.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent
DUMP_FORMULAE = Path("/tmp/hb-formulae.txt")
DUMP_VSCODE = Path("/tmp/hb-vscode.txt")
DUMP_TAPS = Path("/tmp/hb-taps.txt")


def parse_formula_blocks(text: str) -> dict[str, str]:
    blocks: dict[str, str] = {}
    comments: list[str] = []
    for raw in text.splitlines():
        line = raw.rstrip()
        if line.startswith("#"):
            comments.append(line)
            continue
        m = re.match(r'^brew\s+"([^"]+)"\s*$', line)
        if m:
            key = m.group(1)
            blocks[key] = "\n".join(comments + [line]) if comments else line
            comments = []
        else:
            comments = []
    return blocks


def parse_old_brew_blocks(path: Path) -> tuple[list[str], dict[str, str]]:
    """Return ordered brew tokens and token -> original block to preserve if missing from dump."""
    order: list[str] = []
    old: dict[str, str] = {}
    lines = path.read_text().splitlines()
    i = 0
    while i < len(lines):
        line = lines[i].rstrip()
        if not line.strip():
            i += 1
            continue
        if line.strip().startswith("#"):
            chunk = [line]
            i += 1
            while i < len(lines):
                nxt = lines[i].rstrip()
                if re.match(r'^brew\s+"', nxt):
                    break
                if nxt.strip():
                    chunk.append(nxt)
                i += 1
            if i < len(lines):
                brew_ln = lines[i].rstrip()
                m = re.match(r'^brew\s+"([^"]+)"', brew_ln)
                if m:
                    tok = m.group(1)
                    chunk.append(brew_ln)
                    order.append(tok)
                    old[tok] = "\n".join(chunk)
                i += 1
            continue
        m = re.match(r'^brew\s+"([^"]+)"', line)
        if m:
            tok = m.group(1)
            order.append(tok)
            old[tok] = line
            i += 1
            continue
        i += 1
    return order, old


def parse_vscode_order_and_old(path: Path) -> tuple[list[str], dict[str, str]]:
    order: list[str] = []
    old: dict[str, str] = {}
    for raw in path.read_text().splitlines():
        line = raw.strip()
        m = re.match(r'^vscode\s+"([^"]+)"', line)
        if m:
            vid = m.group(1)
            order.append(vid)
            old[vid] = line
    return order, old


def parse_vscode_dump(p: Path) -> dict[str, str]:
    d: dict[str, str] = {}
    for line in p.read_text().splitlines():
        line = line.strip()
        m = re.match(r'^vscode\s+"([^"]+)"\s*$', line)
        if m:
            d[m.group(1)] = line
    return d


def main() -> int:
    for p, label in (
        (DUMP_FORMULAE, "formula dump"),
        (DUMP_VSCODE, "vscode dump"),
        (DUMP_TAPS, "tap dump"),
    ):
        if not p.is_file():
            print(f"Missing {label}: {p} (run brew bundle dump first)", file=sys.stderr)
            return 1

    fb = parse_formula_blocks(DUMP_FORMULAE.read_text())
    vd = parse_vscode_dump(DUMP_VSCODE)
    taps_body = DUMP_TAPS.read_text().strip() + "\n"
    (REPO / "Brewfile.taps").write_text(taps_body)
    print("Wrote Brewfile.taps")

    ess = REPO / "Brewfile.essential"
    hdr_e = "# Brews (System Utilities) — casks are chosen interactively via brew/casks.zsh\n"
    order_e, old_e = parse_old_brew_blocks(ess)
    parts_e = [hdr_e.rstrip("\n")]
    for tok in order_e:
        if tok in fb:
            parts_e.append(fb[tok])
        else:
            parts_e.append(old_e.get(tok, f'brew "{tok}"'))
        parts_e.append("")
    ess.write_text("\n".join(parts_e).rstrip() + "\n")
    print("Wrote Brewfile.essential")

    dev = REPO / "Brewfile.dev"
    raw = dev.read_text()
    if "# VS Code Extensions" not in raw:
        print("Brewfile.dev: missing '# VS Code Extensions' marker", file=sys.stderr)
        return 1
    brew_text, vscode_text = raw.split("# VS Code Extensions", 1)
    vscode_text = "# VS Code Extensions" + vscode_text

    tmp_brew = Path("/tmp/_brewfile_dev_brew_only.txt")
    tmp_brew.write_text(brew_text)
    order_d, old_d = parse_old_brew_blocks(tmp_brew)

    brew_lines = [ln for ln in brew_text.splitlines() if ln.strip()]
    hdr_d = brew_lines[0] if brew_lines else "# Brews + VS Code extensions — casks are chosen via brew/casks.zsh"

    parts_d = [hdr_d.rstrip()]
    for tok in order_d:
        if tok in fb:
            parts_d.append(fb[tok])
        else:
            parts_d.append(old_d.get(tok, f'brew "{tok}"'))
        parts_d.append("")

    tmp_vscode = Path("/tmp/_brewfile_dev_vscode.txt")
    tmp_vscode.write_text(vscode_text)
    v_order, v_old = parse_vscode_order_and_old(tmp_vscode)

    parts_v = ["# VS Code Extensions", ""]
    for vid in v_order:
        if vid in vd:
            parts_v.append(vd[vid])
        else:
            parts_v.append(v_old.get(vid, f'vscode "{vid}"'))
    parts_v.append("")

    out = "\n".join(parts_d).rstrip() + "\n\n" + "\n".join(parts_v).rstrip() + "\n"
    dev.write_text(out)
    print("Wrote Brewfile.dev")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
