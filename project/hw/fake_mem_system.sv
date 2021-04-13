// for faking memory to test fetch
// v1.0 Simulates single cycle memory
// v2.0 :: TODO Integrate Cache to Read from Rom Image and Mem_system has variable cycle output
module mem_system
	(
	//Memory System does not need reset
	input clk,
	input wr, 
	input [31 : 0] addr, 
	input [31 : 0] data_in, 
	output logic [31:0] data_out,
	output logic data_valid
	);

	reg [31:0] test_memory [0:4095]; 

	//Addr must be from 0x2000 to 0x2FFF
	logic [31:0] ram_addr;
	assign ram_addr = {addr[23:2], 2'b0};	//Rounded Down Word Alignment

	always_ff @(posedge clk) begin
		if(wr) begin
			test_memory[ram_addr] <= data_in;
			data_valid = 1'b0;
		end
		else begin
			data_out <= test_memory[ram_addr];
			data_valid = 1'b1;
		end
	end

// instructor recommends the tutorial https://projectf.io/posts/initialize-memory-in-verilog/    
// which says to do this:
	
	initial begin 
		$display("Loading rom."); 
		$readmemh("rom_image.mem", test_memory); 

		$display("Contents of Memory: "); // display
		for(int i=0; i< 4096; i++) begin
			$display("%x \n", test_memory[i]) // display
		end
	end


endmodule : mem_system


