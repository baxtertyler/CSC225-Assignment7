
.global interruptInit
.global isr
.text
# initialization subroutine

interruptInit:

	addi	sp, sp -4
	sw	ra, 0(sp)
	
#To configure an interrupt in the RARS Emulator:
#●NOTE: Interrupts are simplified in RARS. It’s an incomplete implementation, but still close enough to be educational.
#●Configure utvec with the address of the handler/service routine
#–RARS only supports Direct Mapped Interrupts

	la 	t0, isr
 	csrrw 	zero, 5, t0

#●Initialize System Stack Pointer by setting the scratch register with the starting address of the System Stack (0x0).

	csrw	sp, 64

#●Enable detection of external device interrupts.
#–Set User External Interrupt Enable (UEIE) bit  (bit 8) in the User Interrupt Enable (uie) register to enable detection of 
#external device interrupts.

	#li	t0, 128
	li	t0, -1
	csrw	t0, 4

#●Configure device to send Interrupts if necessary (see following slide)

	lw	t0, RCR
	li	t1, 3
	sw	t1, (t0)

#●Set global interrupt enable (ie) bit in ustatus.
#–All interrupt configuration must be done before asserting Global Interrupts in the ustatus register.
#–Bad things can happen if you change interrupt setting while enabled.
	
	li	t0, 1
	csrw	t0, 0
		
	la	a0, Ii			# print statement 
	jal 	printString
	
	lw	ra, 0(sp)		# restore sp and ra
	addi	sp, sp, 4
	ret	
	
	
	
	
	
# handler code 
	
isr:
	addi	sp, sp, -32		# save reg to stack because interrupt
	sw	t1, 0(sp)
	sw	t4, 4(sp)
	sw	t5, 8(sp)
	sw	t6, 12(sp)
	
	la	t4, counter		# creeate counter to make sure loop only runs 5 times
	lw	t5, 0(t4)
	addi	t5, t5, 1
	li	t6, 5
	
	sw	t5, 0(t4)		# save counter to memory
	
	la	a0, Kp
	jal 	printString		# print key pressed is: string

	jal 	readChar		# get a char from input
	
	jal	printChar		# print one char after key pressed is: statement
	
	beq	t5, t6, reset
	
	sw	a0, 16(sp)		# save a0 so we can print a newline without losing char pressed
	la	a0, newLine
	jal	printString
	lw	a0, 16(sp)
	
	li	t0, 1			# reset ustatus so we can accept multiple key pressed
	csrw	t0, 0

	lw	t1, 0(sp)		# reload all reg
	lw	t4, 4(sp)
	lw	t5, 8(sp)
	lw	t6, 12(sp)
	addi	sp, sp, 32
	
	b	loop			# go back to other file


reset:
	la	a0, newLine		# print a new line for formatting
	jal	printString
	
	la	t4, counter		# reset counter
	li	t5, 0
	sw	t5, 0(t4)
	
	la	t4, main		# go back to main to restart program
	csrrw 	zero, 65, t4
	uret
	





.data

Ii:		.string "\nInitializing Interrupts\n"
Kp:		.string "\nKey Pressed is: "
newLine:	.string "\n"

RCR: 		.word 0xffff0000
RDR: 		.word 0xffff0004
TCR: 		.word 0xffff0008
TDR: 		.word 0xffff000c

counter:	.word 0x00000000






