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

#import <ClearLake/ClearLake.h>
#import "opcodes.h"

@class Disassembler;

@interface Assembly:CLObject
{
  CLUInteger len;
  BOOL entryPoint;
  CLString *line;
  CLUInteger value;
  OpcodeType type;
}

-(id) init;
-(id) initFromString:(CLString *) aString value:(CLUInteger) addr
	      length:(int) aValue entryPoint:(BOOL) flag type:(OpcodeType) aType;
-(void) dealloc;

-(CLString *) line;
-(CLString *) lineWithLabel:(CLDictionary *) labels disassembler:(Disassembler *) disasm;
-(CLUInteger) value;
-(CLUInteger) length;
-(BOOL) isEntryPoint;
-(OpcodeType) type;

@end
