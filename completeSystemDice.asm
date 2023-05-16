/* 
	Awara
*/
 
;==============================================================================
; Definitions of registers, etc. ("constants")
;==============================================================================
	.EQU RESET		= 0x0000
	.EQU PM_START	= 0x0056
	.EQU NO_KEY		= 0x0F
	 
	.EQU charA		= 0b1010
	.EQU charB		= 0b1011
		
	.DEF TEMP		= R16
	.DEF RVAL		= R24
;==============================================================================
; Start of program
;==============================================================================
	.CSEG
	.ORG RESET
	RJMP init

	.ORG PM_START
	.INCLUDE "delay.inc"
	.INCLUDE "lcd.inc"
;==============================================================================
; Basic initializations of stack pointer, I/O pins, etc.
;==============================================================================
init:
	; Set stack pointer to point at the end of RAM.
	LDI TEMP, LOW(RAMEND)
	OUT SPL, TEMP
	LDI TEMP, HIGH(RAMEND)
	OUT SPH, TEMP
	; Initialize pins
	CALL init_pins
	; Initialize LCD
	CALL lcd_init
	; Jump to main part of program
	RJMP main

;==============================================================================
; Initialize I/O pins
;==============================================================================
init_pins:
	LDI TEMP, 0xF0	; PORTF4-F7 �r utg�ngar
	OUT DDRF, TEMP

	LDI TEMP, 0xF0	; PORTB4-B7 �r utg�ngar
	OUT DDRB, TEMP

	LDI TEMP, 0xFF	; PORTF4 - F7 �r utg�ngar
	OUT DDRD, TEMP

	SBI PORTE,6 
	RET
;==============================================================================
; Read keyboard
;==============================================================================
read_keyboard:
	LDI R18, 0				; reset counter
scan_key:
	MOV R19, R18
	LSL R19
	LSL R19
	LSL R19
	LSL R19
	OUT PORTB, R19			; set column and row
	
	RCALL delay_1_micros	; sets a delay of 10ms
	RCALL delay_1_micros
	RCALL delay_1_micros
	RCALL delay_1_micros
	RCALL delay_1_micros
	RCALL delay_1_micros
	RCALL delay_1_micros
	RCALL delay_1_micros
	RCALL delay_1_micros
	RCALL delay_1_micros

	SBIC PINE, 6
	RJMP return_key_val
	INC R18
	CPI R18, 12
	BRNE scan_key
	LDI R18, NO_KEY		; no key was pressed!
return_key_val:
	MOV RVAL, R18
	RET
;==============================================================================
; Write keyboard to display
;==============================================================================
write_keyboard:
next_charA:
	CPI R24, charA			; if(r24 == charA)
	BRNE next_charB			; else jumpto next_charB
	LDI R24, 'A'			; skriv A p� LCD
	RCALL lcd_write_chr		; skicka data till display
	JMP end
next_charB:
	CPI R24, charB
	BRNE write_value
	LDI R24, 'B'
	RCALL lcd_write_chr
	JMP end
write_value:
	LDI R17, 48
	ADD R24, R17
	RCALL lcd_write_chr
end:
	RET
;==============================================================================
; Main part of program
;==============================================================================
main: 
	LDI R24, 'K'			; Writes "KEY:" to display
	RCALL lcd_write_chr
	LDI R24, 'E'
	RCALL lcd_write_chr
	LDI R24, 'Y'
	RCALL lcd_write_chr
	LDI R24, ':'
	RCALL lcd_write_chr

	LDI R24, 0xC0			; Set cursor position to second row
	RCALL lcd_write_instr
							
	LDI R24, 0x0C			; Remove visible cursor
	RCALL lcd_write_instr

main_loop:					; start of the main loop
	RCALL read_keyboard		; read keyboard by calling the subroutine 'read_keyboard'

	MOV R16, RVAL			; R16 = TEMP
	CPI R16, NO_KEY			; if RVAL = NO_KEY
	BREQ main_loop			; if true, jump to to main_loop
	
	RCALL write_keyboard	; Write the key to LCD

	LDI R24, 150			; Delay of 150 ms to eliminate switch bouncing 
	RCALL delay_ms

key_pressed:
	RCALL read_keyboard		; Checking if key is still pressed.
	CP R16, RVAL			; If the same key is still pressed

	BREQ key_pressed		; Jump to key_pressed
	JMP main_loop			; Else jump to main_lopp (repeat everything)