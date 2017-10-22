/*
 * dma_api.c
 *
 *  Created on: Oct 15, 2017
 *      Author: arun
 */
#include "dma_api.h"

static INTC Intc;
//DMA instance
static XAxiDma AxiDma;		/* Instance of the XAxiDma */


// DMA interrupt flags.
volatile int TxDone;
volatile int RxDone;
volatile int Error;


void DisableIntrSystem(u16 TxIntrId, u16 RxIntrId)
{
	/* Disconnect the interrupts for the DMA TX and RX channels */
	XIntc_Disconnect(&Intc, TxIntrId);
	XIntc_Disconnect(&Intc, RxIntrId);
}

void TxIntrHandler(void *Callback)
{
	u32 IrqStatus;
	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;
	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
		return;
	}
	if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK)) {
		Error = 1;
		XAxiDma_Reset(AxiDmaInst);
		TimeOut = RESET_TIMEOUT_COUNTER;
		while (TimeOut) {
			if (XAxiDma_ResetIsDone(AxiDmaInst)) {
				break;
			}
			TimeOut -= 1;
		}
		return;
	}
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
		TxDone = 1;
	}
}

void RxIntrHandler(void *Callback)
{
	u32 IrqStatus;
	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;
	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
		return;
	}
	if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK)) {
		Error = 1;
		XAxiDma_Reset(AxiDmaInst);
		TimeOut = RESET_TIMEOUT_COUNTER;
		while (TimeOut) {
			if(XAxiDma_ResetIsDone(AxiDmaInst)) {
				break;
			}
			TimeOut -= 1;
		}
		return;
	}
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
		RxDone = 1;
	}
}


int SetupIntrSystem(INTC * IntcInstancePtr,
	   XAxiDma * AxiDmaPtr, u16 TxIntrId, u16 RxIntrId)
{
	int Status;
	/* Initialize the interrupt controller and connect the ISRs */
	Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		xil_printf("Failed init intc\r\n");
		return XST_FAILURE;
	}
	// connect the dma tx interrupt id with txintr handler.
	Status = XIntc_Connect(IntcInstancePtr, TxIntrId,
			       (XInterruptHandler) TxIntrHandler, AxiDmaPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Failed tx connect intc\r\n");
		return XST_FAILURE;
	}
	Status = XIntc_Connect(IntcInstancePtr, RxIntrId,
			       (XInterruptHandler) RxIntrHandler, AxiDmaPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Failed rx connect intc\r\n");
		return XST_FAILURE;
	}
	/* Start the interrupt controller */
	Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		xil_printf("Failed to start intc\r\n");
		return XST_FAILURE;
	}
	XIntc_Enable(IntcInstancePtr, TxIntrId);
	XIntc_Enable(IntcInstancePtr, RxIntrId);
	/* Enable interrupts from the hardware */
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
		(Xil_ExceptionHandler)INTC_HANDLER,
		(void *)IntcInstancePtr);
	Xil_ExceptionEnable();
	return XST_SUCCESS;
}


int setup_dma()
{
	xil_printf("Setting up DMA \r\n");
	int status;
	XAxiDma_Config *Config;
	//look up the hardware configuration of the DMA.
	Config = XAxiDma_LookupConfig(DMA_DEV_ID);
	if (!Config) {
		xil_printf("No config found for %d\r\n", DMA_DEV_ID);

		return XST_FAILURE;
	}
	status = XAxiDma_CfgInitialize(&AxiDma, Config);
	if (status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", status);
		return XST_FAILURE;
	}
	// Check If DMA is in scatter gather mode.
	if (XAxiDma_HasSg(&AxiDma)) {
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}
	status = SetupIntrSystem(&Intc, &AxiDma, TX_INTR_ID, RX_INTR_ID);
	if (status != XST_SUCCESS) {
		xil_printf("Failed intr setup\r\n");
		return XST_FAILURE;
	}
	xil_printf("Disabling Interrupts \r\n");
	/* Disable all interrupts before setup */
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
		XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
		XAXIDMA_DEVICE_TO_DMA);
	xil_printf("Enabling Interrupts \r\n");
	/* Enable all interrupts */
	XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
		XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
		XAXIDMA_DEVICE_TO_DMA);
	/* Initialize flags before start transfer test  */
	TxDone = 0;
	RxDone = 0;
	Error = 0;

	return status;
}

int dma_tx_req(void *data_ptr, u32 size)
{
	int status;
	status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) data_ptr,
		size, XAXIDMA_DMA_TO_DEVICE);
	if (status != XST_SUCCESS) {
		xil_printf("configuring DMA for tx failed \r\n");
		return XST_FAILURE;
	}
	return status;
}

int dma_rx_req(void *data_ptr, u32 size)
{
	int status;
	status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) data_ptr,
		size, XAXIDMA_DEVICE_TO_DMA);
	if (status != XST_SUCCESS) {
		xil_printf("configuring DMA for rx failed \r\n");
		return XST_FAILURE;
	}
	return status;

}

void wait_till_rx_done()
{
	while (!RxDone  && !Error) {
					/* NOP */
	}
}

void wait_till_tx_done()
{
	while (!TxDone  && !Error) {
					/* NOP */
	}
}
