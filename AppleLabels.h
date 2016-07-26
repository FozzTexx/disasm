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
  {0xFC58, @"HOME"},
  {0xFC9C, @"CLREOL"},
  {0xFDF0, @"COUT1"},
  {0xFD0C, @"RDKEY"},
  {0xFB5B, @"TABV"},
  {0xFDED, @"COUT"},
  {0x3D6, @"DOS3IO"},
  {0x3DC, @"DOS3SYS"},
  {0xA060, @"DOS3UNK"},
  {0, nil},
};
