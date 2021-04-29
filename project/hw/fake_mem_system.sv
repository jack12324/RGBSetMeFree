// for faking memory to test fetch
// v1.0 Simulates single cycle memory
// v2.0 :: TODO Integrate Cache to Read from Rom Image and Mem_system has variable cycle output
module fake_mem_system
#(parameter FILENAME = "project/test_images/rom_image.mem") 
	(
	//Memory System does not need reset
	input clk,
	input rst_n,
	input en,
	input wr, 
	input [31 : 0] addr, 
	input [31 : 0] data_in, 
	output logic [31:0] data_out,
	output logic stall,
	output logic done //unused
	);

	reg [31:0] test_memory [0:4095]; 

	//Addr must be from 0x2000 to 0x2FFF
	logic [31:0] ram_addr;
	assign ram_addr = {addr[23:2], 2'b0};	//Rounded Down Word Alignment

	always_ff @(posedge clk) begin
		if(wr) begin
			test_memory[ram_addr] <= data_in;
			done = 1'b1;
			stall = 1'b0;
		end
		else begin
			data_out <= test_memory[ram_addr];
			stall = 1'b1;
			done = 1'b0;
		end
	end

// instructor recommends the tutorial https://projectf.io/posts/initialize-memory-in-verilog/    
// which says to do this:
	
	initial begin 
	        $display("Loading FILENAME:%s", FILENAME);
	        //$readmemh("project/test_images/rom_image.mem", test_memory); 
	        $readmemh(FILENAME, test_memory); 
		// relative file path form same place where work folder is

	        $display("addr :: data "); // display   	    	
		for (int i=0; i<10; i++) begin
        	    $display("%x :: %x", (i+32'h0600), test_memory[i]);//2000 is wrong meanwhile, and 0600 only for fetch inst mem
        	end
    	end
endmodule : fake_mem_system


