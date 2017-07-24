/* Copyright 2017 by Chris Osborn <fozztexx@fozztexx.com>
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

#import "constant.h"

constant vic20Subs[] = {
  {0x01, @"USRADD"},
  {0x03, @"ADRAY1"},
  {0x05, @"ADRAY2"},
  {0x43, @"INPPTR"},
  {0xF5, @"KETAB"},
  {0x300, @"IERROR"},
  {0x302, @"IMAIN"},
  {0x304, @"ICRNCH"},
  {0x314, @"CINV"},
  {0x316, @"CBINV"},
  {0x318, @"NMINV"},
  {0x31A, @"IOPEN"},
  {0x31C, @"ICLOSE"},
  {0x31E, @"ICHKIN"},
  {0x320, @"ICKOUT"},
  {0x322, @"ICLRCH"},
  {0x324, @"IBASIN"},
  {0x326, @"IBSOUT"},
  {0x328, @"ISTOP"},
  {0x32A, @"IGETIN"},
  {0x32C, @"ICLALL"},
  {0x32E, @"USRCMD"},
  {0x330, @"ILOAD"},
  {0x332, @"ISAVE"},
  {0x9000, @"HZCNRG"},
  {0x900F, @"BCLREG"},
  {0x9004, @"TVRAST"},
  {0x9114, @"TIMER1"},
  {0x9116, @"TIMER2"},
  {0x9118, @"TIMER3"},
  {0x911B, @"AUXRG1"},
  {0x911E, @"INTENR"},
  {0x9124, @"TM1LAT"},
  {0, nil},
};
