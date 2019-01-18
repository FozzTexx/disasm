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

#import "Disassembler.h"
#import "Assembly.h"
#import "SubroutineArguments.h"
#import "AppleLabels.h"
#import "VIC20Labels.h"
#import "disasm.h"

#import "opcode6502.h"

#include <unistd.h>

enum {
  ModeNone = 0,
  ModeString,
  ModeBinary,
  ModeAddress,
};

@implementation Disassembler

-(id) init
{
  return [self initWithBinary:nil origin:0];
}

-(id) initWithBinary:(CLData *) aData origin:(CLUInteger) org
{
  [super init];
  binary = [aData retain];
  origin = org;
  stack = [[CLMutableArray alloc] init];
  assembly = [[CLMutableDictionary alloc] init];
  labels = [[CLMutableDictionary alloc] init];
  entries = [[CLMutableArray alloc] init];
  subs = [[CLMutableDictionary alloc] init];
  subArgs = [[CLMutableDictionary alloc] init];

  return self;
}

-(void) dealloc
{
  [binary release];
  [stack release];
  [assembly release];
  [labels release];
  [entries release];
  [subs release];
  [subArgs release];
  [super dealloc];
  return;
}

-(void) pushStack:(CLUInteger) address
{
  CLNumber *num;
  

  num = [CLNumber numberWithUnsignedInt:address];
  if (address < origin || address >= [binary length] + origin) {
    if (![labels objectForKey:num]) {
#if 1
      fprintf(stderr, "Trying to disassemble outside of program: %04X\n", address);
      return;
#endif
      [self error:@"Trying to disassemble outside of program: %04X", address];
    }
    return;
  }
  
  if (![assembly objectForKey:num])
    [stack addObject:num];

  return;
}

-(void) addAssembly:(CLString *) line value:(CLUInteger) target
	     length:(CLUInteger) len entryPoint:(BOOL) entryFlag
		 at:(CLUInteger) address type:(OpcodeType) type
	     forced:(BOOL) forcedFlag
{
  Assembly *asmObj;
  CLNumber *nearest;


  nearest = [self assemblyWithAddress:[CLNumber numberWithUnsignedInt:address] length:len];
  if (nearest)
    [self error:@"Already have something there! %04X %04X", address,
	  [nearest unsignedIntValue]];
  asmObj = [[Assembly alloc] initFromString:line value:target length:len entryPoint:entryFlag
				       type:type forced:forcedFlag];
  [assembly setObject:asmObj forKey:[CLNumber numberWithUnsignedInt:address]];
  [asmObj release];
}

-(CLUInteger) valueAt:(CLUInteger) address length:(CLUInteger) length
{
  CLUInteger val;
  const unsigned char *bytes = [binary bytes];

  
  if (address < origin || address >= [binary length] + origin)
    [self error:@"Outside of scope: %04X", address];
  for (val = 0; length > 0; length--) {
    val <<= 8;
    val |= *(bytes + address - origin + length - 1);
  }

  return val;
}

-(CLUInteger) declareBytes:(CLUInteger) len at:(CLUInteger) address forced:(BOOL) forced
{
  CLMutableString *mString;
  int i, b;
  

  mString = [CLMutableString stringWithFormat:@"byt"];
  for (i = b = 0; i < len; i++, b++) {
    if (b)
      [mString appendString:@","];
    [mString appendFormat:@" %@",
	  [self formatHex:[self valueAt:address + i length:1] length:2]];
    if (b == 9) {
      [self addAssembly:mString value:0 length:b + 1 entryPoint:NO at:address + i - b
		   type:OpcodeConst forced:forced];
      b = -1;
      [mString setString:@"byt"];
    }
  }
  if (b)
    [self addAssembly:mString value:0 length:b entryPoint:NO at:address + i - b
		 type:OpcodeConst forced:forced];

  return len;
}

