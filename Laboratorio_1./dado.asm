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
; external declarations
;--------------------------------------------------------
	extern	_ANSEL
	extern	_TRISIO
	extern	_GPIO
	extern	_GPIObits
	extern	__sdcc_gsinit_startup
;--------------------------------------------------------
; global declarations
;--------------------------------------------------------
	global	_main
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
r0x1001	res	1
r0x1000	res	1
r0x1002	res	1
r0x1003	res	1
r0x1004	res	1
r0x1005	res	1
r0x1006	res	1
r0x1007	res	1
r0x1008	res	1
r0x1009	res	1
r0x100A	res	1
r0x100B	res	1
r0x100C	res	1
r0x100D	res	1
r0x100E	res	1
;--------------------------------------------------------
; initialized data
;--------------------------------------------------------
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
;8 compiler assigned registers:
;   r0x1008
;   r0x1009
;   r0x100A
;   r0x100B
;   r0x100C
;   r0x100D
;   r0x100E
;   STK00
;; Starting pCode block
S_dado__main	code
_main:
; 2 exit points
;	.line	15; "dado.c"	GPIO   = 0x00;          // Configura todos los pines en bajo inicialmente
	BANKSEL	_GPIO
	CLRF	_GPIO
;	.line	16; "dado.c"	TRISIO = 0b00001000;    // Configura GP3 como entrada y los demás como salidas
	MOVLW	0x08
	BANKSEL	_TRISIO
	MOVWF	_TRISIO
;	.line	17; "dado.c"	ANSEL  = 0x00;          // Configura los pines como digitales
	CLRF	_ANSEL
;	.line	19; "dado.c"	unsigned char estado_anterior = 1; // Variable para rastrear el estado anterior de GP3
	MOVLW	0x01
	BANKSEL	r0x1008
	MOVWF	r0x1008
;	.line	20; "dado.c"	unsigned char gp0_encendido = 0;   // Variable para rastrear el estado de GP0 (apagado por defecto)
	CLRF	r0x1009
;	.line	21; "dado.c"	unsigned char gp1_encendido = 0;   // Variable para rastrear el estado de GP1 (apagado por defecto)
	CLRF	r0x100A
;	.line	22; "dado.c"	unsigned char gp2_encendido = 0;   // Variable para rastrear el estado de GP2 (apagado por defecto)
	CLRF	r0x100B
_00142_DS_:
;	.line	27; "dado.c"	if (boton != estado_anterior)
	BANKSEL	r0x100C
	CLRF	r0x100C
	BANKSEL	_GPIObits
	BTFSS	_GPIObits,3
	GOTO	_00001_DS_
	BANKSEL	r0x100C
	INCF	r0x100C,F
_00001_DS_:
	BANKSEL	r0x100C
	MOVF	r0x100C,W
	MOVWF	r0x100D
	MOVF	r0x1008,W
	MOVWF	r0x100C
;	.line	29; "dado.c"	if (boton == 0) // Cuando el botón cambia de alto a bajo (presionado)
	XORWF	r0x100D,W
	BTFSC	STATUS,2
	GOTO	_00140_DS_
	BANKSEL	_GPIObits
	BTFSC	_GPIObits,3
	GOTO	_00140_DS_
;	.line	32; "dado.c"	gp0_encendido = !gp0_encendido;
	BANKSEL	r0x1009
	MOVF	r0x1009,W
	MOVLW	0x00
	BTFSC	STATUS,2
	MOVLW	0x01
	MOVWF	r0x100C
	MOVWF	r0x1009
;	.line	33; "dado.c"	gp1_encendido = !gp1_encendido;
	MOVF	r0x100A,W
	MOVLW	0x00
	BTFSC	STATUS,2
	MOVLW	0x01
	MOVWF	r0x100C
	MOVWF	r0x100A
;	.line	34; "dado.c"	gp2_encendido = !gp2_encendido;
	MOVF	r0x100B,W
	MOVLW	0x00
	BTFSC	STATUS,2
	MOVLW	0x01
	MOVWF	r0x100C
	MOVWF	r0x100B
