	.data

	.global initialprompt
	.global directionFlag	; track what direction snake is going
	.global pauseFlag ; track if game is paused
	.global board
	.global score




initialprompt: 	.string "\r\n--------------------------------------------------------------------------------\r\n|                                                                              |\r\n|                         THE REFLEX GAME DIRECTIONS                           |\r\n|                                                                              |\r\n--------------------------------------------------------------------------------\r\n|                                                                              |\r\n| Welcome to the Reflex Game! Compete against another player to see who has    |\r\n| the fastest reflexes. One player uses the SW1 button on the Tiva board, and  |\r\n| the other uses the space bar on the keyboard.                                |\r\n|                                                                              |\r\n| HOW TO PLAY:                                                                 |\r\n| 1. Read the rules.                                                            |\r\n| 2. Press the Enter key when you're ready to start the round.                 |\r\n| 3. After a random delay, you'll be prompted to press your button (SW1 or     |\r\n|    space bar). The first to press wins the round.                            |\r\n| 4. If you press too early, you're disqualified for that round.               |\r\n| 5. Scores are displayed after each round. Press Enter to start the next one. |\r\n|                                                                              |\r\n| The game continues until one player scores three points and wins!            |\r\n|                                                                              |\r\n| Good luck, and may the quickest reflex win!                                  |\r\n|                                                                              |\r\n--------------------------------------------------------------------------------\r\n"
board:
    .string " -------------------- ", 0xA, 0xD  ; Top border 

    .string "|                    |", 0xA, 0xD  ; Row 1
    .string "|                    |", 0xA, 0xD  ; Row 2
    .string "|                    |", 0xA, 0xD  ; Row 3
    .string "|                    |", 0xA, 0xD  ; Row 4
    .string "|                    |", 0xA, 0xD  ; Row 5
    .string "|                    |", 0xA, 0xD  ; Row 6
    .string "|                    |", 0xA, 0xD  ; Row 7
    .string "|                    |", 0xA, 0xD  ; Row 8
    .string "|                    |", 0xA, 0xD  ; Row 9
    .string "|                    |", 0xA, 0xD  ; Row 10
    .string "|                    |", 0xA, 0xD  ; Row 11
    .string "|                    |", 0xA, 0xD  ; Row 12
    .string "|                    |", 0xA, 0xD  ; Row 13
    .string "|                    |", 0xA, 0xD  ; Row 14
    .string "|                    |", 0xA, 0xD  ; Row 15
    .string "|                    |", 0xA, 0xD  ; Row 16
    .string "|                    |", 0xA, 0xD  ; Row 17
    .string "|                    |", 0xA, 0xD  ; Row 18
    .string "|                    |", 0xA, 0xD  ; Row 19
    .string "|                    |", 0xA, 0xD  ; Row 20

    .string " -------------------- ", 0xA, 0xD, 0x0  ; Bottom border 

	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global timer_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler			; This is needed for Lab #6
	.global simple_read_character
	.global output_character		; This is from your Lab #4 Library
	.global read_character
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global uart_init					; This is from your Lab #4 Library
	.global lab6
	.global print_all_numbers
	.global string2int

ptr_to_directionFlag: .word directionFlag
ptr_to_pauseFlag: 	.word pauseFlag
ptr_to_score: 	.word score

lab6:								; This is your main routine which is called from
; your C wrapper.
	PUSH {r4-r12,lr}   		; Preserve registers to adhere to the AAPCS

	bl uart_init
	bl uart_interrupt_init ;initializations
	bl gpio_interrupt_init
	bl timer_interrupt_init


	POP {lr}		; Restore registers to adhere to the AAPCS
	MOV pc, lr

	.end

;UART Handler can handle what direction was pressed
; Timer Handler can handle the math and actually moving the *
; how would I pass in what direction was passed in to the timer Handler
;pressing SW1 pauses the game, so you can just disable the timer
; pressing SW1 when its paused, enable the timer
; how do you know when its paused? -
;