-(CLUInteger) declareString:(CLUInteger) len at:(CLUInteger) address forced:(BOOL) forced
{
  CLMutableString *mString;
  int i, b;
  CLUInteger val;
  

  mString = [CLMutableString stringWithFormat:@"byt \""];
  for (i = b = 0; i < len; i++, b++) {
    if (b == 40) {
      [mString appendString:@"\""];
      [self addAssembly:mString value:0 length:b entryPoint:NO at:address + i - b
		   type:OpcodeConst forced:forced];
      [mString setString:@"byt \""];
      b = 0;
    }

    val = [self valueAt:address + i length:1];
    if (val < 32 || val > 126)
      [mString appendFormat:@"\\x%02x", val];
    else if (val == '\'')
      [mString appendFormat:@"\\'"];
    else if (val == '"')
      [mString appendFormat:@"\\\""];
    else
      [mString appendFormat:@"%c", val];
  }
  [mString appendString:@"\""];
  if (b)
    [self addAssembly:mString value:0 length:b entryPoint:NO at:address + i - b
		 type:OpcodeConst forced:forced];

  return len;
}

-(CLUInteger) declareWords:(CLUInteger) len at:(CLUInteger) address forced:(BOOL) forced
{
  int i;
  CLUInteger val;
  

  for (i = 0; i < len; i++, address += 2) {
    val = [self valueAt:address length:2];
    [self addAssembly:@"adr %@" value:val length:2 entryPoint:NO at:address
		 type:OpcodeConst forced:forced];
  }

  return len * 2;
}

-(CLString *) labelForAddress:(CLUInteger) address
{
  CLString *aLabel;


  aLabel = [labels objectForKey:[CLNumber numberWithUnsignedInt:address]];
  if (!aLabel) {
    aLabel = [CLString stringWithFormat:@"L%04X", address];
  }

  return aLabel;
}

-(void) addLabel:(CLString *) aString at:(CLUInteger) address
{
  CLNumber *num = [CLNumber numberWithUnsignedInt:address];


  if (![labels objectForKey:num])
    [labels setObject:aString forKey:num];
  return;
}

-(CLNumber *) assemblyWithAddress:(CLNumber *) anAddress length:(CLUInteger) len
{
  CLArray *anArray;
  int i, j;
  Assembly *asmObj;
  CLNumber *asmAddress;
  CLUInteger a1, a2, a3, a4;

  
  anArray = [[assembly allKeys] sortedArrayUsingSelector:@selector(compare:)];
  a1 = [anAddress unsignedIntValue];
  a2 = a1 + len;
  for (i = 0, j = [anArray count]; i < j; i++) {
    if ([((CLNumber *) [anArray objectAtIndex:i]) unsignedIntValue] > a2)
      break;
  }

  if (i) {
    asmAddress = [anArray objectAtIndex:i-1];
    asmObj = [assembly objectForKey:asmAddress];
    a3 = [asmAddress unsignedIntValue];
    a4 = a3 + [asmObj length];
    if (a4 > a1 && a3 < a2)
      return asmAddress;
  }

  return nil;
}

