--- Corona binding for [luaproc](https://github.com/askyrme/luaproc), a concurrent programming library for Lua.
--
-- Some additional features have been added, among them support for shared variables and events. The latter are
-- built atop [libcuckoo](https://github.com/efficient/libcuckoo) and [pevents](https://github.com/neosmart/pevents)
-- respectively.
--
-- To use the plugin, add the following in <code>build.settings</code>:
--
-- <pre><code class="language-lua">plugins = {
--   ["plugin.luaproc"] = { publisherId = "com.xibalbastudios" }
-- }</code></pre>
--
-- Sample code is available [here](https://github.com/ggcrunchy/corona-plugin-docs/blob/master/luaproc.lua) and
-- [here](https://github.com/ggcrunchy/corona-plugin-docs/tree/master/serialize_luaproc_sample).
--
-- Functions and sections that begin with (**WIP**) describe work in progress. These are features that have not made it into
-- _luaproc_'s public build, but give a reasonable idea of what to expect.
--
-- ========================================================================
--
-- **From the project page:**
--
-- _luaproc_ is a Lua extension library for concurrent programming. This text provides some background information
-- and also serves as a reference manual for the library. The library is available under the same [terms and conditions](http://www.lua.org/copyright.html)
-- as the Lua language, the MIT license. The idea is that if you can use Lua in a project, you should also be able
-- to use _luaproc_.
--
-- Lua natively supports cooperative multithreading by means of coroutines. However, coroutines in Lua cannot be
-- executed in parallel. _luaproc_ overcomes that restriction by building on the proposal and sample implementation
-- presented in [Programming in Lua](http://www.inf.puc-rio.br/~roberto/pil2) (chapter 30). It uses coroutines and
-- multiple independent states in Lua to implement Lua processes, which are user threads comprised of Lua code that
-- have no shared data. Lua processes are executed by workers, which are system threads implemented with POSIX threads
-- (pthreads), and thus can run in parallel.
--
-- Communication between Lua processes relies exclusively on message passing. Each message can carry a tuple of atomic
-- Lua values (strings, numbers, booleans and **nil**). More complex types must be encoded somehow &mdash; for instance
-- by using strings of Lua code that when executed return such a type. Message addressing is based on communication
-- channels, which are decoupled from Lua processes and must be explicitly created.
--
-- Sending a message is always a synchronous operation, i.e., the send operation only returns after a message has been
-- received by another Lua process or if an error occurs (such as trying to send a message to a non-existent channel).
-- Receiving a message, on the other hand, can be a synchronous or asynchronous operation. In synchronous mode, a call
-- to the receive operation only returns after a message has been received or if an error occurs. In asynchronous mode,
-- a call to the receive operation returns immediately and indicates if a message was received or not.
--
-- If a Lua process tries to send a message to a channel where there are no Lua processes waiting to receive a message,
-- its execution is suspended until a matching receive occurs or the channel is destroyed. The same happens if a Lua
-- process tries to synchronously receive a message from a channel where there are no Lua processes waiting to send a
-- message.
--
-- _luaproc_ also offers an optional facility to recycle Lua processes. Recycling consists of reusing states from
-- finished Lua processes, instead of destroying them. When recycling is enabled, a new Lua process can be created by
-- loading its code in a previously used state from a finished Lua process, instead of creating a new state.
--
-- **References**
--
-- A paper about _luaproc_ &mdash; Exploring Lua for Concurrent Programming &mdash; was published in the Journal of
-- Universal Computer Science and is available [here](http://www.jucs.org/jucs_14_21/exploring_lua_for_concurrent) and
-- [here](http://www.inf.puc-rio.br/~roberto/docs/ry08-05.pdf). Some information in the paper is already outdated, but
-- it still provides a good overview of the library and some of its design choices.
--
-- A tech report about concurrency in Lua, which uses _luaproc_ as part of a case study, is also available
-- [here](ftp://ftp.inf.puc-rio.br/pub/docs/techreports/11_13_skyrme.pdf).
--
-- Finally, a paper about an experiment to port _luaproc_ to use Transactional Memory instead of the standard POSIX Threads
-- synchronization constructs, published as a part of the 8th ACM SIGPLAN Workshop on Transactional Computing, can be found
-- [here](http://transact2013.cse.lehigh.edu/skyrme.pdf).
--
-- Copyright © 2008-2015 Alexandre Skyrme, Noemi Rodriguez, Roberto Ierusalimschy.
-- All rights reserved.
--
-- ========================================================================
--
-- **From [libcuckoo's license](https://github.com/efficient/libcuckoo#licence):**
--
-- Copyright (C) 2013, Carnegie Mellon University and Intel Corporation
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
-- with the License. You may obtain a copy of the License at
--
--   [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
-- on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for
-- the specific language governing permissions and limitations under the License.
--
-- ========================================================================
--
-- **From the [license of CityHash](https://raw.githubusercontent.com/efficient/libcuckoo/master/cityhash-1.1.1/COPYING)
-- (used by libcuckoo)**:
--
-- Copyright (c) 2011 Google, Inc.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- ========================================================================
--
-- **From [pevents's license](https://raw.githubusercontent.com/neosmart/pevents/master/LICENSE)**:
--
-- Copyright (C) 2011 - 2015 by NeoSmart Technologies <http://neosmart.net/>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- ========================================================================

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

--- Create a new Lua process to run the specified string of Lua code. The only libraries loaded initially are _luaproc_
-- itself (available as the global **luaproc**) and the standard Lua base and
-- [package](https://docs.coronalabs.com/api/library/package/index.html) libraries.
--
-- The remaining standard Lua libraries (**io**, **os**, **table**, **string**, **math**, **debug**, and **coroutine**) are
-- pre-registered and can be loaded with a call to the standard Lua function
-- [require](https://docs.coronalabs.com/api/library/package/require.html).
--
-- In addition, **system** can be **require()**'d in a similar way. This contains approximations of the following Corona built-ins,
-- under the same names: **CachesDirectory**, **DocumentsDirectory**, **ResourceDirectory**, **TemporaryDirectory**, **getTimer()**,
-- and **pathForFile()**.
--
-- A @{preload} facility is available to load custom plugins in processes.
--
-- Finally, the following modules may also be required:
--
-- * **crypto**, **easing**, **json**, **lfs**, **lpeg**, **ltn12**, **mime**, **re**, **socket**, **sqlite3**
--
-- Note that processes are unique Lua states, so Lua modules loaded in multiple processes, or in one process as well as Corona's own
-- thread, will have different contents. Special care must be taken in the case of dynamically loaded native libraries, since these
-- may keep some of their state outside Lua.
--
-- Thus, libraries meant to allow use in multiple processes should provide explicit guarantees and / or guidelines. For instance, a
-- library that keeps no state at all is fine, as is one that only allocates memory via [lua_newuserdata](http://www.lua.org/manual/5.1/manual.html#lua_newuserdata).
-- Another approach would be to use [thread-specific data](http://pubs.opengroup.org/onlinepubs/009695399/functions/pthread_key_create.html).
--
-- (**WIP, in probation**)
--
-- If a process errors out, the manager will check whether it had a global named **LUAPROC\_ERROR**. If one exists and is a table,
-- its **cleanup** and **report\_method** members are queried.
--
-- When **cleanup** contains a function, it is called as `local result = pcall(cleanup, error)`, with _error_ being the
-- object&mdash;typically a string&mdash;left behind by the crash. This provides a means to restore consistency if the
-- process was using non-trivial resources such as events. When _result_ is non-**nil**, it replaces _error_.
--
-- The final error is handled according to **report\_method**. By default, it gets printed to the console.
--
-- With the **"alert"** method, something like `luaproc.alert("crash_report", tostring(error))` is performed, allowing the
-- application to respond to the error. Example use cases include:
--
-- * Sending a message such as **"fatal"**, if it was a non-recoverable error.
-- * Encoding the final process state into the error, then later attempt to resume or restart the operation.
--
-- When the method is **"ignore"**, the error is silent.
-- @function newproc
-- @string lua_code String of Lua code.
-- @return[1] **true**, indicating success.
-- @return[2] **nil**, indicating an error.
-- @return[2] Error message, of type **string**.
-- @see alert

--- Variant of **newproc** that accepts a function.
--
-- Boolean, **nil**, number, and string upvalues will be copied over to this function (at this point, they take
-- on a life of their own, despite remaining within lexical scope). Upvalues of any other type will result in an
-- error, with two exceptions: the global table will map to its counterpart in the new process, as will the
-- luaproc module itself. The latter is designed to allow this usage:
--    local luaproc = require("plugin.luaproc")
--    luaproc.newchannel("channel")
--    luaproc.newproc(function()
--      luaproc.send("channel", "MESSAGE!") -- would error out with a typical table, but okay
--    end)
-- @function newproc
-- @tparam function f Function.
-- @return[1] **true**, indicating success.
-- @return[2] **nil**, indicating an error.
-- @return[2] Error message, of type **string**.

--- Dispatch an alert event (in the main state), e.g. to react to something in a process.
--
-- Listeners for events named _message_ will be alerted. The event contains _payload_ in field **payload**.
--
-- In the main state, this will be performed immediately. Otherwise, alerts will fire during an **enterFrame**; if Lua is
-- trying to close, this will do nothing.
-- @function alert
-- @string message User-defined message.
-- @tparam ?|string|number|boolean|nil payload User-defined payload.
-- @see get_alert_dispatcher

--- (**WIP**) Create a new event for process scheduling.
-- @function create_event
-- @bool[opt=false] manual_reset Normally, waiting events are reset if and when the operation completes.
--
-- Events created with this flag are left as is, requiring explicit use of @{reset_event}.
-- @bool[opt=false] initial_value If true, the event begins in the set state, as if @{set_event} had been
-- called. Otherwise, the event begins as unset.
-- @treturn ?|string|nil If an event was created, its name. Otherwise, **nil**.
-- @see destroy_event, wait_for_all_events, wait_for_any_events, wait_for_event

--- (**WIP**) Create a shared integer variable.
-- @function create_integer
-- @tparam ?int value Initial value. If absent, 0.
-- @treturn string Name of new integer.
-- @see destroy_integer, get_integer, update_integer

--- (**WIP**) Create a shared number variable.
-- @function create_number
-- @tparam ?number value Initial value. If absent, 0.
-- @treturn string Name of new number.
-- @see destroy_number, get_number, update_number

--- Destroy a channel identified by string name.
--
-- Lua processes waiting to send or receive messages on destroyed channels have their execution resumed and receive an error
-- message indicating the channel was destroyed.
-- @function delchannel
-- @string channel_name Name of communication channel.
-- @return[1] **true**, indicating success.
-- @return[2] **nil**, indicating an error.
-- @return[2] Error message, of type **string**.

--- (**WIP**) Destroy an event, if present.
--
-- This must not be called while waiting for the event.
-- @function destroy_event
-- @string name Name of event, cf. @{create_event}.
-- @treturn boolean Destruction succeeded (or there was nothing to destroy)?
-- @see wait_for_all_events, wait_for_any_events, wait_for_event

--- (**WIP**) Destroy a shared integer variable, if it exists.
--
-- While not encouraged, this may be safely mixed with @{update_integer} operations on the variable.
-- @function destroy_integer
-- @string Name of number, cf. @{create_integer}.

--- (**WIP**) Destroy a shared number variable, if it exists.
--
-- While not encouraged, this may be safely mixed with @{update_number} operations on the variable.
-- @function destroy_number
-- @string Name of number, cf. @{create_number}.

--- (**WIP**) Get an estimate of available hardware concurrency, e.g. for @{setnumworkers}.
-- @function estimate_concurrency
-- @treturn uint Estimated number of hardware cores, or 0 if unable to guess.

--- Get the dispatcher used by @{alert}, in order to add / remove listeners.
--
-- Calling this outside the main state results in an error.
-- @function get_alert_dispatcher
-- @treturn EventDispatcher Dispatcher.

--- (**WIP**) Get a shared integer atomically, if present.
-- @function get_integer
-- @string name Name of integer.
-- @treturn ?|int|nil Value of integer, or **nil** if absent.
-- @see create_integer, update_integer

--- (**WIP**) Get a shared number atomically, if present.
-- @function get_number
-- @string name Name of number.
-- @treturn ?|number|nil Value of number, or **nil** if absent.
-- @see create_number, update_number

--- Return the number of active workers (pthreads).
-- @function getnumworkers
-- @treturn int Number of active workers.
-- @see setnumworkers

--- Check whether the running process is in the main state.
-- @function is_main_state
-- @treturn boolean Is this the main state?

--- Check whether _luaproc_ is waiting for processes to finish, either after a call to @{wait} or when closing down.
-- @function is_waiting
-- @treturn boolean Is _luaproc_ waiting?
-- @see wants_to_close

--- Creates a new channel identified by string name.
-- @function newchannel
-- @string channel_name Name of new communication channel.
-- @return[1] **true**, indicating success.
-- @return[2] **nil**, indicating an error.
-- @return[2] Error message, of type **string**.

--- (**WIP**) DOCME!
-- @function preload
-- @string name
-- @tparam ?function loader

--- Receive a message (tuple of boolean, **nil**, number or string values) from a channel. Suspends execution of the calling Lua
-- process if there is no matching receive and the async (boolean) flag is not set. The async flag, by default, is not set.
--
-- Calling this synchronously from Corona's thread results in an error unless a corresponding send has already fired. As with @{send},
-- this is usually desired, to avoid Corona blocking; @{receive_allow_from_main} is provided to circumvent this protection.
-- @function receive
-- @string channel_name Name of communication channel.
-- @bool[opt=false] asynchronous Receive asynchronously?
-- @return[1] Value(s) passed by @{send}.
-- @return[2] **nil**, indicating an error.
-- @return[2] Error message, of type **string**.

--- Variant of @{receive} that allows unmatched receives from Corona's thread.
-- @function receive_allow_from_main

--- Set the maximum number of Lua processes to recycle. The default number is zero, i.e. no Lua processes are recycled.
-- @function recycle
-- @int maxrecycle Maximum number of processes.
-- @return[1] **true**, indicating success.
-- @return[2] **nil**, indicating an error.
-- @return[2] Error message, of type **string**.

--- (**WIP**) Reset an event.
-- @function reset_event
-- @string name Name of event, cf. @{create_event}.
-- @treturn boolean Event existed and was reset?
-- @see set_event

--- Send a message (tuple of boolean, **nil**, number or string values) to a channel. Suspends execution of the calling Lua process
-- if there is no matching receive.
--
-- Calling this from Corona's thread results in an error if the channel is not already waiting for the results. This is usually desired,
-- as Corona would be likely to block; @{send_allow_from_main} is provided in case the more dangerous behavior is necessary.
-- @function send
-- @string channel_name Name of communication channel.
-- @param ... Values to send, of the above-mentioned types.
-- @return[1] **true**, indicating success.
-- @return[2] **nil**, indicating an error.
-- @return[2] Error message, of type **string**.

--- Variant of @{send} that allows unmatched sends from Corona's thread.
-- @function send_allow_from_main

--- (**WIP**) Set an event.
-- @function set_event
-- @string name Name of event, cf. @{create_event}.
-- @treturn boolean Event existed and was set?
-- @see reset_event

--- Set the number of active workers (pthreads) to n (default = 1, minimum = 1).
--
-- Creates and destroys workers as needed, depending on the current number of active workers.
--
-- No return, raises error if worker could not be created. 
-- @function setnumworkers
-- @int number_of_workers Number of active workers.
-- @see estimate_concurrency, getnumworkers

--- Put the current process to sleep.
--
-- Calling this from the main state results in an error.
--
-- **N.B.** At the moment, this does not respect Corona's suspend and resume logic.
-- @function sleep
-- @tparam ?uint ms Milliseconds to sleep (approximately), &ge; 0.
--
-- If absent or 0, the process yields, giving other processes a chance to use any spare time.
 
--- (**WIP**) Update a shared integer, if present.
--
-- Concurrent updates are atomic (cf. the summary for _op_, below), but have no specific order.
-- @function update_integer
-- @string name Name of integer, cf. @{create_integer}.
-- @string op Binary update operation, which may be one of:
--
-- * **"assign"**: assign _delta_ directly to the variable.
-- * **"add"**, **"sub"**, i.e. arithmetic add, subtract.
-- * **"and"**, **"or"**, **"xor"**, i.e. bitwise and, inclusive-or, exclusive-or.
--
-- The new value will be `old op delta`, e.g. `new = old + 7` for _op_ of **"add"** and _delta_ of `7`.
--
-- Atomicity means w.l.o.g. that when two processes are calling @{update_integer} on the same integer at the
-- same time, one of them will "win": effectively, one goes first and assigns its result to _new_, followed
-- by the other using said result as its _old_.
--
-- If both processes saw the same _old_, there would be a ["race"](https://en.wikipedia.org/wiki/Race_condition)
-- to set _new_, with unpredictable results.
-- @int delta Value combined with the shared integer to update it, according to _op_.
-- @treturn ?|number|nil If the number existed and was given a valid operation, its new value. Otherwise, **nil**.
-- @see get_integer, update_integer_cas

--- (**WIP**) DOCME!
-- @function update_integer_cas
-- @string name Name of integer, cf. @{update_integer}.
-- @string op As per @{update_integer}.
-- @int expected Expected value of integer.
-- @int delta As per @{update_integer}.
-- @return[1] **true**, indicating success: the integer existed, was given a valid operation, and had value _expected_.
-- @return[2] **false**, meaning failure.
-- @treturn[2] ?|int|nil Actual value of integer when the operation was attempted (if absent, **nil**).

--- (**WIP**) Update a shared number, if present.
--
-- The additional details from @{update_integer} apply here as well.
-- @function update_number
-- @string name Name of number, cf. @{create_number}.
-- @string op Binary update operation, which may be **"assign"**, **"add"** or **"sub"**, cf. @{update_integer}.
-- @number delta Value combined with the shared number to update it, according to _op_.
-- @treturn ?|number|nil If the number existed and was given a valid operation, its new value. Otherwise, **nil**.
-- @see get_number

--- Wait until all Lua processes have finished, then continues program execution.
--
-- It only makes sense to call this function from the main Lua script, i.e. from Corona's thread. Moreover, this function is
-- implicitly called when the main Lua script finishes executing, e.g. on a simulator reset or when the app is about to exit.
--
-- **TODO** This and other time-based functions should be robust against suspends and accommodate exits
-- @function wait
-- @see is_waiting

--- Indicates whether Lua wants to close, either from trying to exit the app or Corona simulator, or on account of relaunching the Corona simulator.
--
-- _luaproc_ waits for all its processes to finish, rather than kill them outright. Long-running ones should therefore query this from time to time if
-- graceful early exits are desired. Furthermore, any infinite loop **must** use this, or Corona will hang on exit.
-- @function wants_to_close
-- @treturn boolean Is Lua trying to close?

--- (**WIP**) Wait until all events in a group are set.
-- @function wait_for_all_events
-- @tparam {string,...} events One or more names of events, cf. @{create_event}.
-- @tparam ?uint wait Milliseconds to wait, &ge; 0. When absent, the wait will never time out.
--
-- **N.B.** At the moment, this does not respect Corona's suspend and resume logic.
-- @return[1] **true**, indicating success.
-- @treturn[1] string First name in _events_.
-- @return[2] **"timeout"**, if _wait_ elapsed before all events were set.
-- @return[3] **false**, meaning failure.

--- (**WIP**) Wait until at least one event in a group is set.
-- @function wait_for_any_events
-- @tparam {string,...} events One or more names of events, cf. @{create_event}.
-- @tparam ?uint wait Milliseconds to wait, &ge; 0. When absent, the wait will never time out.
--
-- **N.B.** At the moment, this does not respect Corona's suspend and resume logic.
-- @return[1] **true**, indicating success.
-- @treturn[1] string Name of set event from _events_ with lowest index.
-- @return[2] **"timeout"**, if _wait_ elapsed before any event was set.
-- @return[3] **false**, meaning failure.

--- (**WIP**) Wait until an event is set.
-- @function wait_for_event
-- @string name Name of event, cf. @{create_event}.
-- @tparam ?uint wait Milliseconds to wait, &ge; 0. When absent, the wait will never time out.
--
-- **N.B.** At the moment, this does not respect Corona's suspend and resume logic.
-- @treturn ?|boolean|string If _wait_ elapsed before the event was set, **"timeout"** is returned.
--
-- Otherwise, returns a boolean indicating whether the wait succeeded.