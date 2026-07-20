#!/usr/bin/env python3
"""External toychain verifier.

Fetches the chain from the JSON API and re-validates it independently:
link (previous_hash matches), integrity (SHA-256 recomputes) and work
(hash meets the declared difficulty). Trust nothing; verify everything.

Usage:
    TOYCHAIN_TOKEN=tc_... python3 scripts/verify_chain.py [base_url]
"""
import hashlib
import json
import os
import sys
import urllib.request

BASE_URL = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:3000"
TOKEN = os.environ.get("TOYCHAIN_TOKEN")

if not TOKEN:
    sys.exit("Set TOYCHAIN_TOKEN (create one at /api_tokens)")


def fetch_chain():
    request = urllib.request.Request(
        f"{BASE_URL}/api/v1/chain",
        headers={"Authorization": f"Bearer {TOKEN}"},
    )
    with urllib.request.urlopen(request) as response:
        return json.load(response)


def compute_hash(block):
    payload = f"{block['index']}{block['data']}{block['previous_hash']}{block['nonce']}"
    return hashlib.sha256(payload.encode()).hexdigest()


def verify(blocks):
    previous_hash = None
    for position, block in enumerate(blocks):
        link_ok = previous_hash is None or block["previous_hash"] == previous_hash
        integrity_ok = block["hash"] == compute_hash(block)
        work_ok = block["hash"].startswith("0" * block["difficulty"])

        status = "OK " if (link_ok and integrity_ok and work_ok) else "FAIL"
        print(f"  [{status}] block #{block['index']}  "
              f"link={'✓' if link_ok else '✗'} "
              f"integrity={'✓' if integrity_ok else '✗'} "
              f"work={'✓' if work_ok else '✗'}")

        if not (link_ok and integrity_ok and work_ok):
            return position
        previous_hash = block["hash"]
    return None


def main():
    payload = fetch_chain()
    blocks = payload["blocks"]
    print(f"chain length: {len(blocks)}  (server says valid={payload['valid']})")

    first_invalid = verify(blocks)

    if first_invalid is None:
        print("verdict: CHAIN VALID — independently verified")
    else:
        print(f"verdict: CHAIN CORRUPTED at position {first_invalid}")

    server_agrees = (first_invalid is None) == payload["valid"]
    print(f"server agreement: {'yes' if server_agrees else 'NO — server is lying or stale!'}")
    sys.exit(0 if first_invalid is None else 1)


if __name__ == "__main__":
    main()
