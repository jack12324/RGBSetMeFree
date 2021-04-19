module ReadBank #(BANK_WIDTH = 10, MEM_BUFFER_DEPTH_BYTES = 512)(wr, clk, rst_n, data_in, write_sel, address, data_out);
	input clk, wr, rst_n;
	input [63:0] data_in; 
	input [$clog2(BANK_WIDTH)-1:0] write_sel;
	input [$clog2(MEM_BUFFER_DEPTH_BYTES)-1:0] address;
	output logic [7:0] data_out [BANK_WIDTH-1:0];

	logic [63:0] data_out_all [BANK_WIDTH-1:0];
	logic [1:0] byte_sel;
	logic [$clog2(MEM_BUFFER_DEPTH_BYTES)-3: 0] ram_addr;
	
	assign ram_addr = address[$clog2(MEM_BUFFER_DEPTH_BYTES)-1:2];

	genvar i;
	generate
		for(i = 0; i < BANK_WIDTH; i++)begin
			Single_RAM #(.DEPTH(MEM_BUFFER_DEPTH_BYTES/4), .WIDTH(64)) fpuram(.clk(clk), .wr(wr && (i==write_sel)), .in(data_in), .out(data_out_all[i]), .addr(ram_addr));
		end
	endgenerate

	always_comb begin
		for(int j = 0; j < BANK_WIDTH; j++)begin
			case(byte_sel)
				2'b11: data_out[j] = data_out_all[j][7:0];
				2'b01: data_out[j] = data_out_all[j][15:8];
				2'b10: data_out[j] = data_out_all[j][23:16];
				2'b00: data_out[j] = data_out_all[j][31:24];
			endcase
		end	
	end

	always_ff @(posedge clk)begin
		if(!rst_n) byte_sel = '0;
		else byte_sel <= address[1:0];
	end
endmodule
