/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import "Disassembler.h"
#import "Assembly.h"
#import "AppleLabels.h"
#import "VIC20Labels.h"
#import "disasm.h"

#import "opcode6502.h"

#if 0
#if EPSON
#define DUNNO1 0x589C
#define INIBUF 0x5A0A
#define FREBUF 0x5A49
#define ZPSAVE 0x5A6F
#define DUNNO2 0x5B0E
#else
#define DUNNO1 0x5952
#define INIBUF 0x5AC0
#define FREBUF 0x5AFF
#define ZPSAVE 0x5B25
#define DUNNO2 0x5BC4
#endif
#endif

enum {
  ModeNone = 0,
  ModeString,
  ModeBinary,
  ModeAddress,
};

@implementation Disassembler

-(id) init
{
  return [self initWithBinary:nil origin:0 entry:0];
}

-(id) initWithBinary:(CLData *) aData origin:(CLUInteger) org entry:(CLUInteger) ent
{
  [super init];
  binary = [aData retain];
  origin = org;
  entry = ent;
  stack = [[CLMutableArray alloc] init];
  assembly = [[CLMutableDictionary alloc] init];
  labels = [[CLMutableDictionary alloc] init];

  return self;
}

-(void) dealloc
{
  [binary release];
  [stack release];
  [assembly release];
  [labels release];
  [super dealloc];
  return;
}

-(void) pushStack:(CLUInteger) address
{
  CLNumber *num;
  

  num = [CLNumber numberWithUnsignedInt:address];
  if (address < origin || address >= [binary length] + origin) {
    if (![labels objectForKey:num])
      [self error:@"Trying to disassemble outside of program: %04X", address];
    return;
  }
  
  if (![assembly objectForKey:num])
    [stack addObject:num];

  return;
}

