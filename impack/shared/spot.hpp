/* Handy pixel/color and texture/image classes. zlib/libpng licensed.
 * - rlyeh ~~ listening to Twilightning - Painting the blue eyes
 *
 * Check spot.cpp for a @todo list.
 *
 * API overview {
 *      using unit = color/pixel abstraction;
 *      using rect = std::vector< unit = pixel or color >;
 *
 *      using pixel   = unit<unsigned char>;              //       32 bpp, RGBA space, integer based       , valid range [0..255], clamp range [0..255]
 *      using texture = rect<pixel>;                      //       32 bpp, RGBA space
 *
 *      using color   = unit<float>;                      // hdr, 128 bpp, HSLA space, floating-point based, valid range [-N...N], clamp range [0..1]
 *      using image   = rect<color>;                      // hdr, 128 bpp, HSLA space
 * }
*/

#pragma once

#define SPOT_VERSION "2.1.3" /* (2016/07/01) - ccz loading and saving support (pvr.ccz); bump soil2 and stb_image
#define SPOT_VERSION "2.1.2" // (2016/02/04) - flif and exr loading support
#define SPOT_VERSION "2.1.1" // (2016/02/01) - update nanosvg; add small optimizations
#define SPOT_VERSION "2.1.0" // (2015/09/28) - faster image pasting
#define SPOT_VERSION "2.0.9" // (2015/05/12) - safer decoding on invalid images
#define SPOT_VERSION "2.0.8" // (2015/05/07) - faster etc1 encoding on low quality settings (using custom etcpak library)
#define SPOT_VERSION "2.0.7" // (2015/05/06) - stb image library defined as static (fixes multiple symbol definitions in large projects)
#define SPOT_VERSION "2.0.7" // (2015/05/06) - upgraded tools
#define SPOT_VERSION "2.0.6" // (2015/05/05) - print() method added
#define SPOT_VERSION "2.0.5" // (2015/04/27) - pvrtc encoder: c++0x support
#define SPOT_VERSION "2.0.4" // (2015/04/27) - fixed etc1 encoder
#define SPOT_VERSION "2.0.4" // (2015/04/27) - fixed ya()/a() vector size
#define SPOT_VERSION "2.0.3" // (2015/04/24) - pvrtc encoder
#define SPOT_VERSION "2.0.2" // (2015/04/23) - better ktx/pvr3 file support
#define SPOT_VERSION "2.0.2" // (2015/04/23) - pvrtc decode stream support
#define SPOT_VERSION "2.0.2" // (2015/04/23) - android support (again)
#define SPOT_VERSION "2.0.2" // (2015/04/23) - increased tests
#define SPOT_VERSION "2.0.1" // (2015/04/23) - bugfixed monochromatic images
#define SPOT_VERSION "2.0.0" // (2015/04/22) - etc1 encode/decode stream support
#define SPOT_VERSION "2.0.0" // (2015/04/22) - pvr3/ktx/pkm load/save file support
#define SPOT_VERSION "2.0.0" // (2015/04/22) - a few optimizations
#define SPOT_VERSION "1.0.0" // (2014/xx/xx) - initial commit */

#include <stddef.h>
#include <string.h>
#include <stdint.h>
#include <algorithm>
#include <fstream>
#include <map>
#include <queue>
#include <string>
#include <utility>
#include <vector>

// i hate people (wingdi.h) {
#ifdef RGB
#undef RGB
#endif
// }

//#include "redist/deps/vector_view.hpp"

void GetNow (void);
void AddLapse (int id);
void ShowLapses (void);
void Enable (bool bEnable);

namespace spot
{
    extern bool devel;

    enum {
        SPOT_FAST_QUALITY = 10,
        SPOT_DEFAULT_QUALITY = 90
    };

    namespace internals {
        std::string encode_png( unsigned w, unsigned h, const void *data, unsigned stride  );
        std::string encode_jpg( unsigned w, unsigned h, const void *data, unsigned quality );
        std::string encode_pug( unsigned w, unsigned h, const void *data, unsigned quality );
        std::string encode_wbp( unsigned w, unsigned h, const void *data, unsigned quality );
        std::string encode_ktx( unsigned w, unsigned h, const void *data, unsigned quality );
        std::string encode_pvr( unsigned w, unsigned h, const void *data, unsigned quality );
        std::string encode_ccz( unsigned w, unsigned h, const void *data, unsigned quality );
        std::string encode_pkm( unsigned w, unsigned h, const void *data, unsigned quality );
        bool writefile( const std::string &filename, const std::string &data );
    }

    enum texel_formats {
        RGB_888,
        RGBA_8888,
        RGB_ETC1,
        //RGB_565
        //RGBA_5551
        RGB_888F,
        RGBA_8888F,
    };

    struct stream {
        int w, h, d, fmt;
        union {
            const void *in;
            void *out;
        };
        unsigned len;
        int hint, comp, deleter;
        std::string error;

        bool is_valid() const;
        bool is_compressed() const;
        bool is_etc1() const;
        bool is_pvrtc() const;
    };

    // STEVE CHANGE
    struct ExternalMemory {
        enum { eBypassFiltering = 1 << 0, eNoFancyUpsampling = 1 << 1, ePremultiply = 1 << 2 };
        enum { eWasPremultiplied = 1 << 0, eWasUsed = 1 << 1 };

        std::vector<unsigned char> * mRGBA;
        int mFlags{0}, mStatus{0};

