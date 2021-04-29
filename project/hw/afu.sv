// ***************************************************************************
// Copyright (c) 2013-2018, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ***************************************************************************

// Module Name:  afu.sv
// Project:      ccip_mmio
// Description:  Implements an AFU with a single memory-mapped user register to demonstrate
//               memory-mapped I/O (MMIO) using the Core Cache Interface Protocol (CCI-P).
//
//               This module provides a simplified AFU interface since not all the functionality 
//               of the ccip_std_afu interface is required. Specifically, the afu module provides
//               a single clock, simplified port names, and all I/O has already been registered,
//               which is required by any AFU.
//
// For more information on CCI-P, see the Intel Acceleration Stack for Intel Xeon CPU with 
// FPGAs Core Cache Interface (CCI-P) Reference Manual

`include "platform_if.vh"
`include "afu_json_info.vh"

module afu
  (
   input  clk,
   input  rst, 

   // CCI-P signals
   // Rx receives data from the host processor. Tx sends data to the host processor.
   input  t_if_ccip_Rx rx,
   output t_if_ccip_Tx tx
   );

   // The AFU must respond with its AFU ID in response to MMIO reads of the CCI-P device feature 
   // header (DFH).  The AFU ID is a unique ID for a given program. Here we generated one with 
   // the "uuidgen" program and stored it in the AFU's JSON file. ASE and synthesis setup scripts
   // automatically invoke the OPAE afu_json_mgr script to extract the UUID into a constant 
   // within afu_json_info.vh.
   
   logic [127:0] afu_id = `AFU_ACCEL_UUID;

   //note these connections are not correct, just connecting to something to test synthesis
   logic mapped_data_valid;
   logic mapped_data_request;
   logic [31:0] mapped_data;
   FPUDRAM_if dram_if();
   logic [31:0] mapped_address;
   logic done_fpu;

   // Interrupt signals
   logic INT; 
   logic [31:0] INT_INSTR;
   logic ACK;

   
    // HAL memory signals
    logic tx_done;
    logic rd_valid;
    logic [1:0] op;
    logic [31:0] data_in;
    logic [31:0] data_out;


   FPU #(.COL_WIDTH(10), .MEM_BUFFER_WIDTH(512), .CL_WIDTH(64)) iFPU(
	.clk(clk), .rst_n(!rst), 
	.done(done_fpu), .start(startFPU),
	.mapped_data_valid(mapped_data_valid), 
	.mapped_data_request(mapped_data_request), 
	.mapped_data(mapped_data), 
	.mapped_address(mapped_address), 
	.dram_if(dram_if.FPU));
   
   cpu iCPU(
	.clk(clk), .rst_n(rst_n),
	.INT(INT), .INT_INSTR(INT_INSTR), .ACK(ACK), // todo where from?
	// inst memory
	.FeDataIn_host(FeDataIn_host),
	.Fetx_done_host(Fetx_done_host),
	.Ferd_valid_host(Ferd_valid_host),
	.FeDataOut_host(FeDataOut_host),
	.FeAddrOut_host(FeAddrOut_host),
	.Feop_host(Feop_host),
	// data memory
	.MeDataIn_host(MeDataIn_host),
	.Metx_done_host(Metx_done_host),
	.Merd_valid_host(Merd_valid_host),
	.MeDataOut_host(MeDataOut_host),
	.MeAddrOut_host(MeAddrOut_host),
	.Meop_host(Meop_host),
	// jump start FPU
	.startFPU(startFPU)
	);

                                                        // Highest Priority                                                      // no masking used
  InterruptController iINT(.clk(clk), .rst_n(~rst), .IO({7'b0000000, done_fpu}), .ACK(ACK), .INT(INT), .INT_INSTR(INT_INSTR), .IMR_in({8{1'b1}}));



endmodule
