# solar2d-plugins
Source for various [Solar2D](https://solar2d.com) plugins, both in Lua and C / C++.

Some of these are fairly mature, a few are in development, while others are abandoned or on hold.

## The list so far ##

* AssetReader (a thin veneer over [Android's asset management](https://developer.android.com/reference/android/content/res/AssetManager))
* Bytemap (original, but uses a bit of [stb](https://github.com/nothings/stb))
* cachestack (original, complements **eigen**)
* chips ([eponymous](https://github.com/floooh/chips))
* clipper ([eponymous](http://angusj.com/delphi/clipper.php))
* eigen ([eponymous](http://eigen.tuxfamily.org/index.php?title=Main_Page); WIP)
* FreeImage ([eponymous](http://freeimage.sourceforge.net); abandoned due to difficulty compiling on Android)
* impack (uses several bits of **stb**, many libraries from [Jon Olick](https://www.jonolick.com), [Spot](https://github.com/r-lyeh-archived/spot), [projectNe10](https://projectne10.github.io/Ne10/), [Accelerate](https://developer.apple.com/documentation/accelerate?language=objc), [SDF](https://github.com/memononen/SDF), [urraka's GIF code](https://gist.github.com/urraka/685d9a6340b26b830d49))
* ipc ([luaipc](https://github.com/siffiejoe/lua-luaipc), very slightly modified for use as a plugin)
* libtess2 ([eponymous](https://github.com/memononen/libtess2))
* luaffifb ([eponymous](https://github.com/facebookarchive/luaffifb); mostly usable on desktop, but fails at least one rather esoteric test on Mac)
* luaproc ([eponymous](https://github.com/askyrme/luaproc), plus [concurrentqueue](https://github.com/cameron314/concurrentqueue), [libcuckoo](https://github.com/efficient/libcuckoo), and [pevents](https://github.com/NeoSmart/PEvents); and of course **pthreads**)
* MemoryBlob (uses **libcuckoo**)
* morphing (some code from [here](https://cg.cs.tsinghua.edu.cn/people/~xianying/Papers/PoissonMVCs/index.html))
* mwc (adapts [code](https://www.math.uni-bielefeld.de/~sillke/ALGORITHMS/random/marsaglia-c) from George Marsaglia)
* msquares (from [par](https://github.com/prideout/par))
* nudge ([eponymous](https://github.com/rasmusbarr/nudge); on hold?)
* pagecurl (original)
* qu3e ([eponymous](https://github.com/RandyGaul/qu3e); on hold?)
* quaternion (original)
* serialize (uses [lpack](http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/#lpack), [lua-marshal](https://github.com/richardhundt/lua-marshal), and [struct](http://www.inf.puc-rio.br/~roberto/struct/))
* StableArray (original)
* streamlines (from **par**; WIP)
* tinyfiledialogs ([eponymous](https://sourceforge.net/projects/tinyfiledialogs/))
* truetype (uses **stb**'s `truetype` module)
* Blend2D ([eponymous](https://github.com/blend2d/blend2d); WIP)
* OAML ([Open Adaptive Music Engine](https://github.com/oamldev/oaml); WIP)
* Polylidar ([eponymous](https://github.com/JeremyBYU/polylidar); WIP)
* TheoraPlay ([eponymous](https://www.icculus.org/theoraplay/); WIP)
* gif (Uses the writer from Jon Olick and a more robust [GIFLib](https://sourceforge.net/projects/giflib/)-based implementation; WIP)
* mpeg (Uses the writer from Jon Olick and [pl_mpeg](https://github.com/phoboslab/pl_mpeg); WIP)
* webp (Aiming to give a better home to some "fast path" stuff from **impack**, now supplementing NYI features in **Bytemap**; WIP)

A few larger ones might be divvied up into more manageable sub-plugins.

## Some libraries used by more than one of the above ##

* Accelerate (beyond that used by **impack**)
* [ConcRT](docs.microsoft.com/en-us/cpp/parallel/concrt/concurrency-runtime)
* [DirectXMath](https://github.com/Microsoft/DirectXMath)
* [libdispatch](https://github.com/apple/swift-corelibs-libdispatch)
* [pthreads-win32](https://locklessinc.com/articles/pthreads_on_windows/)
* [XMath](https://github.com/Napoleon314/XMath) (might now be superfluous; **DirectXMath** required a newer C++ version than all targets could honor at the time)


## Under more or less serious consideration ##

Little or no code has gone into the following, but they might get some attention down the road.

* [cffi](https://github.com/q66/cffi-lua) as a better **luaffifb**
* [psd.c](https://github.com/hkrn/psd.c)
* [dmon](https://github.com/septag/dmon) **UPDATE** Implemented by [DannyGlover](https://github.com/DannyGlover)
* [iji2dgrid](https://github.com/incrediblejr/iji2dgrid); **stb** has something along these lines too
* [ExprTk](https://github.com/ArashPartow/exprtk); author has several other interesting libraries as well

### Audio ideas ###

Some of these would benefit from audio-style support in the tradition of "external textures".

* [libfmsynth](https://github.com/Themaister/libfmsynth)
* [Q](https://github.com/cycfi/Q)
* [libsoundio](https://github.com/andrewrk/libsoundio)
* [TinySoundFont](https://github.com/schellingb/TinySoundFont)
* [Soundpipe](https://github.com/PaulBatchelor/Soundpipe)
* [miniaudio](https://github.com/dr-soft/miniaudio)
* [Maximimilian](https://github.com/micknoise/Maximilian)
* [Pure Data](https://github.com/libpd/libpd)
* [liquid-dsp](https://github.com/jgaeddert/liquid-dsp)

### GUI ideas ###

* [nanovg](https://github.com/memononen/nanovg), needs stencil support
* [libagar](https://github.com/JulNadeauCA/libagar)
* [libui](https://github.com/andlabs/libui)
* [raygui](https://github.com/raysan5/raygui) **UPDATE** Under investigation by [DannyGlover](https://github.com/DannyGlover)
* [microui](https://github.com/rxi/microui)
* [lvgl](https://github.com/littlevgl/lvgl)
* [love-nuklear](https://github.com/keharriso/love-nuklear)
* [LURE](https://github.com/rdlaitila/LURE)

### Parser ideas ###

* [ddlt](https://github.com/leiradel/ddlt)
* [mpc](https://github.com/orangeduck/mpc)
* Need to compare those against [parser-gen](https://github.com/vsbenas/parser-gen), which seems to already be in Lua

### Satisfiability and theorem solver ideas ###

* [minisat](https://github.com/niklasso/minisat)
* [MiniZinc](https://github.com/MiniZinc/libminizinc)
* [Z3](https://github.com/Z3Prover/z3)

### Shape generator ideas ###

* [Generator](https://github.com/ilmola/generator)
* `par_shapes` from **par**
* `yocto_shape` in [yocto-gl](https://github.com/xelatihy/yocto-gl)

## Research ##

Other stuff that looked interesting.

Many things here probably aren't plugin material on their own, but might serve well for sourcing components and such.

There is FAR too much here to even review, much less implement. Some of this is just to jog ideas.

* [RSMotion](https://github.com/BasGeertsema/rsmotion)
* [MazuCC](https://github.com/jserv/MazuCC), [chibicc](https://github.com/rui314/chibicc), [CToy](https://github.com/anael-seghezzi/CToy)
* [asmjit](https://github.com/asmjit/asmjit)
* [MemoryModule](https://github.com/fancycode/MemoryModule), [loadlibrary](https://github.com/taviso/loadlibrary)
* [CTPL](https://github.com/vit-vit/CTPL), [jobxx](https://github.com/seanmiddleditch/jobxx), [cpp-taskflow](https://github.com/cpp-taskflow/cpp-taskflow), [px](https://github.com/pplux/px), [transwarp](https://github.com/bloomen/transwarp), [FiberTaskingLib](https://github.com/RichieSams/FiberTaskingLib), [ThreadPool](https://github.com/nbsdx/ThreadPool), [boson](https://github.com/duckie/boson), [oqpi](https://github.com/H-EAL/oqpi), [enkiTS](https://github.com/dougbinks/enkiTS), [libmill](https://github.com/sustrik/libmill), [checkedthreads](https://github.com/yosefk/checkedthreads), [libcsp](https://github.com/shiyanhui/libcsp)
* [RaftLib](https://github.com/RaftLib/RaftLib)
* [libnop](https://github.com/google/libnop)
* [subprocess](https://github.com/sheredom/subprocess.h), [tiny-process-library](https://github.com/eidheim/tiny-process-library) (possibly supersed by **luaipc** above)
* [lcpp](https://github.com/m-schmoock/lcpp), [CParser](https://github.com/facebookresearch/CParser)
* [AGS Fast Wave Function Collapse Plugin](https://github.com/ericoporto/agsfastwfc)
* [robust-predicates](https://github.com/mourner/robust-predicates)
* [xf8](https://github.com/skeeto/xf8)
* [blob](https://github.com/BlockoS/blob)
* [dj_fft](https://github.com/jdupuy/dj_fft), [Simple-FFT](https://github.com/d1vanov/Simple-FFT)
* [CLK](https://github.com/TomHarte/CLK), [x16 emulator](https://github.com/commanderx16/x16-emulator/)
* [luaproc-master](https://github.com/lmillanfdez/luaproc-master) and [https://github.com/fernando-ala/luaproc---messaging-tables-async-read](https://github.com/fernando-ala/luaproc---messaging-tables-async-read)
* [lua-mtmsg](https://github.com/osch/lua-mtmsg)
* [SuRF](https://github.com/efficient/SuRF)
* [Nodable](https://github.com/berdal84/Nodable)
* [SplineLibrary](https://github.com/ejmahler/SplineLibrary), [SplineLib](https://github.com/andrewwillmott/splines-lib), [tinyspline](https://github.com/msteinbeck/tinyspline)
* [nanoflann](https://github.com/jlblancoc/nanoflann), [annoy](https://github.com/spotify/annoy)
* [sse2neon](https://github.com/jratcliff63367/sse2neon), [ARM_NEON_2_x86_SSE](https://github.com/intel/ARM_NEON_2_x86_SSE), [simde](https://github.com/nemequ/simde)
* [geometry-central](https://github.com/nmwsharp/geometry-central), [cinolib](https://github.com/mlivesu/cinolib), [c.thi.ng](https://github.com/thi-ng/c-thing), [libhedra](https://github.com/avaxman/libhedra), [libigl](https://github.com/libigl/libigl); see also [Geometric Tools](https://www.geometrictools.com)
* [TriWild](https://github.com/wildmeshing/TriWild)
* [timeout](https://github.com/wahern/timeout), [Ratas](https://github.com/jsnell/ratas)
* [tinn](https://github.com/glouw/tinn), [tiny-dnn](https://github.com/tiny-dnn/tiny-dnn)
* [Mesh](https://github.com/plasma-umass/Mesh)
* [UVAtlas](https://github.com/microsoft/UVAtlas), [k15_image_atlas](https://github.com/FelixK15/k15_image_atlas)
* [GameNetworkingSockets](https://github.com/ValveSoftware/GameNetworkingSockets)
* [SharedHashFile](https://github.com/simonhf/sharedhashfile)
* [taco](https://github.com/tensor-compiler/taco)
* [poisson_blend](https://github.com/Erkaman/poisson_blend)
* [light2d](https://github.com/miloyip/light2d)
* [cr](https://github.com/fungos/cr)
* [succinct](https://github.com/ot/succinct), [klib](https://github.com/attractivechaos/klib)
* [immer](https://github.com/arximboldi/immer), [Immutable++](https://github.com/rsms/immutable-cpp)
* [ConcurrencyFreaks](https://github.com/pramalhe/ConcurrencyFreaks), [pctl](https://github.com/deepsea-inria/pctl), [Junction](https://github.com/preshing/junction), [libcds](https://github.com/khizmax/libcds), [xenium](https://github.com/mpoeter/xenium)
* [Thrust](https://github.com/thrust/thrust)
* [libs](https://github.com/mattiasgustavsson/libs), [cute_headers](https://github.com/RandyGaul/cute_headers)
* [iEngine](https://github.com/xxfast/iEngine), [FuzzyBrain](https://github.com/pablosproject/FuzzyBrain), [pomagma](https://github.com/fritzo/pomagma), [fuzzy](https://github.com/soulik/fuzzy), [clipsmm](https://github.com/timn/clipsmm)
* [hashids.lua](https://github.com/leihog/hashids.lua)
* [squash](https://github.com/quixdb/squash), [Bundle](https://github.com/r-lyeh-archived/bundle)
* [crunch](https://github.com/BinomialLLC/crunch)
* [acl](https://github.com/nfrechette/acl)
* [ik](https://github.com/TheComet/ik)
* [tinygizmo](https://github.com/ddiakopoulos/tinygizmo)
* [layout](https://github.com/randrew/layout), [Amoeba](https://github.com/starwing/amoeba), [Cassowary](https://github.com/sile-typesetter/cassowary.lua)
* [Slang](https://github.com/shader-slang/slang), [GLSL Optimizer](https://github.com/aras-p/glsl-optimizer), [HLSLParser](https://github.com/Thekla/hlslparser), [glsl-parser](https://github.com/graphitemaster/glsl-parser), [hlslparser](https://github.com/unknownworlds/hlslparser), [HLSLCrossCompiler](https://github.com/James-Jones/HLSLCrossCompiler)
* [cjellyfish](https://github.com/jamesturk/cjellyfish), [lua-bk-tree](https://github.com/profan/lua-bk-tree)
* [msdfgen](https://github.com/Chlumsky/msdfgen)
* [nbind](https://github.com/charto/nbind)
* [Remotery](https://github.com/Celtoys/Remotery)
* [renderdoc](https://github.com/baldurk/renderdoc), [apitrace](https://github.com/apitrace/apitrace)

## Licenses ##

Everything original to this repository falls under the MIT license.
