#include "codecJpeg.h"		/* Common decls for cjpeg/djpeg applications */
#include "jversion.h"	/* for version message */
#include <ctype.h>		/* to declare isprint() */
#include <setjmp.h>
#include "jdecode2bmp.h"


#define GMESSAGE(code,string)	string,
static const char * const cdjpeg_message_table[] = {
    // these are originally from cderror.h
    GMESSAGE(JERR_BMP_BADCMAP, "Unsupported BMP colormap format")
    GMESSAGE(JERR_BMP_BADDEPTH, "Only 8- and 24-bit BMP files are supported")
    GMESSAGE(JERR_BMP_BADHEADER, "Invalid BMP file: bad header length")
    GMESSAGE(JERR_BMP_BADPLANES, "Invalid BMP file: biPlanes not equal to 1")
    GMESSAGE(JERR_BMP_COLORSPACE, "BMP output must be grayscale or RGB")
    GMESSAGE(JERR_BMP_COMPRESSED, "Sorry, compressed BMPs not yet supported")
    GMESSAGE(JERR_BMP_EMPTY, "Empty BMP image")
    GMESSAGE(JERR_BMP_NOT, "Not a BMP file - does not start with BM")
    GMESSAGE(JTRC_BMP, "%ux%u 24-bit BMP image")
    GMESSAGE(JTRC_BMP_MAPPED, "%ux%u 8-bit colormapped BMP image")
    GMESSAGE(JTRC_BMP_OS2, "%ux%u 24-bit OS2 BMP image")
    GMESSAGE(JTRC_BMP_OS2_MAPPED, "%ux%u 8-bit colormapped OS2 BMP image")
    GMESSAGE(JERR_TGA_NOTCOMP, "Targa support was not compiled")
    GMESSAGE(JERR_BAD_CMAP_FILE,
         "Color map file is invalid or of unsupported format")
    GMESSAGE(JERR_TOO_MANY_COLORS,
         "Output file format cannot handle %d colormap entries")
    GMESSAGE(JERR_UNGETC_FAILED, "ungetc failed")
    GMESSAGE(JERR_UNKNOWN_FORMAT, "Unrecognized input file format")
    GMESSAGE(JERR_UNSUPPORTED_FORMAT, "Unsupported output file format")
//#include "cderror.h"
  NULL
};

typedef enum {
    FMT_BMP,		/* BMP format (Windows flavor) */
    FMT_GIF,		/* GIF format */
    FMT_OS2,		/* BMP format (OS/2 flavor) */
    FMT_PPM,		/* PPM/PGM (PBMPLUS formats) */
    FMT_RLE,		/* RLE format */
    FMT_TARGA,		/* Targa format */
    FMT_TIFF		/* TIFF format */
} IMAGE_FORMATS;

#ifndef DEFAULT_FMT		/* so can override from CFLAGS in Makefile */
#define DEFAULT_FMT	FMT_PPM
#endif

typedef long INT32;
static IMAGE_FORMATS requested_fmt;
static const char * progname;	/* program name for error messages */
static char * outfilename;	/* for -outfile switch */

