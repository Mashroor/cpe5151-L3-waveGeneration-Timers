/******************************************************************************/
/* TC_ultrasonic_example.c 
Name: Adam Worley, Mashroor Rashid*/
/******************************************************************************/
/* This file is part of the uVision/ARM development tools.                    */
/* Copyright (c) 2005-2006 Keil Software. All rights reserved.                */
/* This software may only be used under the terms of a valid, current,        */
/* end user licence from KEIL for a compatible version of KEIL software       */
/* development tools. Nothing else gives you the right to use this software.  */
/******************************************************************************/
                  
#include <AT91SAM7SE512.H>              /* AT91SAM7SE512 definitions          */
#include "AT91SAM7SE-EK.h"           /* AT91SAM7SE-EK board definitions    */

#include "Exp1_solution.h"
#include "USART0_solution.h"
#include <stdio.h>
#include "Input_Integer.h"     // Not needed for this experiment
#include "TC_Assembly.h"       // Optional Assembly functions
#include <math.h>             // contains the square root function double sqrt(double input);

/* Constant Definitions  */
const unsigned int MAX_COUNT = 65536;

/* Main Program */
int main (void)
{
  unsigned int switch_input,temp,num_overflows;
	unsigned long num_counts;
	float distance;

  switch_input = 1;

  // Configure the PIO Lines for LEDs as Outputs
	USER_LEDS_INIT();
	POWERLED_INIT();
	
	SWITCH_INIT(); // Initialize the switch inputs
	USART0_INIT(); // Initialize USART0

	TC0_INIT(); // Initialize TC0 to create 40KHz waveform
  TC1_INIT(); // Initialize TC1 to create 101us active high pulse and 1.5ms active low pulse
	TC2_INIT(); // Initialize TC2 in capture mode

	AT91C_BASE_TCB->TCB_BMR = (2); // Connect TIOA1 to XC0
	
  // Loop forever
  for (;;) 
	{
		// Wait for a switch to be pressed
		do
    {
			switch_input = AT91C_BASE_PIOB->PIO_PDSR & (1<<22); // check right button
    }while(switch_input);

    // Debounce the switch when pressed
    DELAY_1MS(200);		
			
		// Clear the measurement variables
    num_overflows = 0;
		
		//Start the timer\counters simultaneously
		AT91C_BASE_TCB->TCB_BCR = 1;

    // Wait for the B register to be loaded and check for timer overflows
    do
    {
			// Non-destructive SR check
      temp = AT91C_BASE_TC2->TC_SR & 0xFFFFF;
      if(temp & 1)
        num_overflows++;
    }while(!(temp & (1<<6)) && num_overflows <= 20 );
	
    // Calculate the distance or print error message
		if(num_overflows <= 20)
		{
			num_counts = (num_overflows * MAX_COUNT) + AT91C_BASE_TC2->TC_RA;// - AT91C_BASE_TC2->TC_RA;
			distance = (num_counts * (.0000000417334) * 1129.9)/2;
			printf("Distance: %f \n\r", distance);
			printf("Counts: %d \n\r", num_counts);

		} else{
			printf("Distance too far.\n\r");
		}
	}
}
