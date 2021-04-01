module memA
  #(
    parameter BITS_AB=8,
    parameter DIM=8
    )
   (
    input                      clk,rst_n,en,WrEn,
    input signed [BITS_AB-1:0] Ain [DIM-1:0],
    input [$clog2(DIM)-1:0] Arow,
    output signed [BITS_AB-1:0] Aout [DIM-1:0]
   );
	genvar i;
	logic [BITS_AB-1 : 0] rfifoCol [DIM-1 : 0]; 
	generate
	        rowFifo #(.ENTRIES(DIM), .BITS(BITS_AB)) rfifo (.clk(clk), .rst_n(rst_n), .en(en), .wrEn(WrEn && (0 == Arow)), .d(Ain), .q(Aout[0]));
		for (i = 1; i < DIM; i++)begin
			rowFifo #(.ENTRIES(DIM), .BITS(BITS_AB)) rfifo (.clk(clk), .rst_n(rst_n), .en(en), .wrEn(WrEn && (i == Arow)), .d(Ain), .q(rfifoCol[i]));
			fifo #(.DEPTH(i), .BITS(BITS_AB)) delayFifo (.clk(clk), .rst_n(rst_n), .en(en), .d(rfifoCol[i]), .q(Aout[i]));
		end
	endgenerate
endmodule
