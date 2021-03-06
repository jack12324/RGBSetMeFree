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
	//reg [31:0] EndianChange;

	//Addr must be from 0x2000 to 0x2FFF
	logic [31:0] ram_addr;
	// PC+4? haha no, PC+1 now
	// for fake mem, even in memory stage, every address is divided by 4
	assign ram_addr = {2'b0, addr[23:2]};	//not currently Rounded Down Word Alignment
	always_ff @(posedge clk) begin
		if(wr) begin
			test_memory[ram_addr] <= data_in;
			done = 1'b1;
			stall = 1'b0;
		end
		else begin
			//EndianChange <= {test_memory[ram_addr][7:0], test_memory[ram_addr][15:8], test_memory[ram_addr][23:16], test_memory[ram_addr][31:24]};
			//data_out <= test_memory[ram_addr];
			stall = 1'b1; //unused
			done = 1'b1;
		end
	end
	assign data_out = test_memory[ram_addr];
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


