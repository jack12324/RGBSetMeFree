module WriteBank #(BANK_WIDTH = 10, MEM_BUFFER_DEPTH_BYTES = 512)(wr, clk, rst_n, data_in, read_sel, address, data_out);
	input clk, wr, rst_n;
	input [7:0] data_in [BANK_WIDTH-1: 0]; 
	input [$clog2(BANK_WIDTH)-1:0] read_sel;
	input [$clog2(MEM_BUFFER_DEPTH_BYTES)-1:0] address;
	output [7:0] data_out;

	logic [7:0] data_out_all [BANK_WIDTH-1:0];
	logic [$clog2(BANK_WIDTH)-1:0] last_read_sel;


	genvar i;
	generate
		for(i = 0; i < BANK_WIDTH; i++)begin
			Single_RAM #(.DEPTH(MEM_BUFFER_DEPTH_BYTES), .WIDTH(8)) fpuram(.clk(clk), .wr(wr), .in(data_in[i]), .out(data_out_all[i]), .addr(address));
		end
	endgenerate

	assign data_out = data_out_all[last_read_sel];

	always_ff @(posedge clk)begin
		if(!rst_n) last_read_sel = '0;
		else last_read_sel <= read_sel;
	end
endmodule
