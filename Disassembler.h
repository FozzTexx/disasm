/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import "subroutine.h"

#import <ClearLake/ClearLake.h>

@interface Disassembler:CLObject
{
  CLUInteger origin, entry;
  CLData *binary;
  CLMutableArray *stack;
  CLMutableDictionary *assembly;
  CLMutableDictionary *labels;
  subroutine *subs;

  BOOL relativeLabels;
}

-(id) init;
-(id) initWithBinary:(CLData *) aData origin:(CLUInteger) org entry:(CLUInteger) ent;
-(void) dealloc;

-(void) disassemble;

-(void) addLabels:(CLString *) aString;

-(CLString *) formatHex:(CLUInteger) aValue length:(CLUInteger) len;

-(void) setSubroutines:(CLString *) aString;
-(void) setRelativeLabels:(BOOL) flag;

@end
