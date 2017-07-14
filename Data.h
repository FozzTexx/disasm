/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import <ClearLake/ClearLake.h>

@interface Data:CLObject
{
  CLUInteger value;
  CLUInteger length;
}

-(id) init;
-(id) initFromValue:(CLUInteger) val length:(CLUInteger) len;

-(CLUInteger) value;
-(CLUInteger) length;

@end
