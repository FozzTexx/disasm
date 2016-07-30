/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#define CSTYLE 0

typedef enum {
  OpcodeRelative =	0x01,
  OpcodeImmediate =	0x02,
  OpcodeIndirect =	0x04,
  OpcodeBranch =	0x08,
  OpcodeCall =		0x10,
  OpcodeJump =		0x20,
  OpcodeReturn =	0x40,
  Opcode65c02 =		0x80,
} OpcodeType;

typedef struct {
  int code;
  int length;
  CLString *mnem;
  OpcodeType type;
} opcode;

