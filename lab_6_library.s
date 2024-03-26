	.data

	.global board
	.global direction
	.global hit
	.global moves
	.global number
	.global clearscreen
	.global leftside

direction:		.half 	0x0000	;init to move right				(whichever is greater), it obtains a difference, or deviation. The guidance subsystem
hit:		.string "You hit a wall.",0x00	;					uses deviations to generate corrective commands to drive the * from a position where
moves:		.string "       SCORE: ",0x00	;					it is to a position where it isnt, and arriving at a position where it wasnt, it now is.
number:		.string	0x00,0x00,0x00,0x00,0x00
keyPress:		.string "w",0
position: 		.word 0xFB	; center
quitGame: 		.word 0
pauseGameCheck:	.word 0
lossedCheck:	.word 0

board: 	.string "----------------------", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|          *         |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "----------------------", 0x0

	.text

	.global lab6
	.global game

	.global uart_init
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global timer_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler
	.global simple_read_character
	.global output_character
	.global output_string

	.global new_line
	.global int2string
	.global printscore




**************************************************************************************************
SYSCTL:			.word	0x400FE000	; Base address for System Control
GPIO_PORT_A:	.word	0x40004000	; Base address for GPIO Port A
GPIO_PORT_B:	.word	0x40005000	; Base address for GPIO Port B
GPIO_PORT_D:	.word	0x40007000	; Base address for GPIO Port D
GPIO_PORT_F:	.word	0x40025000	; Base address for GPIO Port F
EN0:			.word   0xE000E000  ; Base address for Set Enable Register
RCGCGPIO:		.equ	0x608		; Offset for GPIO Run Mode Clock Gating Control Register
GPIODIR:		.equ	0x400		; Offset for GPIO Direction Register
GPIODEN:		.equ	0x51C		; Offset for GPIO Digital Enable Register
GPIODATA:		.equ	0x3FC		; Offset for GPIO Data
UART0:			.word	0x4000C000	; Base address for UART0
U0FR: 			.equ 	0x18		; UART0 Flag Register
ASCIIw:		.equ 0x77
ASCIIa:		.equ 0x61
ASCIIs:		.equ 0x73
ASCIId:		.equ 0x64
ASCIIq:		.equ 0x71
ASCIIstar: 	.equ 0x2A
ASCIIwall: 	.equ 0x7C
ASCIItopB: 	.equ 0x2D
**************************************************************************************************
ptr_board: 			.word board
ptr_to_direction:		.word direction
ptr_to_hit:				.word hit
ptr_to_moves:			.word moves
ptr_to_number:			.word number
ptr_to_clearscreen:		.word clearscreen
ptr_to_leftside:		.word leftside
ptr_keyPress:			.word keyPress
ptr_position:			.word position
ptr_quitGame: 			.word quitGame
ptr_pauseGameCheck:		.word pauseGameCheck
ptr_lossedCheck:		.word lossedCheck
**************************************************************************************************

uart_init:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
							; Your code for your uart_init routine is placed here
	MOV r0, #0xE618
    MOVT r0, #0x400F
    MOV r1, #0x1
    STR r1, [r0]



    MOV r0, #0xE608
    MOVT r0, #0x400F
    MOV r1, #0x1
    STR r1, [r0]



    MOV r0, #0xC030
    MOVT r0, #0x4000
    MOV r1, #0x0
    STR r1, [r0]



     MOV r0, #0xC024
    MOVT r0, #0x4000
    MOV r1, #8
    STR r1, [r0]



    MOV r0, #0xC028
    MOVT r0, #0x4000
    MOV r1, #44
    STR r1, [r0]



    MOV r0, #0xCFC8
    MOVT r0, #0x4000
    MOV r1, #0x0
    STR r1, [r0]



    MOV r0, #0xC02C
    MOVT r0, #0x4000
    MOV r1, #0x60
    STR r1, [r0]



    MOV r0, #0xC030
    MOVT r0, #0x4000
    MOV r1, #0x301
    STR r1, [r0]



    MOV r0, #0x451C
    MOVT r0, #0x4000
    MOV r1, #0x03
    LDR r2 ,[r0]
    ORR r1 , r1, r2
    STR r1, [r0]


    MOV r0, #0x4420
    MOVT r0, #0x4000
    MOV r1, #0x03
    LDR r2 ,[r0]
    ORR r1 , r1, r2
    STR r1, [r0]


	MOV r0, #0x452C
    MOVT r0, #0x4000
    MOV r1, #0x11
    LDR r2 ,[r0]
    ORR r1 , r1, r2
    STR r1, [r0]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


	;############################################# uart_init END #############################################


