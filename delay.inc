
;==============================================================================
; Delay of 1 �s (including RCALL)
;==============================================================================
delay_1_micros:   /* UPPGIFT: komplettera med ett antal NOP-instruktioner!!! */
	NOP /* 8 NOP + 4 cycles + 4 cycles = 1 �s */
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	RET

;==============================================================================
; Delay of X �s,
;	LDI + RCALL = 4 cycles
;==============================================================================
delay_micros:			/* UPPGIFT: komplettera med ett antal NOP-instruktioner!!! */
	DEC R24
	CPI R24, 0			; more loops to do?
	NOP					/* 12 NOP to make this subroutine 16 cycles */
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	BRNE delay_micros;
	RET

;==============================================================================
; Delay of X ms
;	LDI + RCALL = 4 cycles
;==============================================================================
delay_ms:
	MOV R18, R24
loop_dms:
	LDI R24, 250
	RCALL delay_micros
	LDI R24, 250
	RCALL delay_micros
	LDI R24, 250
	RCALL delay_micros
	LDI R24, 250
	RCALL delay_micros
	DEC R18
	CPI R18, 0			; more loops to do?
	BRNE loop_dms		;	continue!
	RET