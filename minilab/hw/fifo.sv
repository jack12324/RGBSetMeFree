// fifo.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

module fifo
  #(
  parameter DEPTH=8,
  parameter BITS=64
  )
  (
  input clk,rst_n,en,
  input [BITS-1:0] d,
  output [BITS-1:0] q
  );
  
  reg [BITS-1:0] mem [0:DEPTH-1];
  integer i;
  
  assign q = mem[DEPTH-1];
  
  always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i=0; i< DEPTH; i=i+1) begin	
			mem[i] <= 0;
		end
	end
	else begin
		if (en) begin	
			for (i=1; i< DEPTH; i=i+1)begin	
				mem[i] <= mem[i-1];
			end
			mem[0] <= d;
		end
	end
  end
  // your RTL code here
endmodule // fifo
