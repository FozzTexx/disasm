/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import <ClearLake/ClearLake.h>

#define LABEL_COL	"-8"

@interface Disassembler:CLObject
{
  CLUInteger origin, entry;
  CLData *binary;
  CLMutableArray *stack;
  CLMutableDictionary *assembly;
  CLMutableDictionary *labels;
}

-(id) init;
-(id) initWithBinary:(CLData *) aData origin:(CLUInteger) org entry:(CLUInteger) ent;
-(void) dealloc;

-(void) disassemble;

-(void) addLabels:(CLString *) aString;

@end
