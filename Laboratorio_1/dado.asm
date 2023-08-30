;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
; PIC port for the 14-bit core
;--------------------------------------------------------
;	.file	"dado.c"
	list	p=12f683
	radix dec
	include "p12f683.inc"
;--------------------------------------------------------
; config word(s)
;--------------------------------------------------------
	__config 0x3f84
;--------------------------------------------------------
; external declarations
;--------------------------------------------------------
	extern	_TRISIO
	extern	_OPTION_REG
	extern	_GPIO
	extern	_TMR0
	extern	_GPIObits
	extern	__sdcc_gsinit_startup
;--------------------------------------------------------
; global declarations
;--------------------------------------------------------
	global	_main
	global	_valor_anterior
	global	_valor_actual
	global	_delay

	global PSAVE
	global SSAVE
	global WSAVE
	global STK12
	global STK11
	global STK10
	global STK09
	global STK08
	global STK07
	global STK06
	global STK05
	global STK04
	global STK03
	global STK02
	global STK01
	global STK00

sharebank udata_ovr 0x0070
PSAVE	res 1
SSAVE	res 1
WSAVE	res 1
STK12	res 1
STK11	res 1
STK10	res 1
STK09	res 1
STK08	res 1
STK07	res 1
STK06	res 1
STK05	res 1
STK04	res 1
STK03	res 1
STK02	res 1
STK01	res 1
STK00	res 1

;--------------------------------------------------------
; global definitions
;--------------------------------------------------------
;--------------------------------------------------------
; absolute symbol definitions
;--------------------------------------------------------
;--------------------------------------------------------
; compiler-defined variables
;--------------------------------------------------------
UDL_dado_0	udata
r0x100A	res	1
r0x1003	res	1
r0x1002	res	1
r0x1004	res	1
r0x1005	res	1
r0x1006	res	1
r0x1007	res	1
r0x1008	res	1
r0x1009	res	1
;--------------------------------------------------------
; initialized data
;--------------------------------------------------------

IDD_dado_0	idata
_valor_actual
	db	0x00	; 0


IDD_dado_1	idata
_valor_anterior
	db	0x00	; 0

;--------------------------------------------------------
; initialized absolute data
;--------------------------------------------------------
;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
;	udata_ovr
;--------------------------------------------------------
; reset vector 
;--------------------------------------------------------
STARTUP	code 0x0000
	nop
	pagesel __sdcc_gsinit_startup
	goto	__sdcc_gsinit_startup
;--------------------------------------------------------
; code
;--------------------------------------------------------
code_dado	code
;***
;  pBlock Stats: dbName = M
;***
;has an exit
;functions called:
;   _delay
;   _delay
;2 compiler assigned registers:
;   r0x100A
;   STK00
;; Starting pCode block
S_dado__main	code
_main:
; 2 exit points
;	.line	40; "dado.c"	TRISIO = 0b00001000; 
	MOVLW	0x08
	BANKSEL	_TRISIO
	MOVWF	_TRISIO
;	.line	42; "dado.c"	GPIO = 0x00; 
	BANKSEL	_GPIO
	CLRF	_GPIO
;	.line	46; "dado.c"	OPTION_REG = 0b00000100; 
	MOVLW	0x04
	BANKSEL	_OPTION_REG
	MOVWF	_OPTION_REG
