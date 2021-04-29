/*  Mem_System v2.0 : Uses Cache and Cache Controller. Need to verify functionality with DMA
 *
*/
module mem_system
	(
	input clk,
	input rst_n,
	input en,
	input wr, 
	input [31 : 0] addr, 
	input [31 : 0] data_in, 
	output logic [31:0] data_out,
	output logic stall,
	output logic done,
	//Wires to Mem_ctrl
	input logic [511:0] DataIn_host,
	input logic tx_done_host,
	input logic rd_valid_host,

	output logic [511:0] DataOut_host,
	output logic [31:0] AddrOut_host,
	output logic [1:0] op_host,
	//Output for test
	output logic CacheHit
	);


	//These wires are from the perspective of cache
	logic [7:0] index;
	logic [5:0]	offset;
	logic comp, wr_cache;
	logic [17:0] tag_in;
	logic [31:0] data_in_cache;
	logic valid_in;
	logic [511:0] cacheLine_in;
	logic [511:0] cacheLine_out;
	logic replaceLine;
	
	logic hit;
	logic dirty;
	logic [17:0] tag_out;
	logic [31:0] data_out_cache;
	logic valid;

	logic hit_ctrl, stallMem, done_ctrl;	//Hit coming out of cache_ctrl

	cpu_cache_ctrl cache_ctrl(
    //Inputs
    // Mem_system
    .clk		(clk), 
	.rst_n		(rst_n), 
	.en 			(en),
	.AddrIn_mem	(addr), 
	.DataIn_mem	(data_in), 
	.Rd_in		(~wr), 
	.Wr_in		(wr), //New data to write
    // DMA
    .DataIn_host	(DataIn_host), 
	.tx_done_host	(tx_done_host), 
	.rd_valid_host	(rd_valid_host),
        // From Cache 
    .hit_in			(hit), 
	.dirty_in		(dirty), 
	.tag_in			(tag_out), 
	.validIn_cache	(valid), 
	.DataIn_cache	(data_out_cache), 
	.cache_line_in	(cacheLine_out), 

    //Outputs
        //Mem_system
    .DataOut_mem	(data_out), 
	.stall			(stallMem), 
	.done			(done_ctrl), 
	.hit_out		(hit_ctrl),
        //DMA
    .AddrOut_host	(AddrOut_host), 
	.DataOut_host	(DataOut_host), 
	.op_host		(op_host),
        //Cache
    .cache_en		(cache_en), 
	.index			(index), 
	.offset			(offset), 
	.comp			(comp), 
	.wr_cache		(wr_cache), 
	.tag_out		(tag_in), 
	.DataOut_cache	(data_in_cache), 
	.cache_line_out	(cacheLine_in), 
	.replaceLine	(replaceLine)
	);

	cpu_cache c0(
		//Input
		.en			(cache_en),
		.clk		(clk),
		.rst_n		(rst_n),
		.index		(index),
		.offset		(offset),
		.comp		(comp),
		.wr			(wr_cache),
		.tag_in		(tag_in),
		.data_in	(data_in_cache),
		.valid_in	(valid_in),
		.replaceLine(replaceLine),
		.cl_in 		(cacheLine_in),

		//Output
		.hit		(hit),
		.dirty		(dirty),
		.tag_out	(tag_out),
		.data_out	(data_out_cache),
		.valid		(valid),
		.cl_out		(cacheLine_out)
	);

	assign valid_in = 1'b1;
    assign done = done_ctrl;	
	assign stall = stallMem;
	assign CacheHit = hit_ctrl;

endmodule 