-(void) addAssembly:(CLString *) line value:(CLUInteger) target
	     length:(CLUInteger) len entryPoint:(BOOL) flag
		 at:(CLUInteger) address type:(OpcodeType) type
{
  Assembly *asmObj;


  asmObj = [[Assembly alloc] initFromString:line value:target length:len entryPoint:flag
				       type:type];
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

-(CLUInteger) declareBytes:(CLUInteger) len at:(CLUInteger) address
{
  CLMutableString *mString;
  int i;
  

  mString = [CLMutableString stringWithFormat:@"byt"];
  for (i = 0; i < len; i++) {
    if (i)
      [mString appendString:@","];
    [mString appendFormat:@" %@",
	  [self formatHex:[self valueAt:address + i length:1] length:2]];
  }
  [self addAssembly:mString value:0 length:len entryPoint:NO at:address type:OpcodeConst];

  return len;
}

-(CLUInteger) declareWords:(CLUInteger) len at:(CLUInteger) address
{
  int i;
  CLUInteger val;
  

  for (i = 0; i < len; i++) {
    val = [self valueAt:address length:2];
    [self addAssembly:@"adr %@" value:val length:2 entryPoint:NO at:address
		 type:OpcodeConst];
  }

  return len * 2;
}

-(CLString *) labelForAddress:(CLUInteger) address
{
  uint16_t offset;

  
  if (relativeLabels) {
    offset = address;
    offset -= entry;
    return [CLString stringWithFormat:@"R%04X", offset];
  }
  
  return [CLString stringWithFormat:@"L%04X", address];
}

-(void) addLabel:(CLString *) aString at:(CLUInteger) address
{
  CLNumber *num = [CLNumber numberWithUnsignedInt:address];


  if (![labels objectForKey:num])
    [labels setObject:aString forKey:num];
  return;
}

-(CLNumber *) assemblyWithAddress:(CLNumber *) anAddress
{
  CLArray *anArray;
  int i, j;
  Assembly *asmObj;
  CLNumber *asmAddress;

  
  anArray = [[assembly allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (i = 0, j = [anArray count]; i < j; i++) {
    if ([((CLNumber *) [anArray objectAtIndex:i]) compare:anAddress] > 0)
      break;
  }

  if (i) {
    asmAddress = [anArray objectAtIndex:i-1];
    asmObj = [assembly objectForKey:asmAddress];
    if ([asmObj length] + [asmAddress unsignedIntValue] > [anAddress unsignedIntValue])
      return asmAddress;
  }

  return nil;
}

-(void) disassembleFrom:(CLUInteger) start
{
  CLUInteger progCounter, val, instr, len;
  opcode *oc;
  CLString *label;


  progCounter = start;
  [self addLabel:[self labelForAddress:progCounter] at:progCounter];
  
  for (;;) {
    if (progCounter < origin || progCounter >= [binary length] + origin)
      [self error:@"Trying to disassemble outside of program"];

    instr = [self valueAt:progCounter length:1];
    oc = &opcodes[instr];

    if ([oc->mnem isEqualToString:@"BRK"] || !oc->mnem)
      [self error:@"Unlikely: %04X $%02X", progCounter, oc->code];

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
      nearest = [self assemblyWithAddress:anAddress];
      asmObj = [assembly objectForKey:nearest];
      if ([nearest compare:anAddress]) {
	len = [anAddress unsignedIntValue] - [nearest unsignedIntValue];
	[assembly removeObjectForKey:nearest];
	[self declareBytes:len at:[nearest unsignedIntValue]];
	asmObj = nil;
      }
      if (!asmObj)
	[self addAssembly:oc->mnem value:val length:oc->length
	       entryPoint:progCounter == start at:progCounter type:oc->type];
    }

    progCounter += oc->length;
    
    if (oc->type & OpcodeBranch || oc->type & OpcodeCall) {
      [self pushStack:val];

#if 0
      /* FIXME - don't hardcode this in */
      if (oc->type & OpcodeCall) {
	switch (val) {
	case DUNNO1:
	  {
	    int addrCount;


	    addrCount = [self valueAt:progCounter + 2 length:1] + 1;

	    progCounter += [self declareBytes:4 at:progCounter];

	    for (; addrCount; addrCount--) {
	      val = [self valueAt:progCounter length:2];
	      if (val >= origin && val < [binary length] + origin)
		[self pushStack:val];
	      progCounter += [self declareWords:1 at:progCounter];
	    }
	  }
	  break;
	  
	case INIBUF:
	  val = [self valueAt:progCounter length:2];
	  [self pushStack:val];
	  progCounter += [self declareWords:1 at:progCounter];
	  break;

	case FREBUF:
	  progCounter += [self declareBytes:1 at:progCounter];
	  break;

	case ZPSAVE:
	  progCounter += [self declareBytes:1 at:progCounter];
	  progCounter += [self declareWords:1 at:progCounter];
	  break;

	case DUNNO2:
	  {
	    int addrCount;


	    addrCount = [self valueAt:progCounter length:1] * 2;
	    
	    progCounter += [self declareBytes:4 at:progCounter];

	    for (; addrCount; addrCount--) {
	      val = [self valueAt:progCounter length:2];
	      if (val >= origin && val < [binary length] + origin)
		[self pushStack:val];
	      progCounter += [self declareWords:1 at:progCounter];
	    }
	  }
	  break;
	}
      }
#endif
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
  CLUInteger len = end - start;
  int i, j, b, val, dval, si, mode;
  CLMutableString *mString;
  CLString *aLabel;
  CLNumber *anAddress;


  if (end < start)
    [self error:@"What?"];
  
  mString = [[CLMutableString alloc] init];

  [self addLabel:[self labelForAddress:start] at:start];

#if 1
  for (si = 0; si < len - 1; si++) {
    val = [self valueAt:start + si length:2];
    anAddress = [CLNumber numberWithUnsignedInt:val];
    aLabel = [labels objectForKey:anAddress];
    if (!aLabel && val >= origin && val < [binary length] + origin) {
      aLabel = [self labelForAddress:val];
      [self addLabel:aLabel at:val];

#if 0
      asmAddress = [self assemblyWithAddress:anAddress];
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
      if (si < len - 1) {
	dval = [self valueAt:start + si length:2];
	anAddress = [CLNumber numberWithUnsignedInt:dval];
	aLabel = [labels objectForKey:anAddress];
      }

      if (aLabel) {
	if (si - i)
	  break;

	[self declareWords:1 at:start + si];
	si += 2;
	i += 2;
	break;
      }

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
			   at:start + j - b type:OpcodeConst];
	    b = -1;
	    [mString setString:@"byt"];
	  }
	}
	if (b)
	  [self addAssembly:mString value:0 length:b entryPoint:NO at:start + j - b
		       type:OpcodeConst];
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
		     type:OpcodeConst];
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
  Assembly *asmObj;


  asmObj = [assembly objectForKey:anAddress];
#if 0
  anAddress = [CLNumber numberWithUnsignedInt:[anAddress unsignedIntValue] + [asmObj length]];
#endif
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
  CLNumber *start, *next = [self nextLabeledAddressAfter:anAddress];
  CLMutableString *mString;
  Assembly *asmObj;
  CLString *line;


  if (!next)
    next = [CLNumber numberWithUnsignedInt:origin + [binary length]];
  start = anAddress;
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
#if 0
  fprintf(stderr, "%04x: %s\n", [start unsignedIntValue], [mString UTF8String]);
#endif

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
  CLUInteger val;

  
  [stack removeAllObjects];
  [stack addObject:[CLNumber numberWithUnsignedInt:entry]];
#if 0
  [stack addObject:[CLNumber numberWithUnsignedInt:entry + 16]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x233A]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x2399]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x23E2]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x342A]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x3440]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x345F]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x4011]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x407E]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x4B09]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x54B7]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5539]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5594]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5622]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5870]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5923]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5940]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5AE7]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5BD3]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5BF8]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5C1B]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5C6A]];
  [stack addObject:[CLNumber numberWithUnsignedInt:0x5C99]];
