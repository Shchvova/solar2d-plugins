--- This module implements a multiply-with-carry RNG.
--
-- Based on code and algorithm by George Marsaglia:
-- [MWC](http://www.math.uni-bielefeld.de/~sillke/ALGORITHMS/random/marsaglia-c)

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

-- Cached module references --
local _MakeGenerator_

-- Forward references --
local band
local lshift
local rshift

-- Imports --
if package.loaded["plugin_bit"] then
	band = bit.band
	lshift = bit.lshift
	rshift = bit.rshift
else -- Otherwise, make equivalents for RNG purposes
	local floor = math.floor

	function band (i)
		return i % 0x10000
	end

	function lshift (i)
		return i * 0x10000
	end

	function rshift (i)
		return floor(i / 0x10000)
	end
end

-- Library --
local lib = require("CoronaLibrary"):new{ name = 'mwc', publisherId = 'com.xibalbastudios' }

--- Instantiates a new random generator.
-- @ptable[opt] opts Generator options. Fields:
--
-- * **z** Z seed; if absent, uses a default.
-- * **w** W Seed; if absent, uses a default.
-- @treturn function May be called as `z, w = gen("get_zw")`, in which case _z_ and _w_ will
-- be the current Z and W seeds, respectively.
--
-- Otherwise, called as `result = gen(how)`. When _how_ is **"float"**, _result_ will be a
-- random number &isin; [0, 1); with anything else, it will instead be a random non-negative
-- 32-bit integer.
function lib.MakeGenerator (opts)
	local z, w

	if opts then
		z, w = opts.z, opts.w
	end

	local zdef, wdef = not z, not w

	z = z or 362436069
	w = w or 521288629

	-- Mix the words together if only one seed was specified.
	if zdef ~= wdef then
		z = (36969 * band(z, 0xFFFF) + rshift(w, 16)) % 2^32
		w = (18000 * band(w, 0xFFFF) + rshift(z, 16)) % 2^32
	end

	--[[
		You may replace the two constants 36969 and 18000 by any
		pair of distinct constants from this list:
		18000 18030 18273 18513 18879 19074 19098 19164 19215 19584
		19599 19950 20088 20508 20544 20664 20814 20970 21153 21243
		21423 21723 21954 22125 22188 22293 22860 22938 22965 22974
		23109 23124 23163 23208 23508 23520 23553 23658 23865 24114
		24219 24660 24699 24864 24948 25023 25308 25443 26004 26088
		26154 26550 26679 26838 27183 27258 27753 27795 27810 27834
		27960 28320 28380 28689 28710 28794 28854 28959 28980 29013
		29379 29889 30135 30345 30459 30714 30903 30963 31059 31083
		(or any other 16-bit constants k for which both k*2^16-1
		and k*2^15-1 are prime)
	]]

	return function(how)
		if how == "get_zw" then
			return z, w
		end

		z = (36969 * band(z, 0xFFFF) + rshift(z, 16))
		w = (18000 * band(w, 0xFFFF) + rshift(w, 16))

		local result = (lshift(z, 16) + band(w, 0xFFFF)) % 2^32

		if how == "float" then
			result = result * 2.328306e-10
		end

		return result
	end
end

--- Variant of @{MakeGenerator}, where the generators behave like @{math.random}.
-- @ptable[opt] opts As per @{MakeGenerator}.
-- @treturn function Generator with the semantics of @{math.random}.
--
-- This may also be called as `z, w = gen("get_zw")`, in which case _z_ and _w_ will be the
-- current Z and W seeds, respectively.
function lib.MakeGenerator_Lib (opts)
	local gen = _MakeGenerator_(opts)

	return function(a, b)
		if a == "get_zw" then
			return gen("get_zw")
		elseif a then
			if not b then
				a, b = 1, a
			end

			return a + gen() % (b - a + 1)
		else
			return gen("float")
		end
	end
end

-- Cache module members.
_MakeGenerator_ = lib.MakeGenerator

-- Export the module.
return lib