-(void) disassembleFrom:(CLUInteger) start
{
  CLUInteger progCounter, val, instr, len;
  opcode *oc;
  CLString *label;
  CLNumber *anAddress;
  Assembly *asmObj;


  progCounter = start;
  [self addLabel:[self labelForAddress:progCounter] at:progCounter];
  
  for (;;) {
    if (progCounter < origin || progCounter >= [binary length] + origin)
      [self error:@"Trying to disassemble outside of program"];

    anAddress = [CLNumber numberWithUnsignedInt:progCounter];
    asmObj = [assembly objectForKey:anAddress];
    if ([asmObj type] & OpcodeJump)
      return;
    
    if (asmObj) {
      progCounter += [asmObj length];
      continue;
    }
    
    instr = [self valueAt:progCounter length:1];
    oc = &opcodes[instr];

    if ([oc->mnem isEqualToString:@"BRK"] || !oc->mnem) {
#if 1
      fprintf(stderr, "Unlikely: %04X $%02X\n", progCounter, oc->code);
      return;
#endif
      [self error:@"Unlikely: %04X $%02X", progCounter, oc->code];
    }

    if (oc->length - 1)
      val = [self valueAt:progCounter + 1 length:oc->length - 1];

    len = oc->length - 1;
    label = nil;
    
    if (len && !(oc->type & OpcodeImmediate)) {
      if (oc->type & OpcodeRelative) {
	val = ((int8_t) val) + progCounter + oc->length;
	len = 2;
      }
	
      if (len == 2) {
	CLNumber *num;


	num = [CLNumber numberWithUnsignedInt:val];
	if ((val >= origin && val < [binary length] + origin) ||
	    [labels objectForKey:num]) {
	  label = [self labelForAddress:val];
	  [self addLabel:label at:val];
	}
      }
    }

    {
      Assembly *asmObj;
      CLNumber *anAddress, *nearest;


      anAddress = [CLNumber numberWithUnsignedInt:progCounter];
      nearest = [self assemblyWithAddress:anAddress length:oc->length];
      asmObj = [assembly objectForKey:nearest];
      if ([nearest compare:anAddress]) {
	len = [anAddress unsignedIntValue] - [nearest unsignedIntValue];
	[assembly removeObjectForKey:nearest];
	[self declareBytes:len at:[nearest unsignedIntValue] forced:NO];
	asmObj = nil;
      }
      if (!asmObj)
	[self addAssembly:oc->mnem value:val length:oc->length
	       entryPoint:progCounter == start at:progCounter type:oc->type forced:NO];
    }

    progCounter += oc->length;
    
    if (oc->type & OpcodeBranch || oc->type & OpcodeCall) {
      [self pushStack:val];

      if (oc->type & OpcodeCall) {
	SubroutineArguments *args;


	args = [subArgs objectForKey:[CLNumber numberWithUnsignedInt:val]];
	if (args) {
	  len = [args declareArguments:self at:progCounter];
	  progCounter += len;
	}
      }
    }

    if (oc->type & OpcodeJump) {
      if (!(oc->type & OpcodeIndirect))
	[self pushStack:val];
      return;
    }
    else if (oc->type & OpcodeReturn)
      return;
  }

  return;
}

-(void) declareDataFrom:(CLUInteger) start to:(CLUInteger) end
{
  CLInteger len = end - start;
  int i, j, b, val, dval, si, mode;
  CLMutableString *mString;
  CLString *aLabel;
  CLNumber *anAddress;


  if (end < start)
    [self error:@"What?"];
  
  mString = [[CLMutableString alloc] init];

  [self addLabel:[self labelForAddress:start] at:start];

#if 1 /* FIXME - make a command line flag */
  /* Create labels for things that look like addresses */
  for (si = 0; si < len - 1; si++) {
    val = [self valueAt:start + si length:2];
    anAddress = [CLNumber numberWithUnsignedInt:val];
    aLabel = [labels objectForKey:anAddress];
    if (!aLabel && val >= origin && val < [binary length] + origin) {
      aLabel = [self labelForAddress:val];
      [self addLabel:aLabel at:val];
      si++;

#if 0
      asmAddress = [self assemblyWithAddress:anAddress length:si];
      if ([asmAddress compare:anAddress]) {
	asmObj = [assembly objectForKey:asmAddress];
	fprintf(stderr, "Entry into existing block $%04x $%04x\n", val,
		[asmAddress unsignedIntValue]);
      }
#endif
    }
  }
#endif
  
  for (i = 0; i < len; ) {
    mode = ModeNone;
    for (si = i; si < len; si++) {
      if (si > i && [labels objectForKey:[CLNumber numberWithUnsignedInt:si]])
	break;
      
      val = [self valueAt:start + si length:1];
      aLabel = nil;
#if 1
      /* Use labels for things that look like addresses */
      if (si < len - 1) {
	dval = [self valueAt:start + si length:2];
	anAddress = [CLNumber numberWithUnsignedInt:dval];
	aLabel = [labels objectForKey:anAddress];
      }

      if (aLabel) {
	if (si - i)
	  break;

	[self declareWords:1 at:start + si forced:NO];
	si += 2;
	i += 2;
	break;
      }
#endif

#if 1
      if (val >= ' ' && val <= '~') {
	if (mode == ModeBinary)
	  break;
	mode = ModeString;
      }
      else {
	if (mode == ModeString)
	  break;
	mode = ModeBinary;
      }
#else
      mode = ModeBinary;
#endif
    }

    if (si - i) {
      if (mode == ModeBinary) {
	[mString setString:@"byt"];
	for (j = i, b = 0; j < si; j++, b++) {
	  if (b)
	    [mString appendString:@","];
	  [mString appendFormat:@" %@",
		[self formatHex:[self valueAt:start + j length:1] length:2]];
	  if (b == 9) {
	    [self addAssembly:mString value:0 length:b + 1 entryPoint:NO
			   at:start + j - b type:OpcodeConst forced:NO];
	    b = -1;
	    [mString setString:@"byt"];
	  }
	}
	if (b)
	  [self addAssembly:mString value:0 length:b entryPoint:NO at:start + j - b
		       type:OpcodeConst forced:NO];
      }
      else {
	[mString setString:@"byt \""];
	for (j = i; j < si; j++) {
	  val = [self valueAt:start + j length:1];
	  if (val == '\\' || val == '"') {
	    [mString appendString:@"\\"];
	    if (val == '"')
	      val = 'I';
	  }
	  [mString appendFormat:@"%c", val];
	}
	[mString appendString:@"\""];
	[self addAssembly:mString value:0 length:si - i entryPoint:NO at:start + i
		     type:OpcodeConst forced:NO];
      }
    }

    i = si;
  }

  [mString release];
  return;
}