        static void Bind (ExternalMemory * memory);
        static ExternalMemory * GetBinding (void);
    };

	enum { eLoadNone, eLoadFailed, eExternalLoad };

	void SetLoadResult (int result);
	int GetLoadResult (void);
    // /STEVE CHANGE
    
    int write_bmp( char const *filename, int w, int h, int comp, const void *data );
    int write_dds( char const *filename, int w, int h, int comp, const void *data );
    int write_tga( char const *filename, int w, int h, int comp, const void *data );

    bool info( stream &nfo, const void *data, size_t len );
    bool infof( stream &nfo, const void *data, size_t len );
    bool decode( stream &dst, const stream &src );
    bool decodef( stream &dst, const stream &src );

    std::vector<unsigned char> decode8(
        const void *ptr, size_t size,
        size_t *w = 0, size_t *h = 0, size_t *comp = 0, std::string *error = 0 );

    std::vector<unsigned char> decode8(
        const std::string &filename,
        size_t *w = 0, size_t *h = 0, size_t *comp = 0, std::string *error = 0 );

    std::vector<unsigned int> decode32(
        const void *ptr, size_t size,
        size_t *w = 0, size_t *h = 0, size_t *comp = 0, std::string *error = 0 );

    std::vector<unsigned int> decode32(
        const std::string &filename,
        size_t *w = 0, size_t *h = 0, size_t *comp = 0, std::string *error = 0 );

    std::vector<float> decodef(
        const void *ptr, size_t size,
        size_t *w = 0, size_t *h = 0, size_t *comp = 0, std::string *error = 0 );

    std::vector<float> decodef(
        const std::string &filename,
        size_t *w = 0, size_t *h = 0, size_t *comp = 0, std::string *error = 0 );

    std::vector<std::string> list_supported_inputs();
    std::vector<std::string> list_supported_outputs();

    void hsl2rgb( const float *hsl, float *rgb );
    void rgb2hsl( const float *rgb, float *hsl );

    union color;

    union pixel {
        typedef unsigned char T;

        enum { empty = 0, fill = 255 };

        unsigned int rgba;     // packed
        struct { T r,g,b,a; }; // components
        struct { T x,y,z,w; }; // aliases
        T array[4];            // array access

        pixel() : r(0),g(0),b(0),a(0)
        {}

        pixel( float r, float g, float b, float a ) : r(T(r)),g(T(g)),b(T(b)),a(T(a)) // <- STEVE CHANGE
        {}

        pixel clamp() const {
            return *this;
        }
        pixel to_rgba() const {
            return *this;
        }
        pixel to_hsla() const {
            const float inv = 1.f / 255.f;
            float rgb[3] = { r * inv, g * inv, b * inv };
            float hsl[3];
            rgb2hsl( rgb, hsl );
            return pixel( hsl[0] * 255.f, hsl[1] * 255.f, hsl[2] * 255.f, a );
        }

        // array access

        T& operator[]( int i ) {
            return array[ i & 3 ];
        }
        const T& operator[]( int i ) const {
            return array[ i & 3 ];
        }

        // conversion

        operator color() const;
    };

    union color
    {
        typedef float T;

        enum { empty = 0, fill = 1 };

        struct { T h,s,l,a; }; // components
        struct { T x,y,z,w; }; // aliases
        T array[4];            // array access

        color() : h(0),s(0),l(0),a(0)
        {}

        color( float h, float s, float l, float a ) : h(h), s(s), l(l), a(a)
        {}

        // array access

        T& operator[]( int i ) {
            return array[ i & 3 ];
        }
        const T& operator[]( int i ) const {
            return array[ i & 3 ];
        }

        // conversion

        operator pixel() const {
            color c = this->clamp().to_rgba();
            return pixel(c.h * 255, c.s * 255, c.l * 255, c.a * 255);
        }

        // color algebra

        color operator *( const color &other ) const {
            return color( h * other.h, s * other.s, l * other.l, a * other.a );
        }
        color operator /( const color &other ) const {
            return color( h / other.h, s / other.s, l / other.l, a / other.a );
        }
        color operator +( const color &other ) const {
            return color( h + other.h, s + other.s, l + other.l, a + other.a );
        }
        color operator -( const color &other ) const {
            return color( h - other.h, s - other.s, l - other.l, a - other.a );
        }

        color &operator *=( const color &other ) {
            *this = operator*( other );
            return *this;
        }
        color &operator /=( const color &other ) {
            *this = operator/( other );
            return *this;
        }
        color &operator +=( const color &other ) {
            *this = operator+( other );
            return *this;
        }
        color &operator -=( const color &other ) {
            *this = operator-( other );
            return *this;
        }

        color operator *( const T &other ) const {
            return *this * color( other, other, other, other );
        }
        color operator /( const T &other ) const {
            return *this / color( other, other, other, other );
        }
        color operator +( const T &other ) const {
            return *this + color( other, other, other, other );
        }
        color operator -( const T &other ) const {
            return *this - color( other, other, other, other );
        }

        color &operator *=( const T &other ) {
            return *this *= color( other, other, other, other );
        }
        color &operator /=( const T &other ) {
            return *this /= color( other, other, other, other );
        }
        color &operator +=( const T &other ) {
            return *this += color( other, other, other, other );
        }
        color &operator -=( const T &other ) {
            return *this -= color( other, other, other, other );
        }

        //

