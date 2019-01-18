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

#import "constant.h"

#import <ClearLake/ClearLake.h>

@interface Disassembler:CLObject
{
  CLUInteger origin;
  CLData *binary;
  CLMutableArray *stack, *entries;
  CLMutableDictionary *assembly, *labels, *subs, *subArgs;

  BOOL hashedLabels;
}

-(id) init;
-(id) initWithBinary:(CLData *) aData origin:(CLUInteger) org;
-(void) dealloc;

-(void) disassemble;

-(CLUInteger) valueAt:(CLUInteger) address length:(CLUInteger) length;
-(CLUInteger) declareBytes:(CLUInteger) len at:(CLUInteger) address forced:(BOOL) forced;
-(CLUInteger) declareString:(CLUInteger) len at:(CLUInteger) address forced:(BOOL) forced;
-(CLUInteger) declareWords:(CLUInteger) len at:(CLUInteger) address forced:(BOOL) forced;
-(CLNumber *) assemblyWithAddress:(CLNumber *) anAddress length:(CLUInteger) len;

-(void) addLabels:(CLString *) labels;
-(void) addEntryPoints:(CLString *) entries;
-(void) addDataBlocks:(CLString *) blockString;

-(CLString *) formatHex:(CLUInteger) aValue length:(CLUInteger) len;

-(void) setConstants:(CLString *) aString;
-(void) setHashedLabels:(BOOL) flag;

-(void) addConstant:(CLString *) label at:(CLUInteger) address;

@end
