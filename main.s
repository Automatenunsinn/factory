| MC68331CAG16
| Based on CPU32 instruction set
    .section .text
    .org 0x1500
	.globl start
start:
	movea.l	$0x10000, %a0
	movea.l	0x00000000:w, %a1
	suba.l	$0x100, %a1

loop:
	cmpa.l	%a1, %a0
	bhi.b	finish
	clr.l	(%a0)+
	bra.b	loop

finish:
	clr.l	0x00001000

	move.l	$0x494e4954, 0x00fffd00

	movea.w	$0x408, %a0
	jsr	(%a0)

die:
	bra.b	die
