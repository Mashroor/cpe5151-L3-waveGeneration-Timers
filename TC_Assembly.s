;*********************************************************************
;    Example Assmbly - This file contains "do-nothing" functions
;        that are setup so that they can be called from a C program.
;        The exported label (EXPORT function_name) is the
;        name of the function in C.  The functions save and restore
;        some registers so that they can be used in the function, but
;        not altered in the C program.
;
;        Some of the functions are named to match experiment 1
;        These names can be changed as needed by the programmer.
;*********************************************************************
;    Code written by: Roger Younger
;    v1.0 Released: February 17, 2016
;*********************************************************************
;    CONSTANT DEFINITIONS
;*********************************************************************
		INCLUDE AT91SAM7SE512.INC


;*********************************************************************
;    VARIABLE DEFINITIONS
;*********************************************************************
         PRESERVE8


		AREA VARIABLES,DATA,READWRITE
			
VARIABLE_1 DCD 0
VARIABLE_2 DCD 0


;***********************************************************
;    AREA DEFINITION AND OPTIONS
;***********************************************************
		PRESERVE8


		AREA EXAMPLE,CODE,READONLY
		ARM
		
		
		
;***********************************************************
;    Function: void TIMER_CLOCK_INIT(void) 
;    The timer clocks can be enabled with this function 
;    or in the timer initialization
;***********************************************************
		EXPORT TIMER_CLOCK_INIT
			
TIMER_CLOCK_INIT
        PUSH {R4,R5,R14}
		NOP               ; Replace with your code
		NOP               ; Replace with your code
		POP {R4,R5,R14}
		BX R14


;***********************************************************
;    Function: void TC0_INIT(void) 
;    Used to set up TC0
;
; Waveform mode; outputs a 40kHz square wave.
;***********************************************************
		EXPORT TC0_INIT

RC_TC0 EQU 599
RB_TC0 EQU 299

WAVE_BIT EQU (1<<15)
WAVE_SEL_TC0 EQU (2<<13) ; UP WITH TRIGGER, RC COMPARE
EEVT_TC0 EQU (3<<10) ; XC2
BCPB_TC0 EQU (1<<24) ; SET
BCPC_TC0 EQU (2<<26) ; CLEAR
BSWTRG_TC0 EQU (0<<30) ; NONE
TCCLKS_TC0 EQU 0 ; TIMER CLOCK 1 (PRESCALE = 1/2)
BURST_TC0 EQU (1<<4) ; AND WITH XC0
CMR_TC0 EQU (WAVE_BIT :OR: EEVT_TC0 :OR: WAVE_SEL_TC0 :OR: BCPB_TC0 :OR: BCPC_TC0 :OR: BSWTRG_TC0 :OR: TCCLKS_TC0 :OR: BURST_TC0)

TIOB0_BIT EQU (1<<1)

