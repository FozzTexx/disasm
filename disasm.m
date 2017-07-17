/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * This file is part of disasm.
 *
 * disasm is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * disasm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with disasm; see the file COPYING. If not see
 * <http://www.gnu.org/licenses/>.
 */

#import "disasm.h"
#import "Disassembler.h"

CLUInteger parseUnsigned(CLString *aString)
{
  /* FIXME - support math operations */
  if ([aString hasPrefix:@"$"])
    aString = [CLString stringWithFormat:@"0x%@", [aString substringFromIndex:1]];
  if ([aString hasSuffix:@"H"] || [aString hasSuffix:@"h"])
    aString = [CLString stringWithFormat:@"0x%@",
			[aString substringToIndex:[aString length] - 1]];
  return [aString unsignedIntValue];
}

int main(int argc, char *argv[])
{
  int count;
  CLString *org = nil, *entry = nil, *labels = nil;
  CLUInteger origin = 0;
  CLData *aData;
  Disassembler *disasm;
  CLAutoreleasePool *pool;


  pool = [[CLAutoreleasePool alloc] init];

  count = CLGetArgs(argc, argv, @"osesls", &org, &entry, &labels);

  /* FIXME - allow declaring data blocks and type: binary, string, word */
  /* FIXME - option to disable/enable looking for addresses in data */
  /* FIXME - option to disable/enable looking for strings in data */
  /* FIXME - option to disable/enable printing address as comment */
  /* FIXME - option to disable/enable hashed labels */
  
  if (count < 0 || (argc - count) != 1) {
    if (count < 0 && -count != '-')
      fprintf(stderr, "Bad flag: %c\n", -count);
    fprintf(stderr, "Usage: %s [-flags] <binary>\n"
	                "Flags are:\n"
	    "\to: origin address\n"
	    "\te: entry point(s), separate by commas or file with separate lines\n"
	    "\tl: create label for address(es), separate by commas or file with separate lines\n"
	    "\ts: subroutine type (apple, vic20)\n"
	    , *argv);
    exit(1);
  }

  if (org)
    origin = parseUnsigned(org);
  if (!entry)
    entry = org;

  aData = [CLData dataWithContentsOfFile:[CLString stringWithUTF8String:argv[count]]];

  disasm = [[Disassembler alloc] initWithBinary:aData origin:origin];
  [disasm setConstants:@"vic20"];
  //[disasm setRelativeLabels:YES];
  [disasm addLabels:labels];
  [disasm addEntryPoints:entry];
  [disasm disassemble];
  [disasm release];

  [pool release];
  
  exit(0);
}
