/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#define CSTYLE 1

typedef enum {
  OpcodeRelative =	0x01,
  OpcodeImmediate =	0x02,
  OpcodeIndirect =	0x04,
  OpcodeBranch =	0x08,
  OpcodeCall =		0x10,
  OpcodeJump =		0x20,
  OpcodeReturn =	0x40,
  Opcode65c02 =		0x80,
} opcodeType;

typedef struct {
  int code;
  int length;
  CLString *mnem;
  opcodeType type;
} opcode;

#if CSTYLE
opcode opcodes[] = {
  {0x00, 1, @"BRK", 0},
  {0x01, 2, @"_A |= mem[memw(%@ + _X)];", OpcodeIndirect},
  {0x02, 0, nil, 0},
  {0x03, 0, nil, 0},
  {0x04, 2, @"TSB %@", Opcode65c02},
  {0x05, 2, @"_A |= mem[%@];", 0},
  {0x06, 2, @"mem[%@] <<= 1;", 0},
  {0x07, 0, nil, 0},
  {0x08, 1, @"PHP", 0},
  {0x09, 2, @"_A |= %@;", OpcodeImmediate},
  {0x0A, 1, @"_A <<= 1;", 0},
  {0x0B, 0, nil, 0},
  {0x0C, 3, @"TSB %@", Opcode65c02},
  {0x0D, 3, @"_A |= mem[%@];", 0},
  {0x0E, 3, @"mem[%@] <<= 1;", 0},
  {0x0F, 0, nil, 0},
  {0x10, 2, @"BPL %@", OpcodeRelative | OpcodeBranch},
  {0x11, 2, @"_A |= mem[memw(%@) + _Y];", OpcodeIndirect},
  {0x12, 2, @"ORA (%@)", OpcodeIndirect | Opcode65c02},
  {0x13, 0, nil, 0},
  {0x14, 2, @"TRB %@", Opcode65c02},
  {0x15, 2, @"_A |= mem[%@ + _X];", 0},
  {0x16, 2, @"mem[%@ + _X] <<= 1;", 0},
  {0x17, 0, nil, 0},
  {0x18, 1, @"CLC", 0},
  {0x19, 3, @"_A |= mem[%@ + _Y];", 0},
  {0x1A, 1, @"_A++;", Opcode65c02},
  {0x1B, 0, nil, 0},
  {0x1C, 3, @"TRB %@", Opcode65c02},
  {0x1D, 3, @"_A |= mem[%@ + _X];", 0},
  {0x1E, 3, @"mem[%@ + _X] <<= 1;", 0},
  {0x1F, 0, nil, 0},
  {0x20, 3, @"JSR %@", OpcodeCall},
  {0x21, 2, @"_A &= mem[memw(%@ + _X)];", OpcodeIndirect},
  {0x22, 0, nil, 0},
  {0x23, 0, nil, 0},
  {0x24, 2, @"BIT %@", 0},
  {0x25, 2, @"_A &= mem[%@];", 0},
  {0x26, 2, @"ROL %@", 0},
  {0x27, 0, nil, 0},
  {0x28, 1, @"PLP", 0},
  {0x29, 2, @"_A &= %@;", OpcodeImmediate},
  {0x2A, 1, @"ROL A", 0},
  {0x2B, 0, nil, 0},
  {0x2C, 3, @"BIT %@", 0},
  {0x2D, 3, @"_A &= mem[%@];", 0},
  {0x2E, 3, @"ROL %@", 0},
  {0x2F, 0, nil, 0},
  {0x30, 2, @"BMI %@", OpcodeRelative | OpcodeBranch},
  {0x31, 2, @"_A &= mem[memw(%@) + _Y];", OpcodeIndirect},
  {0x32, 2, @"AND (%@)", OpcodeIndirect | Opcode65c02},
  {0x33, 0, nil, 0},
  {0x34, 2, @"BIT %@,X", Opcode65c02},
  {0x35, 2, @"AND %@,X", 0},
  {0x36, 2, @"ROL %@,X", 0},
  {0x37, 0, nil, 0},
  {0x38, 1, @"SEC", 0},
  {0x39, 3, @"AND %@,Y", 0},
  {0x3A, 1, @"DEC", Opcode65c02},
  {0x3B, 0, nil, 0},
  {0x3C, 3, @"BIT %@,X", Opcode65c02},
  {0x3D, 3, @"AND %@,X", 0},
  {0x3E, 3, @"ROL %@,X", 0},
  {0x3F, 0, nil, 0},
  {0x40, 1, @"RTI", 0},
  {0x41, 2, @"EOR (%@,X)", OpcodeIndirect},
  {0x42, 0, nil, 0},
  {0x43, 0, nil, 0},
  {0x44, 0, nil, 0},
  {0x45, 2, @"EOR %@", 0},
  {0x46, 2, @"LSR %@", 0},
  {0x47, 0, nil, 0},
  {0x48, 1, @"PHA", 0},
  {0x49, 2, @"EOR #%@", OpcodeImmediate},
  {0x4A, 1, @"LSR A", 0},
  {0x4B, 0, nil, 0},
  {0x4C, 3, @"JMP %@", OpcodeJump},
  {0x4D, 3, @"EOR %@", 0},
  {0x4E, 3, @"LSR %@", 0},
  {0x4F, 0, nil, 0},
  {0x50, 2, @"BVC %@", OpcodeRelative | OpcodeBranch},
  {0x51, 2, @"EOR (%@),Y", OpcodeIndirect},
  {0x52, 2, @"EOR (%@)", OpcodeIndirect | Opcode65c02},
  {0x53, 0, nil, 0},
  {0x54, 0, nil, 0},
  {0x55, 2, @"EOR %@,X", 0},
  {0x56, 2, @"LSR %@,X", 0},
  {0x57, 0, nil, 0},
  {0x58, 1, @"CLI", 0},
  {0x59, 3, @"EOR %@,X", 0},
  {0x5A, 1, @"PHY", Opcode65c02},
  {0x5B, 0, nil, 0},
  {0x5C, 0, nil, 0},
  {0x5D, 3, @"EOR %@,X", 0},
  {0x5E, 3, @"LSR %@,X", 0},
  {0x5F, 0, nil, 0},
  {0x60, 1, @"RTS", OpcodeReturn},
  {0x61, 2, @"ADC (%@,X)", OpcodeIndirect},
  {0x62, 0, nil, 0},
  {0x63, 0, nil, 0},
  {0x64, 2, @"STZ %@", Opcode65c02},
  {0x65, 2, @"ADC %@", 0},
  {0x66, 2, @"ROR %@", 0},
  {0x67, 0, nil, 0},
  {0x68, 1, @"_A = popByte();", 0},
  {0x69, 2, @"_A += %@;", OpcodeImmediate},
  {0x6A, 1, @"ROR A", 0},
  {0x6B, 0, nil, 0},
  {0x6C, 3, @"JMP (%@)", OpcodeIndirect | OpcodeJump},
  {0x6D, 3, @"_A += mem[%@];", 0},
  {0x6E, 3, @"ROR %@", 0},
  {0x6F, 0, nil, 0},
  {0x70, 2, @"BVS %@", OpcodeRelative | OpcodeBranch},
  {0x71, 2, @"_A += mem[memw(%@) + _Y];", OpcodeIndirect},
  {0x72, 2, @"_A += mem[memw(%@)];", OpcodeIndirect | Opcode65c02},
  {0x73, 0, nil, 0},
  {0x74, 2, @"STZ %@,X", Opcode65c02},
  {0x75, 2, @"_A = mem[%@ + _X];", 0},
  {0x76, 2, @"ROR %@,X", 0},
  {0x77, 0, nil, 0},
  {0x78, 1, @"SEI", 0},
  {0x79, 3, @"_A += mem[%@ + _Y];", 0},
  {0x7A, 1, @"PLY", Opcode65c02},
  {0x7B, 0, nil, 0},
  {0x7C, 3, @"JMP (%@,X)", OpcodeIndirect | OpcodeJump | Opcode65c02},
  {0x7D, 3, @"_A += mem[%@ + _X];", 0},
  {0x7E, 3, @"ROR %@,X", 0},
  {0x7F, 0, nil, 0},
  {0x80, 2, @"BRA %@", OpcodeRelative | OpcodeBranch | Opcode65c02},
  {0x81, 2, @"mem[memw(%@ + _X)] = _A;", OpcodeIndirect},
  {0x82, 0, nil, 0},
  {0x83, 0, nil, 0},
  {0x84, 2, @"mem[%@] = _Y;", 0},
  {0x85, 2, @"mem[%@] = _A;", 0},
  {0x86, 2, @"mem[%@] = _X;", 0},
  {0x87, 0, nil, 0},
  {0x88, 1, @"_Y--;", 0},
  {0x89, 2, @"BIT #%@", OpcodeImmediate | Opcode65c02},
  {0x8A, 1, @"_A = _X;", 0},
  {0x8B, 0, nil, 0},
  {0x8C, 3, @"mem[%@] = _Y;", 0},
  {0x8D, 3, @"mem[%@] = _A;", 0},
  {0x8E, 3, @"mem[%@] = _X;", 0},
  {0x8F, 0, nil, 0},
  {0x90, 2, @"BCC %@", OpcodeRelative | OpcodeBranch},
  {0x91, 2, @"mem[memw(%@) + _Y] = _A;", OpcodeIndirect},
  {0x92, 2, @"mem[memw(%@)] = _A;", OpcodeIndirect | Opcode65c02},
  {0x93, 0, nil, 0},
  {0x94, 2, @"mem[%@ + _X] = _Y;", 0},
  {0x95, 2, @"mem[%@ + _X] = _A;", 0},
  {0x96, 2, @"mem[%@ + _Y] = _X;", 0},
  {0x97, 0, nil, 0},
  {0x98, 1, @"_A = _Y;", 0},
  {0x99, 3, @"mem[%@ + _Y] = _A;", 0},
  {0x9A, 1, @"TXS", 0},
  {0x9B, 0, nil, 0},
  {0x9C, 3, @"STZ %@", Opcode65c02},
  {0x9D, 3, @"mem[%@ + _X] = _A;", 0},
  {0x9E, 3, @"STZ %@,X", Opcode65c02},
  {0x9F, 0, nil, 0},
  {0xA0, 2, @"_Y = %@;", OpcodeImmediate},
  {0xA1, 2, @"_A = mem[memw(%@ + _X)];", OpcodeIndirect},
  {0xA2, 2, @"_X = %@;", OpcodeImmediate},
  {0xA3, 0, nil, 0},
  {0xA4, 2, @"_Y = mem[%@];", 0},
  {0xA5, 2, @"_A = mem[%@];", 0},
  {0xA6, 2, @"_X = mem[%@];", 0},
  {0xA7, 0, nil, 0},
  {0xA8, 1, @"_Y = _A;", 0},
  {0xA9, 2, @"_A = %@;", OpcodeImmediate},
  {0xAA, 1, @"_X = _A;", 0},
  {0xAB, 0, nil, 0},
  {0xAC, 3, @"_Y = mem[%@];", 0},
  {0xAD, 3, @"_A = mem[%@];", 0},
  {0xAE, 3, @"_X = mem[%@];", 0},
  {0xAF, 0, nil, 0},
  {0xB0, 2, @"BCS %@", OpcodeRelative | OpcodeBranch},
  {0xB1, 2, @"_A = mem[memw(%@) + _Y];", OpcodeIndirect},
  {0xB2, 2, @"_A = mem[memw(%@)];", OpcodeIndirect | Opcode65c02},
  {0xB3, 0, nil, 0},
  {0xB4, 2, @"_Y = mem[%@ + _X];", 0},
  {0xB5, 2, @"_A = mem[%@ + _X];", 0},
  {0xB6, 2, @"_X = mem[%@ + _Y];", 0},
  {0xB7, 0, nil, 0},
  {0xB8, 1, @"CLV", 0},
  {0xB9, 3, @"_A = mem[%@ + _Y];", 0},
  {0xBA, 1, @"TSX", 0},
  {0xBB, 0, nil, 0},
  {0xBC, 3, @"_Y = mem[%@ + _X];", 0},
  {0xBD, 3, @"_A = mem[%@ + _X];", 0},
  {0xBE, 3, @"_X = mem[%@ + _Y];", 0},
  {0xBF, 0, nil, 0},
  {0xC0, 2, @"CPY #%@", OpcodeImmediate},
  {0xC1, 2, @"CMP (%@,X)", OpcodeIndirect},
  {0xC2, 0, nil, 0},
  {0xC3, 0, nil, 0},
  {0xC4, 2, @"CPY %@", 0},
  {0xC5, 2, @"CMP %@", 0},
  {0xC6, 2, @"mem[%@]--;", 0},
  {0xC7, 0, nil, 0},
  {0xC8, 1, @"_Y++;", 0},
  {0xC9, 2, @"CMP #%@", OpcodeImmediate},
  {0xCA, 1, @"_X--;", 0},
  {0xCB, 0, nil, 0},
  {0xCC, 3, @"CPY %@", 0},
  {0xCD, 3, @"CMP %@", 0},
  {0xCE, 3, @"mem[%@]--;", 0},
  {0xCF, 0, nil, 0},
  {0xD0, 2, @"BNE %@", OpcodeRelative | OpcodeBranch},
  {0xD1, 2, @"CMP (%@),Y", OpcodeIndirect},
  {0xD2, 2, @"CMP (%@)", OpcodeIndirect | Opcode65c02},
  {0xD3, 0, nil, 0},
  {0xD4, 0, nil, 0},
  {0xD5, 2, @"CMP %@,X", 0},
  {0xD6, 2, @"mem[%@ + _X]--;", 0},
  {0xD7, 0, nil, 0},
  {0xD8, 1, @"CLD", 0},
  {0xD9, 3, @"CMP %@,Y", 0},
  {0xDA, 1, @"PHX", Opcode65c02},
  {0xDB, 0, nil, 0},
  {0xDC, 0, nil, 0},
  {0xDD, 3, @"CMP %@,X", 0},
  {0xDE, 3, @"mem[%@ + _X]--;", 0},
  {0xDF, 0, nil, 0},
  {0xE0, 2, @"CPX #%@", OpcodeImmediate},
  {0xE1, 2, @"_A -= mem[memw(%@ + _X)];", OpcodeIndirect},
  {0xE2, 0, nil, 0},
  {0xE3, 0, nil, 0},
  {0xE4, 2, @"CPX %@", 0},
  {0xE5, 2, @"_A -= mem[%@];", 0},
  {0xE6, 2, @"mem[%@]++;", 0},
  {0xE7, 0, nil, 0},
  {0xE8, 1, @"_X++;", 0},
  {0xE9, 2, @"_A -= %@;", OpcodeImmediate},
  {0xEA, 1, @"NOP", 0},
  {0xEB, 0, nil, 0},
  {0xEC, 3, @"CPX %@", 0},
  {0xED, 3, @"_A -= mem[%@];", 0},
  {0xEE, 3, @"mem[%@]++;", 0},
  {0xEF, 0, nil, 0},
  {0xF0, 2, @"BEQ %@", OpcodeRelative | OpcodeBranch},
  {0xF1, 2, @"_A -= mem[memw(%@) + _Y];", OpcodeIndirect},
  {0xF2, 2, @"_A -= mem[memw(%@)];", OpcodeIndirect | Opcode65c02},
  {0xF3, 0, nil, 0},
  {0xF4, 0, nil, 0},
  {0xF5, 2, @"_A -= mem[%@ + _X];", 0},
  {0xF6, 2, @"mem[%@ + _X]++;", 0},
  {0xF7, 0, nil, 0},
  {0xF8, 1, @"SED", 0},
  {0xF9, 3, @"_A -= mem[%@ + _Y];", 0},
  {0xFA, 1, @"PLX", Opcode65c02},
  {0xFB, 0, nil, 0},
  {0xFC, 0, nil, 0},
  {0xFD, 3, @"_A == mem[%@ + _X];", 0},
  {0xFE, 3, @"mem[%@ + _X]++;", 0},
  {0xFF, 0, nil, 0},
};
#else
opcode opcodes[] = {
  {0x00, 1, @"BRK", 0},
  {0x01, 2, @"ORA (%@,X)", OpcodeIndirect},
  {0x02, 0, nil, 0},
  {0x03, 0, nil, 0},
  {0x04, 2, @"TSB %@", Opcode65c02},
  {0x05, 2, @"ORA %@", 0},
  {0x06, 2, @"ASL %@", 0},
  {0x07, 0, nil, 0},
  {0x08, 1, @"PHP", 0},
  {0x09, 2, @"ORA #%@", OpcodeImmediate},
  {0x0A, 1, @"ASL A", 0},
  {0x0B, 0, nil, 0},
  {0x0C, 3, @"TSB %@", Opcode65c02},
  {0x0D, 3, @"ORA %@", 0},
  {0x0E, 3, @"ASL %@", 0},
  {0x0F, 0, nil, 0},
  {0x10, 2, @"BPL %@", OpcodeRelative | OpcodeBranch},
  {0x11, 2, @"ORA (%@),Y", OpcodeIndirect},
  {0x12, 2, @"ORA (%@)", OpcodeIndirect | Opcode65c02},
  {0x13, 0, nil, 0},
  {0x14, 2, @"TRB %@", Opcode65c02},
  {0x15, 2, @"ORA %@,X", 0},
  {0x16, 2, @"ASL %@,X", 0},
  {0x17, 0, nil, 0},
  {0x18, 1, @"CLC", 0},
  {0x19, 3, @"ORA %@,Y", 0},
  {0x1A, 1, @"INC", Opcode65c02},
  {0x1B, 0, nil, 0},
  {0x1C, 3, @"TRB %@", Opcode65c02},
  {0x1D, 3, @"ORA %@,X", 0},
  {0x1E, 3, @"ASL %@,X", 0},
  {0x1F, 0, nil, 0},
  {0x20, 3, @"JSR %@", OpcodeCall},
  {0x21, 2, @"AND (%@,X)", OpcodeIndirect},
  {0x22, 0, nil, 0},
  {0x23, 0, nil, 0},
  {0x24, 2, @"BIT %@", 0},
  {0x25, 2, @"AND %@", 0},
  {0x26, 2, @"ROL %@", 0},
  {0x27, 0, nil, 0},
  {0x28, 1, @"PLP", 0},
  {0x29, 2, @"AND #%@", OpcodeImmediate},
  {0x2A, 1, @"ROL A", 0},
  {0x2B, 0, nil, 0},
  {0x2C, 3, @"BIT %@", 0},
  {0x2D, 3, @"AND %@", 0},
  {0x2E, 3, @"ROL %@", 0},
  {0x2F, 0, nil, 0},
  {0x30, 2, @"BMI %@", OpcodeRelative | OpcodeBranch},
  {0x31, 2, @"AND (%@),Y", OpcodeIndirect},
  {0x32, 2, @"AND (%@)", OpcodeIndirect | Opcode65c02},
  {0x33, 0, nil, 0},
  {0x34, 2, @"BIT %@,X", Opcode65c02},
  {0x35, 2, @"AND %@,X", 0},
  {0x36, 2, @"ROL %@,X", 0},
  {0x37, 0, nil, 0},
  {0x38, 1, @"SEC", 0},
  {0x39, 3, @"AND %@,Y", 0},
  {0x3A, 1, @"DEC", Opcode65c02},
  {0x3B, 0, nil, 0},
  {0x3C, 3, @"BIT %@,X", Opcode65c02},
  {0x3D, 3, @"AND %@,X", 0},
  {0x3E, 3, @"ROL %@,X", 0},
  {0x3F, 0, nil, 0},
  {0x40, 1, @"RTI", 0},
  {0x41, 2, @"EOR (%@,X)", OpcodeIndirect},
  {0x42, 0, nil, 0},
  {0x43, 0, nil, 0},
  {0x44, 0, nil, 0},
  {0x45, 2, @"EOR %@", 0},
  {0x46, 2, @"LSR %@", 0},
  {0x47, 0, nil, 0},
  {0x48, 1, @"PHA", 0},
  {0x49, 2, @"EOR #%@", OpcodeImmediate},
  {0x4A, 1, @"LSR A", 0},
  {0x4B, 0, nil, 0},
  {0x4C, 3, @"JMP %@", OpcodeJump},
  {0x4D, 3, @"EOR %@", 0},
  {0x4E, 3, @"LSR %@", 0},
  {0x4F, 0, nil, 0},
  {0x50, 2, @"BVC %@", OpcodeRelative | OpcodeBranch},
  {0x51, 2, @"EOR (%@),Y", OpcodeIndirect},
  {0x52, 2, @"EOR (%@)", OpcodeIndirect | Opcode65c02},
  {0x53, 0, nil, 0},
  {0x54, 0, nil, 0},
  {0x55, 2, @"EOR %@,X", 0},
  {0x56, 2, @"LSR %@,X", 0},
  {0x57, 0, nil, 0},
  {0x58, 1, @"CLI", 0},
  {0x59, 3, @"EOR %@,X", 0},
  {0x5A, 1, @"PHY", Opcode65c02},
  {0x5B, 0, nil, 0},
  {0x5C, 0, nil, 0},
  {0x5D, 3, @"EOR %@,X", 0},
  {0x5E, 3, @"LSR %@,X", 0},
  {0x5F, 0, nil, 0},
  {0x60, 1, @"RTS", OpcodeReturn},
  {0x61, 2, @"ADC (%@,X)", OpcodeIndirect},
  {0x62, 0, nil, 0},
  {0x63, 0, nil, 0},
  {0x64, 2, @"STZ %@", Opcode65c02},
  {0x65, 2, @"ADC %@", 0},
  {0x66, 2, @"ROR %@", 0},
  {0x67, 0, nil, 0},
  {0x68, 1, @"PLA", 0},
  {0x69, 2, @"ADC #%@", OpcodeImmediate},
  {0x6A, 1, @"ROR A", 0},
  {0x6B, 0, nil, 0},
  {0x6C, 3, @"JMP (%@)", OpcodeIndirect | OpcodeJump},
  {0x6D, 3, @"ADC %@", 0},
  {0x6E, 3, @"ROR %@", 0},
  {0x6F, 0, nil, 0},
  {0x70, 2, @"BVS %@", OpcodeRelative | OpcodeBranch},
  {0x71, 2, @"ADC (%@),Y", OpcodeIndirect},
  {0x72, 2, @"ADC (%@)", OpcodeIndirect | Opcode65c02},
  {0x73, 0, nil, 0},
  {0x74, 2, @"STZ %@,X", Opcode65c02},
  {0x75, 2, @"ADC %@,X", 0},
  {0x76, 2, @"ROR %@,X", 0},
  {0x77, 0, nil, 0},
  {0x78, 1, @"SEI", 0},
  {0x79, 3, @"ADC %@,Y", 0},
  {0x7A, 1, @"PLY", Opcode65c02},
  {0x7B, 0, nil, 0},
  {0x7C, 3, @"JMP (%@,X)", OpcodeIndirect | OpcodeJump | Opcode65c02},
  {0x7D, 3, @"ADC %@,X", 0},
  {0x7E, 3, @"ROR %@,X", 0},
  {0x7F, 0, nil, 0},
  {0x80, 2, @"BRA %@", OpcodeRelative | OpcodeBranch | Opcode65c02},
  {0x81, 2, @"STA (%@,X)", OpcodeIndirect},
  {0x82, 0, nil, 0},
  {0x83, 0, nil, 0},
  {0x84, 2, @"STY %@", 0},
  {0x85, 2, @"STA %@", 0},
  {0x86, 2, @"STX %@", 0},
  {0x87, 0, nil, 0},
  {0x88, 1, @"DEY", 0},
  {0x89, 2, @"BIT #%@", OpcodeImmediate | Opcode65c02},
  {0x8A, 1, @"TXA", 0},
  {0x8B, 0, nil, 0},
  {0x8C, 3, @"STY %@", 0},
  {0x8D, 3, @"STA %@", 0},
  {0x8E, 3, @"STX %@", 0},
  {0x8F, 0, nil, 0},
  {0x90, 2, @"BCC %@", OpcodeRelative | OpcodeBranch},
  {0x91, 2, @"STA (%@),Y", OpcodeIndirect},
  {0x92, 2, @"STA (%@)", OpcodeIndirect | Opcode65c02},
  {0x93, 0, nil, 0},
  {0x94, 2, @"STY %@,X", 0},
  {0x95, 2, @"STA %@,X", 0},
  {0x96, 2, @"STX %@,Y", 0},
  {0x97, 0, nil, 0},
  {0x98, 1, @"TYA", 0},
  {0x99, 3, @"STA %@,Y", 0},
  {0x9A, 1, @"TXS", 0},
  {0x9B, 0, nil, 0},
  {0x9C, 3, @"STZ %@", Opcode65c02},
  {0x9D, 3, @"STA %@,X", 0},
  {0x9E, 3, @"STZ %@,X", Opcode65c02},
  {0x9F, 0, nil, 0},
  {0xA0, 2, @"LDY #%@", OpcodeImmediate},
  {0xA1, 2, @"LDA (%@,X)", OpcodeIndirect},
  {0xA2, 2, @"LDX #%@", OpcodeImmediate},
  {0xA3, 0, nil, 0},
  {0xA4, 2, @"LDY %@", 0},
  {0xA5, 2, @"LDA %@", 0},
  {0xA6, 2, @"LDX %@", 0},
  {0xA7, 0, nil, 0},
  {0xA8, 1, @"TAY", 0},
  {0xA9, 2, @"LDA #%@", OpcodeImmediate},
  {0xAA, 1, @"TAX", 0},
  {0xAB, 0, nil, 0},
  {0xAC, 3, @"LDY %@", 0},
  {0xAD, 3, @"LDA %@", 0},
  {0xAE, 3, @"LDX %@", 0},
  {0xAF, 0, nil, 0},
  {0xB0, 2, @"BCS %@", OpcodeRelative | OpcodeBranch},
  {0xB1, 2, @"LDA (%@),Y", OpcodeIndirect},
  {0xB2, 2, @"LDA (%@)", OpcodeIndirect | Opcode65c02},
  {0xB3, 0, nil, 0},
  {0xB4, 2, @"LDY %@,X", 0},
  {0xB5, 2, @"LDA %@,X", 0},
  {0xB6, 2, @"LDX %@,Y", 0},
  {0xB7, 0, nil, 0},
  {0xB8, 1, @"CLV", 0},
  {0xB9, 3, @"LDA %@,Y", 0},
  {0xBA, 1, @"TSX", 0},
  {0xBB, 0, nil, 0},
  {0xBC, 3, @"LDY %@,X", 0},
  {0xBD, 3, @"LDA %@,X", 0},
  {0xBE, 3, @"LDX %@,Y", 0},
  {0xBF, 0, nil, 0},
  {0xC0, 2, @"CPY #%@", OpcodeImmediate},
  {0xC1, 2, @"CMP (%@,X)", OpcodeIndirect},
  {0xC2, 0, nil, 0},
  {0xC3, 0, nil, 0},
  {0xC4, 2, @"CPY %@", 0},
  {0xC5, 2, @"CMP %@", 0},
  {0xC6, 2, @"DEC %@", 0},
  {0xC7, 0, nil, 0},
  {0xC8, 1, @"INY", 0},
  {0xC9, 2, @"CMP #%@", OpcodeImmediate},
  {0xCA, 1, @"DEX", 0},
  {0xCB, 0, nil, 0},
  {0xCC, 3, @"CPY %@", 0},
  {0xCD, 3, @"CMP %@", 0},
  {0xCE, 3, @"DEC %@", 0},
  {0xCF, 0, nil, 0},
  {0xD0, 2, @"BNE %@", OpcodeRelative | OpcodeBranch},
  {0xD1, 2, @"CMP (%@),Y", OpcodeIndirect},
  {0xD2, 2, @"CMP (%@)", OpcodeIndirect | Opcode65c02},
  {0xD3, 0, nil, 0},
  {0xD4, 0, nil, 0},
  {0xD5, 2, @"CMP %@,X", 0},
  {0xD6, 2, @"DEC %@,X", 0},
  {0xD7, 0, nil, 0},
  {0xD8, 1, @"CLD", 0},
  {0xD9, 3, @"CMP %@,Y", 0},
  {0xDA, 1, @"PHX", Opcode65c02},
  {0xDB, 0, nil, 0},
  {0xDC, 0, nil, 0},
  {0xDD, 3, @"CMP %@,X", 0},
  {0xDE, 3, @"DEC %@,X", 0},
  {0xDF, 0, nil, 0},
  {0xE0, 2, @"CPX #%@", OpcodeImmediate},
  {0xE1, 2, @"SBC (%@,X)", OpcodeIndirect},
  {0xE2, 0, nil, 0},
  {0xE3, 0, nil, 0},
  {0xE4, 2, @"CPX %@", 0},
  {0xE5, 2, @"SBC %@", 0},
  {0xE6, 2, @"INC %@", 0},
  {0xE7, 0, nil, 0},
  {0xE8, 1, @"INX", 0},
  {0xE9, 2, @"SBC #%@", OpcodeImmediate},
  {0xEA, 1, @"NOP", 0},
  {0xEB, 0, nil, 0},
  {0xEC, 3, @"CPX %@", 0},
  {0xED, 3, @"SBC %@", 0},
  {0xEE, 3, @"INC %@", 0},
  {0xEF, 0, nil, 0},
  {0xF0, 2, @"BEQ %@", OpcodeRelative | OpcodeBranch},
  {0xF1, 2, @"SBC (%@),Y", OpcodeIndirect},
  {0xF2, 2, @"SBC (%@)", OpcodeIndirect | Opcode65c02},
  {0xF3, 0, nil, 0},
  {0xF4, 0, nil, 0},
  {0xF5, 2, @"SBC %@,X", 0},
  {0xF6, 2, @"INC %@,X", 0},
  {0xF7, 0, nil, 0},
  {0xF8, 1, @"SED", 0},
  {0xF9, 3, @"SBC %@,Y", 0},
  {0xFA, 1, @"PLX", Opcode65c02},
  {0xFB, 0, nil, 0},
  {0xFC, 0, nil, 0},
  {0xFD, 3, @"SBC %@,X", 0},
  {0xFE, 3, @"INC %@,X", 0},
  {0xFF, 0, nil, 0},
};
#endif
