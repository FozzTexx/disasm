/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import "Assembly.h"

@implementation Assembly

-(id) init
{
  return [self initFromString:nil value:0 length:0 entryPoint:NO];
}

-(id) initFromString:(CLString *) aString value:(CLUInteger) aValue
	      length:(int) aLength entryPoint:(BOOL) flag
{
  [super init];
  line = [aString copy];
  len = aLength;
  entryPoint = flag;
  value = aValue;
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

-(CLString *) lineWithLabel:(CLDictionary *) labels origin:(CLUInteger) origin
{
  CLNumber *num;
  CLString *label;


  num = [CLNumber numberWithUnsignedInt:value - origin];
  label =[labels objectForKey:num];
  if (!label)
    label = [CLString stringWithFormat:@"$%04X", value];

  return [CLString stringWithFormat:line, label];
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

