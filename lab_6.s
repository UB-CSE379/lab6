	.data

	.global board
	.global current
	.global pauseflag


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



prompt1: 			.string "", 0xA, 0xD
					.string "Please Press SW1 On the Tiva To Play!!!", 0xA, 0xD
					.string "",0x0

lastprompt: 		.string "", 0xA, 0xD
					.string "GAME OVER!!!", 0xA, 0xD
					.string "Your Score is: ",0

clearscreen: 		.string 27,"[2J",0
leftside: 			.string 27,"[0;0H",0

scoreOutput: 		.string "                                h"
newLine: 			.cstring "\r\n"
score: 				.word 1
runningscore:	.cstring "Score: "


current:		.string "w",0
position: 		.word 0xFB	; center
check3:			.word 0
pauseflag:		.word 0


;_______________________________________________________________________________________
	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global timer_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler			; This is needed for Lab #6
	.global simple_read_character
	.global lab6


	; from library file
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global uart_init				; This is from your Lab #4 Library
	.global int2string				; This is from your Lab #4 Library

;_______________________________________________________________________________________

U0FR: 		.equ 0x18

;_______________________________________________________________________________________


ptr_to_board: 			.word board
ptr_to_clearscreen:		.word clearscreen
ptr_to_leftside			.word leftside

ptr_to_prompt1: 		.word prompt1
ptr_to_lastprompt: 		.word lastprompt

ptr_to_runningscore: 	.word runningscore
ptr_scoreOutput: 		.word scoreOutput
ptr_newLine: 			.word newLine

ptr_to_current:			.word current
ptr_position:			.word position

ptr_to_check3:			.word check3
ptr_to_pauseflag:		.word pauseflag
ptr_score:				.word score


;_______________________________________________________________________________________

lab6:
	PUSH {r4-r12,lr}

	;initializes the things
 	BL uart_init
	BL uart_interrupt_init
	BL gpio_interrupt_init
	BL timer_interrupt_init


	LDR r0, ptr_to_clearscreen	; clears the uart
	BL output_string

	LDR r0, ptr_to_leftside		; Goes to left side idk why but from lect
	BL output_string

	LDR r0, ptr_to_board			;prints the initial board
    BL output_string


lab6loop:


	B lab6loop

lab6GameEnd:

	LDR r0, ptr_to_clearscreen	; clears the uart
	BL output_string

	LDR r0, ptr_to_leftside		; Goes to left side idk why but from lect
	BL output_string

	;outputs score during each tick
	LDR r0, ptr_to_runningscore
	BL output_string


	LDR r0, ptr_scoreOutput
	LDR r2, ptr_score
	LDR r1, [r2]
	BL int2string

	LDR r0, ptr_scoreOutput
	BL output_string
	LDR r0, ptr_newLine
	BL output_string

	LDR r0, ptr_to_board			;prints the board
    BL output_string


	LDR r0, ptr_scoreOutput
	BL output_string
	B end


	POP {lr}
	MOV pc, lr


;_______________________________________________________________________________________

