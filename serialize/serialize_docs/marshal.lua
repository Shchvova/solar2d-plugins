---	Corona binding for [lua-marshal](https://github.com/richardhundt/lua-marshal): fast table serialization for Lua.
--
--    local marshal = require("plugin.serialize").marshal
--
-- Features:
-- ---------
--
-- Serializes tables, which may contain cycles, Lua functions with upvalues and basic data types.
--
-- All functions take an optional constants table which, if encountered during serialization,
-- are simply referenced from the constants table passed during deserialization. For example:
--
--    local orig = { answer = 42, print = print }
--    local pack = marshal.encode(orig, { print })
--    local copy = marshal.decode(pack, { print })
--    assert(copy.print == print)
--
-- Hooks
-- -----
--
-- A hook is provided for influencing serializing behaviour via the `__persist` metamethod.
-- The `__persist` metamethod is expected to return a closure which is called during
-- deserialization. The return value of the closure is taken as the final decoded result.
--
-- This is useful for serializing both userdata and for use with object-oriented Lua,
-- since metatables are not serialized.
--
-- For example:
--
--    local Point = { }
--    function Point:new(x, y)
--     self.__index = self
--     return setmetatable({ x = x, y = y }, self)
--    end
--    function Point:move(x, y)
--     self.x = x
--     self.y = y
--    end
--    function Point:__persist()
--     local x = self.x
--     local y = self.y
--     return function()
--   	  -- do NOT refer to self in this scope
--   	  return setmetatable({ x = x, y = y }, Point)
--     end
--    end
--
-- The above shows a way to persist an "instance" of Point (if you're thinking
-- in OO terms). In this case `Point` itself will be included in the encoded chunk
-- because it's referenced as an upvalue of the returned closure.
--
-- The `__persist` hook may *NOT* refer to the receiver (i.e. `self`
-- in the example) because this will cause deep recursion when upvalues
-- are serialized.
--
-- Limitations:
-- ------------
--
-- Coroutines are not serialized. Userdata doesn't serialize either
-- however support for userdata the `__persist` metatable hook can be used.
--
-- Metatables and function environments are not serialized.
--
-- Attempt to serialize C functions, threads and userdata without a `__persist` hook
-- raises an exception.
--
-- Serialized code is not portable.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

--- Serializes a value to a byte stream.
-- @function marshal.encode
-- @param v Value to encode.
-- @ptable[opt] constants See notes in the summary.
-- @treturn string Encoded value.

--- Deserializes a byte stream to a value.
-- @function marshal.decode
-- @string s Encoded string.
-- @ptable[opt] constants See notes in the summary.
-- @return Decoded value.

--- Deep clone a value (deep for tables and functions).
-- @function marshal.clone
-- @param orig Value to clone.
-- @ptable[opt] constants See notes in the summary.
-- @return Cloned value.

-- Tests:

local marshal = require "marshal"

local k = { "tkey" }
local a = { "a", "b", "c", [k] = "tval" }
local s = assert(marshal.encode(a))
--print(string.format("%q", s))
local t = marshal.decode(s)
--print(t)
table.foreach(t, print)
assert(t[1] == "a")
assert(t[2] == "b")
assert(t[3] == "c")
---[==[
assert(#t == 3)
local _k = next(t, #t)
assert(type(_k) == "table")
assert(_k[1] == "tkey")
assert(t[_k] == "tval")

local o = { }
o.__index = o
local s = marshal.encode(o)
local t = marshal.decode(s)
assert(type(t) == 'table')
assert(t.__index == t)

local up = 69
local s = marshal.encode({ answer = 42, funky = function() return up end })
local t = marshal.decode(s)
assert(t.answer == 42)
assert(type(t.funky) == "function")
assert(t.funky() == up)

local t = { answer = 42 }
local c = { "cycle" }
c.this = c
t.here = c
local s = marshal.encode(t)
local u = marshal.decode(s)
assert(u.answer == 42)
assert(type(u.here) == "table")
assert(u.here == u.here.this)
assert(u.here[1] == "cycle")

local o = { x = 11, y = 22 }
local seen_hook
setmetatable(o, {
   __persist = function(o)
      local x = o.x
      local y = o.y
      seen_hook = true
      local mt = getmetatable(o)
      local print = print
      return function()
         local o = { }
         o.x = x
         o.y = y
         print("constant table: 'print'")
         return setmetatable(o, mt)
      end
   end
})

local s = marshal.encode(o, { print })
assert(seen_hook)
local p = marshal.decode(s, { print })
assert(p ~= o)
assert(p.x == o.x)
assert(p.y == o.y)
assert(getmetatable(p))
assert(type(getmetatable(p).__persist) == "function")

local o = { 42 }
local a = { o, o, o }
local s = marshal.encode(a)
local t = marshal.decode(s)
assert(type(t[1]) == "table")
assert(t[1] == t[2])
assert(t[2] == t[3])

local u = { 42 }
local f = function() return u end
local a = { f, f, u, f }
local s = marshal.encode(a)
local t = marshal.decode(s)
assert(type(t[1]) == "function")
assert(t[1] == t[2])
assert(t[2] == t[4])
assert(type(t[1]()) == "table")
assert(type(t[3]) == "table")
assert(t[1]() == t[3])

local u = function() return 42 end
local f = function() return u end
local a = { f, f, f, u }
local s = marshal.encode(a)
local t = marshal.decode(s)
assert(type(t[1]) == "function")
assert(t[1] == t[2])
assert(t[2] == t[3])
assert(type(t[1]()) == "function")
assert(type(t[4]) == "function")
assert(t[1]() == t[4])

local u = newproxy()
debug.setmetatable(u, {
   __persist = function()
      return function()
         return newproxy()
      end
   end
})

local s = marshal.encode{u}
local t = marshal.decode(s)
assert(type(t[1]) == "userdata")

local t1 = { 1, 'a', b = 'b' }
table.foreach(t1, print)
local t2 = marshal.clone(t1)
print('---')
table.foreach(t1, print)
print('---')
table.foreach(t2, print)
assert(t1[1] == t2[1])
assert(t1[2] == t2[2])
assert(t1.b == t2.b)

local t1 = marshal.clone({ })

local answer = 42
local f1 = function()
   return "answer: "..answer
end
local s1 = marshal.encode(f1)
local f2 = marshal.decode(s1)
assert(f2() == 'answer: 42')

assert(marshal.decode(marshal.encode()) == nil)
assert(marshal.decode(marshal.encode(nil)) == nil)

local s1 = marshal.encode(pt)
local p2 = marshal.decode(s1)
print(string.format('%q',s1))

print "OK"

--[[ micro-bench (~4.2 seconds on my laptop)
local t = { a='a', b='b', c='c', d='d', hop='jump', skip='foo', answer=42 }
local s = marshal.encode(t)
for i=1, 1000000 do
   s = marshal.encode(t)
   t = marshal.decode(s)
end
--]]
--]==]