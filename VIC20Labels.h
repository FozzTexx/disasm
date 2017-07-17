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
  {0x314, @"IRQVEC"},
  {0x316, @"BRKVEC"},
  {0x318, @"NMIVEC"},
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