LOCAL(void)
usage (void)
/* complain about bad command line */
{
  fprintf(stderr, "usage: %s [switches] ", progname);
#ifdef TWO_FILE_COMMANDLINE
  fprintf(stderr, "inputfile outputfile\n");
#else
  fprintf(stderr, "[inputfile]\n");
#endif

  fprintf(stderr, "Switches (names may be abbreviated):\n");
  fprintf(stderr, "  -colors N      Reduce image to no more than N colors\n");
  fprintf(stderr, "  -fast          Fast, low-quality processing\n");
  fprintf(stderr, "  -grayscale     Force grayscale output\n");
#ifdef IDCT_SCALING_SUPPORTED
  fprintf(stderr, "  -scale M/N     Scale output image by fraction M/N, eg, 1/8\n");
#endif
#ifdef BMP_SUPPORTED
  fprintf(stderr, "  -bmp           Select BMP output format (Windows style)%s\n",
      (DEFAULT_FMT == FMT_BMP ? " (default)" : ""));
#endif
#ifdef GIF_SUPPORTED
  fprintf(stderr, "  -gif           Select GIF output format%s\n",
      (DEFAULT_FMT == FMT_GIF ? " (default)" : ""));
#endif
#ifdef BMP_SUPPORTED
  fprintf(stderr, "  -os2           Select BMP output format (OS/2 style)%s\n",
      (DEFAULT_FMT == FMT_OS2 ? " (default)" : ""));
#endif
#ifdef PPM_SUPPORTED
  fprintf(stderr, "  -pnm           Select PBMPLUS (PPM/PGM) output format%s\n",
      (DEFAULT_FMT == FMT_PPM ? " (default)" : ""));
#endif
#ifdef RLE_SUPPORTED
  fprintf(stderr, "  -rle           Select Utah RLE output format%s\n",
      (DEFAULT_FMT == FMT_RLE ? " (default)" : ""));
#endif
#ifdef TARGA_SUPPORTED
  fprintf(stderr, "  -targa         Select Targa output format%s\n",
      (DEFAULT_FMT == FMT_TARGA ? " (default)" : ""));
#endif
  fprintf(stderr, "Switches for advanced users:\n");
#ifdef DCT_ISLOW_SUPPORTED
  fprintf(stderr, "  -dct int       Use integer DCT method%s\n",
      (JDCT_DEFAULT == JDCT_ISLOW ? " (default)" : ""));
#endif
#ifdef DCT_IFAST_SUPPORTED
  fprintf(stderr, "  -dct fast      Use fast integer DCT (less accurate)%s\n",
      (JDCT_DEFAULT == JDCT_IFAST ? " (default)" : ""));
#endif
#ifdef DCT_FLOAT_SUPPORTED
  fprintf(stderr, "  -dct float     Use floating-point DCT method%s\n",
      (JDCT_DEFAULT == JDCT_FLOAT ? " (default)" : ""));
#endif
  fprintf(stderr, "  -dither fs     Use F-S dithering (default)\n");
  fprintf(stderr, "  -dither none   Don't use dithering in quantization\n");
  fprintf(stderr, "  -dither ordered  Use ordered dither (medium speed, quality)\n");
#ifdef QUANT_2PASS_SUPPORTED
  fprintf(stderr, "  -map FILE      Map to colors used in named image file\n");
#endif
  fprintf(stderr, "  -nosmooth      Don't use high-quality upsampling\n");
#ifdef QUANT_1PASS_SUPPORTED
  fprintf(stderr, "  -onepass       Use 1-pass quantization (fast, low quality)\n");
#endif
  fprintf(stderr, "  -maxmemory N   Maximum memory to use (in kbytes)\n");
  fprintf(stderr, "  -outfile name  Specify name for output file\n");
  fprintf(stderr, "  -verbose  or  -debug   Emit debug output\n");
  exit(EXIT_FAILURE);
}

LOCAL(unsigned int)
jpeg_getc (j_decompress_ptr cinfo)
/* Read next byte */
{
  struct jpeg_source_mgr * datasrc = cinfo->src;

  if (datasrc->bytes_in_buffer == 0) {
    if (! (*datasrc->fill_input_buffer) (cinfo))
      ERREXIT(cinfo, JERR_CANT_SUSPEND);
  }
  datasrc->bytes_in_buffer--;
  return GETJOCTET(*datasrc->next_input_byte++);
}


METHODDEF(boolean)
print_text_marker (j_decompress_ptr cinfo)
{
  boolean traceit = (cinfo->err->trace_level >= 1);
  INT32 length;
  unsigned int ch;
  unsigned int lastch = 0;

  length = jpeg_getc(cinfo) << 8;
  length += jpeg_getc(cinfo);
  length -= 2;			/* discount the length word itself */

  if (traceit) {
    if (cinfo->unread_marker == JPEG_COM)
      fprintf(stderr, "Comment, length %ld:\n", (long) length);
    else			/* assume it is an APPn otherwise */
      fprintf(stderr, "APP%d, length %ld:\n",
          cinfo->unread_marker - JPEG_APP0, (long) length);
  }

  while (--length >= 0) {
    ch = jpeg_getc(cinfo);
    if (traceit) {
      if (ch == '\r') {
    fprintf(stderr, "\n");
      } else if (ch == '\n') {
    if (lastch != '\r')
      fprintf(stderr, "\n");
      } else if (ch == '\\') {
    fprintf(stderr, "\\\\");
      } else if (isprint(ch)) {
    putc(ch, stderr);
      } else {
    fprintf(stderr, "\\%03o", ch);
      }
      lastch = ch;
    }
  }

  if (traceit)
    fprintf(stderr, "\n");

  return TRUE;
}


