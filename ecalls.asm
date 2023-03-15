# ecalls.asm
.globl printInt
.globl printString
.globl printChar
.globl printNewLine

.globl readInt
.globl readChar
.globl readString
.globl exitProgram

printInt:
	li 	a7, 1
	ecall
	ret
	
printString:
	li	a7, 4
	ecall
	ret
	
printChar:
	li	a7, 11
	ecall
	ret
	
printNewLine:
	la 	a0, newLine
	li 	a7, 4
	ecall
	ret
	
readInt:
	li	a7, 5
	ecall
	ret
	
readChar:
	li	a7, 12
	ecall
	ret
	
exitProgram:
	li 	a7, 10
	ecall	
	ret

readString:	
	li	t2, 0
	add	t2, t2, a0
	li	t0, 10

	cont:

	li	a7, 12
	ecall
	
	beq	a0, t0, end
	
	sb	a0, 0(t2)
	addi	t2, t2, 1
	
	b	cont
	
end:
	ret
	
	
	
	.data
newLine: 	.string "\n"
svra:		.word	-1
