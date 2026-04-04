<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# TOPOLOGY.md — pandoc-a2ml

## Purpose

Pandoc A2ML filter enables document transformation to/from A2ML format. Implements Lua-based reader, writer, and filter for Pandoc, allowing seamless integration of A2ML (Axiom 2 Meta Language) documents into documentation pipelines and multi-format publishing workflows.

## Module Map

```
pandoc-a2ml/
├── a2ml.lua             # Core A2ML Lua module
├── a2ml-reader.lua      # A2ML document reader
├── a2ml-writer.lua      # A2ML document writer
├── a2ml-filter.lua      # Pandoc filter implementation
├── a2ml.html            # HTML reference documentation
├── container/           # Containerfile for portable builds
└── docs/                # Filter usage guides
```

## Data Flow

```
[A2ML Source] ──► [Lua Reader] ──► [Pandoc AST] ──► [Writer] ──► [Output Format]
                       ↑                                    ↓
                  [Filter Chain] ◄────────────────────────┘
```

## Integration

- Part of RSR standard documentation pipeline
- Works with Pandoc's Lua filter interface
- Enables A2ML as first-class document format in hyperpolymath ecosystem
- Containerized for consistent CI/CD processing
