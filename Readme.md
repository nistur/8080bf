8080BF
======
[Brainfuck](https://esolangs.org/wiki/brainfuck) compiler for Intel 8080 CPU.

This came about because I saw the [Hackaday's 1kB
challenge](https://hackaday.io/contest/18215-the-1kb-challenge) and
wondered what fun things I could do with 1kb. As I'm relatively
familiar with 8080 code, having written a
[simulator](https://github.com/nistur/tlvm) for it, it seemed like the
obvious choice. I do not know at this point whether I will be entering
the competition as I will be required to build a board to demo this
on. For now I will just aim to emulate the entry and possibly if I get
the code running correctly, I will look into running it on actual
hardware.

So far my thoughts on the competition are:
- 1kB is a ridiculously low limit, even for embedded systems nowadays,
so let's make it as ridiculous as possible
- Use an old processor for that real retro feel (ie Intel 8080)
- Use an esoteric language not meant for human consumption (ie
Brainfuck)
- Write a compiler for the aforementioned language, because where
would the challenge be otherwise
- Use the rest of the space to make something cool

At this stage my ASM has some embedded brainfuck code, 'borrowed' from
a [stackexchange
post](https://codegolf.stackexchange.com/questions/55422/hello-world/68494#68494),
but this is just placeholder as I obviously want it to do something
more fun.

The compiler currently supports all 8 Brainfuck instructions, with
input/output instructions mapping to IN 0 and OUT 0 respectively. This
means that they don't work precisely as Brainfuck was designed
(blocking stdin/stdout calls).

At this stage, I've rewritten the compiler, and succeeded in breaking
the loop instructions. I need to figure out how they work and fix
this. More comments required!

As mentioned, a redesign has happened. The plan is as follows:
- 0x0000 - 0x00FF : Compiler. If this ever gets put into hardware, it
would represent a ROM chip
- 0x0100 - 0x02FF : BF code. I'm limiting even further than 1kB, I'm
not going to use the whole 768B remaining for BF code, I'm limiting it
to 512B instead. This is even more limiting as the machine code will
be larger than the BF code itself. This would be a 512B non-volatile
memory chip.
- 0x0300 - 0x03FF : Data. I figured that whatever I wanted to do might
need either data to work upon (lookup tables etc), or maybe it might
use it as persistent storage for whatever program I end up writing for
this. Either way it would be accessible as negative cells in the BF
tape. It would be a 256B non-volatile memory chip.
- 0x0400 -> : RAM, will be used for compilation and then re-used as
the BF tape once it's compiled.
- The plan would be that the code gets compiled into RAM, then
copied back over the original code. Unfortunately this means that all
the JMP locations have to be retargetted, which is why this is
currently broken.