        color clamp() const {
            color result;
            result.h = ( h >= 1.f ? 1.f : ( h <= 0.f ? 0.f : h ) );
            result.s = ( s >= 1.f ? 1.f : ( s <= 0.f ? 0.f : s ) );
            result.l = ( l >= 1.f ? 1.f : ( l <= 0.f ? 0.f : l ) );
            result.a = ( a >= 1.f ? 1.f : ( a <= 0.f ? 0.f : a ) );
            return result;
        }
        color to_rgba() const {
            const float hsl[3] = { h, s, l };
            float rgb[3];
            hsl2rgb( hsl, rgb );
            return color( rgb[0], rgb[1], rgb[2], a );
        }
        color to_hsla() const {
            return *this;
        }

        color premultiply() const {
            return color( h * a, s * a, l * a, a );
        }
        color unpremultiply() const {
            return color( h / a, s / a, l / a, a );
        }
    };

    // color-space aliases

    static color hsla() {
        return color( 0, 0, 0, 0 );
    }
    static color hsla( float h, float s, float l, float a = 1.f ) {
        return color( h, s, l, a );
    }

    static pixel rgba() {
        return pixel( 0, 0, 0, 0 );
    }
    static pixel rgba( float r, float g, float b, float a = 1.f ) {
        return pixel( r, g, b, a );
    }

    static pixel bgra() { return rgba(); }
    static pixel bgra( float b, float g, float r, float a = 1.f ) { return rgba(r,g,b,a); }

    // uppercase aliases
    static color HSLA() { return hsla(); }
    static color HSLA( float h, float s, float l, float a = 1.f ) { return hsla(h,s,l,a); }
    static pixel RGBA() { return rgba(); }
    static pixel RGBA( float r, float g, float b, float a = 1.f ) { return rgba(r,g,b,a); }
    static pixel BGRA() { return rgba(); }
    static pixel BGRA( float b, float g, float r, float a = 1.f ) { return rgba(r,g,b,a); }

    // more aliases
    static color hsl() { return hsla(); }
    static color HSL() { return hsla(); }
    static color hsl( float h, float s, float l ) { return hsla(h,s,l); }
    static color HSL( float h, float s, float l ) { return hsla(h,s,l); }

    static pixel rgb() { return rgba(); }
    static pixel RGB() { return rgba(); }
    static pixel rgb( float r, float g, float b ) { return rgba(r,g,b); }
    static pixel RGB( float r, float g, float b ) { return rgba(r,g,b); }

    static pixel bgr() { return rgba(); }
    static pixel BGR() { return rgba(); }
    static pixel bgr( float b, float g, float r ) { return rgba(r,g,b); }
    static pixel BGR( float b, float g, float r ) { return rgba(r,g,b); }

    enum { SPACE_RGBA = 0, SPACE_HSLA = 1 };

    template<typename unit>
    class rect : public std::vector<unit> {
        public:
// STEVE CHANGE
		std::string mError;
// /STEVE CHANGE
        unsigned id;   // may be used with your engine, texture/resource ID maybe?
        float delay;   // may be used with your engine, frame delay (when loading an animation)
        size_t w, h, d;
        int space;

        rect( size_t w = 0, size_t h = 0, size_t d = 0, const unit &filler = unit() ) :
            id(0), delay(0), w(w), h(h), d(d), space(SPACE_RGBA),
            std::vector<unit>(w*(h?h:1)*(d?d:1),filler)
			, mError() // <- STEVE CHANGE
        {}

        bool loaded() const {
            return !this->empty();
        }

        // unit/subunit accesors

        // 1d manipulation

        inline unit &at( size_t offset ) {
            return this->std::vector<unit>::operator[]( offset );
        }
        inline unit &atf( float x01 ) {
            return this->at( size_t(x01 * (w-1)) ); // <- STEVE CHANGE
        }
        inline const unit &at( size_t offset ) const {
            return this->std::vector<unit>::operator[]( offset );
        }
        inline const unit &atf( float x01 ) const {
            return this->at( size_t(x01 * (w-1)) ); // <- STEVE CHANGE
        }

        // [...] copy, paste...

        // 3d manipulation

        inline unit &at( size_t x, size_t y, size_t z ) {
            return this->std::vector<unit>::operator[]( x + y * w + z * w * h );
        }
        inline unit &atf( float x01, float y01, float z01 ) {
            return this->at( size_t(x01 * (w-1)), size_t(y01 * (h-1)), size_t(z01 * (d-1)) ); // <- STEVE CHANGE
        }
        inline const unit &at( size_t x, size_t y, size_t z ) const {
            return this->std::vector<unit>::operator[]( x + y * w + z * w * h );
        }
        inline const unit &atf( float x01, float y01, float z01 ) const {
            return this->at( size_t(x01 * (w-1)), size_t(y01 * (h-1)), size_t(z01 * (d-1)) ); // <- STEVE CHANGE
        }

        // [...] copy, paste...

        // 2d manipulation

        inline unit &at( size_t x, size_t y ) {
            return this->std::vector<unit>::operator[]( x + y * w );
        }
        inline unit &atf( float x01, float y01 ) {
            return this->at( size_t(x01 * (w-1)), size_t(y01 * (h-1)) ); // <- STEVE CHANGE
        }
        inline const unit &at( size_t x, size_t y ) const {
            return this->std::vector<unit>::operator[]( x + y * w );
        }
        inline const unit &atf( float x01, float y01 ) const {
            return this->at( size_t(x01 * (w-1)), size_t(y01 * (h-1)) ); // <- STEVE CHANGE
        }

