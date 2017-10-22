/*
 * hw_dut_api.c
 *
 *  Created on: Oct 15, 2017
 *      Author: arun
 */
#include "hw_dut_api.h"

static XDut dut_inst;

int setup_hw_dut()
{
	XDut_Config* config_ptr;
	int status;
	config_ptr = XDut_LookupConfig(XPAR_XDUT_0_DEVICE_ID);
	if (!config_ptr) {
		xil_printf("Error Lookup config failed. \r\n");
		return XST_FAILURE;
	}
	status = XDut_CfgInitialize(&dut_inst, config_ptr);
	if (status != XST_SUCCESS) {
		xil_printf("Failed to configure the XDUT \r\n");
	}
	XDut_EnableAutoRestart(&dut_inst);
	XDut_Start(&dut_inst);
	return status;
}

void write_trans_mat_hw(void *trans_mat_buff)
{
	data_type trans_mat_rb[36];
	u8 matches = 0;
	data_type *trans_mat = (data_type*)trans_mat_buff;
	xil_printf("Write the trans matrix \r\n");
	XDut_Write_trans_mat_V_Words(&dut_inst, 0, (int*)trans_mat, 36);
	// read back to see if the written to dut is same.
	XDut_Read_trans_mat_V_Words(&dut_inst, 0, (int*)trans_mat_rb, 36);
	for (unsigned i = 0; i < 6 ; i ++) {
		for (unsigned j = 0; j < 6 ; j++) {
			if (trans_mat_rb[6*i + j] == trans_mat[6*i + j]){
				matches++;
			}
		}
	}
	if (matches !=36){
		xil_printf("hw fault, trans mat read back failed\r\n");
	}
}
