/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
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
    }
    if (!label)
      label = [disasm formatHex:value length:(len - 1) * 2];
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

@end
