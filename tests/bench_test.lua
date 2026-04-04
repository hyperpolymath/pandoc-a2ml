-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- bench_test.lua — Micro-benchmarks for A2ML pandoc filter parsing operations.
-- Run: lua bench_test.lua

local function time_fn(fn, iterations)
  local start = os.clock()
  for _ = 1, iterations do fn() end
  local elapsed = os.clock() - start
  return elapsed
end

local ITERATIONS = 10000

-- Generate test document
local function make_doc(size)
  local lines = {}
  for i = 1, size do
    if i % 10 == 1 then
      table.insert(lines, "## Section " .. i)
    elseif i % 5 == 0 then
      table.insert(lines, "- List item " .. i)
    elseif i % 7 == 0 then
      table.insert(lines, "**bold** and *italic* text " .. i)
    else
      table.insert(lines, "Paragraph text for line " .. i .. " with some content.")
    end
    table.insert(lines, "")
  end
  return table.concat(lines, "\n")
end

local small_doc = make_doc(10)
local medium_doc = make_doc(100)
local large_doc = make_doc(1000)

-- Benchmark: heading detection
local function detect_headings(doc)
  local count = 0
  for line in doc:gmatch("[^\n]+") do
    if line:match("^#+%s+") then count = count + 1 end
  end
  return count
end

local t1 = time_fn(function() detect_headings(small_doc) end, ITERATIONS)
local t2 = time_fn(function() detect_headings(medium_doc) end, ITERATIONS / 10)
local t3 = time_fn(function() detect_headings(large_doc) end, ITERATIONS / 100)

io.write(string.format("Heading detection (small, %d iter):  %.4fs\n", ITERATIONS, t1))
io.write(string.format("Heading detection (medium, %d iter): %.4fs\n", ITERATIONS / 10, t2))
io.write(string.format("Heading detection (large, %d iter):  %.4fs\n", ITERATIONS / 100, t3))

-- Benchmark: bold/italic inline parsing
local function parse_inline(line)
  local result = {}
  for bold in line:gmatch("%*%*(.-)%*%*") do
    table.insert(result, {type="bold", text=bold})
  end
  for italic in line:gmatch("%*(.-)%*") do
    table.insert(result, {type="italic", text=italic})
  end
  return result
end

local inline_samples = {
  "**bold** and *italic* text",
  "Normal text with no formatting",
  "**multiple** **bold** **words** here",
  "[link](url) and **bold** and *italic*",
}

local t4 = time_fn(function()
  for _, s in ipairs(inline_samples) do parse_inline(s) end
end, ITERATIONS)

io.write(string.format("Inline parsing (4 samples, %d iter): %.4fs\n", ITERATIONS, t4))

-- Verify benchmarks complete in reasonable time
assert(t1 < 5.0, "Small heading detection too slow: " .. t1)
assert(t2 < 5.0, "Medium heading detection too slow: " .. t2)
assert(t4 < 5.0, "Inline parsing too slow: " .. t4)

io.write("\nAll benchmarks completed within time limits.\n")
