---	Various FreeImage enumerations.
--
-- Theses are shown here as tables, for documentation purposes. In practice, the Corona binding only
-- accepts strings, namely one of the field names from the enumeration in question, e.g. `"RED"` when
-- supplying a **FREE\_IMAGE\_COLOR\_CHANNEL**-type argument.
-- @module enums

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

--- Color channels.
--
-- Constants used in color manipulation routines.
-- @field RGB Use red, green and blue channels.
-- @field RED Use red channel.
-- @field GREEN Use green channel.
-- @field BLUE Use blue channel.
-- @field ALPHA Use alpha channel.
-- @field BLACK Use black channel.
-- @field REAL Complex images: use real part.
-- @field IMAG Complex images: use imaginary part.
-- @field MAG Complex images: use magnitude.
-- @field PHASE Complex images: use phase.
-- @table FREE_IMAGE_COLOR_CHANNEL

--- Image color type used in FreeImage.
-- @field MINISWHITE Min value is white.
-- @field MINISBLACK Min value is black.
-- @field RGB RGB color model.
-- @field PALETTE Color map indexed.
-- @field RGBALPHA RGB color model with alpha channel.
-- @field CMYK CMYK color model.
-- @table FREE_IMAGE_COLOR_TYPE

--- Dithering algorithms.
-- @field FS Floyd & Steinberg error diffusion.
-- @field BAYER4x4 Bayer ordered dispersed dot dithering (order 2 dithering matrix).
-- @field BAYER8x8 Bayer ordered dispersed dot dithering (order 3 dithering matrix).
-- @field CLUSTER6x6 Ordered clustered dot dithering (order 3 - 6x6 matrix).
-- @field CLUSTER8x8 Ordered clustered dot dithering (order 4 - 8x8 matrix).
-- @field CLUSTER16x16 Ordered clustered dot dithering (order 8 - 16x16 matrix).
-- @field BAYER16x16 Bayer ordered dispersed dot dithering (order 4 dithering matrix).
-- @table FREE_IMAGE_DITHER

--- Upsampling / downsampling filters.
-- @field BOX Box, pulse, Fourier window, 1st order (constant) b-spline.
-- @field BICUBIC Mitchell & Netravali's two-param cubic filter.
-- @field BILINEAR Bilinear filter.
-- @field BSPLINE 4th order (cubic) b-spline.
-- @field CATMULLROM Catmull-Rom spline, Overhauser spline.
-- @field LANCZOS3 Lanczos3 filter.
-- @table FREE_IMAGE_FILTER

--- I/O image format identifiers.
-- @field UNKNOWN
-- @field BMP
-- @field ICO
-- @field JPEG
-- @field JNG
-- @field KOALA
-- @field LBM
-- @field IFF (synonym for **LBM**)
-- @field MNG
-- @field PBM
-- @field PBMRAW
-- @field PCD
-- @field PCX
-- @field PGM
-- @field PGMRAW
-- @field PNG
-- @field PPM
-- @field PPMRAW
-- @field RAS
-- @field TARGA
-- @field TIFF
-- @field WBMP
-- @field PSD
-- @field CUT
-- @field XBM
-- @field XPM
-- @field DDS
-- @field GIF
-- @field HDR
-- @field FAXG3
-- @field SGI
-- @field EXR
-- @field J2K
-- @field JP2
-- @field PFM
-- @field PICT
-- @field RAW
-- @field WEBP
-- @field JXR
-- @table FREE_IMAGE_FORMAT

--- Metadata models supported by FreeImage.
-- @field NODATA
-- @field COMMENTS Single comment or keywords.
-- @field EXIF_MAIN Exif-TIFF metadata.
-- @field EXIF_EXIF Exif-specific metadata.
-- @field EXIF_GPS Exif GPS metadata.
-- @field EXIF_MAKERNOTE Exif maker note metadata.
-- @field EXIF_INTEROP Exif interoperability metadata.
-- @field IPTC IPTC/NAA metadata.
-- @field XMP Abobe XMP metadata.
-- @field GEOTIFF GeoTIFF metadata.
-- @field ANIMATION Animation metadata.
-- @field CUSTOM Used to attach other metadata types to a dib.
-- @field EXIF_RAW Exif metadata as a raw buffer.
-- @table FREE_IMAGE_MDMODEL

--- Tag data type information (based on TIFF specifications).
--
-- Note: RATIONALs are the ratio of two 32-bit integer values.
-- @field NOTYPE Placeholder .
-- @field BYTE 8-bit unsigned integer. 
-- @field ASCII 8-bit bytes w/ last byte null.
-- @field SHORT 16-bit unsigned integer. 
-- @field LONG 32-bit unsigned integer.
-- @field RATIONAL 64-bit unsigned fraction. 
-- @field SBYTE	8-bit signed integer.
-- @field UNDEFINED	8-bit untyped data.
-- @field SSHORT 16-bit signed integer.
-- @field SLONG 32-bit signed integer.
-- @field SRATIONAL 64-bit signed fraction.
-- @field FLOAT 32-bit IEEE floating point.
-- @field DOUBLE 64-bit IEEE floating point.
-- @field IFD 32-bit unsigned integer (offset).
-- @field PALETTE 32-bit RGBQUAD.
-- @field LONG8 64-bit unsigned integer.
-- @field SLONG8 64-bit signed integer.
-- @field IFD8 64-bit unsigned integer (offset).
-- @table FREE_IMAGE_MDTYPE

--- Color quantization algorithms.
-- @field WUQUANT Xiaolin Wu color quantization algorithm.
-- @field NNQUANT NeuQuant neural-net quantization algorithm by Anthony Dekker.
-- @field LFPQUANT Lossless Fast Pseudo-Quantization Algorithm by Carsten Klein.
-- @table FREE_IMAGE_QUANTIZE

--- Tone mapping operators.
-- @field DRAGO03 Adaptive logarithmic mapping (F. Drago, 2003).
-- @field REINHARD05 Dynamic range reduction inspired by photoreceptor physiology (E. Reinhard, 2005).
-- @field FATTAL02 Gradient domain high dynamic range compression (R. Fattal, 2002).
-- @table FREE_IMAGE_TMO

--- Image type used in FreeImage.
-- @field UNKNOWN Unknown type.
-- @field BITMAP Standard image: 1-, 4-, 8-, 16-, 24-, 32-bit.
-- @field UINT16 Array of unsigned short: unsigned 16-bit.
-- @field INT16 Array of short: signed 16-bit.
-- @field UINT32 Array of unsigned long: unsigned 32-bit.
-- @field INT32 Array of long: signed 32-bit.
-- @field FLOAT Array of float: 32-bit IEEE floating point.
-- @field DOUBLE Array of double: 64-bit IEEE floating point.
-- @field COMPLEX Array of FICOMPLEX: 2 x 64-bit IEEE floating point.
-- @field RGB16 48-bit RGB image: 3 x 16-bit.
-- @field RGBA16 64-bit RGBA image: 4 x 16-bit.
-- @field RGBF 96-bit RGB float image: 3 x 32-bit IEEE floating point.
-- @field RGBAF 128-bit RGBA float image: 4 x 32-bit IEEE floating point.
-- @table FREE_IMAGE_TYPE