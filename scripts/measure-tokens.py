#!/usr/bin/env python3
"""Token measurement tool for plugin instruction files.
Compares original vs converted file token counts using tiktoken (cl100k_base).
Usage:
  python3 scripts/measure-tokens.py <original> <converted>
  python3 scripts/measure-tokens.py --baseline <dir>   # measure all .md/.json/.sh files
"""
import tiktoken, sys, json, os, glob

enc = tiktoken.get_encoding("cl100k_base")

def count(path):
    with open(path) as f:
        return len(enc.encode(f.read()))

def compare(orig_path, conv_path):
    orig, conv = count(orig_path), count(conv_path)
    savings = (1 - conv / orig) * 100 if orig > 0 else 0
    return {"file": os.path.basename(conv_path),
            "original": orig, "converted": conv,
            "savings_pct": round(savings, 1)}

def baseline(directory):
    results = []
    for ext in ["**/*.md", "**/*.json", "**/*.sh"]:
        for path in sorted(glob.glob(os.path.join(directory, ext), recursive=True)):
            # Skip README.md, PLAN.md, REVIEW.md (user-facing, kept in Korean)
            basename = os.path.basename(path)
            if basename in ("README.md", "PLAN.md", "REVIEW.md"):
                continue
            # Skip .obsidian, .git, tests, .mcp.json
            if "/.git/" in path or "/.obsidian/" in path or "/tests/" in path or basename == ".mcp.json":
                continue
            tokens = count(path)
            rel = os.path.relpath(path, directory)
            results.append({"file": rel, "tokens": tokens})
    total = sum(r["tokens"] for r in results)
    return {"files": results, "total_tokens": total, "file_count": len(results)}

if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "--baseline":
        result = baseline(sys.argv[2])
        print(json.dumps(result, indent=2))
    elif len(sys.argv) == 3:
        result = compare(sys.argv[1], sys.argv[2])
        print(json.dumps(result, indent=2))
    else:
        print("Usage:")
        print("  measure-tokens.py <original> <converted>")
        print("  measure-tokens.py --baseline <dir>")
        sys.exit(1)
