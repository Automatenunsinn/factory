#!/bin/bash
m68k-linux-gnu-as -mcpu=cpu32 main.s -o main.o
m68k-linux-gnu-objcopy -O binary main.o factory_raw.bin