uart_interrupt_init:
	PUSH {lr} ; Store register lr on stack
	;Configuring the UART for Interrupts
	LDR r0, UART0		;set address to 0x4000C000
	LDR r1, [r0, #0x038]
	ORR r1, #0x10		;mask and set bit 4 to 1
	STR r1, [r0, #0x038]
	;Configure Processor to allow UART0 to Interrupt Processor (EN0)
	MOV r0, #0xE000		;set address to 0xE000E000
	MOVT r0, #0xE000
	LDR r1, [r0, #0x100]
	ORR r1, r1, #0x20	;mask and set bit 5 to 1
	STR r1, [r0, #0x100]

	POP {lr}
	MOV pc, lr
	;############################################# uart_interrupt_init END #############################################



gpio_interrupt_init:
	PUSH {lr}
	;ENABLING SWITCH 1 ON TIVA BOARD
	;enabling clock for Port F
	LDR r0, SYSCTL				;load memory address of clock to r0
    LDR r1, [r0, #0x608]		;load content of r0 with offset of 0x608 to r1
    ORR r1, r1, #0x20			;set bit 6 to enable clock for Port F
    STR r1, [r0, #0x608]		;store r1 into r0 with offset of 0x608 enabling clock in Port F

    ;set GPIO Pin Direction as Input for Port F
    LDR r0, GPIO_PORT_F		    ;move memory address of Port F base address to r0
    LDR r1, [r0, #0x400]		;load content of r0 with offset of 0x400 to r1
    BIC r1, r1, #0x10			;bitwise manipulation to clear bit 5 for Port F Pin 4
    STR r1, [r0, #0x400]		;store r1 into GPIO Pin Direction as Input for Port F Pin 4

    ;Enable GPIO Pin 4 for Port F to Digital
    LDR r1, [r0, #0x51C]		;load content of r0 wuth offset of 0x51C to r1
	ORR r1, #0x10				;bitwise manipluation to set bit 5 as 1 for Port F Pin 4
	STR r1, [r0, #0x51C]		;store r1 to r0 with offset of 0x51C enabling Port F Pin 4 as Digital Pin

	;Enable pull-up resistor for Port F
    LDR r1, [r0, #0x510]		;load content of r0 with offset of 0x510 to r1
	ORR r1, #0x10				;set bit 5 to enable pull-up resistor for Pin 4 for Port F
	STR r1, [r0, #0x510]		;store r1 into r0 enabling pull-up resistor for Pin 5 for Port F

	;Set Edge Sensitive for Port F Pin 4
	LDR r0, GPIO_PORT_F			;move memory address of Port F base address to r0
	LDR r1, [r0, #0x404]		;load content of r0 with offset of 0x404 to r1
	BIC r1, #0x10				;bitwise manipulation to clear bit 5 for Port F Pin 4
	STR r1, [r0, #0x404]		;store r1 into r0 to change it edge sensitive (Falling or Rising Edge) for Port F Pin 4

	;Setup the Interrupt for Edge Sensitive via the GPIO Interrupt Single Edges Register for Port F Pin 4
	LDR r1, [r0, #0x408]		;load content of r0 with offset of 0x408 to r1
	BIC r1, #0x10				;bitwise manipulation to clear bit 5 for Port F Pin 4
	STR r1, [r0, #0x408]		;store r1 into r0 to change it to allow GPIO Interrupt Event (GPIOEV) Register to Control Pin for Port F Pin 4

	;Setting the Interrupt for Falling Edge Triggering via the GPIO Interrupt Event Register for Port F Pin 4
	LDR r1, [r0, #0x40C]		;load content of r0 with offset of 0x40C to r1
	BIC r1, #0x10			;clear bit 4 to enable the falling edge for Port F Pin 4
	STR r1, [r0, #0x40C]		;store r1 into r0 to enable the falling edge for Port F Pin 4

	;Enabling the Interrupt for Port F Pin 4
	LDR r1, [r0, #0x410]		;load content of r0 with offset of 0x410 to r1
	ORR r1, #0x10				;set bit 5 to enable interrupt for Pin 4 for Port F
	STR r1, [r0, #0x410]		;store r1 into r0 to enable the interrupt for Port F Pin 4

	;Configure Processor to Allow GPIO Port F to Interrupt Processor
	LDR r0, EN0
	LDR r1, [r0, #0x100]		;load content of r0 with offset with 0x100 to r1
	ORR r1, #0x40000000			;set bit 30 to allow GPIO Port F to Interrupt Processor
	STR r1, [r0, #0x100]		;store r1 into r0 to allow GPIO Port F to Interrupt Processor

	POP {lr}
	MOV pc, lr

	;############################################# gpio_interrupt_init END #############################################

timer_interrupt_init:
	PUSH {lr}
	;Enable Clock for Timer (Tx) where x is timer number
	MOV r0, #0xE000				;move memory address of Clock base address to r0
	MOVT r0, #0x400F
	LDR r1, [r0, #0x604]		;load content of r0 with offset with 0x604 to r1
	ORR r1, #0x1				;set bit 0 to allow enable Clock for Timer0
	STR r1, [r0, #0x604]		;store r1 into r0 to allow Clock to be enable for Timer0

	;Disable Timer
	MOV r0, #0x0000				;move memory address of Timer0 base address to r0
	MOVT r0, #0x4003
	LDR r1, [r0, #0x00C]		;load content of r0 with offset with 0x00C to r1
	BIC r1, #0x1				;clear bit 0 to disable Timer0
	STR r1, [r0, #0x00C]		;store r1 into r0 to disable Timer0

	;Setting up Timer for 32-Bit Mode
	LDR r1, [r0, #0x000]		;load content of r0 with offset with 0x000 to r1
	BIC r1, #0x000				;Clear bit 0,1,2 to configure the Timer as a single 32-bit timer
	STR r1, [r0, #0x000]		;store r1 into r0 to set Timer0 as a single 32-bit timer

	;Put Timer in Periodic Mode
	LDR r1, [r0, #0x004]		;load content of r0 with offset with 0x004 to r1
	ORR r1, #0x2				;Write 2 to TAMR to change the mode of Timer0 to Periodic Mode
	STR r1, [r0, #0x004]		;store r1 into r0 to change Timer as Periodic Mode

	;Setup Interval Period
	LDR r1, [r0, #0x028]		;load content of r0 with offset with 0x028 to r1
	MOV r1, #0x2400				;set r1 as 16000000 to make the Timer interrupt to start at 1 second
	MOVT r1, #0x00F4
	STR r1, [r0, #0x028]		;store r1 into r0 to make Timer interrupt start every 1 second

	;Setup Timer to Interrupt Processor
	LDR r1, [r0, #0x018]		;load content of r0 with offset with 0x018 to r1
	ORR r1, #0x1				;set bit 0 to enable Timer to Interrupt Processor
	STR r1, [r0, #0x018]		;store r1 into r0 to enable Timer to Interrupt Processor

	;Configure Processor to Allow Timer to Interrupt Processor
	LDR r0, EN0					;move memory address of EN0 base address to r0
	LDR r1, [r0, #0x100]		;load content of r0 with offset of 0x100 to r1
	ORR r1, #0x80000			;set bit 19 to Timer0 to Interrupt Processor
	STR r1, [r0, #0x100]		;store r1 into r0 to allow Timer0 to Interrupt Processor

	;Enable Timer
	MOV r0, #0x0000				;move memory address of Timer0 base address to r0
	MOVT r0, #0x4003
	LDR r1, [r0, #0x00C]		;load content of r0 with offset of 0x00C to r1
	ORR r1, #0x1				;set bit 0 to enable Timer0
	STR r1, [r0, #0x00C]		;store r1 into r0 to enable Timer0

	POP {lr}
	MOV pc, lr
	;############################################# timer_interrupt_init END #############################################


;UART0_HANLDER SUBROUTINE
UART0_Handler:
	PUSH {r4-r12,lr}

	; clear interrupt
	MOV r4, #0xC000
	MOVT r4, #0x4000
	LDR r5, [ r4, #0x044]
	ORR r5, r5, #16
	STR r5, [ r4, #0x044]

	; read character and store accordinly
	BL simple_read_character
	MOV r5, r0

	CMP r0, #ASCIIw
	BEQ wPressed
	CMP r0, #ASCIIa
	BEQ aPressed
	CMP r0, #ASCIIs
	BEQ sPressed
	CMP r0, #ASCIId
	BEQ dPressed
	CMP r0, #ASCIIq
	BEQ qPressed
	B wPressed


wPressed:
	LDR r4, ptr_keyPress
	STR r0, [r4]
	B UARTend

aPressed:
	LDR r4, ptr_keyPress
	STR r0, [r4]
	B UARTend

sPressed:
	LDR r4, ptr_keyPress
	STR r0, [r4]
	B UARTend

dPressed:
	LDR r4, ptr_keyPress
	STR r0, [r4]
	B UARTend

qPressed:
	LDR r4, ptr_quitGame
	MOV r5, #1
	STR r5, [r4]
	B UARTend

UARTend:


	POP {r4-r12,lr}
	BX lr       	; Return
	;############################################# UART0_Handler END #############################################


;SWITCH_HANDLER SUBROTUINE
Switch_Handler:
	PUSH {r4-r12,lr}

	; clear interupt
	MOV r0, #0x5000
    MOVT r0, #0x4002
    LDRB r1, [r0, #0x41C]
    ORR r1, r1, #0x10
    STRB r1, [r0, #0x41C]

	; xoring the pause shit and putting it back
	LDR r4, ptr_pauseGameCheck
	LDR r5, [r4]
	EOR r5, #1
	STR r5, [r4]

	POP {r4-r12,lr}
	BX lr       	; Return
	;############################################# Switch_Handler END #############################################


Timer_Handler:
	PUSH {lr}

	MOV r0, #0x0000				;move memory address of Timer0 base address to r0
	MOVT r0, #0x4003
	LDR r1, [r0, #0x024]		;load content of r0 with offset of 0x024 to r1
	ORR r1, #0x1				;set bit 0 to clear Timer0 interrupt so Timer0 interrupt can be interrupted again
	STR r1, [r0, #0x024]		;store r1 into r0 to clear Timer0 interrupt so Timer0 interrupt can be itnerrupted again
	ADD r9, r9, #1

		; check pause -> skip to end if 1
	LDR r0, ptr_pauseGameCheck
	LDR r1, [r0]
	CMP r1, #1
	BEQ timerEnd

	; check lossed -> skip to end if 1
	LDR r0, ptr_lossedCheck
	LDR r1, [r0]
	CMP r1, #1
	BEQ timerEnd

	; check last key pressed
	LDR r0, ptr_keyPress
	LDR r1, [r0]
	CMP r1, #ASCIIw
	BEQ wFunction
	CMP r1, #ASCIIa
	BEQ aFunction
	CMP r1, #ASCIIs
	BEQ sFunction
	CMP r1, #ASCIId
	BEQ dFunction

wFunction:
	; r1 new position
	LDR r0, ptr_position
	LDR r1, [r0]
	SUB r1, r1, #24

	; check new move location
	LDR r2, ptr_board
	LDRB r3, [r2, r1]

	CMP r3, #ASCIIstar
	BEQ lossedFunction
	CMP r3, #ASCIIwall
	BEQ lossedFunction
	CMP r3, #ASCIItopB
	BEQ lossedFunction


	; update position global variable
	LDR r0, ptr_position
	LDR r1, [r0]
	SUB r1, r1, #24
	MOV r3, r1
	STR r1, [r0]


	; update position on board
	LDR r0, ptr_board
	MOV r4, #ASCIIstar
	STRB r4, [r0, r3]
	NOP
	B moveSuccess



aFunction:
	; r1 new position
	LDR r0, ptr_position
	LDR r1, [r0]
	SUB r1, r1, #1

	; check new move location
	LDR r2, ptr_board
	LDRB r3, [r2, r1]

	CMP r3, #ASCIIstar
	BEQ lossedFunction
	CMP r3, #ASCIIwall
	BEQ lossedFunction
	CMP r3, #ASCIItopB
	BEQ lossedFunction


	; update position global variable
	LDR r0, ptr_position
	LDR r1, [r0]
	SUB r1, r1, #1
	MOV r3, r1
	STR r1, [r0]


	; update position on board
	LDR r0, ptr_board
	MOV r4, #ASCIIstar
	STRB r4, [r0, r3]
	NOP
	B moveSuccess


sFunction:
	; r1 new position
	LDR r0, ptr_position
	LDR r1, [r0]
	ADD r1, r1, #24

	; check new move location
	LDR r2, ptr_board
	LDRB r3, [r2, r1]

	CMP r3, #ASCIIstar
	BEQ lossedFunction
	CMP r3, #ASCIIwall
	BEQ lossedFunction
	CMP r3, #ASCIItopB
	BEQ lossedFunction


	; update position global variable
	LDR r0, ptr_position
	LDR r1, [r0]
	ADD r1, r1, #24
	MOV r3, r1
	STR r1, [r0]


	; update position on board
	LDR r0, ptr_board
	MOV r4, #ASCIIstar
	STRB r4, [r0, r3]
	NOP
	B moveSuccess

dFunction:
	; r1 new position
	LDR r0, ptr_position
	LDR r1, [r0]
	ADD r1, r1, #1

	; check new move location
	LDR r2, ptr_board
	LDRB r3, [r2, r1]

	CMP r3, #ASCIIstar
	BEQ lossedFunction
	CMP r3, #ASCIIwall
	BEQ lossedFunction
	CMP r3, #ASCIItopB
	BEQ lossedFunction


	; update position global variable
	LDR r0, ptr_position
	LDR r1, [r0]
	ADD r1, r1, #1
	MOV r3, r1
	STR r1, [r0]


	; update position on board
	LDR r0, ptr_board
	MOV r4, #ASCIIstar
	STRB r4, [r0, r3]
	NOP
	B moveSuccess


moveSuccess:
	; set key pressed to w
	LDR r0, ptr_keyPress
	MOV r1, #ASCIIw
	STRB r1, [r0]

	; set score increase by 1

	B timerEnd

lossedFunction:
	LDR r0, ptr_lossedCheck
	MOV r1, #1
	STR r1, [r0]
	B timerEnd


timerEnd:

	BL game

	POP {r4-r12,lr}
	BX lr       	; Return

	BL game


	;############################################# Timer_Handler END #############################################


simple_read_character:
	PUSH {lr}   ; Store register lr on stack
	LDR r2, UART0
	LDRB r0, [r2]			;load data

	POP {lr}
	MOV pc, lr
	;############################################# simple_read_character END #############################################


;OUTPUT_CHARACTER_SUBROUTINE
output_character:
	PUSH {lr}   ; Store register lr on stack

output_character_loop:
	LDR r2, UART0
	LDRB r1, [r2, #U0FR]		;get TxFF bit
	AND r1, #0x20				;isolate 0xFF bit
	CMP r1, #0					;if bit 1 branch
	BNE output_character_loop
	STRB r0, [r2]				;if 0 store in data

	POP {lr}
	MOV pc, lr
	;############################################# output_character END #############################################


;OUTPUT_STRING SUBROUTINE
output_string:
	PUSH {lr}   			; Store register lr on stack

output_string_loop:
	MOV r1, r0				;store addy in r1
	PUSH {r0}				;push addy to stack
LOAD_num_string:
	LDRB r0, [r1]			;load char
	CMP r0, #0x00			;check for NULL char
	BEQ end_output_string
	BL output_character
	POP {r0}				;pop addy from stack
	ADD r0, r0, #1			;increment addy
	B output_string_loop

end_output_string:
	POP {r0}
	POP {lr}
	MOV pc, lr
	;############################################# output_string END #############################################

;NEW_LINE SUBROUTINE
new_line:
	PUSH {lr}

	MOV r0, #0xA
	BL output_character
	MOV r0, #0xD
	BL output_character

	POP {lr}
	MOV pc, lr
	;############################################# new_line END #############################################


;INT2STRING SUBROUTINE
int2string:
	PUSH {lr}   				; Store register lr on stack
								;r0  = int
								;r1  = addy
								;r4 or higher must push pop
								;## not passed in ##
								;r2  = avg size (lmao)
	PUSH {r4}					;r4  = didgit compare
								;	 = avg maniuplated
	PUSH {r5}					;r5  = temp var
								;	 = digit to be stored
	MOV r5, #1						;init
	PUSH {r9}					;r9  = BASETEN var
	MOV r9, #10						;init
	PUSH {r10}					;r10 = 10
	MOV r10, #10					;init

integer_digit:		;get size of int if 1
	MOV r4, #9		;load 9 for digit compare
	MOV r2, #1		;load 1 to count digits
	CMP r0, r4		;compare number and digit compare to determine if more then one digit
	BGT COMPARE		;if more then one digit jump to compare
	MOV r2, #1		;return 1 as digit count

COMPARE:			;get size of average >1
	ADD r2, r2, #1
	MUL r4, r4, r10		;jump another digit ie 9 to 90
	ADD r4, r4, #9		;push to highest for digit ie 99 for two digits
	CMP r0, r4
	BGT COMPARE			;if greater then check for another digit

	MOV r4, r0		;r4 will be maniuptlated
	CMP r2, #1		;if first digit then base being 10 works
	BEQ MODULO

BASETEN:			;this will calulate the size used for MOD ie. 10/100/1000
	ADD r5, r5, #1
	MUL r9, r9, r10
	CMP r2, r5
	BNE BASETEN

loopint2string:

MODULO:
	SDIV r5, r4, r9		;input/base 10 mod
	MUL r5, r5, r9		;qoutient*base 10 mod
	SUB r5, r4, r5		;input - product = remainder
	CMP r1, #1
	BNE MODULOTWO
	B STORE_int2string

MODULOTWO:
	SDIV r9, r9, r10
	SDIV r5, r5, r9

STORE_int2string:
	ADD r5, r5, #48   	;convert int into string
	STRB r5, [r1] 		;store the string into the memory address
	CMP r2, #1 		  	;check if last didigt
	BEQ end_int2string 	;exit if it null
	ADD r1, r1, #1		;add 1 to r1 to move to the next address
	SUB r2, r2, #1		;next didgit

	B loopint2string    ;go back to loop
end_int2string:
	MOV r4, #0x00
	STRB r4, [r1, #1]

	POP {r10}	;reset stack and regs
	POP {r9}	;FIFO
	POP {r5}
	POP {r4}

	POP {lr}
	mov pc, lr
	;############################################# int2string END #############################################


printscore:
	PUSH {lr}

	LDR r0, ptr_to_leftside
	BL output_string

	LDR r0, ptr_to_moves
	BL output_string
	MOV r0, r9				;allow the move counter to be store as a string in memory
	LDR r1, ptr_to_number
	BL int2string
	LDR r0, ptr_to_number	;print said move counter
	BL output_string

	BL new_line


	POP {lr}
	MOV pc, lr



end_game:
	PUSH {lr}

	;need to shut off timer interupt
	BL new_line				;print under gameboard
	LDR r0, ptr_to_hit
	BL output_string

	NOP

.end
