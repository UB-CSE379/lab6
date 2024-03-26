	.data

	 .global board
	 .global direction
	 .global hit
	 .global moves
	 .global clearscreen
	 .global leftside


clearscreen: 	.string 27,"[2J",0
leftside: 		.string 27,"[0;0H",0

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


ptr_to_clearscreen: 	.word clearscreen
ptr_to_leftside:		.word leftside
ptr_to_board:			.word board


lab6:
	PUSH {lr}

	BL uart_init
	BL uart_interrupt_init
	BL gpio_interrupt_init
	BL timer_interrupt_init
	MOV r5, #1
loop:
	B loop

	POP {lr}
	MOV pc, lr

game:
	PUSH {lr}
	LDR r0, ptr_to_clearscreen

	BL output_string
	BL printscore

	LDR r0, ptr_to_board
	BL output_string


	POP {lr}
	MOV pc, lr


.end
