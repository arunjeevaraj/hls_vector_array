/*
 * system_config.h
 *
 *  Created on: Oct 15, 2017
 *      Author: arun
 */

#ifndef SRC_SYSTEM_CONFIG_H_
#define SRC_SYSTEM_CONFIG_H_

#include "xil_printf.h"
#include "xuartlite.h"
#include "xtmrctr.h"
#include "xil_cache.h"
#include "xaxidma.h"
#include "xil_exception.h"
#include "xintc.h"
#include <stdio.h>
#include "xdut.h"


typedef float data_type;



#define DMA_DEV_ID			XPAR_AXIDMA_0_DEVICE_ID
#define DDR_BASE_ADDR		XPAR_MIG7SERIES_0_BASEADDR
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#define RX_INTR_ID			XPAR_INTC_0_AXIDMA_0_S2MM_INTROUT_VEC_ID
#define TX_INTR_ID			XPAR_INTC_0_AXIDMA_0_MM2S_INTROUT_VEC_ID

#define TX_BUFFER_BASE		(MEM_BASE_ADDR + 0x02000000)
#define RX_BUFFER_BASE		(MEM_BASE_ADDR + 0x03000000)
#define RX_BUFFER_HIGH		(MEM_BASE_ADDR + 0x04FFFFFF)

#define RESET_TIMEOUT_COUNTER	10000
#define UARTLITE_DEVICE_ID	XPAR_UARTLITE_0_DEVICE_ID

#define INTC_DEVICE_ID   	XPAR_INTC_0_DEVICE_ID
#define INTC				XIntc
#define INTC_HANDLER		XIntc_InterruptHandler

#define RESET_TIMEOUT_COUNTER	10000
#define MAX_PKT_LEN		256*4*6 // will be able to send 256*6 u32 values.

#endif /* SRC_SYSTEM_CONFIG_H_ */