        rect copy( size_t ox, size_t oy, size_t w = ~0, size_t h = ~0, size_t d = ~0 ) const {
            if( w == ~0 ) w = this->w - ox;
            if( h == ~0 ) h = this->h - oy;

            rect pic( w, h );
            pic.delay = delay;
            pic.space = space;

            for( size_t i = 0, y = 0 ; y < h; ++y )
                for( size_t x = 0; x < w; ++x, ++i )
                    pic.at( i ) = this->at( ox + x, oy + y );

            return pic;
        }

        void paste( rect &pic, size_t at_x, size_t at_y, const rect &other ) const {
            pic.delay = delay;
            pic.space = space;

            for( size_t y = 0, i = 0 ; y < other.h; ++y )
                for( size_t x = 0; x < other.w; ++x, ++i )
                    pic.at( at_x + x, at_y + y ) = other.at( i );
        }

        rect paste( size_t at_x, size_t at_y, const rect &other ) const {
            rect pic = *this;
            pic.delay = delay;
            pic.space = space;
            return paste( pic, at_x, at_y, other ), pic;
        }

        rect crop( size_t left, size_t right, size_t top, size_t bottom ) const { // each param is number of row/cols to crop
            return copy( left, top, this->w - (left + right), this->h - (top + bottom) );
        }

        rect flip_w() const {
            rect pic( w, h );
            pic.resize(0);
            pic.delay = delay;
            pic.space = space;

            for( size_t y = 0; y < h; ++y ) {
                for( int x = w - 1 ; x >= 0; --x ) {
                    pic.push_back( at(x,y) );
                }
            }
            return pic;
        }

        rect flip_h() const {
            rect pic( w, h );
            pic.resize(0);
            pic.delay = delay;
            pic.space = space;

            for( int y = h-1; y >= 0; --y ) {
                for( size_t x = 0; x < w; ++x ) {
                    pic.push_back( at(x,y) );
                }
            }
            return pic;
        }

        rect rotate_left() const {
            rect pic( h, w );
            pic.resize(0);
            pic.delay = delay;
            pic.space = space;

            for( int x = w - 1; x >= 0; --x ) {
                for( size_t y = 0; y < h; ++y ) {
                    pic.push_back( at(x,y) );
                }
            }
            return pic;
        }

        rect rotate_right() const {
            rect pic( h, w );
            pic.resize(0);
            pic.delay = delay;
            pic.space = space;

            for( size_t x = 0; x < w; ++x ) {
                for( int y = h - 1; y >= 0; --y ) {
                    pic.push_back( at(x,y) );
                }
            }
            return pic;
        }

        // pixel-space conversions

        rect clamp() const {
            rect pic( w, h );
            pic.resize( 0 );
            pic.delay = delay;
            pic.space = space;

            for( const auto &it : *this ) {
                pic.push_back( it.clamp() );
            }
            return pic;
        }

        rect to_hsla() const {
            if( space == SPACE_HSLA ) {
                return *this;
            }

            rect pic( w, h );
            pic.resize( 0 );
            pic.delay = delay;
            pic.space = SPACE_HSLA;

            for( const auto &it : *this ) {
                pic.push_back( it.to_hsla() );
            }
            return pic;
        }

        rect to_rgba() const {
            if( space == SPACE_RGBA ) {
                return *this;
            }

            rect pic( w, h );
            pic.resize( 0 );
            pic.delay = delay;
            pic.space = SPACE_RGBA;

            for( const auto &it : *this ) {
                pic.push_back( it.to_rgba() );
            }
            return pic;
        }

        // image algebra

        rect operator *( const unit &other ) const {
            rect that = *this;
            that.delay = delay;

            for( auto &it : that ) {
                it *= other;
            }
            return that;
        }

        rect operator /( const unit &other ) const {
            rect that = *this;
            that.delay = delay;

            for( auto &it : that ) {
                it /= other;
            }
            return that;
        }

        rect operator +( const unit &other ) const {
            rect that = *this;
            that.delay = delay;

            for( auto &it : that ) {
                it += other;
            }
            return that;
        }

        rect operator -( const unit &other ) const {
            rect that = *this;
            that.delay = delay;

            for( auto &it : that ) {
                it -= other;
            }
            return that;
        }

        rect &operator *=( const unit &other ) {
            for( auto &it : *this ) { // <- STEVE CHANGE
                it *= other;
            }
            return *this;
        }

        rect &operator /=( const unit &other ) {
            for( auto &it : *this ) { // <- STEVE CHANGE
                it /= other;
            }
            return *this;
        }

        rect &operator +=( const unit &other ) {
            for( auto &it : *this ) { // <- STEVE CHANGE
                it += other;
            }
            return *this;
        }

        rect &operator -=( const unit &other ) {
            for( auto &it : *this ) { // <- STEVE CHANGE
                it -= other;
            }
            return *this;
        }

        // import/export

        bool load( const void *ptr, size_t len) {
            size_t comp;AddLapse(11100);
            /*std::string*/mError = image_load( (const unsigned char *)ptr, len, &w, &h, &comp, *this ); // <- STEVE CHANGE
			AddLapse(11111);
            return mError.empty() ? true : false; // <- STEVE CHANGE
        }

