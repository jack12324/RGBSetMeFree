module mem_system_tb ();
    // Clock
	logic clk;
	
    logic wr;
	logic [31 : 0] addr;
	logic [31 : 0] data_in;
	logic [31:0] data_out;
	logic data_valid;

	always #5 clk = ~clk; 

    int i, j, expected_data, errors;
    
    mem_system mem_dut(.*);

    initial begin
        clk = 1'b0;
        errors = 0;

        // //TEST 1: Write test 
        //     Write to 100 addresses, 
        //     check if mem_dut.ram[] has the appropriate value.

        // //TEST 2: Bank Read test
        //     Check that the output from memsystem is correct for
        //     the appropriate byte in  mem_dut.ram

        // //TEST 3: Unaligned Memory Access test
        //     Check that entire word is returned on unaligned memory access

        // //TEST 4: Constant reads and writes test
        //     Check repeated reads and writes to same memory locations, 
        //     with byte addressability and word addressability.
        
    end


endmodule