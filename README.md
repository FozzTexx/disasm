disasm: A disassembler for 8 bit CPUs.
Copyright 2016 by Chris Osborn <fozztexx@fozztexx.com>

This is a disassembler I originally hacked together to try to take
apart the Cauzin software. It was intended to be somewhat generic and
architected to allow for different CPU types, but so far I've only put
in 6502 support.

There are currently lots of hardcoded hacks to deal with special
conditions of whatever current thing I'm trying to reverse
engineer. I'm lazy and it's faster to do that than add lots of options
and smarts. ;-)

See COPYING file for detailed information on terms of copying.
