module ReadBank #(BANK_WIDTH = 10, MEM_BUFFER_DEPTH_BYTES = 512)(wr, clk, rst_n, data_in, write_sel, address, data_out);
	input clk, wr, rst_n;
	input [63:0] data_in; 
	input [$clog2(BANK_WIDTH)-1:0] write_sel;
	input [$clog2(MEM_BUFFER_DEPTH_BYTES)-1:0] address;
	output logic [7:0] data_out [BANK_WIDTH-1:0];

	logic [63:0] data_out_all [BANK_WIDTH-1:0];
	logic [2:0] byte_sel;
	logic [$clog2(MEM_BUFFER_DEPTH_BYTES)-4: 0] ram_addr;
	
	assign ram_addr = address[$clog2(MEM_BUFFER_DEPTH_BYTES)-1:3];

	genvar i;
	generate
		for(i = 0; i < BANK_WIDTH; i++)begin
			Single_RAM #(.DEPTH(MEM_BUFFER_DEPTH_BYTES/8), .WIDTH(64)) fpuram(.clk(clk), .wr(wr && (i==write_sel)), .in(data_in), .out(data_out_all[i]), .addr(ram_addr));
		end
	endgenerate

	always_comb begin
		for(int j = 0; j < BANK_WIDTH; j++)begin
			case(byte_sel)
				3'b111: data_out[j] = data_out_all[j][7:0];
				3'b110: data_out[j] = data_out_all[j][15:8];
				3'b101: data_out[j] = data_out_all[j][23:16];
				3'b100: data_out[j] = data_out_all[j][31:24];
				3'b011: data_out[j] = data_out_all[j][39:32];
				3'b010: data_out[j] = data_out_all[j][47:40];
				3'b001: data_out[j] = data_out_all[j][55:48];
				3'b000: data_out[j] = data_out_all[j][63:56];
			endcase
		end	
	end

	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n) byte_sel = '0;
		else byte_sel <= address[2:0];
	end
endmodule