typedef struct {
  struct djpeg_dest_struct pub;	/* public fields */

  jvirt_sarray_ptr whole_image;	/* needed to reverse row order */
  JDIMENSION data_width;	/* JSAMPLEs per row */
  JDIMENSION row_width;		/* physical width of one row in the BMP file */
  int pad_bytes;		/* number of padding bytes needed per row */
  JDIMENSION cur_output_row;	/* next row# to write to virtual array */
} bmp_dest_struct;

typedef bmp_dest_struct * bmp_dest_ptr;


/* Forward declarations */
LOCAL(void) write_colormap
    JPP((j_decompress_ptr cinfo, bmp_dest_ptr dest,
         int map_colors, int map_entry_size, QByteArray &outStream));


METHODDEF(void)
put_pixel_rows (j_decompress_ptr cinfo, djpeg_dest_ptr dinfo,
        JDIMENSION rows_supplied)
/* This version is for writing 24-bit pixels */
{
  bmp_dest_ptr dest = (bmp_dest_ptr) dinfo;
  JSAMPARRAY image_ptr;
  register JSAMPROW inptr, outptr;
  register JDIMENSION col;
  int pad;

  /* Access next row in virtual array */
  image_ptr = (*cinfo->mem->access_virt_sarray)
    ((j_common_ptr) cinfo, dest->whole_image,
     dest->cur_output_row, (JDIMENSION) 1, TRUE);
  dest->cur_output_row++;

  /* Transfer data.  Note destination values must be in BGR order
   * (even though Microsoft's own documents say the opposite).
   */
  inptr = dest->pub.buffer[0];
  outptr = image_ptr[0];
  for (col = cinfo->output_width; col > 0; col--) {
    outptr[2] = *inptr++;	/* can omit GETJSAMPLE() safely */
    outptr[1] = *inptr++;
    outptr[0] = *inptr++;
    outptr += 3;
  }

  /* Zero out the pad bytes. */
  pad = dest->pad_bytes;
  while (--pad >= 0)
    *outptr++ = 0;
}


#ifdef _NEED_TO_PARSE
LOCAL(int)
parse_switches (j_decompress_ptr cinfo, int argc, char **argv,
        int last_file_arg_seen, boolean for_real)
