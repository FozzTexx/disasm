/* Copyright 2017 by Chris Osborn <fozztexx@fozztexx.com>
 * http://insentricity.com
 *
 * $Id$
 */

#import "subroutine.h"

subroutine vic20Subs[] = {
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
