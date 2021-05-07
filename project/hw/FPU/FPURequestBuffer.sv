module FPURequestBuffer#(BUFFER_DEPTH = 512, COL_WIDTH = 10)(clk, rst_n, request_write_address, request_read_address, request_data_in, request_data_out, wr_en_rd_buffer, wr_en_wr_buffer, rd_buffer_sel, wr_buffer_sel, read_col, write_col, read_col_address, write_col_address);

	localparam BADDR_BITS = $clog2(BUFFER_DEPTH);
	localparam CADDR_BITS = $clog2(COL_WIDTH);
	localparam WADDR_BITS = $clog2(COL_WIDTH-2);

	input clk, rst_n, wr_en_rd_buffer, wr_en_wr_buffer, rd_buffer_sel, wr_buffer_sel;
	input [BADDR_BITS-1:0] read_col_address;
	input [BADDR_BITS-1:0] write_col_address;
	input [BADDR_BITS + CADDR_BITS - 1:0] request_write_address;
	input [BADDR_BITS + WADDR_BITS - 1:0] request_read_address;
	input [63:0] request_data_in;
	input [7:0] write_col [COL_WIDTH - 3: 0];

	output logic [7:0] read_col [COL_WIDTH-1:0];
	output [7:0] request_data_out;

	logic [7:0] read_col_out [COL_WIDTH-1:0];
	logic [7:0] rb0_out [COL_WIDTH-1:0];
	logic [7:0] rb1_out [COL_WIDTH-1:0];
	logic [7:0] wb0_out;
	logic [7:0] wb1_out;
	logic last_rd_buffer_sel;
	logic last_wr_buffer_sel;

	ReadBank #(.BANK_WIDTH(COL_WIDTH) , .MEM_BUFFER_DEPTH_BYTES(BUFFER_DEPTH)) rb0 (.clk(clk), 
											.rst_n(rst_n), 
											.wr(wr_en_rd_buffer && rd_buffer_sel), 
											.data_in(request_data_in), 
											.write_sel(request_write_address[BADDR_BITS+CADDR_BITS-1:BADDR_BITS]), 
											.address(wr_en_rd_buffer && rd_buffer_sel ? request_write_address[BADDR_BITS-1:0] : read_col_address), 
											.data_out(rb0_out));

	ReadBank #(.BANK_WIDTH(COL_WIDTH) , .MEM_BUFFER_DEPTH_BYTES(BUFFER_DEPTH)) rb1 (.clk(clk), 
											.rst_n(rst_n), 
											.wr(wr_en_rd_buffer && !rd_buffer_sel), 
											.data_in(request_data_in), 
											.write_sel(request_write_address[BADDR_BITS+CADDR_BITS-1:BADDR_BITS]), 
											.address(wr_en_rd_buffer && !rd_buffer_sel ? request_write_address[BADDR_BITS-1:0] : read_col_address), 
											.data_out(rb1_out));

	assign read_col_out = last_rd_buffer_sel ? rb1_out : rb0_out;
	assign request_data_out = !last_wr_buffer_sel ? wb1_out : wb0_out;

	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n) read_col <= '{default:'0};
		else read_col <= read_col_out;
	end
	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n) last_rd_buffer_sel <= '0;
		else last_rd_buffer_sel <= rd_buffer_sel;
	end
	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n) last_wr_buffer_sel <= '0;
		else last_wr_buffer_sel <= wr_buffer_sel;
	end

	WriteBank #(.BANK_WIDTH(COL_WIDTH-2), .MEM_BUFFER_DEPTH_BYTES(BUFFER_DEPTH)) wb0 (	.clk(clk),
												.rst_n(rst_n), 
												.wr(wr_en_wr_buffer && !wr_buffer_sel),
												.data_in(write_col), 
												.read_sel(request_read_address[BADDR_BITS + WADDR_BITS - 1:BADDR_BITS]), 
												.address(wr_en_wr_buffer && !wr_buffer_sel ? write_col_address : request_read_address[BADDR_BITS-1:0]), 
												.data_out(wb0_out));

	WriteBank #(.BANK_WIDTH(COL_WIDTH-2), .MEM_BUFFER_DEPTH_BYTES(BUFFER_DEPTH)) wb1 (	.clk(clk),
												.rst_n(rst_n), 
												.wr(wr_en_wr_buffer && wr_buffer_sel),
												.data_in(write_col), 
												.read_sel(request_read_address[BADDR_BITS + WADDR_BITS - 1:BADDR_BITS]), 
												.address(wr_en_wr_buffer && wr_buffer_sel ? write_col_address : request_read_address[BADDR_BITS-1:0]), 
												.data_out(wb1_out));
endmodule