/* Parse optional switches.
 * Returns argv[] index of first file-name argument (== argc if none).
 * Any file names with indexes <= last_file_arg_seen are ignored;
 * they have presumably been processed in a previous iteration.
 * (Pass 0 for last_file_arg_seen on the first or only iteration.)
 * for_real is FALSE on the first (dummy) pass; we may skip any expensive
 * processing.
 */
{
  int argn;
  char * arg;

  /* Set up default JPEG parameters. */
  requested_fmt = DEFAULT_FMT;	/* set default output file format */
  outfilename = NULL;
  cinfo->err->trace_level = 0;

  /* Scan command line options, adjust parameters */

  for (argn = 1; argn < argc; argn++) {
    arg = argv[argn];
    if (*arg != '-') {
      /* Not a switch, must be a file name argument */
      if (argn <= last_file_arg_seen) {
    outfilename = NULL;	/* -outfile applies to just one input file */
    continue;		/* ignore this name if previously processed */
      }
      break;			/* else done parsing switches */
    }
    arg++;			/* advance past switch marker character */

    if (keymatch(arg, "bmp", 1)) {
      /* BMP output format. */
      requested_fmt = FMT_BMP;

    } else if (keymatch(arg, "colors", 1) || keymatch(arg, "colours", 1) ||
           keymatch(arg, "quantize", 1) || keymatch(arg, "quantise", 1)) {
      /* Do color quantization. */
      int val;

      if (++argn >= argc)	/* advance to next argument */
    usage();
      if (sscanf(argv[argn], "%d", &val) != 1)
    usage();
      cinfo->desired_number_of_colors = val;
      cinfo->quantize_colors = TRUE;

    } else if (keymatch(arg, "dct", 2)) {
      /* Select IDCT algorithm. */
      if (++argn >= argc)	/* advance to next argument */
    usage();
      if (keymatch(argv[argn], "int", 1)) {
    cinfo->dct_method = JDCT_ISLOW;
      } else if (keymatch(argv[argn], "fast", 2)) {
    cinfo->dct_method = JDCT_IFAST;
      } else if (keymatch(argv[argn], "float", 2)) {
    cinfo->dct_method = JDCT_FLOAT;
      } else
    usage();

    } else if (keymatch(arg, "dither", 2)) {
      /* Select dithering algorithm. */
      if (++argn >= argc)	/* advance to next argument */
    usage();
      if (keymatch(argv[argn], "fs", 2)) {
    cinfo->dither_mode = JDITHER_FS;
      } else if (keymatch(argv[argn], "none", 2)) {
    cinfo->dither_mode = JDITHER_NONE;
      } else if (keymatch(argv[argn], "ordered", 2)) {
    cinfo->dither_mode = JDITHER_ORDERED;
      } else
    usage();

    } else if (keymatch(arg, "debug", 1) || keymatch(arg, "verbose", 1)) {
      /* Enable debug printouts. */
      /* On first -d, print version identification */
      static boolean printed_version = FALSE;

      if (! printed_version) {
    fprintf(stderr, "Independent JPEG Group's DJPEG, version %s\n%s\n",
        JVERSION, JCOPYRIGHT);
    printed_version = TRUE;
      }
      cinfo->err->trace_level++;

    } else if (keymatch(arg, "fast", 1)) {
      /* Select recommended processing options for quick-and-dirty output. */
      cinfo->two_pass_quantize = FALSE;
      cinfo->dither_mode = JDITHER_ORDERED;
      if (! cinfo->quantize_colors) /* don't override an earlier -colors */
    cinfo->desired_number_of_colors = 216;
      cinfo->dct_method = JDCT_FASTEST;
      cinfo->do_fancy_upsampling = FALSE;

    } else if (keymatch(arg, "gif", 1)) {
      /* GIF output format. */
      requested_fmt = FMT_GIF;

    } else if (keymatch(arg, "grayscale", 2) || keymatch(arg, "greyscale",2)) {
      /* Force monochrome output. */
      cinfo->out_color_space = JCS_GRAYSCALE;

    } else if (keymatch(arg, "map", 3)) {
      /* Quantize to a color map taken from an input file. */
      if (++argn >= argc)	/* advance to next argument */
    usage();
      if (for_real) {		/* too expensive to do twice! */
#ifdef QUANT_2PASS_SUPPORTED	/* otherwise can't quantize to supplied map */
    FILE * mapfile;

    if ((mapfile = fopen(argv[argn], READ_BINARY)) == NULL) {
      fprintf(stderr, "%s: can't open %s\n", progname, argv[argn]);
      exit(EXIT_FAILURE);
    }
    read_color_map(cinfo, mapfile);
    fclose(mapfile);
    cinfo->quantize_colors = TRUE;
#else
    ERREXIT(cinfo, JERR_NOT_COMPILED);
#endif
      }

    } else if (keymatch(arg, "maxmemory", 3)) {
      /* Maximum memory in Kb (or Mb with 'm'). */
      long lval;
      char ch = 'x';

      if (++argn >= argc)	/* advance to next argument */
    usage();
      if (sscanf(argv[argn], "%ld%c", &lval, &ch) < 1)
    usage();
      if (ch == 'm' || ch == 'M')
    lval *= 1000L;
      cinfo->mem->max_memory_to_use = lval * 1000L;

    } else if (keymatch(arg, "nosmooth", 3)) {
      /* Suppress fancy upsampling */
      cinfo->do_fancy_upsampling = FALSE;

    } else if (keymatch(arg, "onepass", 3)) {
      /* Use fast one-pass quantization. */
      cinfo->two_pass_quantize = FALSE;

    } else if (keymatch(arg, "os2", 3)) {
      /* BMP output format (OS/2 flavor). */
      requested_fmt = FMT_OS2;

    } else if (keymatch(arg, "outfile", 4)) {
      /* Set output file name. */
      if (++argn >= argc)	/* advance to next argument */
    usage();
      outfilename = argv[argn];	/* save it away for later use */

    } else if (keymatch(arg, "pnm", 1) || keymatch(arg, "ppm", 1)) {
      /* PPM/PGM output format. */
      requested_fmt = FMT_PPM;

    } else if (keymatch(arg, "rle", 1)) {
      /* RLE output format. */
      requested_fmt = FMT_RLE;

    } else if (keymatch(arg, "scale", 1)) {
      /* Scale the output image by a fraction M/N. */
      if (++argn >= argc)	/* advance to next argument */
    usage();
      if (sscanf(argv[argn], "%d/%d",
         &cinfo->scale_num, &cinfo->scale_denom) < 1)
    usage();

    } else if (keymatch(arg, "targa", 1)) {
      /* Targa output format. */
      requested_fmt = FMT_TARGA;

    } else {
      usage();			/* bogus switch */
    }
  }

  return argn;			/* return index of next arg (file name) */
}
#endif


struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */

  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

METHODDEF(void)
my_error_exit (j_common_ptr cinfo) {
    my_error_ptr myerr = (my_error_ptr) cinfo->err;

    (*cinfo->err->output_message) (cinfo);

    longjmp(myerr->setjmp_buffer, 1);
}

int decodeJpeg2Bmp(QByteArray &inBuffer, QByteArray &outBuffer)
{
    struct jpeg_decompress_struct cinfo;
    //struct jpeg_error_mgr jerr;
    struct my_error_mgr jerr;
    djpeg_dest_ptr dest_mgr = NULL;
    JDIMENSION num_scanlines;

    /* Initialize the JPEG decompression object with default error handling. */
    cinfo.err = jpeg_std_error(&jerr.pub);
    cinfo.err->error_exit = my_error_exit;
    if (setjmp(jerr.setjmp_buffer)) {
        jpeg_destroy_decompress(&cinfo);
        return -1;
    }
    jpeg_create_decompress(&cinfo);
    /* Add some application-specific error messages (from cderror.h) */
    jerr.pub.addon_message_table = cdjpeg_message_table;
    jerr.pub.first_addon_message = JMSG_FIRSTADDONCODE;
    jerr.pub.last_addon_message = JMSG_LASTADDONCODE;

    /* Insert custom marker processor for COM and APP12.
     * APP12 is used by some digital camera makers for textual info,
     * so we provide the ability to display it as text.
     * If you like, additional APPn marker types can be selected for display,
     * but don't try to override APP0 or APP14 this way (see libjpeg.doc).
     */
    jpeg_set_marker_processor(&cinfo, JPEG_COM, print_text_marker);
    jpeg_set_marker_processor(&cinfo, JPEG_APP0+12, print_text_marker);

    /* Specify data source for decompression */
    jpeg_mem_src(&cinfo, (unsigned char*)inBuffer.data(), inBuffer.size());

    /* Read file header, set default decompression parameters */
    (void) jpeg_read_header(&cinfo, TRUE);

    cinfo.dct_method = JDCT_ISLOW; //JDCT_IFAST;
    cinfo.dither_mode = JDITHER_FS;
    cinfo.two_pass_quantize = TRUE;
    cinfo.quantize_colors = FALSE;
    cinfo.mem->max_memory_to_use = 1000000;
    dest_mgr = jinit_write_bmp(&cinfo, FALSE);

    dest_mgr->qbuf = new QBuffer();
    dest_mgr->qbuf->setBuffer(&outBuffer);
    dest_mgr->qbuf->open(QIODevice::ReadWrite);

    /* Start decompressor */
    (void) jpeg_start_decompress(&cinfo);

    /* Write output file header */
    (*dest_mgr->start_output) (&cinfo, dest_mgr);

    /* Process data */
    while (cinfo.output_scanline < cinfo.output_height) {
      num_scanlines = jpeg_read_scanlines(&cinfo, dest_mgr->buffer,
                      dest_mgr->buffer_height);
      (*dest_mgr->put_pixel_rows) (&cinfo, dest_mgr, num_scanlines);
    }

    /* Finish decompression and release memory.
     * I must do it in this order because output module has allocated memory
     * of lifespan JPOOL_IMAGE; it needs to finish before releasing memory.
     */
    (*dest_mgr->finish_output) (&cinfo, dest_mgr);
    (void) jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);

    /* All done. */
    return jerr.pub.num_warnings ? EXIT_WARNING : EXIT_SUCCESS;
}
