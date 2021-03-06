--- Corona wrapper for **fipMetadataFind**, a metadata iterator.
-- Usage :
--
--    local freeimage = require("plugin.freeimage")
--    local image
--    -- ...
--    local finder = freeimage.NewMetadataFind()
--    local ok, tag = finder:findFirstMetadata("EXIF_MAIN", image)
--
--    if ok then
--      repeat
--        -- process the tag
--        print(tag:getKey())
--
--        ok, tag = finder:findNextMetadata()
--      until not ok
--    end
--
--    -- the class can be called again with another metadata model
--    ok, tag = finder:findFirstMetadata("EXIF_EXIF", image)
--
--    if ok then
--      repeat
--        -- process the tag
--        print(tag:getKey())
--
--        ok, tag = finder:findNextMetadata()
--      until not ok
--    end
-- @module fipMetadataFind

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

--- Provides information about the first instance of a tag that matches the metadata model specified in the model argument.
-- @function fipMetadataFind:findFirstMetadata
-- @string model Metadata model, cf. @{enums.FREE_IMAGE_MDMODEL}.
-- @tparam fipImage image Input image.
-- @treturn boolean Find succeeded?
-- @treturn fipTag On success, the first tag.

--- Find the next tag, if any, that matches the metadata model argument in a previous call to @{fipMetadataFind:findFirstMetadata}.
-- @function fipMetadataFind:findNextMetadata
-- @treturn boolean Find succeeded?
-- @treturn fipTag On success, the next tag.

--- Indicates whether the iterator is valid for use.
-- @function fipMetadataFind:isValid
-- @treturn boolean Search handle is allocated?