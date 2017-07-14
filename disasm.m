/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import "disasm.h"
#import "Disassembler.h"

CLUInteger parseUnsigned(CLString *aString)
{
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
  CLString *org = nil, *ent = nil, *labels = nil;
  CLUInteger origin = 0, entry = 0;
  CLData *aData;
  Disassembler *disasm;
  CLAutoreleasePool *pool;


  pool = [[CLAutoreleasePool alloc] init];

  count = CLGetArgs(argc, argv, @"osesls", &org, &ent, &labels);

  if (count < 0 || (argc - count) != 1) {
    if (count < 0 && -count != '-')
      fprintf(stderr, "Bad flag: %c\n", -count);
    fprintf(stderr, "Usage: %s [-flags] <binary>\n"
	                "Flags are:\n"
	    "\to: origin address\n"
	    "\te: entry point\n"
	    "\ts: subroutine type (apple, vic20)\n"
	    , *argv);
    exit(1);
  }

  if (org)
    origin = parseUnsigned(org);
  if (ent)
    entry = parseUnsigned(ent);
  else
    entry = origin;

  aData = [CLData dataWithContentsOfFile:[CLString stringWithUTF8String:argv[count]]];

  disasm = [[Disassembler alloc] initWithBinary:aData origin:origin entry:entry];
  [disasm setSubroutines:@"vic20"];
  //[disasm setRelativeLabels:YES];
  [disasm addLabels:labels];
  [disasm disassemble];
  [disasm release];

  [pool release];
  
  exit(0);
}
