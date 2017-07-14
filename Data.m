/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import "Data.h"

@implementation Data

-(id) init
{
  return [self initFromValue:0 length:0];
}

-(id) initFromValue:(CLUInteger) val length:(CLUInteger) len
{
  [super init];
  value = val;
  length = len;
  return self;
}

-(CLUInteger) value
{
  return value;
}

-(CLUInteger) length
{
  return length;
}

@end
