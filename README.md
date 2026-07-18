# ⛓ toychain

Educational blockchain built with Ruby on Rails — SHA-256 proof-of-work,
chain validation, and visual tamper detection.

> Mine blocks, tamper with them, and watch integrity break in cascade.

![demo](docs/demo.gif)

## What it demonstrates

- **Proof-of-work**: each block is mined by brute-forcing a nonce until its
  SHA-256 hash meets a difficulty target (4 leading zeros).
- **Chain integrity**: every block stores the previous block's hash. Altering
  any historical block invalidates it and every block after it.
- **Tamper detection**: the `☠ tamper` button modifies a block's data without
  re-mining — exactly what an attacker editing the database would do. The
  validator catches it instantly and the UI shows the corruption cascade.

## Architecture notes

Business logic lives in plain Ruby objects under `app/services/`
(`ProofOfWork`, `ChainValidator`) with zero Rails dependencies — tested in
isolation with Structs. Controllers stay thin; routes only expose `index`,
`new`, `create`: blocks are immutable by design, so no edit/update/destroy.

## Security details worth noting

- Strong parameters: clients can only submit `data`; index, hashes and nonce
  are always computed server-side (mass assignment mitigated).
- State-mutating actions (`tamper`, `reset`) use POST/DELETE with CSRF tokens,
  never GET — no prefetch accidents, no cross-site request forgery.
- CI runs Brakeman (static security analysis), RuboCop and the full test
  suite on every push.

## Running it

    bin/setup
    bin/dev          # server + Tailwind watcher
    bin/rails test

## Stack

Rails 8 · Ruby 3.4 · SQLite · Tailwind CSS 4 · Hotwire · Minitest

## License

MIT © Zoel Manchón