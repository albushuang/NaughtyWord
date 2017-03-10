/*
 * cdjpeg.c
 *
 * Copyright (C) 1991-1997, Thomas G. Lane.
 * This file is part of the Independent JPEG Group's software.
 * For conditions of distribution and use, see the accompanying README file.
 *
 * This file contains common support routines used by the IJG application
 * programs (cjpeg, djpeg, jpegtran).
 */

#include "cdjpeg.h"		/* Common decls for cjpeg/djpeg applications */
#include <ctype.h>		/* to declare isupper(), tolower() */
#ifdef NEED_SIGNAL_CATCHER
#include <signal.h>		/* to declare signal() */
#endif
#ifdef USE_SETMODE
#include <fcntl.h>		/* to declare setmode()'s parameter macros */
/* If you have setmode() but not <io.h>, just delete this line: */
#include <io.h>			/* to declare setmode() */
#endif

#define GLOBAL(type)		type
typedef int boolean;
#define FALSE	0
#define TRUE    1

/*
 * Signal catcher to ensure that temporary files are removed before aborting.
 * NB: for Amiga Manx C this is actually a global routine named _abort();
 * we put "#define signal_catcher _abort" in jconfig.h.  Talk about bogus...
 */



/*
 * Optional progress monitor: display a percent-done figure on stderr.
 */




/*
 * Case-insensitive matching of possibly-abbreviated keyword switches.
 * keyword is the constant keyword (must be lower case already),
 * minchars is length of minimum legal abbreviation.
 */
#ifdef _NEED_TO_PARSE
GLOBAL(boolean)
keymatch (char * arg, const char * keyword, int minchars)
{
  register int ca, ck;
  register int nmatched = 0;

  while ((ca = *arg++) != '\0') {
    if ((ck = *keyword++) == '\0')
      return FALSE;		/* arg longer than keyword, no good */
    if (isupper(ca))		/* force arg to lcase (assume ck is already) */
      ca = tolower(ca);
    if (ca != ck)
      return FALSE;		/* no good */
    nmatched++;			/* count matched characters */
  }
  /* reached end of argument; fail if it's too short for unique abbrev */
  if (nmatched < minchars)
    return FALSE;
  return TRUE;			/* A-OK */
}

#endif
