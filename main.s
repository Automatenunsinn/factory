| MC68331CAG16
| Based on CPU32 instruction set

| Build-time parameters (override with as --defsym, see Makefile):
.ifndef TYPE
	.set TYPE, 0x31415926
.endif
.ifndef NVRAM_SIZE
	.set NVRAM_SIZE, 0x80000
.endif

    .section .text

	.org 0x1000                     | header (struct DB_XC_FILE_HEADER)
_base:
    .long 0x182d                    | 0x00 checksum
    .long (die - _base) + 0x1000 + 1 | 0x04 length = die address + 1
	.long ~((die - _base) + 0x1000 + 1) | 0x08 length_inv = ~length
	.long TYPE						| 0x0C image_type

	.long 0							| 0x10 sram_start
	.long 0							| 0x14 sram_end

	.org 0x104c	
	.long (start - _base) + 0x1000	| 0x4C start_address
	.long ~((start - _base) + 0x1000) | 0x50 start_address_inv = ~start_address

	.org 0x1100						| vector table
	.long NVRAM_SIZE				| nvram size/stack pointer vector
	.long (start - _base) + 0x1000	| start address

    .org 0x1500
	.globl start
start:
	movea.l	#0x10000, %a0
	movea.l	0x00000000:w, %a1       | stack pointer vector
	suba.l	#0x100, %a1             | do not clear the stack

loop:
	cmpa.l	%a1, %a0                | arrived at stack - 0x100 ?
	bhi.b	finish
	clr.l	(%a0)+
	bra.b	loop

finish:
	clr.l	0x00001000:l

	move.l	#0x494e4954, 0x00fffd00 | ascii INIT

	movea.w	#0x408, %a0
	jsr	(%a0)                       | jump to loader

die:
	bra.b	die
