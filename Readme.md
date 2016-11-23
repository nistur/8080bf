8080BF
======
[Brainfuck](https://esolangs.org/wiki/brainfuck) compiler for Intel 8080 CPU.

This came about because I saw the [Hackaday's 1kb challenge](https://hackaday.io/contest/18215-the-1kb-challenge) and wondered what fun things I could do with 1kb. As I'm relatively familiar with 8080 code, having written a [simulator](https://github.com/nistur/tlvm) for it, it seemed like the obvious choice. I do not know at this point whether I will be entering the competition as I will be required to build a board to demo this on. For now I will just aim to emulate the entry and possibly if I get the code running correctly, I will look into running it on actual hardware.

So far my thoughts on the competition are:
- 1kb is a ridiculously low limit, even for embedded systems nowadays, so let's make it as ridiculous as possible
- Use an old processor for that real retro feel (ie Intel 8080)
- Use an esoteric language not meant for human consumption (ie Brainfuck)
- Write a compiler for the aforementioned language, because where would the challenge be otherwise
- Use the rest of the space to make something cool

At this stage my ASM has some embedded brainfuck code, 'borrowed' from a [stackexchange post](https://codegolf.stackexchange.com/questions/55422/hello-world/68494#68494), but this is just placeholder as I obviously want it to do something more fun.
It supports the 4 simple instructions in Brainfuck:
+-<>
The code for the compiler itself currently weighs in at 100Bytes, so I'm looking good to being able to write the compiler in a small enough space to be able to spend a good deal of space on the Brainfuck code itself.
(the [],. instructions will be coming shortly)

One thing which I still have to decide upon is how to do input and output from the system I create. One of the ideas for a Brainfuck program I would like to try is to implement Conway's Game of Life, however for this I would have to have a display output which would need rendering code.
The pondering continues