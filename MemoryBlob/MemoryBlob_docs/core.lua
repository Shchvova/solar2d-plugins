--- Various free functions used by memory blobs.

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

--- (**WIP**) Check whether an entry exists in storage.
-- @function M.ExistsInStorage
-- @string id Stored entry's lookup ID, cf. @{MemoryBlob:Submit}.
-- @treturn boolean The entry exists?

--- Get the dispatcher used by blob-related events, in order to add / remove listeners.
--
-- Calling this outside [Corona's main thread](https://ggcrunchy.github.io/corona-plugin-docs/DOCS/luaproc/api.html#is_main_state)
-- results in an error.
-- @function M.GetBlobDispatcher
-- @treturn EventDispatcher Dispatcher.
-- @see MemoryBlob:Submit

--- (**WIP**, in probation) Acquire a [Lua process](https://ggcrunchy.github.io/corona-pluin-docs/DOCS/luaproc/api.html)-local
-- reference to a queue created by @{NewQueue}.
-- @function M.GetQueueReference
-- @string id Queue ID, as returned by @{NewQueue}.
-- @tparam ?|string|nil token If absent, a garden-variety queue reference is returned. Otherwise, may be **"consumer"**
-- or **"producer"** to acquire the corresponding token-bearing reference.
-- @treturn ?|ConsumerQueueRef|ProducerQueueRef|QueueRef|nil Queue reference, or **nil** on error, e.g. for invalid IDs.

--- Indicates whether an object is a **MemoryBlob**.
-- @function M.IsBlob
-- @param object Object to check.
-- @tparam ?string type If present, refine the query to only consider blobs of a given type, cf. @{New}.
-- @treturn boolean Is _object_ a blob?

--- Create a new memory blob.
--
-- No assumptions should be made about the original contents; whatever the allocator provides is left intact.
-- @function M.New
-- @tparam ?|table|uint|nil opts Blob creation options.
--
-- When _opts_ is a table, it may contain the following options:
--
--  * **alignment**: If specified, the memory alignment, which must be a multiple of 2, &ge; 4. The
-- blob's memory will start at an address that is a multiple of this value, which is useful and / or
-- needed e.g. for SIMD operations. By default, blobs use the Lua allocator's alignment.
-- <br/><br/>
-- Currently, the upper limit is 1024, one level beyond [AVX2](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions#Advanced_Vector_Extensions_2) support.
--  * **resizable**: If true, the blob can be resized. Off by default.
--  * **size**: Blob size in bytes, &ge; 0. For resizable blobs, this is the blob's initial size;
-- otherwise, it specifies the fixed size. If absent, 0.
--  * **type**: A string that will be used to name the blob userdata's metatable; if absent, uses a default.
-- <br/><br/>
-- Blobs themselves make no further use of this value; rather it is exposed as a convenience, e.g. so
-- plugin authors can identify their own blobs via @{IsBlob}.
--
-- If _opts_ is an integer, it specifies the fixed size (&ge; 0) of the blob to create.
--
-- For any other value of _opts_, a resizable blob will be created.
-- @treturn MemoryBlob The new blob.

--- (**WIP**, in probation) Create a new concurrent queue that may be enqueued and dequeued by multiple [Lua processes](https://ggcrunchy.github.io/corona-pluin-docs/DOCS/luaproc/api.html). (**TODO**: flesh
-- out from library docs)
-- @function M.NewQueue
-- @uint[opt=0] size Number of elements in a full queue, honored by some of the enqueue operations. A
-- _size_ of 0 will be given a reasonable default.
-- @treturn string An ID referring to the queue, for later lookup by @{GetQueueReference}.