/* Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

typedef struct {
  CLUInteger address;
  CLString *label;
} subroutine;

subroutine appleSubs[] = {
  {0x3CA, @"DOS3UN1"},
  {0x3CD, @"DOS3UN2"},
  {0x3D6, @"DOS3IO"},
  {0x3DC, @"DOS3SYS"},
  {0x3F2, @"SOFTEV"},
  {0xAA66, @"DOSVOL"},
  {0xC000, @"KBD"},
  {0xC010, @"KBDSTB"},
  {0xE000, @"BASIC"},
  {0xFB5B, @"TABV"},
  {0xFBB3, @"SYSID1"},
  {0xFBC0, @"SYSID2"},
  {0xFC58, @"HOME"},
  {0xFC9C, @"CLREOL"},
  {0xFD0C, @"RDKEY"},
  {0xFDED, @"COUT"},
  {0xFDF0, @"COUT1"},
  {0, nil},
};
