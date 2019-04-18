#ifndef _USART_SOLUTION_H
#define _USART_SOLUTION_H

#define CR (0x0D)
#define LF (0x0A)

#define TX_Error   (0xE0000000)				// defined by student
#define RX_Error   (0xF0000000)
#define No_Char_Received  (0xC0000000)	

void USART0_INIT(void);
unsigned int USART0_Transmit(unsigned int);
unsigned int USART0_Receive(void);
unsigned int USART0_Receive_Check(void);

#endif

