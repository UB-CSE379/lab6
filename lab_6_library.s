	.data

	.global directionFlag
	.global pauseFlag

directionFlag: 		.byte 0 ;address to keep track of what button was pressed,
						; 1 - up, 2 - down, 3 - right , 4 - left
pauseFlag: 			.byte 0





	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global timer_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler			; This is needed for Lab #6
	.global simple_read_character
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global uart_init					; This is from your Lab #4 Library
	.global lab6
	.global print_all_numbers
	.global read_character
	.global string2int


ptr_to_directionFlag: .word directionFlag
ptr_to_pauseFlag: 	.word pauseFlag

U0FR: 	.equ 0x18	; UART0 Flag Register

uart_interrupt_init:

	; Your code to initialize the UART0 interrupt goes here
	; Set the Receive Interrupt Mask

	MOV r0, #0xC000
	MOVT r0, #0x4000 ; UART Base Address

	LDRB r4, [r0, #0x038] ; UARTIM Offset

	ORR r4, r4, #0x10 ; 0001 0000
	STRB r4, [r0, #0x038]

	;Configure Processor to Allow Interrupts in UART
	MOV r1, #0xE000
	MOVT r1, #0xE000 ; ENO Base Address

	LDRB r5, [r1, #0x100]
	ORR r5, r5, #0x20 ; 0010 0000
	STRB r5, [r1, #0x100]

	MOV pc, lr


gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.

	;Enable Clock Address for Port F
    MOV r1, #0xE000
    MOVT r1, #0x400F

    ;NEED TO ENABLE CLOCK FOR ONLY PORT F
    LDRB r4, [r1, #0x608]
    ORR r4, r4, #0x20	; find specfic port 0010 0000
    STRB r4, [r1, #0x608] ;enable clock for Port F


    ;Initlize r3 with Port F address
    ; Set Pin 4 Direction to Input
    MOV r3, #0x5000
    MOVT r3, #0x4002
    LDRB r5, [r3, #0x400] ;offset 0x400 to port F
    AND r5, r5, #0xEF ; configure pin 4 as input
    STRB r5, [r3, #0x400] ; write 0 to configure pin 4 as input

	;Enable pull-up resistor
	LDRB r6, [r3, #0x510]
	ORR r6, r6, #0x10 ;
	STRB r6, [r3, #0x510] ;Write 1 to enable pull-up resistor

    ;Initilize pin as digital
    LDRB r7, [r3, #0x51C]
    ORR r7, r7, #0x10  ; enable pin 4 , by writing 1
	STRB r7, [r3, #0x51C] ;write 1 to make pin digital

	;Enable Edge Sensitive GPIOIS
	LDR r8, [r3, #0x404]
	BIC r8, r8, #0x10	;Write 0 to pin 4 to enable edge sensitive
	STR r8, [r3, #0x404]

	; Allow GPIOEV to determine edge, write 0 to pin on port
	LDR r9, [r3, #0x408]
	BIC r9, r9, #0x10
	STR r9, [r3, #0x408]

	; Write 0 to pin when button press ; Select this
	LDR r6, [r3, #0x40C]
	BIC r6, r6, #0x10
	STR r6, [r3, #0x40C]

	;Enable the Interrupt, write 1 to Bit 4
	LDR r7, [r3, #0x410]
	ORR r7, r7, #0x10 ; 0001 0000
	STR r7, [r3, #0x410]

	;ENO, set bit 30 bit
	MOV r8, #0xE000
	MOVT r8, #0xE000 ;ENO Base Address

	MOV r12, #1

	LDR r9, [r8, #0x100] ; ENO Offset
	LSL r12, r12, #30   ; 0100 0000 0000 0000 0000 0000 0000 0000
	ORR r9, r9, r12
	STR r9, [r8, #0x100]

	MOV pc, lr

;Initalize timer interrupt
timer_interrupt_init:
	; Connect Clock to Timer
	MOV r1, #0xE000
	MOVT r1, #0x400F

	;RCGCTIMER, using Timer 0
	LDR r5, [r1, #0x604]
	;Write a 1 to bit 0
	ORR r5, r5, #0x01
	STR r5, [r1, #0x604]

	;Disable Timer to Configure (GPTMCTL), write 0 to TAEN
	MOV r1, #0x0000
	MOVT r1, #0x4003 ; Timer 0 Base Address

	LDR r5, [r1, #0x00C]
	BIC r5, r5, #0x01
	STR r5, [r1, #0x00C]

	;Put Timer in 32-bit Mode
	LDR r5, [r1, #0x000]
	BIC r5, r5, #0x000 	; clear bits 0 1 and 2
	STR r5, [r1, #0x000]

	;Put Timer in Periodic Mode
	LDR r5, [r1, #0x004]
	ORR r5, r5, #0x02 	; Write 2 to TAMR
	STR r5, [r1, #0x004]

	;Setup Interval Period
	LDR r5, [r1, #0x028] ;16MHz per second, want to move 2 spaces per second
							; so interval needs to be half 8 X 10^6, 1 space per half sec
	MOV r6, #0x1200   ; 8 million into r6 to store into reg
	MOVT r6, #0x007A
	STR r6, [r1, #0x028]

	;Enable Timer to Interrupt Processor
	LDR r5, [r1, #0x018]
	ORR r5, r5, #0x01 ; Write 1 to TATOIM, bit 0
	STR r5, [r1, #0x018]

	;Config Timer to Allow Timer to Interrupt /
	; ENO Base Address
	MOV r7, #0xE000
	MOVT r7, #0xE000

	LDR r5, [r7, #0x100]
	; Set Bit 19 (TIMER0A) to 1
	ORR r5, r5, #0x00080000
	STR r5, [r7, #0x100]

	;Enable Timer
	LDR r5, [r1, #0x00C]
	ORR r5, r5, #0x01 ; Write 1 to bit 0 to enable timer
	STR r5, [r1, #0x00C]

	MOV pc, lr

UART0_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4-r11}


	; Clear Interrupt
	MOV r4, #0xC000
	MOVT r4, #0x4000 ; UART0 Base Address

	LDRB r5, [r4, #0x044] ;UARTICR Offset
	; Set the bit 4 (RXIC)
	ORR r5, r5, #0x10 ; 0001 0000
	STRB r5, [r4, #0x044]
	
	LDRB r1, [r4]

	;Check if w pressed, up, write 1 for up
	CMP r1, #0x87 ; Ascii for W
	BEQ UP_PRESSED

	;Check if s pressed, down, write 2 for down
	CMP r1, #0x83	; ASCII for S
	BEQ DOWN_PRESSED

	;Check if d pressed, right, write 3 for right
	CMP r1, #0x68 ; Ascii for D
	BEQ RIGHT_PRESSED

	;Check if a pressed, left, write 4 for left
	CMP r1, #0x65 ; ASCII for A
	BEQ LEFT_PRESSED

	;if anything else pressed, dont do anything
	B UART_END

UP_PRESSED:							;	write 1 for up
	LDR r5, ptr_to_directionFlag
	LDRB r6, [r5]
	; Need to reset flag to 0 before adding the # for the direction
	SUB r6, r6, r6	;subtracting by itself so its back to 0
	ADD r6, r6, #1	; add value for flag
	STRB r6, [r5]
	B UART_END

DOWN_PRESSED:						;  write 2 for down
	LDR r5, ptr_to_directionFlag
	LDRB r6, [r5]
	;reset flag
	SUB r6, r6, r6
	ADD r6, r6, #2 ; add value for down
	STRB r6, [r5]
	B UART_END

RIGHT_PRESSED:						;  write 3 for right
	LDR r5, ptr_to_directionFlag
	LDRB r6, [r5]
	;reset flag
	SUB r6, r6, r6
	ADD r6, r6, #3 ; add value for right
	STRB r6, [r5]
	B UART_END

LEFT_PRESSED:						;  write 4 for left
	LDR r5, ptr_to_directionFlag
	LDRB r6, [r5]
	;reset flag
	SUB r6, r6, r6
	ADD r6, r6, #4 ; add value for left
	STRB r6, [r5]
	B UART_END



UART_END:

	POP {r4-r11}

	BX lr       	; Return


Switch_Handler:

	; Your code for your Switch handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4 - r11}

	; Clear Interrupt
	MOV r4, #0x5000
	MOVT r4, #0x4002

	; Get Timer 0 Base Address
	MOV r5, #0x0000
	MOVT r5, #0x4003 ; Timer 0 Base Address

	;GPIOICR Offset
	LDRB r6, [r4, #0x41C]
	ORR r6, r6, #0x10 ; 0001 0000
	STRB r6, [r4, #0x41C]

	; check if game is paused
	LDR r7, ptr_to_pauseFlag
	LDRB r8, [r7]
	CMP r8, #1 ; if 1, need to resume game
	BEQ RESUME

	; If not paused, need to pause the game
	; Disable the timer
	LDR r9, [r5, #0x00C]
	BIC r9, r9, #0x01
	STR r9, [r5, #0x00C]

	; Add 1 to pauseFlag saying game is paused now
	ADD r8, r8, #1
	STRB r8, [r7]
	B SWITCH_END



RESUME: ;If flag is 1, game is paused, need to resume, enable timer
	;Enable Timer
	LDR r9, [r5, #0x00C]
	ORR r9, r9, #0x01 ; Write 1 to bit 0 to enable timer
	STR r9, [r5, #0x00C]
	; Set pauseflag to 0 saying game is not paused
	SUB r8, r8, #1 ; r8 was 1, r8 - 1 = 0
	STRB r8, [r7]



SWITCH_END:


	POP {r4 - r11}

	BX lr       	; Return


Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed for
	; Lab #5, but will be used in Lab #6.  It is referenced here because
	; the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.

	BX lr       	; Return


simple_read_character:

	PUSH {r4 - r12, lr}
	; Read from UART0 Data Register
	MOV r4, #0xC000
	MOVT r4, #0x4000

	LDRB r0, [r4] ;r0 has the character

	POP {r4 - r12, lr}


	MOV pc, lr	; Return


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

output_character:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
	MOV r1, #0xC000			;Base address
	MOVT r1, #0x4000
LOOP2:
	LDRB r2, [r1, #U0FR]
	AND r2,r2, #0x20
	CMP r2, #0x20
	BEQ LOOP2
	STRB r0,[r1]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;_________________________________________________________________________________________________________________________________________________


read_character:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
  	MOV r1, #0xC000
	MOVT r1, #0x4000

LOOP1:

	LDRB r2, [r1, #U0FR]
	AND r2,r2, #0x10
	CMP r2, #0x10
	BEQ LOOP1

	LDRB r0,[r1]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;_________________________________________________________________________________________________________________________________________________

print_all_numbers:
    PUSH {r4-r12, lr}        ; Save registers that will be used.

    MOV r2, r0               ; Copy the target number to r2 for manipulation.
    MOV r3, #0               ; r3 will count the number of digits.

    ; Special handling to print 0 directly if the number is 0.
    CMP r2, #0
    BEQ print_zero           ; If the number is zero, print it directly and skip to done.

extract_digits:
    CMP r2, #0               ; Check if there are more digits to process.
    BLE print_digits         ; If r2 is less or equal to 0, start printing digits.

    ; Extract the last digit and push it onto the stack.
    MOV r6, #10
    UDIV r1, r2, r6          ; Divide r2 by 10, quotient in r1.
    MUL r4, r1, r6           ; Multiply quotient by 10.
    SUB r0, r2, r4           ; Subtract to find the remainder, which is the last digit.
    PUSH {r0}                ; Push the digit onto the stack.
    ADD r3, r3, #1           ; Increment the digit count.
    MOV r2, r1               ; Prepare the next number for extraction.
    B extract_digits

print_digits:
    CMP r3, #0               ; Check if there are digits to print.
    BLE done                 ; If no digits to print, we're done.

    ; Pop a digit off the stack and print it.
    POP {r0}                 ; Pop the next digit.
    ADD r0, r0, #'0'         ; Convert to ASCII.
    BL output_character      ; Print the character.
    SUB r3, r3, #1           ; Decrement the digit count.
    B print_digits           ; Continue printing until all digits are printed.

print_zero:
    MOV r0, #'0'             ; Move ASCII code for '0' into r0.
    BL output_character      ; Print '0'.

done:
    POP {r4-r12, lr}         ; Restore registers.
    MOV pc, lr               ; Return from subroutine.


;_________________________________________________________________________________________________________

read_string:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
    MOV r4, r0

LOOP_RS:
    BL read_character
    CMP r0, #0xD
    BEQ ENTER
    STRB r0, [r4]
    BL output_character
    ADD r4, r4, #1
    B LOOP_RS

ENTER:
    MOV r0, #0x0
    STRB r0, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;_________________________________________________________________________________________________________________________________________________


output_string:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
    MOV r4, r0

LOOP_OS:
	LDRB r6, [r4]
	ADD r4, r4, #1

	CMP r6, #0x0
	BEQ EXIT
	MOV r0,r6
	BL output_character
	B LOOP_OS



EXIT:

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;_________________________________________________________________________________________________________________________________________________

int2string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.

						; Your code for your int2string routine is placed here
						;handle negatives
    MOV r4, r0
    MOV r5, r1        ; Move int into r5
    MOV r10, #0       ; Initialize accum

    CMP r5, #0
    BGE pos      ; If positive
    MOV r8, #'-'
    STRB r8, [r4], #1
    RSB r5, r5, #0    ; make positive

pos: ; Check if the num is zero
    CMP r5, #0
    BEQ zero_fin ; If zero, go to zero_finalize

conversion:
    ; Extract digits from the number
    MOV r7, #10
    UDIV r8, r5, r7
    MUL r11, r8, r7
    SUB r7, r5, r11
    ADD r7, r7, #'0'
    PUSH {r7}
    ADD r10, r10, #1  ; Increment
    MOV r5, r8
    CMP r5, #0
    BNE conversion ; Loop

r_loop:
    CMP r10, #0
    BEQ f
    POP {r7}
    STRB r7, [r4], #1 ; Store the digit
    SUBS r10, r10, #1 ; Decrement
    B r_loop    ; Repeat until all digits are stored



zero_fin:
    MOV r8, #'0'
    STRB r8, [r4], #1 ; Store and increment
    B f       ; Go to f to null-term and end

f:

    MOV r8, #0
    STRB r8, [r4]

    POP {r4-r12,lr}   ; Restore registers
    mov pc, lr

;_______________________________________________________________________________________________

string2int:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
							; Your code for your string2int routine is placed here

    MOV r2, #0
    MOV r3, #10            ; Base val
    MOV r8, #0             ;flag for neg nums
    LDRB r4, [r0]          ; Load
    CMP r4, #'-'           ; Compare ASCII value
    BNE conv_loop
    ADD r0, r0, #1         ; If '-', skip
    MOV r8, #1             ; Set flag

conv_loop:
    LDRB r4, [r0], #1      ; Load a byte, increment r0
    CMP r4, #0
    BEQ conver_d    ; If byte is NULL, done with conversion

    SUB r4, r4, #0x30      ; Convert ASCII digit to int
    MUL r2, r2, r3         ; Multiply result by 10
    ADD r2, r2, r4         ; Add to accumulator

    B conv_loop         ; Loop

conver_d:
    CMP r8, #1             ; Check if the number was neg
    BEQ make_neg      ; If neg adjust
    B move_res          ; move result into r0

make_neg:
    RSB r2, r2, #0             ; Negate

move_res:
    MOV r0, r2
    POP {r4-r12,lr}

	mov pc, lr

;_________________________________________________________________________________________________________________________________________________

	.end
