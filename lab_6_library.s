	.data

	.global board
	.global current
	.global pauseflag


	.text
	.global uart_init
	.global output_character
	.global output_string
	.global read_string
	.global int2string
	.global UART0_Handler
	.global Switch_Handler

	.global gpio_interrupt_init
	.global uart_interrupt_init
	.global timer_interrupt_init
	.global simple_read_character

;_______________________________________________________________________________________


U0FR: 		.equ 0x18

ptr_to_current:			.word current
ptr_to_pauseflag:		.word pauseflag

;_______________________________________________________________________________________


simple_read_character:

	MOV r1, #0xC000
    MOVT r1, #0x4000
   	LDRB r0, [r1]

	MOV pc, lr

;_______________________________________________________________________________________

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
	LDR r7, ptr_to_pauseflag
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

;_______________________________________________________________________________________


UART0_Handler:
	PUSH {r4-r12,lr}

	MOV r4, #0xC000				;clears the interupt
	MOVT r4, #0x4000
	LDR r5, [ r4, #0x044]
	ORR r5, r5, #16
	STR r5, [ r4, #0x044]

	BL simple_read_character
	MOV r5, r0

	CMP r0, #'w'
	BEQ w
	CMP r0, #'d'
	BEQ d
	CMP r0, #'a'
	BEQ a
	CMP r0, #'s'
	BEQ s
	B w

w:
	LDR r4, ptr_to_current
	STR r0, [r4]
	B end2

d:
	LDR r4, ptr_to_current
	STR r0, [r4]
	B end2

a:
	LDR r4, ptr_to_current
	STR r0, [r4]
	B end2

s:
	LDR r4, ptr_to_current
	STR r0, [r4]
	B end2

end2:

	POP {r4-r12,lr}
	BX lr       	; Return
;_______________________________________________________________________________________

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

;_______________________________________________________________________________________

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


;_______________________________________________________________________________________


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


;_______________________________________________________________________________________

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

;_______________________________________________________________________________________


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


;_______________________________________________________________________________________

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


;_______________________________________________________________________________________

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


;_______________________________________________________________________________________

uart_interrupt_init:

	PUSH {lr}
	; Set the Receive Interrupt Mask

	MOV r0, #0xC000
	MOVT r0, #0x4000 ; UART Base Address

	LDR r4, [r0, #0x038] ; UARTIM Offset

	ORR r4, r4, #0x10 ; 0001 0000
	STR r4, [r0, #0x038]

	;Configure Processor to Allow Interrupts in UART
	MOV r1, #0xE000
	MOVT r1, #0xE000 ; ENO Base Address

	LDR r5, [r1, #0x100]
	ORR r5, r5, #0x20 ; 0010 0000
	STR r5, [r1, #0x100]


	POP {lr}
	MOV pc, lr
;_______________________________________________________________________________________
;Initalize timer interrupt
timer_interrupt_init:
	PUSH {lr}
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

	POP {lr}
	MOV pc, lr

;_______________________________________________________________________________________



	.end
