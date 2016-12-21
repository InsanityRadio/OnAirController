# OnAirController
A stupidly simple on-air controller written in Ruby.

This controller theoretically supports multiple playout systems (if you can code it!). There is currently support for Myriad, as it's the only one we have access to. 

OnAirController can now receive now playing metadata. 

###?What it doesn't do

Splits. That's far far out of the scope here, sadly. Hardware control isn't built in yet, either. 

It's not also guaranteed to be stable yet, as there are probably some edge cases that were missed in testing.

## Development

The software is written in Ruby and aims to be completely stable (notwithstanding Ruby's MTTF) and portable, and with few dependencies. More or less every class with even the slightest amount of logic has an RSpec test. 

This software is one component of Metal, part of Insanity Radio's [technical masterplan](https://wiki.insanityradio.com/wiki/Technical_Masterplan). The big aim here is to move towards object/event-oriented radio, and make it totally open for anyone who wants to hop on the bandwagon.

One goal of this software is to allow the "ON AIR" status that's displayed on the playout machine to correspond to the studio that's actually on air - including hardware. This hasn't been implemented yet, but OAC in its current state should theoretically support this.

## Gotchas

Myriad won't keep a connection to the OAC open unless it is trying to go on air. Myriad's TCP/IP protocol can work around this, but this hasn't been implemented yet.

Be wary if you're using Raspberry Pi GPIO pins here - you should definitely use opto-isolated circuitry, especially if (like us, there are some huge lighting transformers downstairs) your ground is noisy. Make sure that you (somehow) persist GPOs in case the software crashes, as this is very likely in the current state. 