-(Assembly *) findDataBlock:(CLNumber *) address
{
  int i, j;
  CLArray *anArray;
  CLNumber *num;
  Assembly *asmObj;


  anArray = [assembly allKeys];
  for (i = 0, j = [anArray count]; i < j; i++) {
    num = [anArray objectAtIndex:i];
    if ([num compare:address] <= 0) {
      asmObj = [assembly objectForKey:num];
      if ([num unsignedIntValue] + [asmObj length] > [address unsignedIntValue])
	return asmObj;
    }
  }

  return nil;
}

-(CLNumber *) nextLabeledAddressAfter:(CLNumber *) anAddress
{
  CLArray *anArray;
  int i, j;
  CLNumber *asmAddress;


  anArray = [[labels allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (i = 0, j = [anArray count]; i < j; i++) {
    asmAddress = [anArray objectAtIndex:i];
    if ([assembly objectForKey:asmAddress] && [asmAddress compare:anAddress] > 0)
      return asmAddress;
  }

  return nil;
}

-(CLNumber *) hashBlockAt:(CLNumber *) anAddress
{
  CLNumber *next = [self nextLabeledAddressAfter:anAddress];
  CLMutableString *mString;
  Assembly *asmObj;
  CLString *line;


  if (!next)
    next = [CLNumber numberWithUnsignedInt:origin + [binary length]];
  mString = [CLMutableString string];
  while ([anAddress compare:next] < 0) {
    if (!(asmObj = [assembly objectForKey:anAddress]))
      break;
    if ([asmObj length] < 3 && !([asmObj type] & OpcodeRelative) &&
	!([asmObj type] & OpcodeConst))
      line = [asmObj lineWithLabel:nil disassembler:self];
    else
      line = [asmObj line];
    [mString appendString:line];
    anAddress = [CLNumber numberWithUnsignedInt:
			    [anAddress unsignedIntValue] + [asmObj length]];
  }

  return [CLNumber numberWithUnsignedInt:[mString hash] & 0xffff];
}

-(void) disassemble
{
  CLUInteger progCounter;
  CLAutoreleasePool *pool;
  CLArray *anArray;
  int i, j;
  Assembly *asmObj;
  CLNumber *num;
  CLString *label;
  CLMutableDictionary *refCount;

  
  [stack removeAllObjects];
  [stack addObjectsFromArray:entries];

  while ([stack count]) {
    pool = [[CLAutoreleasePool alloc] init];
    num = [stack lastObject];
    progCounter = [num unsignedIntValue];
    [stack removeLastObject];
    if (![assembly objectForKey:num])
      [self disassembleFrom:progCounter];
    [pool release];
  }

  anArray = [[assembly allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (i = 0, progCounter = origin, j = [anArray count]; i < j; i++) {
    num = [anArray objectAtIndex:i];
    asmObj = [assembly objectForKey:num];
    if (progCounter < [num unsignedIntValue] && [num unsignedIntValue] - progCounter)
      [self declareDataFrom:progCounter to:[num unsignedIntValue]];
    progCounter = [num unsignedIntValue] + [asmObj length];
  }

  if ([binary length] - progCounter)
    [self declareDataFrom:progCounter to:[binary length] + origin];

  {
    CLNumber *addr;
    CLUInteger address, end;


    end = [binary length] + origin;
    anArray = [labels allKeys];
    for (i = [anArray count] - 1; i >= 0; i--) {
      addr = [anArray objectAtIndex:i];
      address = [addr unsignedIntValue];
      if (address >= origin && address < end && ![assembly objectForKey:addr])
	[labels removeObjectForKey:addr];
    }
  }
  
  {
    CLNumber *anAddress, *asmAddress;
    CLString *newLabel;

    
    anArray = [[labels allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (i = 0, j = [anArray count]; i < j; i++) {
      anAddress = [anArray objectAtIndex:i];
      asmAddress = [self assemblyWithAddress:anAddress length:1];
      if ([asmAddress compare:anAddress]) {
	asmObj = [assembly objectForKey:asmAddress];
	newLabel = [CLString stringWithFormat:@"%@+%i",
			[self labelForAddress:[asmAddress unsignedIntValue]],
			     [anAddress unsignedIntValue] - [asmAddress unsignedIntValue]];
	[labels setObject:newLabel forKey:anAddress];
	if (![labels objectForKey:asmAddress])
	  [labels setObject:[self labelForAddress:[asmAddress unsignedIntValue]]
		     forKey:asmAddress];
#if 0	
	/* FIXME - make sure all labels within binary are pointing to
	   something by splitting data blocks */

	fprintf(stderr, "Entry into existing block $%04x $%04x\n", val,
		[asmAddress unsignedIntValue]);
#endif
      }
    }
  }

  if (hashedLabels) {
    CLNumber *anAddress, *hash;
    CLString *newLabel, *oldLabel;
    CLMutableDictionary *remap, *remap2;
    CLRange aRange;
    int lno;
    CLUInteger dval;


    remap = [CLMutableDictionary dictionary];
    remap2 = [CLMutableDictionary dictionary];
    anArray = [[labels allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (i = lno = 0, j = [anArray count]; i < j; i++) {
      anAddress = [anArray objectAtIndex:i];
      dval = [anAddress unsignedIntValue];
      if (dval < origin || dval >= origin + [binary length])
	continue;
      oldLabel = [labels objectForKey:anAddress];
      if ([subs objectForKey:anAddress]) {
	[remap setObject:oldLabel forKey:oldLabel];
	continue;
      }
      
      aRange = [oldLabel rangeOfString:@"+"];
      hash = [self hashBlockAt:anAddress];
      if (aRange.length)
	newLabel = [[remap objectForKey:[oldLabel substringToIndex:aRange.location]]
		     stringByAppendingString:[oldLabel substringFromIndex:aRange.location]];
      else {
	newLabel = [CLString stringWithFormat:@"G%04X", [hash unsignedIntValue]];
	if ([[remap2 allKeysForObject:hash] count]) {
	  /* FIXME - go to double characters if count is > 'Z' */
	  newLabel = [CLString stringWithFormat:@"%c%04X",
			       'G' + [[remap2 allKeysForObject:hash] count],
			       [hash unsignedIntValue]];
	  //[self error:@"Collision"];
	}
      }
      [remap setObject:newLabel forKey:oldLabel];
      [remap2 setObject:hash forKey:oldLabel];
      [labels setObject:newLabel forKey:anAddress];
    }
  }

  {
    CLNumber *num;
    Assembly *asmObj;
    CLUInteger count;
    CLString *label;
    CLRange aRange;

    
    refCount = [CLMutableDictionary dictionary];
    
    anArray = [assembly allValues];
    for (i = 0, j = [anArray count]; i < j; i++) {
      asmObj = [anArray objectAtIndex:i];
      if ([asmObj length] > 1 && !([asmObj type] & OpcodeImmediate)) {
	num = [CLNumber numberWithUnsignedInt:[asmObj value]];
	if ((label = [labels objectForKey:num])) {
	  aRange = [label rangeOfString:@"+"];
	  if (aRange.length)
	    label = [label substringToIndex:aRange.location];
	  count = [[refCount objectForKey:label] unsignedIntValue] + 1;
	  [refCount setObject:[CLNumber numberWithUnsignedInt:count] forKey:label];
	}
      }
    }
  }

  printf("\tORG %s\n", [[self formatHex:origin length:4] UTF8String]);
  printf("\n");

  {
    CLNumber *anAddress;
    CLMutableArray *mArray;

    
    mArray = [[[subs allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    [mArray removeObjectsInArray:[assembly allKeys]];
    for (i = 0, j = [mArray count]; i < j; i++) {
      anAddress = [mArray objectAtIndex:i];
      label = [subs objectForKey:anAddress];
      if ([refCount objectForKey:label])
	printf("%s\tEQU %s\n", [label UTF8String],
	       [[self formatHex:[anAddress unsignedIntValue] length:4] UTF8String]);
    }
    printf("\n");
  }
  
  anArray = [[assembly allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (i = 0, j = [anArray count]; i < j; i++) {
    num = [anArray objectAtIndex:i];
    asmObj = [assembly objectForKey:num];
    if (i && [asmObj isEntryPoint])
      printf("\n");
    label = [labels objectForKey:num];
#if 0
    if (label && ![refCount objectForKey:label] && ![subs objectForKey:num])
      label = nil;
#endif
    label = [label stringByAppendingString:@":"];
    printf("%s\t%s", label ? [label UTF8String] : "",
	   [[asmObj lineWithLabel:labels disassembler:self] UTF8String]);
    if (label && hashedLabels)
      printf("\t; $%04X", [[anArray objectAtIndex:i] unsignedIntValue]);
    printf("\n");
  }
  
  return;
}

-(void) addLabels:(CLString *) labelString
{
  CLArray *anArray, *constant;
  int i, j;
  CLString *aString, *types;
  CLUInteger addr;
  CLCharacterSet *sep = [CLCharacterSet characterSetWithCharactersInString:@",\n"];
  CLRange aRange;
  SubroutineArguments *args;
  

  /* FIXME - allow setting comments */
  
  if (access([labelString UTF8String], F_OK) == 0) {
    aString = [CLString stringWithContentsOfFile:labelString encoding:CLUTF8StringEncoding];
    labelString = aString;
  }
  
  anArray = [labelString componentsSeparatedByCharactersInSet:sep];
  for (i = 0, j = [anArray count]; i < j; i++) {
    aString = [[anArray objectAtIndex:i] stringByTrimmingWhitespaceAndNewlines];
    if (![aString length] || [aString hasPrefix:@";"] || [aString hasPrefix:@"#"])
      continue;

    aRange = [aString rangeOfString:@"/"];
    types = nil;
    if (aRange.length) {
      types = [[aString substringFromIndex:CLMaxRange(aRange)]
		stringByTrimmingWhitespaceAndNewlines];
      aString = [[aString substringToIndex:aRange.location]
		  stringByTrimmingWhitespaceAndNewlines];
    }

    constant = [aString componentsSeparatedByString:@"="];
    if ([constant count] > 1) {
      addr = parseUnsigned([constant objectAtIndex:1]);
      [self addConstant:[[constant objectAtIndex:0] stringByTrimmingWhitespaceAndNewlines]
		       at:addr];
    }
    else {
      addr = parseUnsigned([constant objectAtIndex:0]);
      aString = [self labelForAddress:addr];
      [self addLabel:aString at:addr];
    }

    if (types) {
      args = [[SubroutineArguments alloc] initFromString:types];
      [subArgs setObject:args forKey:[CLNumber numberWithUnsignedInt:addr]];
      [args release];
    }
  }

  return;
}

-(void) addEntryPoints:(CLString *) entryString
{
  CLArray *anArray;
  int i, j;
  CLString *aString, *types;
  CLCharacterSet *sep = [CLCharacterSet characterSetWithCharactersInString:@",\n"];
  CLRange aRange;
  CLNumber *addr;
  SubroutineArguments *args;
  

  /* FIXME - allow setting comments */
  
  if (access([entryString UTF8String], F_OK) == 0) {
    aString = [CLString stringWithContentsOfFile:entryString encoding:CLUTF8StringEncoding];
    entryString = aString;
  }
  
  anArray = [entryString componentsSeparatedByCharactersInSet:sep];
  for (i = 0, j = [anArray count]; i < j; i++) {
    aString = [[anArray objectAtIndex:i] stringByTrimmingWhitespaceAndNewlines];
    if (![aString length] || [aString hasPrefix:@";"] || [aString hasPrefix:@"#"])
      continue;

    aRange = [aString rangeOfString:@"/"];
    types = nil;
    if (aRange.length) {
      types = [[aString substringFromIndex:CLMaxRange(aRange)]
		stringByTrimmingWhitespaceAndNewlines];
      aString = [[aString substringToIndex:aRange.location]
		  stringByTrimmingWhitespaceAndNewlines];
    }

    addr = [CLNumber numberWithUnsignedInt:parseUnsigned(aString)];
    [entries addObject:addr];
    if (types) {
      args = [[SubroutineArguments alloc] initFromString:types];
      [subArgs setObject:args forKey:addr];
      [args release];
    }
  }

  return;
}

-(void) addDataBlocks:(CLString *) blockString
{
  CLArray *anArray;
  int i, j, type, len;
  CLString *aString;
  CLCharacterSet *sep = [CLCharacterSet characterSetWithCharactersInString:@",\n"];
  CLRange aRange;
  CLUInteger begin, end;
  

  /* FIXME - allow setting comments */
  
  if (access([blockString UTF8String], F_OK) == 0) {
    aString = [CLString stringWithContentsOfFile:blockString encoding:CLUTF8StringEncoding];
    blockString = aString;
  }
  
  anArray = [blockString componentsSeparatedByCharactersInSet:sep];
  for (i = 0, j = [anArray count]; i < j; i++) {
    aString = [[anArray objectAtIndex:i] stringByTrimmingWhitespaceAndNewlines];
    if (![aString length] || [aString hasPrefix:@";"] || [aString hasPrefix:@"#"])
      continue;

    type = 0;
    aRange = [aString rangeOfString:@"/"];
    if (aRange.length) {
      type = [[[[aString substringFromIndex:CLMaxRange(aRange)]
			stringByTrimmingWhitespaceAndNewlines] uppercaseString]
	       characterAtIndex:0];
      aString = [aString substringToIndex:aRange.location];
    }
    aRange = [aString rangeOfString:@":"];
    if (aRange.length) {
      begin = parseUnsigned([[aString substringToIndex:aRange.location]
			      stringByTrimmingWhitespaceAndNewlines]);
      end = parseUnsigned([[aString substringFromIndex:CLMaxRange(aRange)]
			      stringByTrimmingWhitespaceAndNewlines]);
    }
    else 
      begin = end = parseUnsigned([aString stringByTrimmingWhitespaceAndNewlines]);

    if (type == 'A' || type == 'W') {
      len = (end - begin + 2) / 2;
      [self declareWords:len at:begin forced:YES];
    }
    else if (type == 'C') {
      for (; [self valueAt:end length:1]; end++)
	;
      len = end - begin + 1;
      [self declareString:len at:begin forced:YES];
    }
    else {
      len = end - begin + 1;
      if (type == 'S')
	[self declareString:len at:begin forced:YES];
      else
	[self declareBytes:len at:begin forced:YES];
    }
  }

  return;
}

-(CLString *) formatHex:(CLUInteger) aValue length:(CLUInteger) len
{
  return [CLString stringWithFormat:@"$%0*X", len, aValue];
}

-(void) addConstant:(CLString *) label at:(CLUInteger) address
{
  CLNumber *anAddress;


  anAddress = [CLNumber numberWithUnsignedInt:address];
  [subs setObject:label forKey:anAddress];
  [labels setObject:label forKey:anAddress];
  return;
}

-(void) setConstants:(CLString *) aString
{
  int i;
  constant *defsubs;

  
  if (aString && ![aString caseInsensitiveCompare:@"vic20"])
    defsubs = vic20Subs;
  else
    defsubs = appleSubs;

  for (i = 0; defsubs[i].label; i++)
    [self addConstant:defsubs[i].label at:defsubs[i].address];
  
  return;
}

-(void) setHashedLabels:(BOOL) flag
{
  hashedLabels = flag;
  return;
}

@end
