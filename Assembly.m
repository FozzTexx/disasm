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

#import "Assembly.h"
#import "Disassembler.h"

@implementation Assembly

-(id) init
{
  return [self initFromString:nil value:0 length:0 entryPoint:NO type:0];
}

-(id) initFromString:(CLString *) aString value:(CLUInteger) aValue
	      length:(int) aLength entryPoint:(BOOL) flag type:(OpcodeType) aType;
{
  [super init];
  line = [aString copy];
  len = aLength;
  entryPoint = flag;
  value = aValue;
  type = aType;
  return self;
}

-(void) dealloc
{
  [line release];
  [super dealloc];
  return;
}

-(CLString *) line
{
  return line;
}

-(CLString *) lineWithLabel:(CLDictionary *) labels disassembler:(Disassembler *) disasm
{
  CLNumber *num;
  CLString *label = nil;


  if (len > 1) {
    if (!(type & OpcodeImmediate)) {
      num = [CLNumber numberWithUnsignedInt:value];
      label = [labels objectForKey:num];
      if (!label) {
	num = [CLNumber numberWithUnsignedInt:value-1];
	label = [labels objectForKey:num];
	label = [label stringByAppendingString:@"+1"];
      }
    }
    if (!label)
      label = [disasm formatHex:value length:(len - (type & OpcodeConst ? 0 : 1)) * 2];
  }

  if (label)
    return [CLString stringWithFormat:line, label];

  return line;
}

-(CLUInteger) length
{
  return len;
}

-(CLUInteger) value
{
  return value;
}

-(BOOL) isEntryPoint
{
  return entryPoint;
}

-(OpcodeType) type
{
  return type;
}

@end