        bool load( const std::string &pathfile) {
			AddLapse(11000);
            if( pathfile.empty() ) {
				mError = "Error! empty filename"; // <- STEVE CHANGE
                return /*"Error! empty filename",*/ false;
            }AddLapse(11001);
            std::ifstream ifs( pathfile.c_str(), std::ios::binary );
            if( !ifs.good() ) {
				mError = "Error! unable to read file: " + pathfile; // <- STEVE CHANGE
                return /*"Error! unable to read file: " + pathfile*/ false;
            }AddLapse(11002);
			// STEVE CHANGE
//            std::vector<char> buffer( (std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
			ifs.seekg(0, ifs.end);

			size_t size = (size_t)int(ifs.tellg());

			std::vector<char> buffer; // ?? MSVC complaining about constructor...

			buffer.resize(size); // ...so I resize

			ifs.seekg(0, ifs.beg);
			ifs.read(buffer.data(), size);
			// /STEVE CHANGE
			AddLapse(11003);
            return load( buffer.data(), buffer.size() );
        }

        bool load_hdr( const void *ptr, size_t len) {
            size_t comp;
            /*std::string*/mError = image_load_hdr( (const unsigned char *)ptr, len, &w, &h, &comp, *this ); // <- STEVE CHANGE
            return mError.empty() ? true : false; // <- STEVE CHANGE
        }

        bool load_hdr( const std::string &pathfile) {
            if( pathfile.empty() ) {
				mError = "Error! empty filename"; // <- STEVE CHANGE
                return /*"Error! empty filename",*/ false;
            }
            std::ifstream ifs( pathfile.c_str(), std::ios::binary );
            if( !ifs.good() ) {
				mError = "Error! unable to read file: " + pathfile; // <- STEVE CHANGE
                return /*"Error! unable to read file: " + pathfile*/ false;
            }
            std::vector<char> buffer( (std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
            return load_hdr( buffer.data(), buffer.size() );
        }
		// STEVE CHANGE
		std::string GetExtension (const std::string & filename)
		{
			std::string ext = filename.substr(filename.find_last_of('.') + 1);

            if (ext == filename) return std::string();

			else
			{
                for (auto & ch : ext) if (ch >= 'A' && ch <= 'Z') ch = ch - 'A' + 'a';

				return ext;
			}
		}
		// /STEVE CHANGE
        bool save( const std::string &filename, unsigned quality = SPOT_DEFAULT_QUALITY ) {
            std::string ext = filename.substr( filename.find_last_of('.') + 1 );
            if( ext != filename ) {
                for( auto &ch : ext ) if( ch >= 'A' && ch <= 'Z' ) ch = ch - 'A' + 'a';
                if( ext == "bmp" ) return save_as_bmp( filename );
                if( ext == "dds" ) return save_as_dds( filename );
                if( ext == "tga" ) return save_as_tga( filename );
                if( ext == "png" ) return save_as_png( filename );
                if( ext == "jpg" ) return save_as_jpg( filename, quality );
                if( ext == "pug" ) return save_as_pug( filename, quality );
                if( ext == "ktx" ) return save_as_ktx( filename, quality );
                if( ext == "pvr" ) return save_as_pvr( filename, quality );
                if( ext == "ccz" ) return save_as_ccz( filename, quality );
                if( ext == "pkm" ) return save_as_pkm( filename, quality );
                if( ext == "webp") return save_as_webp( filename, quality );
            }
            return false;
        }

        bool save_as_bmp( const std::string &filename ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            std::vector<unsigned char> pixels = rgba();
            return ( write_bmp( filename.c_str(), w, h, 4, &pixels[0] ) != 0 );
        }

        bool save_as_dds( const std::string &filename ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            std::vector<unsigned char> pixels = rgba();
            return ( write_dds( filename.c_str(), w, h, 4, &pixels[0] ) != 0 );
        }

        bool save_as_tga( const std::string &filename ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            std::vector<unsigned char> pixels = rgba();
            return ( write_tga( filename.c_str(), w, h, 4, &pixels[0] ) != 0 );
        }

        std::string encode_as_png( unsigned stride = 4 ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels;
            switch( stride ) {
                default: case 4: pixels = rgba();
                break;   case 3: pixels = rgb();
                break;   case 2: pixels = ya();
                break;   case 1: pixels = a();
            }
            return internals::encode_png( w, h, &pixels[0], stride );
        }

        bool save_as_png( const std::string &filename, unsigned stride = 4 ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_png( stride ) );
        }

        std::string encode_as_jpg( unsigned quality = SPOT_DEFAULT_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels = rgba();
            return internals::encode_jpg( w, h, &pixels[0], quality );
        }

        bool save_as_jpg( const std::string &filename, unsigned quality = SPOT_DEFAULT_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_jpg( quality ) );
        }

        std::string encode_as_pug( unsigned quality = SPOT_DEFAULT_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels = rgba();
            return internals::encode_pug( w, h, &pixels[0], quality );
        }

        bool save_as_pug( const std::string &filename, unsigned quality = SPOT_DEFAULT_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_pug( quality ) );
        }

        std::string encode_as_webp( unsigned quality = SPOT_DEFAULT_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels = rgba();
            return internals::encode_wbp( w, h, &pixels[0], quality );
        }

