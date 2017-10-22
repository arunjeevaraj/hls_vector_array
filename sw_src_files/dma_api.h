/*
 * dma_api.h
 *
 *  Created on: Oct 15, 2017
 *      Author: arun
 */

#ifndef SRC_DMA_API_H_
#define SRC_DMA_API_H_

#include "system_config.h"

void DisableIntrSystem(u16 TxIntrId, u16 RxIntrId);
int setup_dma();
int dma_tx_req(void *data_ptr, u32 size);
int dma_rx_req(void *data_ptr, u32 size);
void wait_till_rx_done();
void wait_till_tx_done();
#endif /* SRC_DMA_API_H_ */
