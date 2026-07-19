# ⛓ toychain

Educational blockchain built with Ruby on Rails — SHA-256 proof-of-work,
background mining, live chain updates, and visual tamper detection.

> Mine blocks, tamper with them, and watch integrity break in cascade — live,
> in every connected browser.

![demo](docs/demo.gif)

## What it demonstrates

- **Proof-of-work**: each block is mined by brute-forcing a nonce until its
  SHA-256 hash meets a difficulty target of 2–6 leading zeros, selectable per
  block. Each block records how long its mining took (`mined in … ms`), making
  the exponential cost of each extra zero visible in real data.
- **Chain integrity**: every block stores the previous block's hash. The
  validator checks three things per block — the **link** (previous hash
  matches), the **integrity** (stored hash verifies against the block's own
  data) and the **work** (the hash actually meets the difficulty the block
  claims), so under-mined blocks can't sneak into a stricter chain.
- **Tamper detection**: the `☠ tamper` button modifies a block's data without
  re-mining — exactly what an attacker editing the database would do. The
  validator catches it instantly and the UI shows the corruption cascade.

## Background mining & live updates

Mining doesn't block the request. `POST /blocks` enqueues a `MineBlockJob` on
**Solid Queue** (database-backed, no Redis) and responds immediately; a
separate worker process does the proof-of-work. When the block is mined, the
job broadcasts the updated chain over **Turbo Streams**: every connected
browser sees the new block appear without reloading. Cross-process delivery
(worker → web) runs on **Solid Cable**, so the whole realtime stack is plain
SQLite. Open the app in two windows and mine from one to see it.

## Architecture notes

Business logic lives in plain Ruby objects under `app/services/`
(`ProofOfWork`, `ChainValidator`) with zero Rails dependencies — tested in
isolation with Structs. Controllers stay thin; routes only expose `index`,
`new`, `create`: blocks are immutable by design, so no edit/update/destroy.
Development mirrors the production architecture: three processes (`web`,
`css`, `jobs`) and three SQLite databases (primary, queue, cable).

## Security details worth noting

- Strong parameters: clients can only submit `data` and `difficulty`; index,
  hashes and nonce are always computed server-side (mass assignment mitigated).
- Difficulty is **clamped server-side to 2–6** and validated at the model —
  a tampered form can't enqueue hour-long mining jobs (DoS via user input).
- State-mutating actions (`tamper`, `reset`) use POST/DELETE with CSRF tokens,
  never GET — no prefetch accidents, no cross-site request forgery.
- CI runs Brakeman (static security analysis), RuboCop and the full test
  suite on every push.

## Running it

    bin/setup
    bin/dev          # web + Tailwind watcher + Solid Queue worker
    bin/rails test

## Stack

Rails 8 · Ruby 3.4 · SQLite ×3 · Solid Queue · Solid Cable · Turbo Streams ·
Tailwind CSS 4 · Minitest

## License

MIT © Zoel Manchón
