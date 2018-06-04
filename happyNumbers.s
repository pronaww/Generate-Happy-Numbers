.equ SWI_Exit, 0X11
.equ SWI_Printint, 0X6B
.equ SWI_Open, 0x66
.equ SWI_Close, 0x68
.equ SWI_PrintStr, 0X69
.equ SWI_PrChr, 0x00
.text

Main:
ldr r0,=OutFileName @ set Name for output file
mov r1,#1 @ mode is output
swi SWI_Open @ open file for output
ldr r1,=OutFileHandle @ load output file handle
str r0,[r1]



mov r1, #0 @j
mov r2, #1 @i
ldr r3, =P @r3 is x
ldr r4, =Q @r4 is y

ldr r3 , =O

Loop:
ldr r0, =9999
cmp r2, r0

bge Loop_end
add r2,r2,#1

mov r11, r4
mov r8, r3
bl copy_BCD
Chk1:
ldr r0, [r4, #4]
cmp r0, #0
beq Chk2
Loop1:
@r9
@r4
bl sum_square
Back_from_sum_square:
mov r11, r4
mov r8, r5
bl copy_BCD
b Chk1

Chk2:
ldr r0, [r4, #8]
cmp r0, #0
beq Chk3
b Loop1

Chk3:
ldr r0, [r4, #12]
cmp r0, #0
beq Chk_if
b Loop1

Chk_if:
ldr r0, [r4]
cmp r0, #1
beq Printer
ldr r0, [r4]
cmp r0, #7
beq Printer

Back_from_print:

ldr r0, =Ores

ldr r9, [r3]
ldr r10,[r0]
mov r6, #0
bl add_BCD_single
str r9, [r3]

ldr r9, [r3,#4]
ldr r10,[r0,#4]
bl add_BCD_single
str r9, [r3,#4]

ldr r9, [r3,#8]
ldr r10,[r0,#8]
bl add_BCD_single
str r9, [r3,#8]

ldr r9, [r3,#12]
ldr r10,[r0,#12]
bl add_BCD_single
str r9, [r3,#12]

b Loop

Loop_end:

@ load the file handle
ldr r0,=OutFileHandle
ldr r0,[r0]
swi SWI_Close

swi SWI_Exit


Printer:
mov r11, r1
add r11,r11, #1

ldr r0,=OutFileHandle
ldr r0, [r0]
ldr r1, =msg1
swi SWI_PrintStr
mov r1, r11
swi SWI_Printint
ldr r1, =msg2
swi SWI_PrintStr
ldr r1, [r3, #12]
swi SWI_Printint
ldr r1, [r3, #8]
swi SWI_Printint
ldr r1, [r3, #4]
swi SWI_Printint
ldr r1, [r3]
swi SWI_Printint
ldrb r1, =EOL
swi SWI_PrintStr


mov r1, r11

b Back_from_print

@r11 is *first number
@r8 is *s
copy_BCD:

	ldr r0, [r8]
	str r0, [r11]
	ldr r0, [r8, #4]
	str r0, [r11, #4]
	ldr r0, [r8, #8]
	str r0, [r11, #8]
	ldr r0, [r8, #12]
	str r0, [r11, #12]

	mov pc, lr


@r8 is output as well as dd
@r7 is d
square_digit:
	ldr r8, =Z2
	mov r0,#0
	str r0, [r8]
	str r0, [r8, #4]
	str r0, [r8, #8]
	str r0, [r8, #12]
	mul r0, r7, r7

	str r0, [r8]
	cmp r0, #9

	ble L_end
	SubBranch:
	ldr r0, [r8]
	sub r0, r0, #10
	str r0, [r8]

	ldr r0, [r8, #4]
	add r0, r0 , #1
	str r0, [r8, #4]

	ldr r0, [r8]
	cmp r0, #10
	bge SubBranch

	L_end:
	mov pc, lr 

@r9 is *y
@r10 is *z
add_BCD_single:
	

	add r9, r9 ,r10
	add r9, r9, r6
	
	mov r6, #0
	cmp r9, #9
	ble L1
	sub r9, r9, #10	
	mov r6, #1
	L1:

	mov pc, lr

@r9 is *s
@r4 is *x
sum_square:
@r8 is always dd
mov r0,#0
ldr r5, =Z
str r0, [r5]
str r0, [r5, #4]
str r0, [r5, #8]
str r0, [r5, #12]
mov r12, #0 @i

L2:
cmp r12, #4
subge r4, r4, #16
bge Back_from_sum_square
add r12, r12, #1
ldr r7, [r4]
bl square_digit

ldr r9, [r5]
ldr r10,[r8]
mov r6, #0
bl add_BCD_single
str r9, [r5]

ldr r9, [r5, #4]
ldr r10,[r8, #4]
bl add_BCD_single
str r9, [r5, #4]

ldr r9, [r5, #8]
ldr r10, [r8, #8]
bl add_BCD_single
str r9, [r5, #8]

ldr r9, [r5, #12]
ldr r10,[r8, #12]
bl add_BCD_single
str r9, [r5, #12]

add r4,r4,#4
b L2



.data
O: .word 1,0,0,0
Ores: .word 1,0,0,0
Z: .word 0,0,0,0
Z2: .word 0,0,0,0
P: .space 16
Q: .space 16
dd: .space 16
msg1: .asciiz "number["
msg2: .asciiz "] = "

OutFileName: .asciz "Outfile1.txt"
OutFileError:.asciz "Unable to open output file\n"
.align
OutFileHandle:.word 0
EOL: .asciiz "\n   "

.end
