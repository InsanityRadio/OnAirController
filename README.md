# OnAirController
A stupidly simple on-air controller written in Ruby.

This controller theoretically supports multiple playout systems (if you can code it!). There is currently support for Myriad, as it's the only one we have access to. 

Nowhere near complete/stable, so definitely don't try to use me in production yet! 

### What it doesn't do

OAC can't yet do anything with metadata. I mean, technically, it can't do anything at the moment. 

## Development

The software is written in Ruby and aims to be completely stable (notwithstanding Ruby's MTTF) and portable, and with few dependencies. More or less every class with even the slightest amount of logic has an RSpec test. 

This software is one component of Metal, part of Insanity Radio's [technical masterplan](https://wiki.insanityradio.com/wiki/Technical_Masterplan). The big aim here is to move towards object/event-oriented radio, and make it totally open for anyone who wants to hop on the bandwagon.

