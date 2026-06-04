#!/bin/bash
m68k-linux-gnu-as -mcpu=cpu32 main.s -o main.o
m68k-linux-gnu-objcopy -O binary main.o factory_raw.bin
dd if=factory_raw.bin of=factory.bin bs=1 skip=4096
rm main.o factory_raw.bin
