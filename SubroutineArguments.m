/* Copyright 2019 by Chris Osborn <fozztexx@fozztexx.com>
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

#import "SubroutineArguments.h"
#import "Disassembler.h"

#include <wctype.h>

@implementation SubroutineArguments

-(id) init
{
  return [self initFromString:nil];
}

-(id) initFromString:(CLString *) aString
{
  [super init];
  args = [aString copy];
  return self;
}

-(void) dealloc
{
  [args release];
  [super dealloc];
  return;
}

-(CLUInteger) declareArguments:(Disassembler *) disasm at:(CLUInteger) address
{
  int i, j, k;
  unichar c;
  CLUInteger len = 0;


  for (i = 0, j = [args length]; i < j; i++) {
    c = towupper([args characterAtIndex:i]);
    switch (c) {
    case 'A':
    case 'W':
      [disasm declareWords:1 at:address forced:NO];
      address += 2;
      len += 2;
      break;

    case 'C':
      for (k = 0; [disasm valueAt:address + k length:1]; k++)
	;
      k++;
      [disasm declareString:k at:address forced:NO];
      address += k;
      len += k;
      break;
      
    default:
      [disasm declareBytes:1 at:address forced:NO];
      address++;
      len++;
      break;
    }
  }
  
  return len;
}

@end
