from pathlib import Path
import re
import sys
from urllib.parse import unquote


def check_document(path: Path, root: Path) -> list[str]:
    text = path.read_text()
    errors = []
    relative_path = path.relative_to(root)
    if not text.endswith("\n") or text.endswith("\n\n"):
        errors.append(f"{relative_path}: end with a single newline")
    in_code_block = False
    previous_level = 0
    title_count = 0
    for line_number, line in enumerate(text.splitlines(), start=1):
        if line != line.rstrip():
            errors.append(f"{relative_path}:{line_number}: trailing whitespace")
        if line.startswith("```"):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue
        heading = re.match(r"^(#{1,6}) (.+)$", line)
        if heading:
            level = len(heading[1])
            title_count += level == 1
            if level > previous_level + 1:
                errors.append(f"{relative_path}:{line_number}: skipped heading level")
            previous_level = level
        for link in re.finditer(r"(?<!!)\[[^\]]+\]\(([^)]+)\)", line):
            target = link[1].split("#", maxsplit=1)[0]
            if not target or re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target):
                continue
            target_path = (path.parent / unquote(target)).resolve()
            if not target_path.is_relative_to(root) or not target_path.is_file():
                errors.append(f"{relative_path}:{line_number}: missing/outside relative link {target}")
    if title_count != 1:
        errors.append(f"{relative_path}: expected one H1, found {title_count}")
    if in_code_block:
        errors.append(f"{relative_path}: unclosed code fence")
    return errors


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    paths = sorted(root.rglob("*.md"))
    paths = [path for path in paths if not any(part in {".git", ".terraform"} for part in path.relative_to(root).parts)]
    errors = [error for path in paths for error in check_document(path, root)]
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Documentation checks passed for {len(paths)} Markdown files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
