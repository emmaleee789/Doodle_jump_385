// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x20; //make a pointer to access the PIO block

	*LED_PIO = 0; //clear all LEDs
	while ( (1+1) != 3) //infinite loop
	{
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO |= 0x1; //set LSB
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO &= ~0x1; //clear LSB
	}
	return 1; //never gets here
}


// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x40; //make a pointer to access the PIO block
	volatile unsigned int *SW_PIO = (unsigned int*)0x50; //TODO
	volatile unsigned int *INC_PIO = (unsigned int*)0x60;//TODO for accumulation
    volatile unsigned int *RESET_PIO = (unsigned int*)0x60; // 11 at start //TODO for reset

	*LED_PIO = 0; //clear all LEDs
	unsigned halt = 0; // a halt flag

	while ( (1+1) != 3) //infinite loop
	{
		if (*RESET_PIO)
			*LED_PIO = 0; //clear all LEDs
		if ((!halt) && *INC_PIO == 1){ //TODO (value)
			*LED_PIO += *SW_PIO;
			halt = 1;
		}
		if (halt && *INC_PIO == 0) //TODO (value)
			halt = 0;
	}
	return 1; //never gets here
}
