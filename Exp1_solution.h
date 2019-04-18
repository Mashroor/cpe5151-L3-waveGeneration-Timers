#ifndef EXAMPLE_ASSEMBLY_H
#define EXAMPLE_ASSEMBLY_H


/*----------------------*/
/* Constant Definitions */
/*----------------------*/



//   Function Prototypes

extern void PERIPH_CLOCK_INIT(void); 
extern void POWERLED_INIT(void); 
extern void USER_LEDS_INIT(void); 
extern void SWITCH_INIT(void); 
extern void EXT_LEDS_INIT(void); 
extern void DELAY_1MS(unsigned int a);
extern void POWERLED_CONTROL(unsigned int a);
extern void LED1_CONTROL(unsigned int a);
extern void LED2_CONTROL(unsigned int a);
extern unsigned int COUNTER_FUNCTION(unsigned int a, unsigned int b, unsigned int c);
extern void DISPLAY_FUNCTION(unsigned int a);
extern unsigned int LEFT_JOYSTICK(unsigned int a); 
extern unsigned int RIGHT_JOYSTICK(unsigned int a);  

#endif


