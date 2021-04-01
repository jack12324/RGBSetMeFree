module rowFifo
  #(
  parameter ENTRIES=8,
  parameter BITS=8
  )
  (
  input clk,rst_n,en,wrEn,
  input [BITS-1:0] d [ENTRIES],
  output [BITS-1:0] q
  );
  
  reg [BITS-1:0] mem [0:ENTRIES-1];
  integer i;
  
  assign q = mem[ENTRIES-1];
  
  always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i=0; i< ENTRIES; i=i+1) begin	
			mem[i] <= 0;
		end
	end
	else begin
		if (en) begin	
			for (i=1; i< ENTRIES; i=i+1)begin	
				mem[i] <= mem[i-1];
			end
			mem[0] <= 0;
		end
		if (wrEn) begin
			mem <= d;	
		end
	end
  end
  // your RTL code here
endmodule // fifo
