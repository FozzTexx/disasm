/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import <ClearLake/ClearLake.h>

@class Disassembler;

@interface Assembly:CLObject
{
  CLUInteger len;
  BOOL entryPoint;
  CLString *line;
  CLUInteger value;
}

-(id) init;
-(id) initFromString:(CLString *) aString value:(CLUInteger) addr
	      length:(int) aValue entryPoint:(BOOL) flag;
-(void) dealloc;

-(CLString *) line;
-(CLString *) lineWithLabel:(CLDictionary *) labels disassembler:(Disassembler *) disasm;
-(CLUInteger) value;
-(CLUInteger) length;
-(BOOL) isEntryPoint;

@end
