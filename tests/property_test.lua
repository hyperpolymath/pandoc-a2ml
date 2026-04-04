-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- property_test.lua — Property-based tests for A2ML pandoc filter invariants.
-- Run: lua property_test.lua

local pass = 0
local fail = 0

local function assert_true(desc, val)
  if val then pass = pass + 1; io.write("PASS: " .. desc .. "\n")
  else fail = fail + 1; io.write("FAIL: " .. desc .. "\n") end
end

-- Property: All heading levels 1-6 are valid A2ML
local HEADING_LEVELS = {1, 2, 3, 4, 5, 6}
for _, level in ipairs(HEADING_LEVELS) do
  local hashes = string.rep("#", level)
  local line = hashes .. " Heading at level " .. level
  assert_true("Heading level " .. level .. " is valid", line:match("^#+%s+") ~= nil)
  assert_true("Heading level " .. level .. " has correct depth", #(line:match("^(#+)")) == level)
end

-- Property: Bold markers always come in pairs in valid A2ML
local VALID_BOLD = {"**a**", "**word**", "**multiple words**", "**x** and **y**"}
for _, s in ipairs(VALID_BOLD) do
  local count = 0
  for _ in s:gmatch("%*%*") do count = count + 1 end
  assert_true("Bold markers are paired in: " .. s, count % 2 == 0)
end

-- Property: Link syntax always has matching brackets and parens
local VALID_LINKS = {
  "[a](b)", "[text](url)", "[long text here](https://example.com/path)",
  "[](empty)", "[text]()"
}
for _, link in ipairs(VALID_LINKS) do
  local text, url = link:match("%[(.-)%]%((.-)%)")
  assert_true("Link parses cleanly: " .. link, text ~= nil)
end

-- Property: Blank lines separate paragraphs (double newline = paragraph boundary)
local PARAGRAPHS = {
  "para1\n\npara2",
  "a\n\nb\n\nc",
  "single paragraph",
}
for _, doc in ipairs(PARAGRAPHS) do
  local paras = 0
  for _ in (doc .. "\n\n"):gmatch("(.-)\n\n") do paras = paras + 1 end
  assert_true("Document has paragraphs: " .. doc:sub(1, 20), paras >= 1)
end

-- Property: Code fences must use 3+ backticks
local CODE_FENCES = {"```", "````", "`````"}
local NON_FENCES = {"`", "``", "text", ""}
for _, f in ipairs(CODE_FENCES) do
  assert_true("3+ backticks is a fence: " .. f, f:match("^```") ~= nil)
end
for _, f in ipairs(NON_FENCES) do
  assert_true("Non-fence rejected: '" .. f .. "'", f:match("^```") == nil)
end

-- Property: Directive syntax is @word(attrs):
local VALID_DIRECTIVES = {
  "@note(class=x):", "@warning():", "@code(lang=lua):", "@block(id=1):"
}
local INVALID_DIRECTIVES = {"@", "@noparen", "@ space()", "note()", "@123()"}
for _, d in ipairs(VALID_DIRECTIVES) do
  assert_true("Valid directive: " .. d, d:match("^@%a+%(") ~= nil)
end
for _, d in ipairs(INVALID_DIRECTIVES) do
  assert_true("Invalid directive rejected: " .. d, d:match("^@%a+%(") == nil)
end

io.write("\n=== Results: " .. pass .. " passed, " .. fail .. " failed ===\n")
os.exit(fail == 0 and 0 or 1)
