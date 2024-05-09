//io_handler.c
#include "io_handler.h"
#include <stdio.h>

void IO_init(void)
{
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;
	*otg_hpi_w = 1;
	*otg_hpi_address = 0;
	*otg_hpi_data = 0;
	// Reset OTG chip
	*otg_hpi_cs = 0;
	*otg_hpi_reset = 0;
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
// 为了完成一次写入，先io_write一个地址 (16 bit)至HPI_Address Register，
// 然后再io_write一个数据 (16 bit)至HPI_Data Register。 
//*************************************************************************//
	*otg_hpi_address = Address;
	*otg_hpi_data = Data;
	*otg_hpi_cs = 0; //active low
	*otg_hpi_w = 0; //active low
	//order???

	//reset
	*otg_hpi_w = 1; //active low
	*otg_hpi_cs = 1;


}

alt_u16 IO_read(alt_u8 Address)
{
	alt_u16 temp;
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
// 为了完成一次读取，需要io_write一个地址 (16 bit)至HPI_Address Register，
// 然后再从HPI_Data Register用io_read读取数据。
//*************************************************************************//
	*otg_hpi_address = Address;
	*otg_hpi_cs = 0; //active low


	*otg_hpi_r = 0; //active low
	temp = *otg_hpi_data;

	//reset
	*otg_hpi_r = 1; //active low
	*otg_hpi_cs = 1;

	return temp;
}












// void IO_write(alt_u8 Address, alt_u16 Data)
// {
//     *otg_hpi_address = Address;
//     *otg_hpi_data = Data;

//     *otg_hpi_cs = 0;
//     *otg_hpi_w = 0;
//     *otg_hpi_w = 1;
//     *otg_hpi_cs = 1;
// }

// alt_u16 IO_read(alt_u8 Address)
// {
// 	alt_u16 temp;
//     temp = 0;
    
//     *otg_hpi_address = Address;

//     *otg_hpi_cs = 0;
//     *otg_hpi_r = 0;
//     temp = *otg_hpi_data;
//     *otg_hpi_r = 1;
//     *otg_hpi_cs = 1;

// //	printf("IO read: %x\n",temp);
// 	return temp;
// }