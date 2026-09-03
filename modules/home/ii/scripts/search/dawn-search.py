#!/usr/bin/env python3
"""DawnbreakOS Nix unstable repository search helper."""
import json
import re
import subprocess
import sys
import urllib.parse

MAX_RESULTS = 20
TIMEOUT = 45


def emit(payload):
    print(json.dumps(payload, ensure_ascii=False), flush=True)


def fail(message):
    emit({"ok": False, "error": message})
    return 1


def normalize(value):
    """Normalize names/queries for case-insensitive, punctuation-tolerant matching."""
    value = str(value or "").casefold()
    return re.sub(r"[^a-z0-9]+", " ", value).strip()


def score_result(query, pname, attr_path, description):
    """Rank a nix result by how directly its package identity matches the query."""
    q = normalize(query)
    name = normalize(pname)
    attr = normalize(attr_path)
    desc = normalize(description)

    if not q:
        return 0

    # Package-name matches are deliberately much more important than
    # descriptions. This makes "osu!" prefer osu-lazer over unrelated
    # packages whose descriptions happen to contain "osu".
    score = 0

    if name == q:
        score += 10000
    elif name.startswith(q):
        score += 7000
    elif q in name:
        score += 5000

    # Prefer complete name tokens over accidental substring matches.
    name_tokens = name.split()
    query_tokens = q.split()
    if all(token in name_tokens for token in query_tokens):
        score += 2500

    if attr == q:
        score += 1800
    elif attr.startswith(q):
        score += 1200
    elif q in attr:
        score += 700

    if q in desc:
        score += 250

    # Small bonus for matching all query tokens anywhere in the package
    # identity. Keeps multi-word searches useful without overpowering
    # direct package-name matches.
    identity = f"{name} {attr}"
    if all(token in identity for token in query_tokens):
        score += 400

    return score


def nix_search(query):
    command = [
        "nix",
        "search",
        "--json",
        "nixpkgs/nixos-unstable",
        query,
    ]

    try:
        proc = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=TIMEOUT,
            check=False,
        )
    except subprocess.TimeoutExpired:
        raise RuntimeError("Nix search timed out.")
    except OSError as exc:
        raise RuntimeError(f"Could not run nix: {exc}")

    if proc.returncode != 0:
        error = proc.stderr.strip()
        raise RuntimeError(error or f"nix search exited with {proc.returncode}")

    try:
        data = json.loads(proc.stdout or "{}")
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"nix returned invalid JSON: {exc}") from exc

    if not isinstance(data, dict):
        return []

    ranked = []

    for original_index, (attr, item) in enumerate(data.items()):
        if not isinstance(item, dict):
            continue

        attr_path = str(attr).strip()
        pname = str(item.get("pname") or "").strip()
        version = str(item.get("version") or "").strip()
        description = str(item.get("description") or "").strip()

        title = pname or attr_path
        if version:
            title = f"{title} {version}"

        package_url = (
            "https://search.nixos.org/packages?channel=nixpkgs-unstable&query="
            + urllib.parse.quote(pname or attr_path, safe="")
        )

        result = {
            "title": title,
            "url": package_url,
            "snippet": description,
            "attribute": attr_path,
            "pname": pname,
            "version": version,
            "engine": "NixOS unstable",
        }

        score = score_result(query, pname, attr_path, description)

        # Keep the original nix ordering as the tie-breaker.
        ranked.append((score, -original_index, result))

    ranked.sort(key=lambda entry: (entry[0], entry[1]), reverse=True)

    return [entry[2] for entry in ranked[:MAX_RESULTS]]


def main():
    if len(sys.argv) != 2:
        return fail("Usage: dawn-search QUERY")

    query = sys.argv[1].strip()
    if not query:
        return fail("Enter a package name or search term.")

    try:
        results = nix_search(query)
    except RuntimeError as exc:
        return fail(str(exc))

    emit({
        "ok": True,
        "engine": "NixOS unstable",
        "results": results,
    })
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