;	.line	37; "dado.c"	GPIO = (GPIO & 0b11111000) | (gp0_encendido << 0) | (gp1_encendido << 1) | (gp2_encendido << 2);
	BANKSEL	_GPIO
	MOVF	_GPIO,W
	BANKSEL	r0x100C
	MOVWF	r0x100C
	MOVLW	0xf8
	ANDWF	r0x100C,F
	MOVF	r0x1009,W
	MOVWF	r0x100D
	MOVWF	r0x100E
	MOVWF	r0x100D
	IORWF	r0x100C,F
	MOVF	r0x100A,W
	MOVWF	r0x100D
	BCF	STATUS,0
	RLF	r0x100D,W
	MOVWF	r0x100E
	MOVWF	r0x100D
	IORWF	r0x100C,F
	MOVF	r0x100B,W
	MOVWF	r0x100D
	BCF	STATUS,0
	RLF	r0x100D,W
	MOVWF	r0x100E
	BCF	STATUS,0
	RLF	r0x100E,F
	MOVF	r0x100E,W
	MOVWF	r0x100D
	IORWF	r0x100C,W
	BANKSEL	_GPIO
	MOVWF	_GPIO
;	.line	40; "dado.c"	delay(100); // Este retardo es de 0.1 segundos
	MOVLW	0x64
	MOVWF	STK00
	MOVLW	0x00
	PAGESEL	_delay
	CALL	_delay
	PAGESEL	$
_00140_DS_:
;	.line	45; "dado.c"	estado_anterior = boton;
	BANKSEL	r0x100C
	CLRF	r0x100C
	BANKSEL	_GPIObits
	BTFSS	_GPIObits,3
	GOTO	_00002_DS_
	BANKSEL	r0x100C
	INCF	r0x100C,F
_00002_DS_:
	BANKSEL	r0x100C
	MOVF	r0x100C,W
	MOVWF	r0x1008
	GOTO	_00142_DS_
;	.line	47; "dado.c"	}
	RETURN	
; exit point of _main

;***
;  pBlock Stats: dbName = C
;***
;has an exit
;9 compiler assigned registers:
;   r0x1000
;   STK00
;   r0x1001
;   r0x1002
;   r0x1003
;   r0x1004
;   r0x1005
;   r0x1006
;   r0x1007
;; Starting pCode block
S_dado__delay	code
_delay:
; 2 exit points
;	.line	6; "dado.c"	void delay(unsigned int ciclos)
	BANKSEL	r0x1000
	MOVWF	r0x1000
	MOVF	STK00,W
	MOVWF	r0x1001
;	.line	9; "dado.c"	for (i = 0; i < ciclos; i++)
	CLRF	r0x1002
	CLRF	r0x1003
_00111_DS_:
	BANKSEL	r0x1000
	MOVF	r0x1000,W
	SUBWF	r0x1003,W
	BTFSS	STATUS,2
	GOTO	_00132_DS_
	MOVF	r0x1001,W
	SUBWF	r0x1002,W
_00132_DS_:
	BTFSC	STATUS,0
	GOTO	_00113_DS_
;;genSkipc:3307: created from rifx:0x7fff93ed3b40
;	.line	10; "dado.c"	for (j = 0; j < 255; j++);
	MOVLW	0xff
	BANKSEL	r0x1004
	MOVWF	r0x1004
	CLRF	r0x1005
_00109_DS_:
	MOVLW	0xff
	BANKSEL	r0x1004
	ADDWF	r0x1004,W
	MOVWF	r0x1006
	MOVLW	0xff
	MOVWF	r0x1007
	MOVF	r0x1005,W
	BTFSC	STATUS,0
	INCFSZ	r0x1005,W
	ADDWF	r0x1007,F
	MOVF	r0x1006,W
	MOVWF	r0x1004
	MOVF	r0x1007,W
	MOVWF	r0x1005
	MOVF	r0x1007,W
	IORWF	r0x1006,W
	BTFSS	STATUS,2
	GOTO	_00109_DS_
;	.line	9; "dado.c"	for (i = 0; i < ciclos; i++)
	INCF	r0x1002,F
	BTFSC	STATUS,2
	INCF	r0x1003,F
	GOTO	_00111_DS_
_00113_DS_:
;	.line	11; "dado.c"	}
	RETURN	
; exit point of _delay


;	code size estimation:
;	  117+   22 =   139 instructions (  322 byte)

	end