TC0_INIT
        PUSH {R4,R5,R14}
		
		; ENABLE TC0 PMC
		LDR R4,=PMC_BASE
		MOV R5,#(1<<TC0_PID)
		STR R5,[R4,#PMC_PCER]
		
		; SET TIOB0 TO BE CONTROLLED BY PIOB
		LDR R4,=PIOB_BASE
		LDR R5,=TIOB0_BIT
		STR R5,[R4,#PIO_PDR]
		
		; SET WAVEFORM IN CAPTURE MODE REG, SET RB AND RC
		LDR R4,=TC0_BASE
		LDR R5,=CMR_TC0
		STR R5,[R4,#TC_CMR]
		LDR R5,=RB_TC0
		STR R5,[R4,#TC_RB]
		LDR R5,=RC_TC0
		STR R5,[R4,#TC_RC]
		
		; ENABLE TC0
		MOV R5,#1
		STR R5,[R4,#TC_CCR]
		
		POP {R4,R5,R14}
		BX R14


;***********************************************************
;    Function: void TC1_INIT(void) 
;    Used to set up TC1
;
; Waveform mode; RA acts as a burst for TC0; RB acts as a
; burst for TC2.
;***********************************************************
		EXPORT TC1_INIT

TIOA1_BIT EQU (1<<15)
TIOB1_BIT EQU (1<<16)
TIOAB1 EQU (TIOA1_BIT :OR: TIOB1_BIT)

EEVT_TC1 EQU (3<<10) ; XC2
ACPA_TC1 EQU (2<<16) ; CLEAR
ASWTRG_TC1 EQU (1<<22) ; SET
BCPB_TC1 EQU (1<<24) ; SET
BSWTRG_TC1 EQU (2<<30) ; CLEAR
CPCSTOP_TC1 EQU (1<<6) ; STOP WITH RC COMPARE
TCCLKS_TC1 EQU 0 ; TIMER CLOCK 1 (PRESCALE = 1/2)
CMR_TC1 EQU (EEVT_TC1 :OR: ACPA_TC1 :OR: ASWTRG_TC1 :OR: BSWTRG_TC1 :OR: BCPB_TC1 :OR: TCCLKS_TC1 :OR: WAVE_BIT :OR: CPCSTOP_TC1)

RA_TC1 EQU 2400 ; 2420 These new values came from Dr. Youngers program
RB_TC1 EQU 37000 ; 11981 This value specifically comes from changing to a 1.5ms response, to eliminate echoes
RC_TC1 EQU 38000 ; 23962

TC1_INIT
        PUSH {R4,R5,R14}
		
		; ENABLE TC1 PMC
		LDR R4,=PMC_BASE
		MOV R5,#(1<<TC1_PID)
		STR R5,[R4,#PMC_PCER]
		
		; SET TIOA1 AND TIOB1 TO BE CONTROLLED BY PIOB
		LDR R4,=PIOB_BASE
		LDR R5,=TIOAB1
		STR R5,[R4,#PIO_PDR]
		
		; SET CHANNEL MODE REG, RA, RB, AND RC
		LDR R4,=TC1_BASE
		LDR R5,=CMR_TC1
		STR R5,[R4,#TC_CMR]
		LDR R5,=RA_TC1
		STR R5,[R4,#TC_RA]
		LDR R5,=RB_TC1
		STR R5,[R4,#TC_RB]
		LDR R5,=RC_TC1
		STR R5,[R4,#TC_RC]
		
		; ENABLE TC1
		MOV R5,#1
		STR R5,[R4,#TC_CCR]
		
		POP {R4,R5,R14}
		BX R14


;***********************************************************
;    Function: void TC2_INIT(void) 
;    Used to set up TC2
;
; Set in capture mode; RA holds the number of counts since
; the 40kHz burst from TC0 was sent.
;***********************************************************
		EXPORT TC2_INIT

TIOA2_BIT EQU (1<<26)

LDRA_TC2 EQU (1<<16) ; RA LOAD ON RISING EDGE
LDRB_TC2 EQU (2<<18) ; RB LOAD ON FALLING EDGE
LDBSTOP_TC2 EQU (1<<6) ; STOP ON RB LOAD
TCCLKS_TC2 EQU 0 ; TIMER CLOCK 1 (PRESCALE = 1/2)
CMR_TC2 EQU (TCCLKS_TC2 :OR: LDRA_TC2 :OR: LDRB_TC2 :OR: LDBSTOP_TC2)

TC2_INIT
        PUSH {R4,R5,R14}
		
		; ENABLE TC2 PMC
		LDR R4,=PMC_BASE
		MOV R5,#(1<<TC2_PID)
		STR R5,[R4,#PMC_PCER]
		
		; SET TIOA2 TO BE CONTROLLED BY PIOB
		LDR R4,=PIOB_BASE
		LDR R5,=TIOA2_BIT
		STR R5,[R4,#PIO_PDR]
		
		; SET CHANNEL MODE REG
		LDR R4,=TC2_BASE
		LDR R5,=CMR_TC2
		STR R5,[R4,#TC_CMR]
		
		; ENABLE TC2
		MOV R5,#1
		STR R5,[R4,#TC_CCR]
		
		POP {R4,R5,R14}
		BX R14


;***********************************************************
;    Function: void TCB_INIT(void) 
;    Used to set up the TC block mode reg
;***********************************************************
		EXPORT TCB_INIT
			
TCB_INIT
        PUSH {R4,R5,R14}
		NOP
		NOP
		POP {R4,R5,R14}
		BX R14


;***********************************************************
;    Function: void TC_START(void) 
;    Used to start all of the enabled timers using the 
;    TC block control reg.
;***********************************************************
		EXPORT TC_START
			
TC_START
        PUSH {R4,R5,R14}
		NOP
		NOP
		POP {R4,R5,R14}
		BX R14


        END