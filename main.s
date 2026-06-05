| MC68331CAG16
| Based on CPU32 instruction set
    .section .text

	.org 0x1000                     | header
	| empty for now

	.org 0x1100
    .long 0x182d                    | stack pointer vector?
    .long start                     | reset vector

    .org 0x1500
	.globl start
start:
	movea.l	$0x10000, %a0
	movea.l	0x00000000:w, %a1       | stack pointer vector
	suba.l	$0x100, %a1             | do not clear the stack

loop:
	cmpa.l	%a1, %a0                | arrived at stack - 0x100 ?
	bhi.b	finish
	clr.l	(%a0)+
	bra.b	loop

finish:
	clr.l	0x00001000

	move.l	$0x494e4954, 0x00fffd00 | ascii INIT

	movea.w	$0x408, %a0
	jsr	(%a0)                       | jump to loader

die:
	bra.b	die