        bool save_as_webp( const std::string &filename, unsigned quality = SPOT_DEFAULT_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_webp( quality ) );
        }

        std::string encode_as_ktx( unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels = rgba();
            return internals::encode_ktx( w, h, &pixels[0], quality );
        }

        bool save_as_ktx( const std::string &filename, unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_ktx( quality ) );
        }

        std::string encode_as_pvr( unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels = bgra();
            return internals::encode_pvr( w, h, &pixels[0], quality );
        }

        bool save_as_pvr( const std::string &filename, unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_pvr( quality ) );
        }

        std::string encode_as_ccz( unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels = bgra();
            return internals::encode_ccz( w, h, &pixels[0], quality );
        }

        bool save_as_ccz( const std::string &filename, unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_ccz( quality ) );
        }

        std::string encode_as_pkm( unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return std::string();
            }
            std::vector<unsigned char> pixels = rgba();
            return internals::encode_pkm( w, h, &pixels[0], quality );
        }

        bool save_as_pkm( const std::string &filename, unsigned quality = SPOT_FAST_QUALITY ) const {
            if( this->empty() || w * h <= 0 ) {
                return false;
            }
            return internals::writefile( filename, encode_as_pkm( quality ) );
        }

        // helpers

        template<typename COLOR>
        std::string image_load( const unsigned char *ptr, size_t size, size_t *w, size_t *h, size_t *comp, std::vector<COLOR> &image )
        {
            std::string error;
            std::vector<unsigned char> data = spot::decode8( ptr, size, w, h, comp, &error );

            if (GetLoadResult() == eExternalLoad) return std::string(); // <- STEVE CHANGE
            if (error.size()) {
                return error;
            }
            if (data.empty()) {
				SetLoadResult(eLoadFailed);

                return "failed to decode image";
            }

            image.resize( (*w) * (*h) );

            const unsigned char *data8( data.data() );

            if( *comp == 3 )
            for( size_t i = 0, e = image.size(); i < e; ++i ) {
                unsigned char r = *data8++;
                unsigned char g = *data8++;
                unsigned char b = *data8++;
            //    image.at(i) = pixel( r, g, b, 255 ); // <- STEVE CHANGE
                image[i] = pixel(r, g, b, 255); // <- STEVE CHANGE
            }

            if( *comp == 4 )
            for( size_t i = 0, e = image.size(); i < e; ++i ) {
                unsigned char r = *data8++;
                unsigned char g = *data8++;
                unsigned char b = *data8++;
                unsigned char a = *data8++;
            //    image.at(i) = pixel( r, g, b, a ); // <- STEVE CHANGE
                image[i] = pixel(r, g, b, a); // <- STEVE CHANGE
            }

            return std::string();
        }

        template<typename COLOR>
        std::string image_load_hdr( const unsigned char *ptr, size_t size, size_t *w, size_t *h, size_t *comp, std::vector<COLOR> &image )
        {
            std::string error;
            std::vector<float> data = spot::decodef( ptr, size, w, h, comp, &error );

            if (error.size()) {
                return error;
            }
            if (data.empty()) {
                return "failed to decode image";
            }

            image.resize( (*w) * (*h) );

            const float *dataf( data.data() );

            if( *comp == 3 )
            for( size_t i = 0, e = image.size(); i < e; ++i ) {
                float r = *dataf++;
                float g = *dataf++;
                float b = *dataf++;
                image.at(i) = color( r, g, b, 1 );
            }

            if( *comp == 4 )
            for( size_t i = 0, e = image.size(); i < e; ++i ) {
                float r = *dataf++;
                float g = *dataf++;
                float b = *dataf++;
                float a = *dataf++;
                image.at(i) = color( r, g, b, a );
            }

            return std::string();
        }

        // debug 2d

        std::vector<unsigned char> rgba() const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h * 4 ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.r );
                pixels.push_back( p.g );
                pixels.push_back( p.b );
                pixels.push_back( p.a );
            }
            return pixels;
        }

        std::vector<unsigned char> bgra() const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h * 4 ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.b );
                pixels.push_back( p.g );
                pixels.push_back( p.r );
                pixels.push_back( p.a );
            }
            return pixels;
        }

        std::vector<unsigned char> rgbx( unsigned char x ) const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h * 4 ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.r );
                pixels.push_back( p.g );
                pixels.push_back( p.b );
                pixels.push_back( x );
            }
            return pixels;
        }

        std::vector<unsigned char> bgrx( unsigned char x ) const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h * 4 ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.b );
                pixels.push_back( p.g );
                pixels.push_back( p.r );
                pixels.push_back( x );
            }
            return pixels;
        }

        std::vector<unsigned char> rgb() const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h * 3 ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.r );
                pixels.push_back( p.g );
                pixels.push_back( p.b );
            }
            return pixels;
        }

        std::vector<unsigned char> bgr() const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h * 3 ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.b );
                pixels.push_back( p.g );
                pixels.push_back( p.r );
            }
            return pixels;
        }

        std::vector<unsigned char> y() const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( (unsigned char)((p.r+p.g+p.b)/3) );
            }
            return pixels;
        }

        std::vector<unsigned char> ya() const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h * 2 ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( (p.r+p.g+p.b)/3 );
                pixels.push_back( p.a );
            }
            return pixels;
        }

        std::vector<unsigned char> a() const {
            rect temp = this->to_rgba();

            std::vector<unsigned char> pixels( w * h ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.a );
            }
            return pixels;
        }

        std::vector<unsigned int> rgba32() const {
            rect temp = this->to_rgba();

            std::vector<unsigned int> pixels( w * h ); pixels.resize(0);
            for( auto &px : temp ) {
                pixel p = px;
                pixels.push_back( p.rgba );
            }
            return pixels;
        }

        // filters

        rect blank( bool enabled = true ) const {
            if( !enabled ) {
                return *this;
            }
            rect pic = *this;
            for( auto &px : pic ) {
                if( px.x + px.y + px.z + px.a ) {
                    px = hsla( 0, 0, 1, px.a );
                }
            }
            return pic;
        }

        rect checkered( bool enabled = true ) const {
            if( !enabled ) {
                return *this;
            }
            // check pattern that covers whole rect.
            rect pic( this->w, this->h );
            // cell size is 10% of rect, check pattern is 10 cells wide.
            int cell_size = this->w / 10;//* 0.10f; // <- STEVE CHANGE
            for( size_t y = 0; y < pic.h; ++y ) {
                for( size_t x = 0; x < pic.w; ++x ) {
                    int xc = x / cell_size;
                    int yc = y / cell_size;
                    float light = 0.5f + 0.5f * (( xc % 2 ) ^ ( yc % 2 ));
                    pic.at(x,y) = hsla( 0.f, 0.f, light, 1.f );
                }
            }
            // blend rect
            for( size_t p = 0, pend = this->size(); p < pend; ++p ) {
                float a = this->at(p).a;
                pic.at( p ) = color( this->at( p ) ) * a + color( pic.at( p ) ) * (1-a);
                pic.at( p ).a = unit::fill;
            }
            return pic;
        }

        struct Pos {
            size_t x, y, nb;

            bool operator<( const Pos &p ) const {
                return nb < p.nb;
            }
        };

        rect bleed( bool enabled = true ) const {
            // taken from https://github.com/fgenesis/pngrim/blob/master/src/pngrim/main.cpp
            // original code by False.Genesis, public domain

            if( !enabled ) {
                return *this;
            }

            rect img = *this;

            rect<unsigned char> solid(w, h, 0);
            std::vector<Pos> P, R;
            std::queue<Pos> Q;

            for( size_t y = 0; y < h; ++y ) {
                for( size_t x = 0; x < w; ++x ) {
                    if( img.at(x,y).a ) {
                        solid.at(x,y) = 1;
                    } else {
                        Pos p { x, y, 0 };
                        solid.at(x,y) = 0;
                        for( int oy = -1; oy <= 1; ++oy ) {
                            for( int ox = -1; ox <= 1; ++ox ) {
                                const unsigned int xn = int(x) + ox;
                                const unsigned int yn = int(y) + oy;
                                if(xn < w && yn < h && img.at(xn, yn).a) {
                                    ++p.nb;
                                }
                            }
                        }
                        if( p.nb ) {
                            P.push_back(p);
                        }
                    }
                }
            }

            while( P.size() ) {
                std::sort( P.begin(), P.end() );

                while( P.size() ) {
                    Q.push( P.back() );
                    P.pop_back();
                }

                while( Q.size() ) {
                    Pos p = Q.front();
                    Q.pop();
                    if( !solid.at(p.x, p.y) ) {
                        float a = img.at(p.x, p.y).a, r = 0, g = 0, b = 0, c = 0;
                        for( int oy = -1; oy <= 1; ++oy ) {
                            const unsigned int y = int(p.y) + oy;
                            if( y < h ) {
                                for( int ox = -1; ox <= 1; ++ox ) {
                                    const unsigned int x = int(p.x) + ox;
                                    if( x < w ) {
                                        if( solid.at(x, y) ) {
                                            pixel px( img.at(x, y) );
                                            r += px.r;
                                            g += px.g;
                                            b += px.b;
                                            ++c;
                                        } else {
                                            R.push_back(Pos { x, y, 0 });
                                        }
                                    }
                                }
                            }
                        }
                        solid.at(p.x, p.y) = 1;
                        img.at(p.x, p.y) = pixel( r / c, g / c, b / c, a );
                    }
                }

                while( R.size() ) {
                    Pos p = R.back();
                    R.pop_back();
                    if( !solid.at(p.x, p.y) ) {
                        for(int oy = -1; oy <= 1; ++oy) {
                            for(int ox = -1; ox <= 1; ++ox) {
                                const unsigned int xn = int(p.x) + ox;
                                const unsigned int yn = int(p.y) + oy;
                                if(xn < w && yn < h && solid.at(xn, yn))
                                    ++p.nb;
                            }
                        }

                        P.push_back(p);
                    }
                }
            }

            return img;
        }

        rect glow( bool enabled = true ) const {
            // taken from https://github.com/fgenesis/pngrim/blob/master/src/pngrim/main.cpp
            // original code by False.Genesis, public domain

            if( !enabled ) {
                return *this;
            }

            rect img = *this;

            rect<unsigned char> solid(w, h, 0);
            std::vector<Pos> P, R;
            std::queue<Pos> Q;

            for( size_t y = 0; y < h; ++y ) {
                for( size_t x = 0; x < w; ++x ) {
                    if( img.at(x,y).a ) {
                        solid.at(x,y) = 1;
                    } else {
                        Pos p { x, y, 0 };
                        solid.at(x,y) = 0;
                        for( int oy = -1; oy <= 1; ++oy ) {
                            for( int ox = -1; ox <= 1; ++ox ) {
                                const unsigned int xn = int(x) + ox;
                                const unsigned int yn = int(y) + oy;
                                if(xn < w && yn < h && img.at(xn, yn).a) {
                                    ++p.nb;
                                }
                            }
                        }
                        if( p.nb ) {
                            P.push_back(p);
                        }
                    }
                }
            }

            while( P.size() ) {
                std::sort( P.begin(), P.end() );

                while( P.size() ) {
                    Q.push( P.back() );
                    P.pop_back();
                }

                while( Q.size() ) {
                    Pos p = Q.front();
                    Q.pop();
                    if( !solid.at(p.x, p.y) ) {
                        solid.at(p.x, p.y) = 1;
                        float a = img.at(p.x, p.y).a, r = 0, g = 0, b = 0, c = 0;
                        for( int oy = -1; oy <= 1; ++oy ) {
                            const unsigned int y = int(p.y) + oy;
                            if( y < h ) {
                                for( int ox = -1; ox <= 1; ++ox ) {
                                    const unsigned int x = int(p.x) + ox;
                                    if( x < w ) {
                                        if( solid.at(x, y) ) {
                                            pixel px( img.at(x, y) );
                                            r += px.r;
                                            g += px.g;
                                            b += px.b;
                                            ++c;
                                        } else {
                                            R.push_back(Pos { x, y, 0 });
                                        }
                                    }
                                }
                            }
                        }
                        img.at(p.x, p.y) = pixel( r / c, g / c, b / c, a );
                    }
                }

                while( R.size() ) {
                    Pos p = R.back();
                    R.pop_back();
                    if( !solid.at(p.x, p.y) ) {
                        for(int oy = -1; oy <= 1; ++oy) {
                            for(int ox = -1; ox <= 1; ++ox) {
                                const unsigned int xn = int(p.x) + ox;
                                const unsigned int yn = int(p.y) + oy;
                                if(xn < w && yn < h && solid.at(xn, yn))
                                    ++p.nb;
                            }
                        }

                        P.push_back(p);
                    }
                }
            }

            return img;
        }
    };

    class texture : public rect< pixel >
    {
        public:

        typedef pixel unit;

        // implementation

        texture() : rect<pixel>()
        {}

        texture( size_t w, size_t h, size_t d = 0, const pixel &filler = pixel() ) : rect<pixel>(w,h,d,filler)
        {}

        texture( const rect<pixel> &rt ) : rect<pixel>(rt)
        {}

        texture( const std::string &pathfile ) : rect<pixel>() {AddLapse(34);
            load( pathfile );AddLapse(35);
        }

        texture( const void *ptr, size_t len ) : rect<pixel>() {
            load( ptr, len );
        }

        texture( const stream &sm ) : rect<pixel>(sm.w,sm.h,sm.d) {
            import_texture( sm );
        }

        texture( const void *ptr, unsigned len, unsigned w, unsigned h, unsigned d = 0, unsigned fmt = RGB_888 ) : rect<pixel>(w,h,d) {
            stream sm = {};
            sm.w = w;
            sm.h = h;
            sm.d = d;
            sm.fmt = fmt;
            sm.in = ptr;
            sm.len = len;
            sm.comp = 0;
            sm.deleter = 0;
            sm.hint = 0;
            import_texture( sm );
        }

        // debug 2d

        void print( int x, int y, const char *utf8 );

        private:
        void import_texture( const stream &st ) {
            if( st.fmt == RGB_888 ) {
                uint8_t *rgb = (uint8_t*)st.in;
                for( auto &px : *this ) {
                    px.r = *rgb++;
                    px.g = *rgb++;
                    px.b = *rgb++;
                    px.a = 255;
                }
            }
            if( st.fmt == RGBA_8888 ) {
                uint8_t *rgba = (uint8_t*)st.in;
                for( auto &px : *this ) {
                    px.r = *rgba++;
                    px.g = *rgba++;
                    px.b = *rgba++;
                    px.a = *rgba++;
                }
            }
        }
    };


    class image : public rect< color >
    {
        public:

        typedef color unit;

        // implementation

        image() : rect<color>()
        {}

        image( size_t w, size_t h, size_t d = 0, const color &filler = color() ) : rect<color>(w,h,d,filler)
        {}

        image( const rect<color> &rt ) : rect<color>(rt)
        {}

        image( const void *ptr, size_t len ) : rect<color>() {
            load( ptr, len );
        }

        image( const std::string &pathfile ) : rect<color>() {
            load( pathfile );
        }

        image( const texture &tx ) : rect<color>() {
            load( tx );
        }

        operator texture() const {
            texture tx( w, h, d ); tx.resize(0);
            for( auto &color : *this ) {
                spot::pixel pixel = color;
                tx.push_back( pixel );
            }
            return tx;
        }

        // import/export

        bool load( const void *ptr, size_t len ) {
            rect< color > *self = this;
            if( !self->load( ptr, len ) ) {
                self->load_hdr( ptr, len );
                for( auto &color : *this ) {
                    //color = color.to_hsla();
                }
                return !this->empty();
            }
            return false;
        }

        bool load( const std::string &pathfile ) {
            std::ifstream ifs( pathfile.c_str(), std::ios::binary );
            if( !ifs.good() ) {
				mError = "Error! unable to read file: " + pathfile; // <- STEVE CHANGE
                return false; /*"Error! unable to read file: " + pathfile*/
            }
            std::vector<char> buffer( (std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
            return load( buffer.data(), buffer.size() );
        }

        bool load( const texture &tx ) {
            this->clear();
            this->reserve(((d = tx.d) > 0 ? tx.d : 1) * (w = tx.w) * (h = tx.h));
            for( auto &pixel : tx ) {
                spot::color color = pixel;
                this->push_back( color );
            }
            return true;
        }

        // debug 2d

        void print( int x, int y, const char *utf8 );
    };
}
