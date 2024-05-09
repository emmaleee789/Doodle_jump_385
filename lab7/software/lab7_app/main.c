// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x70; //make a pointer to access the PIO block
	volatile unsigned int *SW_PIO = (unsigned int*)0x50; //TODO
	volatile unsigned int *KEY_PIO = (unsigned int*)0x60;
	// volatile unsigned int *INC_PIO = (unsigned int*)0x60;//TODO for accumulation
    // volatile unsigned int *RESET_PIO = (unsigned int*)0x60; // 11 at start //TODO for reset

	*LED_PIO = 0x00; //clear all LEDs
	unsigned halt = 0; // a halt flag
	volatile unsigned int INC_PIO, RESET_PIO;

	while ( (1+1) != 3) //infinite loop
	{
		INC_PIO = *KEY_PIO & 0x04;
		RESET_PIO = *KEY_PIO & 0x02;
		if (RESET_PIO == 0)
			*LED_PIO = 0; //clear all LEDs
		if ((!halt) && INC_PIO == 0){ //TODO (value)
			*LED_PIO += *SW_PIO;
			halt = 1;
		}
		if (halt && INC_PIO > 0) //TODO (value)
			halt = 0;
	}
	return 1; //never gets here
}
