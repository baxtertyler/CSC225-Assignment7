# ecalls.asm
#Jack Herberger and Tyler Baxter

.global printInt
.global printString
.global printChar
.global printNewLine

.global readInt
.global readChar
.global readString
.global exitProgram

.text

printInt:
	lw	t1, TCR  		# t1 = address of the TCR (value that determines if screen is ready)
	lw	t0, (t1) 		# t0 = value at address of TCR
	andi	t0, t0, 1		# check if t0 = 0 or 1
	beq	t0, zero, printInt	# if t0 = 0, screen is not ready to print and subrountine restarts
	lw	t2, TDR			# t2 = address of the TDR (value to be printed)
	addi	a0, a0, 48		# add 48 to the value to get ascii -> actual number
	sw	a0, (t2)		# a0 = value at address of t2 (TDR)
					# int is printed from TDR to MMIO screen
	ret

	
printString:
	addi	sp, sp, -4		# make room on stack and save the ra to it so we val JAL printchar
	sw	ra, 0(sp)
	mv	t3, a0			# change var being used for location of string to t3
	PSloop:
		lb	a0, 0(t3)	# get current char
		beqz	a0, PSend	# if current char is the null char, b to end of loop
		jal 	printChar	# MMIO print char
		addi	t3, t3, 1	# add 1 to t3 to get to the next char
		b	PSloop		# loop
	PSend:
	lw	ra, 0(sp)		# retore ra and sp
	addi	sp, sp, 4
	ret
	
printChar:
	lw	t1, TCR  		# t1 = address of the TCR (value that determines if screen is ready)
	lw	t0, (t1) 		# t0 = value at address of TCR
	andi	t0, t0, 1	 	# check if t0 = 0 or 1
	beq	t0, zero, printChar	# if t0 = 0, screen is not ready to print and subrountine restarts
	lw	t2, TDR			# t2 = address of the TDR (value to be printed)
	sw	a0, (t2)		# value at address of t2 (TDR) = a0
					# char is printed from TDR to MMIO screen
	ret


printNewLine:				# old ecalls version
	la 	a0, newLine
	li 	a7, 4
	ecall
	ret
	
readInt:
	lw   	t1, RCR 		# t1 = address of the RCR (value that determines if CPU is ready)
	lw   	t0, (t1)		# t0 = value at address of RCR
	andi 	t0, t0, 1		# check if t0 = 0 or 1
	beq  	t0, zero, readInt	# if t0 = 0, CPU is not ready for input and subrountine restarts (polling)
	lw   	t1, RDR  		# t1 = address of the TDR (value to be printed)
	lbu  	a0, (t1) 		# a0 = value at address of t1 (RDR) unsgined
	addi	a0, a0, -48		# subtract 48 to the value to get actual number -> ascii
					# int is read from the MMIO input screen
	ret
	
readChar:
	lw   	t1, RCR 		# t1 = address of the RCR (value that determines if CPU is ready)
	lw   	t0, (t1)		# t0 = value at address of RCR
	andi 	t0, t0, 1		# check if t0 = 0 or 1
	beq  	t0, zero, readChar	# if t0 = 0, CPU is not ready for input and subrountine restarts (polling)
	lw   	t1, RDR 		# t1 = address of the RDR (value to be read)
	lbu  	a0, (t1) 		# a0 = value at address of t1 (RDR) unsgined
					# char is read from the MMIO input screen
	ret
	
exitProgram:				# old ecalls version
	li 	a7, 10
	ecall	
	ret

readString:				
	addi	sp, sp, -16		# create room on the stack to use saved registers and to save the return address
	sw	ra, 12(sp)		# save the return address to the stack
	sw	s0, 8(sp)		# save the value at s0 to be able to use register
	mv	s0, a0			# s0 = a0
	li	t2, 10			# t2 = 10 (ascii for the enter key)

	RSwhile:				# while loop that calls readChar until the char read is the enter key
		jal readChar
		beq	a0, t2, RSend	
		sb	a0, 0(s0)	# store byte at a0 into the location of s0
		addi	s0, s0, 1	# increase s0 by one to contine iteration 
		lb	t1, 8(sp)	# t1 = old s0
		add	a0, t1, a0	# a0 = t1 + a0
		b RSwhile	

	RSend:
	lw	ra, 12(sp)		# return address, s0, and stack pointer are set to values before subroutine call
	lw	s0, 8(sp)
	addi	sp, sp, 16
	ret
	
.data

newLine: 	.string "\n"
svra:		.word	-1
RCR: 		.word 0xffff0000
RDR: 		.word 0xffff0004
TCR: 		.word 0xffff0008
TDR: 		.word 0xffff000c
