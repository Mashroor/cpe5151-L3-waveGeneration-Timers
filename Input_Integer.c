

#include "Input_Integer.h"
#include "USART0_solution.h"
#include <stdlib.h>


/***********************************************************************
DESC:    Waits for user input of a long integer as ASCII characters
        
INPUT: Nothing
RETURNS: unsigned long
CAUTION: UART must be initialized first
************************************************************************/

unsigned int Input_Integer(void)
{
   unsigned int i,c,output_val;
      char valsout[16];
      for(i=0;i<16;i++)
      {
        valsout[i]=0;
      }
      output_val=0xffffffff;
      i=0;
      do
      {
         c=USART0_Receive();
         if((c>0x2f)&&(c<0x3a))
         {
           valsout[i]=(char)c;
           i++;
					 USART0_Transmit(c);
         }
         else if ((c==BS)||(c==DEL))  // Putty uses DEL (127) or BS (0x08) for backspace
         {
           i--;
           valsout[i]=0;
					 USART0_Transmit(BS);
           USART0_Transmit(space);
           USART0_Transmit(BS);
         }
         else if (c==CR||c==LF)
         {
            output_val=atoi(valsout);
            USART0_Transmit(CR);
			      USART0_Transmit(LF);
         }
      }while(output_val==0xffffffff);

return output_val;
}
