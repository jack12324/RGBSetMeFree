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

   parameter COL_WIDTH = 10;
   parameter MEM_BUFFER_WIDTH = 512;
   
   logic shift_cols; 
   logic signed [7:0] filter [8:0];
   logic [$clog2(MEM_BUFFER_WIDTH)-1:0] write_col_address;
   logic [$clog2(MEM_BUFFER_WIDTH)-1:0] read_col_address;
   
   
   logic [7:0] col_new [COL_WIDTH - 1:0];
   logic [7:0] col0   [COL_WIDTH - 1:0];
   logic [7:0] col1   [COL_WIDTH - 1:0];
   logic [7:0] col2   [COL_WIDTH - 1:0];
   logic [7:0] result_pixels [COL_WIDTH-3:0];
   
   //note these connections are not correct, just connecting to something to test synthesis
   FPUController #(.MEM_BUFFER_WIDTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH))controller(
	.clk(clk),
	.rst_n(!rst),
	.mapped_data_valid(rx.c0.rspValid),
	.shift_cols(shift_cols), 
	.filter(filter), 
	.done(tx.c0.valid), 
	.request_read(tx.c1.data[0]), 
	.read_address(tx.c1.data[63:32]), 
	.request_write(tx.c1.data[1]), 
	.write_address(tx.c1.data[95:64]), 
	.write_col_address(write_col_address), 
	.read_col_address(read_col_address), 
	.rd_buffer_sel(tx.c1.data[2]), 
	.wr_buffer_sel(tx.c1.data[3]), 
	.wr_en_wr_buffer(tx.c1.data[4]), 
	.address_mem(tx.c1.data[127:96]), 
	.stall(0), 
	.data_mem(tx.c2.data[63:32]), 
	.making_request(rx.c0.data[8]), 
	.write_request_width(tx.c2.data[16:0]), 
	.write_request_height(tx.c2.data[24:17]));

   FPUMAC #(.COL_WIDTH(COL_WIDTH)) mac(.clk(clk), .rst_n(!rst), .*);
   FPUBuffers #(.COL_WIDTH(COL_WIDTH)) buff(.*, .rst_n(!rst));

   genvar i;
   //this is not correct, just trying to hook something up to test synthesis
   generate
	for(i = 0; i < COL_WIDTH; i++) begin
		col_new[i] = rx.c0.data[7:0]; 
	end
   endgenerate
endmodule
