;*************************************************************************************
;*  USART_solution_2017.s
;*		Routines for initializing USART0, transmitting a character,
;*		receiving a character by continuously polling the RXRDY bit
;*		and receiving a character by checking the RXRDY bit once and 
;* 		returning a character or EOF (-1).
;*		
;*		CpE5151 Experiment #2, Spring 2017
;*************************************************************************************
;*		Version 1.0												Roger Younger
;*************************************************************************************
;*		
;*	CONSTANT DECLARATIONS


			INCLUDE AT91SAM7SE512.INC

;***** UART DECLARATIONS  ***************************
US_MODE     EQU   0
NORMAL_MODE EQU   0x00
RS485_MODE  EQU   0x01
HW_HANDSHAKE EQU  0x02
MODEM_MODE  EQU   0x03
USCLK       EQU   4
US_MCK      EQU   0x00
US_MCK_8    EQU   0x01
US_SCK      EQU   0x03
CHRL        EQU   6
CHRL_5		EQU   0x00
CHRL_6		EQU   0x01
CHRL_7		EQU   0x02
CHRL_8		EQU   0x03
PAR         EQU   9
PAR_EVEN    EQU   0x00
PAR_ODD     EQU   0x01
PAR_SPACE   EQU   0x02
PAR_MARK    EQU   0x03
PAR_NONE    EQU   0x04
PAR_MULTI   EQU   0x06
NB_STOP      EQU   12
STOP_1		EQU   0x00
STOP_1_5	EQU   0x01
STOP_2		EQU   0x02
CHMODE      EQU   14
MODE9       EQU   17
OVER        EQU   19	

RX_TX_PINS  EQU   ((1<<5):OR:(1<<6))     ; PIOA5 - RXD0, PIOA6 - TXD0
RESET_STA   EQU   0x0100     ; RESETS STATUS ONLY
RESET_UART  EQU   (RESET_STA:OR:(1<<2):OR:(1<<3))     ; RESETS STATUS AND RX(bit2) AND TX(bit3)

UART_MODE_REG  EQU   (OVER_bit<<OVER):OR:(0<<CHMODE):OR:(STOP_1<<NB_STOP):OR:(PAR_NONE<<PAR):OR:(CHRL_8<<CHRL):OR:(US_MCK<<USCLK):OR:(NORMAL_MODE<<US_MODE)
	;0x08C0     ; NORMAL MODE 8-N-1
RX_TX_EN    EQU   ((1<<4):OR:(1<<6))     ; ENABLES RX(bit4) AND TX(bit6)

;***** SERIAL DECLARATIONS **************************
MAX_ASCII   EQU   0x007F     ; ASCII RANGE 0 TO 0x7F
TXRDY       EQU   1<<1     ; TXRDY, BIT 1
RXRDY       EQU   1<<0     ; RXRDY, BIT 0
ERR_BITS    EQU   ((1<<5):OR:(1<<6):OR:(1<<7))     ; OVERRUN, FRAME & PARITY ERROR BITS (BITS 5-7)   



OVER_bit	EQU   0
BAUD_RATE	EQU   9600
BRGR_VAL 	EQU	  (47923200/((2-OVER_bit)*8*BAUD_RATE))		; calculated by student

NO_ERROR    EQU   0x0000
TX_Error	EQU   0xE0000000				; defined by student
RX_Error	EQU   0xF0000000
No_Char_Received	EQU  0xC0000000	


;******************************************************************************
;*	AREA DEFINITION
								 
			PRESERVE8
			AREA COMPORT,CODE,READONLY
			ARM

;******************************************************************************
;*	INITIALIZATION ROUTINE			void USART0_INIT(void)
;*		Sets up USART0 to 8-N-1 with 9600 Baud Rate.  
;*******************************************************************************


			EXPORT USART0_INIT

USART0_INIT
			PUSH {R4-R5,R14}
 			LDR R4,=PMC_BASE
			MOV R5,#(1<<PIOA_PID)
			ORR R5,R5,#(1<<USART0_PID)	
			STR R5,[R4,#PMC_PCER]
			LDR R4,=USART0_BASE
			MOV R5,#RESET_UART			
			STR R5,[R4,#US_CR]
			LDR R5,=UART_MODE_REG			
			STR R5,[R4,#US_MR]
			LDR R5,=BRGR_VAL
			STR R5,[R4,#US_BRGR]
			MOV R5,#RX_TX_EN	   
			STR R5,[R4,#US_CR]
			LDR R4,=PIOA_BASE
			MOV R5,#RX_TX_PINS	
			STR R5,[R4,#PIO_PDR]    ; DISABLE PARALLEL I/O, ENABLES PERIPHERAL CONTROL
			STR R5,[R4,#PIO_ASR]    ; SELECTS THE A PERIPHERAL
			POP {R4-R5,R14}
			BX R14

;*******************************************************************************
;*	TRANSMIT ROUTINE				int USART0_Transmit (int)
;*		Value sent to routine in R0.  The value is limited to 8 bits.
;*		The value is placed in the transmit hold register of USART0
;*		when it is empty.  An error flag is returned if a timeout occurs or
;*		if the input value is a non-printable value.
;*******************************************************************************


			EXPORT USART0_Transmit
USART0_Transmit
			PUSH {R4-R5,R14}
			CMP R0,#MAX_ASCII
			MOVHI R0,#TX_Error
			BHI CANNOT_SEND
			LDR R4,=USART0_BASE
TX_LOOP		LDR R5,[R4,#US_CSR]
			TST R5,#TXRDY
			BEQ TX_LOOP
			STR R0,[R4,#US_THR]
			MOV R0,#NO_ERROR
CANNOT_SEND	POP {R4-R5,R14}
			BX R14

;**********************************************************************************
;*	RECEIVE ROUTINE (W/POLLING)		int USART0_Receive(void)
;*		Continuously polls the RXRDY bit until a character is received.  The
;*		received character is returned in R0.  The error bits for parity
;*		frame and over run are checked and an error flag is returned
;*		instead of the received character.
;**********************************************************************************


			EXPORT USART0_Receive
USART0_Receive
			PUSH {R4-R5,R14}
			LDR R4,=USART0_BASE
RX_LOOP		LDR R5,[R4,#US_CSR]
			TST R5,#RXRDY
			BEQ RX_LOOP
			LDR R0,[R4,#US_RHR]
			LDR R5,[R4,#US_CSR]
			TST R5,#ERR_BITS
			MOVNE R0,#RX_Error
			MOVNE R5,#RESET_STA
			STRNE R5,[R4,#US_CR]
			POP {R4-R5,R14}
			BX R14

;**********************************************************************************
;*	RECEIVE ROUTINE (W/EOF RETURN)	int USART0_Receive_Check(void)
;*		Checks the RXRDY bit to see if a character has been received.  If not, then
;*		a no character flag is returned.  If a character has been received, then that 
;*		character is returned in R0.  The errors bits for parity, frame and
;*		over run are checked and if any are set, then an error flag is
;*		returned instead of the character.
;**********************************************************************************


			EXPORT USART0_Receive_Check
USART0_Receive_Check
			PUSH {R4-R5,R14}
 			LDR R4,=USART0_BASE
			MOV R0,#No_Char_Received
			LDR R5,[R4,#US_CSR]
			TST R5,#RXRDY
			LDRNE R0,[R4,#US_RHR]
			TST R5,#ERR_BITS
			MOVNE R0,#RESET_STA
			STRNE R0,[R4,#US_CR]
			MOVNE R0,#RX_Error
			POP {R4-R5,R14}
			BX R14



			END