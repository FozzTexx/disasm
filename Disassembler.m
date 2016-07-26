/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import "Disassembler.h"
#import "Assembly.h"
#import "AppleLabels.h"

typedef struct {
  int length;
  CLString *mnem;
  int type;
} opcode;

#import "opcode6502.h"

@implementation Disassembler

-(id) init
{
  return [self initWithBinary:nil origin:0 entry:0];
}

-(id) initWithBinary:(CLData *) aData origin:(CLUInteger) org entry:(CLUInteger) ent
{
  int i;

  
  [super init];
  binary = [aData retain];
  origin = org;
  entry = ent;
  stack = [[CLMutableArray alloc] init];
  assembly = [[CLMutableDictionary alloc] init];
  labels = [[CLMutableDictionary alloc] init];

  for (i = 0; appleSubs[i].label; i++)
    [labels setObject:appleSubs[i].label
	       forKey:[CLNumber numberWithUnsignedInt:appleSubs[i].address]];
  
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
		 at:(CLUInteger) address
{
  Assembly *asmObj;


  asmObj = [[Assembly alloc] initFromString:line value:target length:len entryPoint:NO];
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
    [mString appendFormat:@" $%02X", [self valueAt:address + i length:1]];
  }
  [self addAssembly:mString value:0 length:len entryPoint:NO at:address];

  return len;
}

-(CLUInteger) declareWords:(CLUInteger) len at:(CLUInteger) address
{
  int i;
  CLUInteger val;
  

  for (i = 0; i < len; i++) {
    val = [self valueAt:address length:2];
    [self addAssembly:@"adr %@" value:val length:len * 2 entryPoint:NO at:address];
  }

  return len * 2;
}

-(void) addLabel:(CLString *) aString at:(CLUInteger) address
{
  CLNumber *num = [CLNumber numberWithUnsignedInt:address];


  if (![labels objectForKey:num])
    [labels setObject:aString forKey:num];
  return;
}

-(void) disassembleFrom:(CLUInteger) start
{
  CLUInteger progCounter, val, instr, len;
  opcode *oc;
  CLMutableString *mString;


  progCounter = start;
  [self addLabel:[CLString stringWithFormat:@"L%04X", progCounter] at:progCounter];
  
  for (;;) {
    if (progCounter < origin || progCounter >= [binary length] + origin)
      [self error:@"Trying to disassemble outside of program"];

    instr = [self valueAt:progCounter length:1];
    oc = &opcodes[instr];

    if ([oc->mnem isEqualToString:@"BRK"])
      [self error:@"Unlikely: %04X", progCounter];

    if (oc->length - 1)
      val = [self valueAt:progCounter + 1 length:oc->length - 1];
    mString = [CLMutableString stringWithFormat:@"%@", oc->mnem];

    len = oc->length - 1;
    if (len) {
      switch (oc->type) {
      case 'B':
	val = ((int8_t) val) + progCounter + oc->length;
	/* Fall-through intentional */
      case 0:
	{
	  CLString *label;
	  CLNumber *num;


	  num = [CLNumber numberWithUnsignedInt:val];
	  if ((val >= origin && val < [binary length] + origin) ||
	      [labels objectForKey:num]) {
	    label = [CLString stringWithFormat:@"L%04X", val];
	    [mString appendString:@" %@"]; /* Will write the label on output */
	    [self addLabel:label at:val];
	  }
	  else 
	    [mString appendFormat:@" $%0*X", len * 2, val];
	}
	break;
      case '#':
	[mString appendFormat:@" #$%0*X", len * 2, val];
	break;
      case '-':
	[mString appendFormat:@" ($%0*X),Y", len * 2, val];
	break;
      case '+':
	[mString appendFormat:@" ($%0*X,X)", len * 2, val];
	break;
      case '(':
	[mString appendFormat:@" ($%0*X)", len * 2, val];
	break;
      case '[':
	[mString appendFormat:@" [$%0*X]", len * 2, val];
	break;
      case 'X':
      case 'Y':
	[mString appendFormat:@" $%0*X,%c", len * 2, val, oc->type];
	break;
      case 's':
	[mString appendFormat:@" ($%0*X,S)", len * 2, val];
	break;
      case 'y':
	[mString appendFormat:@" [$%0*X],Y", len * 2, val];
	break;
      default:
	[self error:@"Unknown mnemonic type %c", oc->type];
	break;
      }
    }

    if (![assembly objectForKey:[CLNumber numberWithUnsignedInt:progCounter]])
      [self addAssembly:mString value:val length:oc->length entryPoint:progCounter == start
		     at:progCounter];

    progCounter += oc->length;
    
    if (oc->type == 'B' || [oc->mnem isEqualToString:@"JSR"]) {
      [self pushStack:val];

      /* FIXME - don't hardcode this in */
      if ([oc->mnem isEqualToString:@"JSR"]) {
	switch (val) {
	case 0x5A6F:
	  progCounter += [self declareBytes:3 at:progCounter];
	  break;

	case 0x5A49:
	  progCounter += [self declareBytes:1 at:progCounter];
	  break;

	case 0x5B0E:
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

	case 0x589C:
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
	  
	case 0x5A0A:
	  val = [self valueAt:progCounter length:2];
	  [self pushStack:val];
	  progCounter += [self declareWords:1 at:progCounter];
	}
      }
    }

    if ([oc->mnem isEqualToString:@"JMP"]) {
      if (!oc->type)
	[self pushStack:val];
      return;
    }
    else if ([oc->mnem isEqualToString:@"RTS"])
      return;
  }

  return;
}

