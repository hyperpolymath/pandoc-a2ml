# TEST-NEEDS.md — pandoc-a2ml

## CRG Grade: C — ACHIEVED 2026-04-04

> Generated 2026-03-29 by punishing audit.

## Current State

| Category     | Count | Notes |
|-------------|-------|-------|
| Unit tests   | 0     | None |
| Integration  | 1     | src/interface/ffi/test/integration_test.zig |
| E2E          | 0     | None |
| Benchmarks   | 0     | None |

**Source modules:** 4 Lua files (a2ml-filter.lua, a2ml.lua, a2ml-reader.lua, a2ml-writer.lua) + 3 Idris2 ABI + 1 Zig FFI + 1 ReScript.

## What's Missing

### P2P (Property-Based) Tests
- [ ] Reader: property tests for arbitrary A2ML document parsing
- [ ] Writer: property tests for output format validity
- [ ] Roundtrip: read -> write -> read = identity

### E2E Tests
- [ ] Full conversion: A2ML input -> pandoc filter -> target format output
- [ ] All supported output formats tested
- [ ] Edge cases: empty document, nested structures, special characters

### Aspect Tests
- **Security:** No tests for injection through A2ML content, Lua sandbox escape
- **Performance:** No conversion speed benchmarks
- **Concurrency:** N/A
- **Error handling:** No tests for malformed A2ML, unsupported constructs, encoding issues

### Build & Execution
- [ ] Pandoc filter execution test
- [ ] Zig FFI test execution
- [ ] Lua syntax validation

### Benchmarks Needed
- [ ] Conversion throughput (documents/second)
- [ ] Memory usage per document size

### Self-Tests
- [ ] Filter can process its own documentation

## Priority

**HIGH.** 4 Lua filter modules with ZERO unit tests. A pandoc filter needs roundtrip testing as a bare minimum — the reader and writer must be inverses. The Zig FFI test is irrelevant to the core Lua functionality.

## FAKE-FUZZ ALERT

- `tests/fuzz/placeholder.txt` is a scorecard placeholder inherited from rsr-template-repo — it does NOT provide real fuzz testing
- Replace with an actual fuzz harness (see rsr-template-repo/tests/fuzz/README.adoc) or remove the file
- Priority: P2 — creates false impression of fuzz coverage
