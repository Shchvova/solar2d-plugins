--- One of the following **string**s:
--
-- * **"EvenOdd"**: Odd numbered sub-regions are filled, while even numbered sub-regions are not.
-- * **"NonZero"**: All non-zero sub-regions are filled.
-- * **"Positive"**: All sub-regions with winding counts > 0 are filled.
-- * **"Negative"**: All sub-regions with winding counts < 0 are filled.
--
-- **OVERVIEW**:
--
-- _Filling_ indicates those regions that are _inside_ a closed path (i.e. 'filled' with a brush color or
-- pattern in a graphical display) and those regions that are _outside_. The Clipper Library supports 4
-- filling rules: Even-Odd, Non-Zero, Positive and Negative.
--
-- The simplest filling rule is _Even-Odd_ filling (sometimes called _alternate_ filling). Given a group of
-- closed paths start from a point outside the paths and progress along an imaginary line through the paths.
-- When the first path is crossed the encountered region is filled. When the next path is crossed the encountered
-- region is _not_ filled. Likewise, each time a path is crossed, filling starts if it had stopped and stops if
-- it had started.
--
-- With the exception of _Even-Odd_ filling, all other filling rules rely on **edge direction** and **winding numbers**
-- to determine filling. Edge direction is determined by the order in which vertices are declared when constructing
-- a path. Edge direction is used to determine the **winding number** of each polygon subregion.
--
-- The winding number for each polygon sub-region can be derived by:
--
-- 1. starting with a winding number of zero and
-- 2. from a point (P1) that's outside all polygons, draw an imaginary line to a point that's inside a given sub-region (P2)
-- 3. while traversing the line from P1 to P2, for each path that crosses the imaginary line from right to left increment the
-- winding number, and for each path that crosses the line from left to right decrement the winding number.
-- 4. Once you arrive at the given sub-region you have its winding number.
--
-- See [here](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/PolyFillType.htm)
-- for a visual example.
--
-- Paths are added to a Clipper object using the @{Clipper:AddPath|AddPath} or @{Clipper:AddPaths|AddPaths} methods and the
-- filling rules (for subject and clip polygons separately) are specified in the @{Clipper:Execute|Execute} method.
--
-- Polygon regions are defined by one or more closed paths which may or may not intersect. A single polygon region can be
-- defined by a single non-intersecting path or by multiple non-intersecting paths where there's typically an 'outer' path
-- and one or more inner 'hole' paths. Looking at the three shapes in the image above, the middle shape consists of two
-- concentric rectangles sharing the same clockwise orientation. With even-odd filling, where orientation can be disregarded,
-- the inner rectangle would create a hole in the outer rectangular polygon. There would be no hole with non-zero filling.
-- In the concentric rectangles on the right, where the inner rectangle is orientated opposite to the outer, a hole will be
-- rendered with either even-odd or non-zero filling. A single path can also define multiple subregions if it self-intersects
-- as in the example of the 5 pointed star shape shown at the earlier link.
--
-- By far the most widely used fill rules are Even-Odd (aka Alternate) and Non-Zero (aka Winding).
--
-- It's useful to note that _edge direction_ has no affect on a winding number's odd-ness or even-ness. (This is why
-- @{core.Orientation|orientation} **is ignored when the _Even-Odd rule_ is employed**.)
--
-- The direction of the Y-axis does affect polygon orientation and _edge direction_. However, changing Y-axis orientation
-- will only change the _sign_ of winding numbers, not their magnitudes, and has no effect on either _Even-Odd_ or _Non-Zero_
-- filling.
-- @classmod PolyFillType

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