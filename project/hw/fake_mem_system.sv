// for faking memory to test fetch
module mem_system
// this was copied in from a quartus RAM template
	#(parameter int
		WORDS = 256,
		RW = 8,
		WW = 32)
	(
	input we, 
	input clk,
	input [$clog2((RW < WW) ? WORDS : (WORDS * RW)/WW) - 1 : 0] waddr, 
	input [WW-1:0] wdata, 
	input [$clog2((RW < WW) ? (WORDS * WW)/RW : WORDS) - 1 : 0] raddr, 
	output logic [RW-1:0] q
	);
   
	// Use a multi-dimensional packed array to model the different read/write
	// width
	localparam int R = (RW < WW) ? WW/RW : RW/WW;
	localparam int B = (RW < WW) ? RW: WW;

	logic [R-1:0][B-1:0] ram[0:WORDS-1];

	generate if(RW < WW) begin
		// Smaller read?
		always_ff@(posedge clk)
		begin
			if(we) ram[waddr] <= wdata;
			q <= ram[raddr / R][raddr % R];
		end
	end
	else begin 
		// Smaller write?
		always_ff@(posedge clk)
		begin
			if(we) ram[waddr / R][waddr % R] <= wdata;
			q <= ram[raddr];
		end
	end 
	endgenerate


// instructor recommends the tutorial https://projectf.io/posts/initialize-memory-in-verilog/    
// which says to do this:
	reg [7:0] test_memory [0:15]; 
	initial begin 
		$display("Loading rom."); 
		$readmemh("rom_image.mem", test_memory); 
	end


endmodule : mem_system


