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
