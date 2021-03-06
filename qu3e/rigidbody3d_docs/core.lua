--- Various free functions used by Clipper.
--
-- A few additional values are provided to build a @{Path} like so:
--
-- `local path = point1 .. point2 .. point3 .. clipper.ToPath`
--
-- As shown, the value must appear at end of the sequence. The following choices are provided:
--
-- * **ToPath**: Points in **Bytes** form are interpreted as a contiguous pair of 32-bit signed integers.
-- * **ToPath8**: Like **ToPath**, but integers are 8-bit... (1 byte per component.)
-- * **ToPath16**: ...or 16-bit... (2 bytes per component.)
-- * **ToPath64**: ...or 64-bit. (8 bytes per component.)
--
-- A point may instead be a two-element array of @{cInt}s, i.e. `{x, y}`. The end marker is irrelevant here.

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

--- This function returns the area of the supplied polygon. Depending on @{Orientation}, this value may be positive
-- or negative. If **Orientation** is true, then the area will be positive and conversely, if **Orientation** is
-- false, then the area will be negative. (It's assumed that the path will be closed.)
-- @function Area
-- @tparam Path poly
-- @treturn number Area.

--- Removes vertices:
--
-- * that join co-linear edges, or join edges that are almost co-linear (such that if the vertex was moved no more than the specified distance the edges would be co-linear)
-- * that are within the specified distance of an adjacent vertex
-- * that are within the specified distance of a semi-adjacent vertex together with their out-lying vertices
--
-- Vertices are _semi-adjacent_ when they are separated by a single (out-lying) vertex.
--
-- The _distance_ parameter's default value is approximately &radic;2 so that a vertex will be removed when adjacent
-- or semi-adjacent vertices having their corresponding X and Y coordinates differing by no more than 1 unit. (If the
-- edges are semi-adjacent the out-lying vertex will be removed too.)
--
-- See [here](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/CleanPolygon.htm) for a visual example.
-- @function CleanPolygon
-- @tparam Path poly
-- @ptable[opt] opts Options, which may include:
--
-- * **distance**: Adjacency distance. (Def 1.415)
-- * **out**: If this is a @{Path} and distinct from _poly_, the results are placed here, leaving _poly_ intact.

--- Like @{CleanPolygon}, but for multiple polygons.
-- @function CleanPolygons
-- @tparam Paths polys
-- @ptable[opt] opts Options, which may include:
--
-- * **distance**: Adjacency distance. (Def 1.415)
-- * **out**: If this is a @{Paths} and distinct from _polys_, the results are placed here, leaving _polys_ intact.

--- This function filters out _open_ paths from the **PolyTree** structure and returns only _closed_ paths.
-- @function ClosedPathsFromPolyTree
-- @tparam PolyTree PT
-- @ptable[opt] opts Options, which may include:
--
-- * **out**: If this is a **Paths**, it will be populated and used as the return value.
-- @treturn Paths P

--- **Minkowski Difference** is performed by subtracting each point in a polygon from the set of points in an
-- open or closed path. A key feature of Minkowski Difference is that when it's applied to two polygons, the
-- resulting polygon will contain the coordinate space origin whenever the two polygons touch or overlap.
-- (This function is often used to determine when polygons collide.)
--
-- See [here](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/MinkowskiDiff.htm)
-- for a visual example.
-- @function MinkowskiDiff
-- @tparam Path poly1
-- @tparam Path poly2
-- @ptable[opt] opts Options, which may include:
--
-- * **out**:  If this is a **Paths**, it will be populated and used as the return value.
-- @treturn Paths

--- **Minkowski Addition** is performed by adding each point in a polygon 'pattern' to the set of points in an open
-- or closed path. The resulting polygon (or polygons) defines the region that the 'pattern' would pass over in moving
-- from the beginning to the end of the 'path'.
--
-- See [here](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/MinkowskiSum.htm)
-- for a visual example.
-- @function MinkowskiSum
-- @tparam Path pattern
-- @tparam ?|Path|Paths path
-- @ptable[opt] opts Options, which may include:
--
-- * **is\_closed**: Is _path_ closed?
-- * **out**: If this is a **Paths**, it will be populated and used as the return value.
-- @treturn Paths

---
-- @function NewClipper
-- @tparam ?|{string,...}|string|nil init_opts This may be an array of one or more of the following options to enable:
-- **"PreserveCollinear"**, **"ReverseSolution"**, **"StrictlySimple"**. See the corresponding setters in @{Clipper}
-- for details.
--
-- As a string, any of the above.
-- @treturn Clipper New **Clipper** object.
-- @see Clipper:SetPreserveCollinear, Clipper:SetReverseSolution, Clipper:SetStrictlySimple

--- DOCME
-- @function NewOffset
-- @ptable[opt] opts Options, which may include:
--
-- * **miter\_limit**: Initial value for the @{Offset:SetMiterLimit|miter limit} (Default 2)
-- * **round\_precision**: Initial value for the @{Offset:SetArcTolerance|arc tolerance}. (Default .25)
-- @treturn Offset New **Offset** object.

---
-- @function NewPath
-- @treturn Path An empty instance.

---
-- @function NewPathArray
-- @treturn Paths An empty instance.

---
-- @function NewPolyNode
-- @treturn PolyNode An empty instance, intended as an **out** parameter.

---
-- @function NewPolyTree
-- @treturn PolyTree An empty instance, intended as an **out** parameter.
		
---  This function filters out _closed_ paths from the **PolyTree** structure and returns only _open_ paths.
-- @function OpenPathsFromPolyTree
-- @ptable[opt] opts Options, which may include:
--
-- * **out**: If this is a **Paths**, it will be populated and used as the return value.
-- @treturn Paths

--- [Orientation](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/Orientation.htm) is
-- only important to closed paths. Given that vertices are declared in a specific order, orientation refers to the
-- direction (clockwise or counter-clockwise) that these vertices progress around a closed path; this will be **true**
-- when the polygon's orientation is clockwise.
--
-- (Follow the link for a nice visual example.)
--
-- **Notes**:
--
-- * Self-intersecting polygons have indeterminate orientations in which case this function won't return a meaningful value.
-- * For Non-Zero filled polygons, the orientation of [holes](../api.html#terminology) _must be opposite_ that of
-- [outer](../api.html#terminology) polygons.
-- * For closed paths (polygons) in the _solution_ returned by @{Clipper:Execute}, their orientations will always be
-- **true** for outer polygons and **false** for hole polygons (unless the @{Clipper:GetReverseSolution|ReverseSolution}
-- property has been enabled).
-- @function Orientation
-- @tparam Path P
-- @treturn boolean B

---
-- @function PointInPolygon
-- @tparam cInt x Point x-coordinate...
-- @tparam cInt y ...and y.
-- @tparam Path poly Polygon that might contain the point.
-- @return If the point is outside, **false**. Otherwise, **"on\_poly"** if the point is on one of
-- _poly_'s edges, or **"inside"** when in the interior.

--- Converts a **PolyTree** structure into a **Paths** structure.
-- @function PolyTreeToPaths
-- @tparam PolyTree poly_tree
-- @ptable[opt] opts Options, which may include:
--
-- * **out**:  If this is a **Paths**, it will be populated and used as the return value.
-- @treturn Paths

--- Reverses the vertex order (and hence @{Orientation|orientation}) in the specified path.
-- @function ReversePath
-- @tparam Path path

--- Reverses the vertex order (and hence @{Orientation|orientation}) in each contained path.
-- @function ReversePaths
-- @tparam Paths paths

--- Removes self-intersections from the supplied polygon (by performing a boolean _union_ operation using
-- the nominated @{PolyFillType}). Polygons with non-contiguous duplicate vertices (i.e. 'touching') will
-- be split into two polygons.
--
-- _Note: There's currently no guarantee that polygons will be strictly simple since 'simplifying' is still a work in progress._
--
-- See [here](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/SimplifyPolygon.htm)
-- for a couple visual examples.
-- @function SimplifyPolygon
-- @tparam Path poly
-- @ptable[opt] opts Options, which may include:
--
-- * **fill\_type**: Fill type for the union operation. (Default **"EvenOdd"**)
-- * **out**: If this is a **Paths**, it will be populated and used as the return value.
-- @treturn Paths
-- @see CleanPolygon, Clipper:SetStrictlySimple

--- Like @{SimplifyPolygon}, but for multiple polygons.
-- @function SimplifyPolygons
-- @tparam Paths polys
-- @ptable[opt] opts As per @{SimplifyPolygon}.
-- @treturn Paths
-- @see CleanPolygons, PolyFillType, Clipper:SetStrictlySimple