#else
  [stack addObject:[CLNumber numberWithUnsignedInt:0xA2B0]];
#endif

  while ([stack count]) {
    pool = [[CLAutoreleasePool alloc] init];
    num = [stack lastObject];
    progCounter = [num unsignedIntValue];
    [stack removeLastObject];
    if (![assembly objectForKey:num])
      [self disassembleFrom:progCounter];
    [pool release];
  }

  anArray = [[labels allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (i = 0, j = [anArray count]; i < j; i++) {
    num = [anArray objectAtIndex:i];
    val = [num unsignedIntValue];
    if (val >= origin && val < origin + [binary length] && ![assembly objectForKey:num]) {
      [self declareDataFrom:[num unsignedIntValue] to:[num unsignedIntValue] + 1];
    }
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

  /* FIXME - make sure all labels within binary are pointing to
     something by splitting data blocks */

  {
    CLNumber *anAddress, *asmAddress;
    CLString *newLabel;

    
    anArray = [[labels allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (i = 0, j = [anArray count]; i < j; i++) {
      anAddress = [anArray objectAtIndex:i];
      val = [anAddress unsignedIntValue];

      asmAddress = [self assemblyWithAddress:anAddress];
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
	fprintf(stderr, "Entry into existing block $%04x $%04x\n", val,
		[asmAddress unsignedIntValue]);
#endif
      }
    }
  }

  {
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
      aRange = [oldLabel rangeOfString:@"+"];
      hash = [self hashBlockAt:anAddress];
      if (aRange.length)
	newLabel = [[remap objectForKey:[oldLabel substringToIndex:aRange.location]]
		     stringByAppendingString:[oldLabel substringFromIndex:aRange.location]];
      else {
	newLabel = [CLString stringWithFormat:@"G%04X", [hash unsignedIntValue]];
	if ([[remap2 allKeysForObject:hash] count]) {
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
  
  printf("\tORG %s\n", [[self formatHex:origin length:4] UTF8String]);
  printf("\n");

  for (i = 0; subs[i].label; i++)
    printf("%s\tEQU %s\n", [subs[i].label UTF8String],
	   [[self formatHex:subs[i].address length:4] UTF8String]);
  printf("\n");
  
  anArray = [[assembly allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (i = 0, j = [anArray count]; i < j; i++) {
    num = [anArray objectAtIndex:i];
    asmObj = [assembly objectForKey:num];
    if (i && [asmObj isEntryPoint])
      printf("\n");
    label = [[labels objectForKey:num] stringByAppendingString:@":"];
    printf("%s\t%s", label ? [label UTF8String] : "",
	   [[asmObj lineWithLabel:labels disassembler:self] UTF8String]);
#if 1
    if (label)
      printf("\t; $%04X", [[anArray objectAtIndex:i] unsignedIntValue]);
#endif
    printf("\n");
  }
  
  return;
}

-(void) addLabels:(CLString *) aString
{
  CLArray *anArray, *label;
  int i, j;


  anArray = [aString componentsSeparatedByString:@","];
  for (i = 0, j = [anArray count]; i < j; i++) {
    label = [[anArray objectAtIndex:i] componentsSeparatedByString:@"="];
    [self addLabel:[[label objectAtIndex:1] stringByTrimmingWhitespaceAndNewlines]
		at:parseUnsigned([label objectAtIndex:0])];
  }

  return;
}

-(CLString *) formatHex:(CLUInteger) aValue length:(CLUInteger) len
{
#if CSTYLE
  return [CLString stringWithFormat:@"0x%0*X", len, aValue];
#else
  return [CLString stringWithFormat:@"$%0*X", len, aValue];
#endif
}

-(void) setSubroutines:(CLString *) aString
{
  int i;

  
  if (![aString caseInsensitiveCompare:@"vic20"])
    subs = vic20Subs;
  else
    subs = appleSubs;

  for (i = 0; subs[i].label; i++)
    [labels setObject:subs[i].label
	       forKey:[CLNumber numberWithUnsignedInt:subs[i].address]];
  
  return;
}

-(void) setRelativeLabels:(BOOL) flag
{
  relativeLabels = flag;
  return;
}

@end
