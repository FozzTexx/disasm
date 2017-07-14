/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#define CSTYLE 0

typedef enum {
  OpcodeRelative =	0x001,
  OpcodeImmediate =	0x002,
  OpcodeIndirect =	0x004,
  OpcodeBranch =	0x008,
  OpcodeCall =		0x010,
  OpcodeJump =		0x020,
  OpcodeReturn =	0x040,
  Opcode65c02 =		0x080,
  OpcodeConst =		0x100,
} OpcodeType;

typedef struct {
  int code;
  int length;
  CLString *mnem;
  OpcodeType type;
} opcode;

