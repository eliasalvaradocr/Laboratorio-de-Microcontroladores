;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
; PIC port for the 14-bit core
;--------------------------------------------------------
;	.file	"dado.c"
	list	p=12f675
	radix dec
	include "p12f675.inc"
;--------------------------------------------------------
; external declarations
;--------------------------------------------------------
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

sharebank udata_ovr 0x0020
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
r0x1008	res	1
r0x1001	res	1
r0x1000	res	1
r0x1002	res	1
r0x1003	res	1
r0x1004	res	1
r0x1005	res	1
r0x1006	res	1
r0x1007	res	1
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
;   _delay
;   _delay
;2 compiler assigned registers:
;   STK00
;   r0x1008
;; Starting pCode block
S_dado__main	code
_main:
; 2 exit points
;	.line	29; "dado.c"	TRISIO = 0b00000000; //Poner todos los pines como salidas
	BANKSEL	_TRISIO
	CLRF	_TRISIO
;	.line	30; "dado.c"	GPIO = 0x00; //Poner pines en bajo
	BANKSEL	_GPIO
	CLRF	_GPIO
_00106_DS_:
;	.line	36; "dado.c"	GP0 = 0x00;
	BANKSEL	_GPIObits
	BCF	_GPIObits,0
;	.line	37; "dado.c"	delay(time);
	MOVLW	0x64
	MOVWF	STK00
	MOVLW	0x00
	PAGESEL	_delay
	CALL	_delay
	PAGESEL	$
;	.line	39; "dado.c"	GP0 = ~GP0;
	CLRF	r0x1008
	BANKSEL	_GPIObits
	BTFSC	_GPIObits,0
	INCF	r0x1008,F
	COMF	r0x1008,W
	MOVWF	r0x1008
	RRF	r0x1008,W
	BTFSS	STATUS,0
	BCF	_GPIObits,0
	BTFSC	STATUS,0
	BSF	_GPIObits,0
;	.line	40; "dado.c"	delay(time);
	MOVLW	0x64
	MOVWF	STK00
	MOVLW	0x00
	PAGESEL	_delay
	CALL	_delay
	PAGESEL	$
	GOTO	_00106_DS_
;	.line	43; "dado.c"	}
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
;	.line	45; "dado.c"	void delay(unsigned int tiempo)
	MOVWF	r0x1000
	MOVF	STK00,W
	MOVWF	r0x1001
;	.line	50; "dado.c"	for(i=0;i<tiempo;i++)
	CLRF	r0x1002
	CLRF	r0x1003
_00117_DS_:
	MOVF	r0x1000,W
	SUBWF	r0x1003,W
	BTFSS	STATUS,2
	GOTO	_00138_DS_
	MOVF	r0x1001,W
	SUBWF	r0x1002,W
_00138_DS_:
	BTFSC	STATUS,0
	GOTO	_00119_DS_
;;genSkipc:3307: created from rifx:0x7ffed6fd1770
;	.line	51; "dado.c"	for(j=0;j<1275;j++);
	MOVLW	0xfb
	MOVWF	r0x1004
	MOVLW	0x04
	MOVWF	r0x1005
_00115_DS_:
	MOVLW	0xff
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
	GOTO	_00115_DS_
;	.line	50; "dado.c"	for(i=0;i<tiempo;i++)
	INCF	r0x1002,F
	BTFSC	STATUS,2
	INCF	r0x1003,F
	GOTO	_00117_DS_
_00119_DS_:
;	.line	52; "dado.c"	}
	RETURN	
; exit point of _delay


;	code size estimation:
;	   62+    8 =    70 instructions (  156 byte)

	end
