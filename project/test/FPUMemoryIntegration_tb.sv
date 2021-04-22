module FPUMemoryIntegration_tb();
	parameter COL_WIDTH = 10;
	parameter MEM_BUFFER_WIDTH = 512;
	localparam BADDR_BITS = $clog2(MEM_BUFFER_WIDTH);
	localparam CADDR_BITS = $clog2(COL_WIDTH);
	localparam WADDR_BITS = $clog2(COL_WIDTH-2);

	// Clock
	logic clk;
	logic rst_n;

	int errors;

	//request buffer inputs
	logic  wr_en_rd_buffer, wr_en_wr_buffer, rd_buffer_sel, wr_bufer_sel;
	logic  [BADDR_BITS-1:0] read_col_address;
	logic  [BADDR_BITS-1:0] write_col_address;
	logic  [BADDR_BITS + CADDR_BITS - 1:0] request_write_address;
	logic  [BADDR_BITS + WADDR_BITS - 1:0] request_read_address;
	logic  [63:0] request_data_in;
	logic  [7:0] write_col [COL_WIDTH - 3: 0];
	//request buffer outputs
	logic [7:0] read_col [COL_WIDTH-1:0];
	logic [7:0] request_data_out;

	FPUCntrlReq_if req_if();

	FPURequestBuffer #(.BUFFER_DEPTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH))(.*);

	always #5 clk = ~clk; 
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		//test_from_file(225, 225);	
	end
endmodule
