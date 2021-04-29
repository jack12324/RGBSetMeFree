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
`include "cci_mpf_if.vh"
`include "afu_json_info.vh"

module afu
  (
   input  clk,
   input  rst, 

   mmio_if.user mmio,
   dma_if.peripheral dma
   );

   
   localparam int CL_ADDR_WIDTH = $size(t_ccip_clAddr);

   // I want to just use dma.count_t, but apparently
   // either SV or Modelsim doesn't support that. Similarly, I can't
   // just do dma.SIZE_WIDTH without getting errors or warnings about
   // "constant expression cannot contain a hierarchical identifier" in
   // some tools. Declaring a function within the interface works just fine in
   // some tools, but in Quartus I get an error about too many ports in the
   // module instantiation.
   typedef logic [CL_ADDR_WIDTH:0] count_t;
   count_t 	size;
   logic 	go;
   logic 	done;

   // The AFU must respond with its AFU ID in response to MMIO reads of the CCI-P device feature 
   // header (DFH).  The AFU ID is a unique ID for a given program. Here we generated one with 
   // the "uuidgen" program and stored it in the AFU's JSON file. ASE and synthesis setup scripts
   // automatically invoke the OPAE afu_json_mgr script to extract the UUID into a constant 
   // within afu_json_info.vh.

   // Software provides 64-bit virtual byte addresses.
   // Again, this constant would ideally get read from the DMA interface if
   // there was widespread tool support.
   localparam int VIRTUAL_BYTE_ADDR_WIDTH = 64;

   logic [127:0] afu_id = `AFU_ACCEL_UUID;

   //note these connections are not correct, just connecting to something to test synthesis
   logic mapped_data_valid;
   logic mapped_data_request;
   logic [511:0] mapped_data;
   FPUDRAM_if dram_if();
   logic [31:0] mapped_address;
   logic done_fpu;

   // Interrupt signals
   logic INT; 
   logic [31:0] INT_INSTR;
   logic ACK;

   
    

    
    // Instantiate the memory map, which provides the starting read/write
    // 64-bit virtual byte addresses, a transfer size (in cache lines), and a
    // go signal. It also sends a done signal back to software.
    memory_map
    #(
      .ADDR_WIDTH(VIRTUAL_BYTE_ADDR_WIDTH),
      .SIZE_WIDTH(CL_ADDR_WIDTH+1)
      )
    memory_map (.*);

    wire local_dma_re, local_dma_we;
    // HAL memory signals
    logic tx_done;
    logic rd_valid;
    wire [1:0] mem_op;
    logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] DMA_Addr;
    logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] final_addr;
    logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] wr_addr;
    logic [511:0] DMA_Data_in;
    //wire tx_done;
    wire ready;
    //wire rd_valid;
    wire rd_go;
    wire wr_go;
 


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

  //Memory Layout//
  fpu_dma_ctrl iFPUDMA(.clk(clk), .rst_n(~rst), .dram_if(dram_if.DRAM));

  fpu_mmio_ctrl iFPUMMIO( 
	.clk(clk),
	.rst_n(rst_n),
    //FPU I/O
	.mapped_data_request(mapped_data_request),
	.mapped_address(mapped_address),
	.mapped_data(mapped_data),
	.mapped_data_valid(mapped_data_valid),
    //Inputs: From mem_ctrl
	.common_data_bus_write_out(common_data_bus_write_out),    
	.tx_done(tx_done),
	.rd_valid(rd_valid),
    //Outputs : To mem_ctrl
	.op(op),
	.raw_address(raw_address),
	.address_offset(address_offset),
	.common_data_bus_read_in(common_data_bus_read_in)  
      );

  mem_arbiter   iARBITER(
      .clk            (clk), 
      .rst_n          (~rst), 
        //Inputs from Src1
      .op_src1                              (Feop_host),
      .raw_address_src1                     (FeAddrOut_host),
      .address_offset_src1                  (),
      .common_data_bus_read_in_src1         (FeDataOut_host),
      //Outputs to Src1
      .common_data_bus_write_out_src1       (FeDataIn_host), 
      .tx_done_src1                         (Fetx_done_host),
      .rd_valid_src1                        (Ferd_valid_host),
      //Inputs from Src2
      .op_src2                              (Meop_host),
      .raw_address_src2                     (MeAddrOut_host),
      .address_offset_src2                  (),
      .common_data_bus_read_in_src2         (MeDataOut_host),
      //Outputs to Src2
      .common_data_bus_write_out_src2       (MeDataIn_host), 
      .tx_done_src2                         (Metx_done_host),
      .rd_valid_src2                        (Merd_valid_host),
      //Inputs from Src3
      .op_src3                              (),
      .raw_address_src3                     (),
      .address_offset_src3                  (),
      .common_data_bus_read_in_src3         (),
      //Outputs to Src3
      .common_data_bus_write_out_src3       (), 
      .tx_done_src3                         (),
      .rd_valid_src3                        (),

      //Inputs from Src3
      .op_src4                              (),
      .raw_address_src4                     (),
      .address_offset_src4                  (),
      .common_data_bus_read_in_src4         (),
      //Outputs to Src3
      .common_data_bus_write_out_src4       (), 
      .tx_done_src4                         (),
      .rd_valid_src4                        (),

      //Inputs: From mem_ctrl
      .common_data_bus_write_out            (dma.wr_data),    
      .tx_done                              (tx_done),
      .rd_valid                             (rd_valid),
      //Outputs : To mem_ctrl
      .op                                   (mem_op),
      .raw_address                          (DMA_Addr),
      .address_offset                       (),
      .common_data_bus_read_in              (DMA_Data_in)
      );

  // Memory Controller module
  mem_ctrl iMEM(
      .clk(clk),
      .rst_n(~rst),
      .host_init(go),
      .host_rd_ready(~dma.empty),
      .host_wr_ready(~dma.full),
      .op(mem_op), // CPU Defined
      .raw_address(cpu_addr), // Address in the CPU space
      .address_offset(wr_addr),
      .common_data_bus_read_in(DMA_Data_in), // CPU data word bus, input
      .common_data_bus_write_out(cpu_in),
      .host_data_bus_read_in(dma.rd_data),
      .host_data_bus_write_out(dma.wr_data),
      .corrected_address(final_addr),
      .ready(ready), // Usable for the host CPU
      .tx_done(tx_done), // Again, notifies CPU when ever a read or write is complete
      .rd_valid(rd_valid), // Notifies CPU whenever the data on the databus is valid
      .host_re(local_dma_re),
      .host_we(local_dma_we),
      .host_rgo(rd_go),
      .host_wgo(wr_go)
  );


  // Assign the starting addresses from the memory map.
  assign dma.rd_addr = final_addr;
  assign dma.wr_addr = final_addr;

  // Use the size (# of cache lines) specified by software.
  assign dma.rd_size = size; //Comes from memory_map.sv
  assign dma.wr_size = size;

  // Start both the read and write channels when the MMIO go is received.
  // Note that writes don't actually occur until dma.wr_en is asserted.
  assign dma.rd_go = rd_go;
  assign dma.wr_go = wr_go;

  // Read from the DMA when there is data available (!dma.empty) and when
  // it is safe to write data (!dma.full).
  assign dma.rd_en = local_dma_re;

  // Since this is a simple loopback, write to the DMA anytime we read.
  // For most applications, write enable would be asserted when there is an
  // output from a pipeline. In this case, the "pipeline" is a wire.
  assign dma.wr_en = local_dma_we;

  // The AFU is done when the DMA is done writing size cache lines.
  assign done = dma.wr_done;


endmodule
