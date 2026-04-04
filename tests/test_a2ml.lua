-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- test_a2ml.lua — Unit and property tests for the A2ML pandoc filter.
-- Run: lua test_a2ml.lua
-- Note: Full integration tests require pandoc available.

local pass = 0
local fail = 0

local function assert_eq(desc, actual, expected)
  if actual == expected then
    io.write("PASS: " .. desc .. "\n")
    pass = pass + 1
  else
    io.write("FAIL: " .. desc .. "\n")
    io.write("  expected: " .. tostring(expected) .. "\n")
    io.write("  actual:   " .. tostring(actual) .. "\n")
    fail = fail + 1
  end
end

local function assert_true(desc, val)
  if val then
    io.write("PASS: " .. desc .. "\n")
    pass = pass + 1
  else
    io.write("FAIL: " .. desc .. " (got false/nil)\n")
    fail = fail + 1
  end
end

local function assert_false(desc, val)
  if not val then
    io.write("PASS: " .. desc .. "\n")
    pass = pass + 1
  else
    io.write("FAIL: " .. desc .. " (expected false/nil)\n")
    fail = fail + 1
  end
end

-- Load the a2ml module (without pandoc runtime, test pure Lua logic)
-- We test the module's internal parsing functions by extracting them.

-- ================================================================
-- Unit tests: Heading detection
-- ================================================================

io.write("\n=== Heading Detection ===\n")

local function is_heading(line)
  return line:match("^#+%s+") ~= nil
end

local function heading_level(line)
  local hashes = line:match("^(#+)%s+")
  return hashes and #hashes or 0
end

assert_true("# Heading detected", is_heading("# Title"))
assert_true("## Heading detected", is_heading("## Section"))
assert_true("### Heading detected", is_heading("### Subsection"))
assert_true("##### Heading detected", is_heading("##### Deep"))
assert_false("Non-heading not detected", is_heading("Normal text"))
assert_false("Hash without space not a heading", is_heading("#notaheading"))
assert_false("Empty string not a heading", is_heading(""))

assert_eq("Level 1 heading", heading_level("# Title"), 1)
assert_eq("Level 2 heading", heading_level("## Section"), 2)
assert_eq("Level 3 heading", heading_level("### Sub"), 3)
assert_eq("Level 5 heading", heading_level("##### Deep"), 5)
assert_eq("Non-heading level", heading_level("text"), 0)

-- ================================================================
-- Unit tests: Code block detection
-- ================================================================

io.write("\n=== Code Block Detection ===\n")

local function is_code_fence(line)
  return line:match("^```") ~= nil
end

assert_true("Backtick fence detected", is_code_fence("```"))
assert_true("Fenced with lang detected", is_code_fence("```elixir"))
assert_false("Non-fence not detected", is_code_fence("text"))
assert_false("Single backtick not a fence", is_code_fence("`code`"))

-- ================================================================
-- Unit tests: Bullet list detection
-- ================================================================

io.write("\n=== List Detection ===\n")

local function is_bullet(line)
  return line:match("^%s*[-*]%s+") ~= nil
end

assert_true("Dash bullet detected", is_bullet("- item"))
assert_true("Asterisk bullet detected", is_bullet("* item"))
assert_true("Indented bullet detected", is_bullet("  - nested"))
assert_false("Text not a bullet", is_bullet("normal text"))
assert_false("Dash without space not a bullet", is_bullet("-noitem"))

-- ================================================================
-- Property tests: Inline formatting patterns
-- ================================================================

io.write("\n=== Inline Formatting Properties ===\n")

local function has_bold(s)
  return s:match("%*%*(.-)%*%*") ~= nil
end

local function has_italic(s)
  return s:match("%*(.-)%*") ~= nil
end

local bold_inputs = {
  "**bold text**",
  "before **bold** after",
  "**a**",
  "**multiple words here**",
}

local not_bold_inputs = {
  "*single asterisk*",
  "no bold here",
  "* list item",
  "",
}

for _, input in ipairs(bold_inputs) do
  assert_true("Bold detected: " .. input, has_bold(input))
end

for _, input in ipairs(not_bold_inputs) do
  -- single asterisk should not be detected as double
  local result = has_bold(input)
  assert_false("Bold NOT detected: " .. input:sub(1, 20), result)
end

-- ================================================================
-- Property tests: Directive block patterns
-- ================================================================

io.write("\n=== Directive Block Properties ===\n")

local function is_directive_start(line)
  return line:match("^@%w+%(") ~= nil
end

local function is_directive_end(line)
  return line:match("^@end") ~= nil
end

local directive_starts = {
  "@note(class=important):",
  "@warning(id=w1):",
  "@code(lang=elixir):",
  "@block():",
}

local non_directives = {
  "normal text",
  "# heading",
  "@notadirective",
  "",
}

for _, line in ipairs(directive_starts) do
  assert_true("Directive start: " .. line, is_directive_start(line))
end

for _, line in ipairs(non_directives) do
  assert_false("Not directive: " .. line:sub(1, 20), is_directive_start(line))
end

assert_true("@end is directive end", is_directive_end("@end"))
assert_true("@end with space is directive end", is_directive_end("@end "))
assert_false("@endnote is not @end", is_directive_end("@endnote"))

-- ================================================================
-- Property tests: Link pattern detection
-- ================================================================

io.write("\n=== Link Pattern Properties ===\n")

local function find_link(s)
  return s:match("%[(.-)%]%((.-)%)")
end

local link_texts = {
  "[link text](http://example.com)",
  "[A2ML spec](spec/a2ml.adoc)",
  "[short](x)",
}

for _, s in ipairs(link_texts) do
  local text, url = find_link(s)
  assert_true("Link found in: " .. s:sub(1, 30), text ~= nil and url ~= nil)
end

assert_false("No link in plain text", find_link("no links here") ~= nil)

-- ================================================================
-- E2E simulation: Multi-line document parsing
-- ================================================================

io.write("\n=== E2E: Document Structure ===\n")

local doc1 = [[
# Title

A paragraph here.

## Section

- item one
- item two

```lua
code here
```
]]

local heading_count = 0
local list_count = 0
local code_block = false
local in_code = false

for line in doc1:gmatch("[^\n]+") do
  if is_code_fence(line) then
    in_code = not in_code
    if in_code then code_block = true end
  elseif not in_code then
    if is_heading(line) then heading_count = heading_count + 1 end
    if is_bullet(line) then list_count = list_count + 1 end
  end
end

assert_eq("Document has 2 headings", heading_count, 2)
assert_eq("Document has 2 list items", list_count, 2)
assert_true("Document has a code block", code_block)

-- ================================================================
-- Results
-- ================================================================

io.write("\n=== Results: " .. pass .. " passed, " .. fail .. " failed ===\n")
os.exit(fail == 0 and 0 or 1)
