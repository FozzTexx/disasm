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

-(CLString *) lineWithLabel:(CLDictionary *) labels
{
  CLNumber *num;
  CLString *label = nil;


  if (len > 1) {
    num = [CLNumber numberWithUnsignedInt:value];
    label = [labels objectForKey:num];
    if (!label)
      label = [CLString stringWithFormat:@"$%0*X", (len - 1) * 2, value];
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
