# tyler baxter and jack herburger

# testint.asm

.text
.global main
.global loop

main:
	jal 	interruptInit
	li	a0, 42
loop:
	jal 	printChar
	b 	loop
