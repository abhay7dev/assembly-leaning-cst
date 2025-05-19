# Assembly Learning

Learning & Playing with Assembly for Comp Sci Topics class.

Run asm with nasm with the following command on my arch linux machine:
nasm -f elf32 -o helloworld.o helloworld.nasm && ld -m elf_i386 -o helloworld helloworld.o && ./helloworld