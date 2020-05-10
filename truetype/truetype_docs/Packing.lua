--- Class that represents a truetype packing context.
--
-- **N.B.** These APIs are only lightly tested at the moment, so use at your own risk!
-- @classmod Packing

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

--- Getter.
-- @function Packing:GetBitmap
-- @param how This may be **"as\_bytes"** to return the bitmap as **Bytes**.
-- @treturn ?|Bytes|string Bitmap pixels with size `width * height`, cf. @{truetype.NewPacking|NewPacking}. As a
-- string, this is a snapshot at the time of the call; otherwise, a proxy object that implements **Bytes** and reflects
-- the current contents.

--- Cleans up the packing context and frees all memory. (The garbage collector will also do this.)
-- @function Packing:PackEnd

--- Given the font data, prepare bitmap layouts for _nchars_ Unicode values, starting at _codepoint_.
-- @function Packing:PackFontRange
-- @tparam ?|Bytes|string bytes Font data, typically the contents of a file.
-- @tparam ?|number|string font_size Target font height. As a number, this will be scaled according
-- to @{FontInfo:ScaleForPixelHeight}; strings, on the other hand, are assumed to come from @{truetype.PointSize|PointSize}
-- and will be handled by @{FontInfo:ScaleForMappingEmToPixels}.
-- @uint codepoint First Unicode character in range.
-- @uint nchars Number of characters.
-- @uint[opt=1] index Font index, &ge; 1.
-- @treturn ?|CharArray|nil On success, rendering data which may be retrieved by @{CharArray:GetPackedQuad}; **nil** otherwise.

--- Representation of a packed range.
-- @field font_size As per @{Packing:PackFontRange}. (Required)
-- @field codepoints Either a single **uint** codepoint or an array of the same. In the second case these are the codepoints
-- themselves; otherwise, this is the first point in a range. (Required)
-- @field num_chars Number of characters in the range. (Ignored when **codepoints** is an array, required otherwise.)
-- @table PackRange

--- Given the font data, prepare bitmap layouts for multiple ranges of characters.
--
-- This will usually create a better-packed bitmaps than multiple calls to @{Packing:PackFontRange}. Note that
-- you can call this multiple times without calling @{Packing:PackEnd}.
-- @function Packing:PackFontRanges
-- @tparam ?|Bytes|string bytes Font data, typically the contents of a file.
-- @tparam {PackRange,...} ranges One or more packed ranges.
-- @uint[opt=1] index Font index, &ge; 1.
-- @treturn ?|{CharArray,...}|nil On success, an array of @{CharArray}s, cf. @{Packing:PackFontRange}; **nil** otherwise.

--- Calculates the dimensions for all the characters to be packed, taking into account font size and
-- oversampling, cf. @{Packing:PackFontRange} and @{Packing:PackSetOversampling} respectively.
--
-- Calling this, @{Packing:PackFontRangesPackRects}, and @{Packing:PackFontRangesRenderIntoRects}
-- in sequence is roughly equivalent to calling @{Packing:PackFontRanges}.
--
-- If you more control over the packing of multiple fonts, or if you want to pack custom data into a
-- font texture, you can create a custom version of **PackFontRanges** using these functions, e.g.
-- gather rects multiple times, @{RectArray:Concatenate|concatenate} the resulting arrays into one, pack that,
-- then render repeatedly. This may result in a better packing than calling **PackFontRanges** multiple
-- times (or it may not).
-- @function Packing:PackFontRangesGatherRects
-- @tparam FontInfo font Info for a specific font.
-- @tparam {PackRange,...} ranges One or more packed ranges.
-- @treturn ?|RectArray|nil On success, the characters' rects with proper dimensions and default
-- positions; **nil** otherwise.

--- Assign packed locations to rectangles.
-- @function Packing:PackFontRangesPackRects
-- @tparam RectArray rects On input, only the @{Packing:PackFontRangesGatherRects|dimensions} are considered.
-- Afterward, valid positions
-- will have been assigned to each successfully packed rect, cf. @{RectArray:WasPacked}.

--- Renders any @{RectArray:WasPacked|successfully packed} characters into the @{Packing:GetBitmap|packing's bitmap}.
-- @function Packing:PackFontRangesRenderIntoRects
-- @tparam FontInfo font Info for a specific font.
-- @tparam {PackRange,...} ranges One or more packed ranges.
-- @tparam RectArray rects @{Packing:PackFontRangesPackRects|Packed locations and dimension information}.
-- @treturn ?|CharArray|nil On success, packed character rendering data; **nil** otherwise.

--- Oversampling a font increases the quality by allowing higher-quality subpixel
-- positioning, and is especially valuable at smaller text sizes.
--
-- This function sets the amount of oversampling for all following calls to
-- @{Packing:PackFontRange}, @{Packing:PackFontRanges}, or @{Packing:PackFontRangesGatherRects}
-- for a given packing. The default (no oversampling) is achieved by `hoversampling == 1`
-- and `voversampling == 1`. The total number of pixels required is
-- `hoversampling * voversampling` larger than the default; for example, 2x2
-- oversampling requires 4x the storage of 1x1. For best results, render
-- oversampled textures with bilinear filtering.
--
-- The [readme](https://github.com/nothings/stb/tree/master/tests/oversample) for **stb**'s
-- oversample tests has some good information about oversampled fonts.
--
-- To use with @{Packing:PackFontRangesGatherRects} and friends, oversampling must be
-- set before the sequence of calls, cf. the docs for the same.
-- @function Packing:PackSetOversampling
-- @uint hoversampling Horizontal oversampling...
-- @uint voversampling ...and vertical.