_00113_DS_:
;	.line	53; "dado.c"	if (boton == 0) {
	BANKSEL	_GPIObits
	BTFSC	_GPIObits,3
	GOTO	_00110_DS_
;	.line	55; "dado.c"	unsigned char valor_aleatorio = TMR0; 
	MOVF	_TMR0,W
	BANKSEL	r0x100A
	MOVWF	r0x100A
;	.line	57; "dado.c"	if (valor_aleatorio != valor_actual) {
	BANKSEL	_valor_actual
	MOVF	_valor_actual,W
;	.line	61; "dado.c"	valor_anterior = valor_actual; 
	BANKSEL	r0x100A
	XORWF	r0x100A,W
	BTFSC	STATUS,2
	GOTO	_00106_DS_
	BANKSEL	_valor_actual
	MOVF	_valor_actual,W
	BANKSEL	_valor_anterior
	MOVWF	_valor_anterior
;	.line	63; "dado.c"	valor_actual = valor_aleatorio; 
	BANKSEL	r0x100A
	MOVF	r0x100A,W
	BANKSEL	_valor_actual
	MOVWF	_valor_actual
;	.line	65; "dado.c"	GPIO = (0b11000000 | valor_actual);
	MOVF	_valor_actual,W
	BANKSEL	r0x100A
	MOVWF	r0x100A
	MOVLW	0xc0
	IORWF	r0x100A,W
	BANKSEL	_GPIO
	MOVWF	_GPIO
_00106_DS_:
;	.line	68; "dado.c"	delay(time);
	MOVLW	0x64
	MOVWF	STK00
	MOVLW	0x00
	PAGESEL	_delay
	CALL	_delay
	PAGESEL	$
	GOTO	_00113_DS_
_00110_DS_:
;	.line	72; "dado.c"	if (valor_actual != valor_anterior) {
	BANKSEL	_valor_anterior
	MOVF	_valor_anterior,W
;	.line	74; "dado.c"	GPIO = (0b11000000 | valor_actual);
	BANKSEL	_valor_actual
	XORWF	_valor_actual,W
	BTFSC	STATUS,2
	GOTO	_00113_DS_
	MOVF	_valor_actual,W
	BANKSEL	r0x100A
	MOVWF	r0x100A
	MOVLW	0xc0
	IORWF	r0x100A,W
	BANKSEL	_GPIO
	MOVWF	_GPIO
;	.line	76; "dado.c"	valor_anterior = valor_actual; 
	BANKSEL	_valor_actual
	MOVF	_valor_actual,W
	BANKSEL	_valor_anterior
	MOVWF	_valor_anterior
	GOTO	_00113_DS_
;	.line	80; "dado.c"	}
	RETURN	
; exit point of _main

;***
;  pBlock Stats: dbName = C
;***
;has an exit
;9 compiler assigned registers:
;   r0x1002
;   STK00
;   r0x1003
;   r0x1004
;   r0x1005
;   r0x1006
;   r0x1007
;   r0x1008
;   r0x1009
;; Starting pCode block
S_dado__delay	code
_delay:
; 2 exit points
;	.line	88; "dado.c"	void delay(unsigned int tiempo) {
	BANKSEL	r0x1002
	MOVWF	r0x1002
	MOVF	STK00,W
	MOVWF	r0x1003
;	.line	92; "dado.c"	for (i = 0; i < tiempo; i++)
	CLRF	r0x1004
	CLRF	r0x1005
_00145_DS_:
	BANKSEL	r0x1002
	MOVF	r0x1002,W
	SUBWF	r0x1005,W
	BTFSS	STATUS,2
	GOTO	_00166_DS_
	MOVF	r0x1003,W
	SUBWF	r0x1004,W
_00166_DS_:
	BTFSC	STATUS,0
	GOTO	_00147_DS_
;;genSkipc:3307: created from rifx:0x7ffd86074560
;	.line	93; "dado.c"	for (j = 0; j < 1275; j++);
	MOVLW	0xfb
	BANKSEL	r0x1006
	MOVWF	r0x1006
	MOVLW	0x04
	MOVWF	r0x1007
_00143_DS_:
	MOVLW	0xff
	BANKSEL	r0x1006
	ADDWF	r0x1006,W
	MOVWF	r0x1008
	MOVLW	0xff
	MOVWF	r0x1009
	MOVF	r0x1007,W
	BTFSC	STATUS,0
	INCFSZ	r0x1007,W
	ADDWF	r0x1009,F
	MOVF	r0x1008,W
	MOVWF	r0x1006
	MOVF	r0x1009,W
	MOVWF	r0x1007
	MOVF	r0x1009,W
	IORWF	r0x1008,W
	BTFSS	STATUS,2
	GOTO	_00143_DS_
;	.line	92; "dado.c"	for (i = 0; i < tiempo; i++)
	INCF	r0x1004,F
	BTFSC	STATUS,2
	INCF	r0x1005,F
	GOTO	_00145_DS_
_00147_DS_:
;	.line	94; "dado.c"	}
	RETURN	
; exit point of _delay


;	code size estimation:
;	   79+   25 =   104 instructions (  258 byte)

	end