-(void) declareDataFrom:(CLUInteger) start to:(CLUInteger) end
{
  CLUInteger len = end - start;
  int i, j, b, val, si;
  CLMutableString *mString;


  if (end < start)
    [self error:@"What?"];
  
  mString = [[CLMutableString alloc] init];

  [self addLabel:[CLString stringWithFormat:@"L%04X", start] at:start];
  
  for (i = 0; i < len; ) {
    for (si = i; si < len; si++) {
      val = [self valueAt:start + si length:1];
      if (val >= ' ' && val <= '~')
	break;
    }

    if (si - i) {
      [mString setString:@"byt"];
      for (j = i, b = 0; j < si; j++, b++) {
	if (b)
	  [mString appendString:@","];
	[mString appendFormat:@" $%02X", [self valueAt:start + j length:1]];
	if (b == 9) {
	  [self addAssembly:mString value:0 length:b + 1 entryPoint:NO
			 at:start + j - b];
	  b = -1;
	  [mString setString:@"byt"];
	}
      }
      if (b)
	[self addAssembly:mString value:0 length:b entryPoint:NO at:start + j - b];
    }

    i = si;

    for (si = i; si < len; si++) {
      val = [self valueAt:start + si length:1];
      if (val < ' ' || val > '~')
	break;
    }

    if (si - i) {
      [mString setString:@"byt \""];
      for (j = i; j < si; j++) {
	val = [self valueAt:start + j length:1];
	if (val == '\\' || val == '"')
	  [mString appendString:@"\\"];
	[mString appendFormat:@"%c", val];
      }
      [mString appendString:@"\""];
      [self addAssembly:mString value:0 length:si - i entryPoint:NO at:start + i];
    }

    i = si;
  }

  [mString release];
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
    if ([num unsignedIntValue] - progCounter)
      [self declareDataFrom:progCounter to:[num unsignedIntValue]];
    progCounter = [num unsignedIntValue] + [asmObj length];
  }

  if ([binary length] - progCounter)
    [self declareDataFrom:progCounter to:[binary length] + origin];

  printf("          ORG $%04X\n", origin);

  for (i = 0; appleSubs[i].label; i++)
    printf("%-10sEQU $%04X\n",
	   [appleSubs[i].label UTF8String], appleSubs[i].address);
  
  anArray = [[assembly allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (i = 0, j = [anArray count]; i < j; i++) {
    asmObj = [assembly objectForKey:[anArray objectAtIndex:i]];
    if (i && [asmObj isEntryPoint])
      printf("\n");
    label = [[labels objectForKey:[anArray objectAtIndex:i]] stringByAppendingString:@":"];
    printf("%-10s%s\n", label ? [label UTF8String] : "",
	   [[asmObj lineWithLabel:labels] UTF8String]);
  }
  
  return;
}

@end