Timer_Handler:
	PUSH {r4-r12,lr}


	MOV r0, #0x0000				; clear interrupt
	MOVT r0, #0x4003
	LDRB r1, [r0, #0x024]
	ORR r1, #1
	STRB r1, [r0, #0x024]

								; check pause
	LDR r0, ptr_to_pauseflag
	LDR r1, [r0]
	CMP r1, #1
	BEQ timerEnd

								; check check3
	LDR r0, ptr_to_check3
	LDR r1, [r0]
	CMP r1, #1
	BEQ timerEnd


							; prev keys
	LDR r0, ptr_to_current
	LDR r1, [r0]
	CMP r1, #'s'
	BEQ sletter
	CMP r1, #'d'
	BEQ dletter
	CMP r1, #'a'
	BEQ aletter


wletter:
	LDR r0, ptr_position
	LDR r1, [r0]
	SUB r1, r1, #24

	LDR r2, ptr_to_board
	LDRB r3, [r2, r1]

	CMP r3, #'*'
	BEQ lcheck
	CMP r3, #'|'
	BEQ lcheck
	CMP r3, #'-'
	BEQ lcheck

	LDR r0, ptr_position
	LDR r1, [r0]
	SUB r1, r1, #24
	MOV r3, r1
	STR r1, [r0]



	LDR r0, ptr_to_board	;update on the board
	MOV r4, #'*'
	STRB r4, [r0, r3]

	B mdone



aletter:

	LDR r0, ptr_position
	LDR r1, [r0]
	SUB r1, r1, #1


	LDR r2, ptr_to_board		;check
	LDRB r3, [r2, r1]

	CMP r3, #'*'
	BEQ lcheck
	CMP r3, #'|'
	BEQ lcheck
	CMP r3, #'-'
	BEQ lcheck



	LDR r0, ptr_position		;update in buffer
	LDR r1, [r0]
	SUB r1, r1, #1
	MOV r3, r1
	STR r1, [r0]



	LDR r0, ptr_to_board		;update on board
	MOV r4, #'*'
	STRB r4, [r0, r3]

	B mdone


sletter:

	LDR r0, ptr_position
	LDR r1, [r0]
	ADD r1, r1, #24


	LDR r2, ptr_to_board		;check
	LDRB r3, [r2, r1]

	CMP r3, #'*'
	BEQ lcheck
	CMP r3, #'|'
	BEQ lcheck
	CMP r3, #'-'
	BEQ lcheck


	LDR r0, ptr_position	;update in buffer
	LDR r1, [r0]
	ADD r1, r1, #24
	MOV r3, r1
	STR r1, [r0]



	LDR r0, ptr_to_board	;update on board
	MOV r4, #'*'
	STRB r4, [r0, r3]

	B mdone

dletter:

	LDR r0, ptr_position
	LDR r1, [r0]
	ADD r1, r1, #1


	LDR r2, ptr_to_board	;check
	LDRB r3, [r2, r1]

	CMP r3, #'*'
	BEQ lcheck
	CMP r3, #'|'
	BEQ lcheck
	CMP r3, #'-'
	BEQ lcheck


	LDR r0, ptr_position	;updates in buffer
	LDR r1, [r0]
	ADD r1, r1, #1
	MOV r3, r1
	STR r1, [r0]


	LDR r0, ptr_to_board	;updates on board
	MOV r4, #'*'
	STRB r4, [r0, r3]

	B mdone


mdone:


	LDR r0, ptr_score	;increases the score by 1
	LDR r1, [r0]
	ADD r1, r1, #1
	STR r1, [r0]
	B outputFunction

lcheck:
	LDR r0, ptr_to_check3
	MOV r1, #1
	STR r1, [r0]
	B lout

outputFunction:

	LDR r0, ptr_to_clearscreen	; clears the uart
	BL output_string

	LDR r0, ptr_to_leftside		; Goes to left side idk why but from lect
	BL output_string




	LDR r0, ptr_to_runningscore ;prints score
	BL output_string

	LDR r0, ptr_scoreOutput
	LDR r2, ptr_score
	LDR r1, [r2]
	BL int2string

	LDR r0, ptr_scoreOutput
	BL output_string
	LDR r0, ptr_newLine
	BL output_string


	LDR r0, ptr_to_board
    BL output_string

    B timerEnd

lout:

	LDR r0, ptr_to_clearscreen	; clears the uart
	BL output_string

	LDR r0, ptr_to_leftside		; Goes to left side idk why but from lect
	BL output_string

	LDR r0, ptr_to_board
    BL output_string
    NOP
    LDR r0, ptr_to_lastprompt
    BL output_string


	LDR r0, ptr_scoreOutput
	LDR r2, ptr_score
	LDR r1, [r2]
	BL int2string

	LDR r0, ptr_scoreOutput
	BL output_string

    B timerEnd

timerEnd:
	POP {r4-r12,lr}
	BX lr       	; Return

end:

	.end

