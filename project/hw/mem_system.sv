/*  Mem_System v1.0 : Includes 4 Bank memory for word seperation
 *  Assumes Single Cycle Reads and Writes. May be used for testing.
 *
*/
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

    logic [7:0] q [3:0];    //Output from RAM

    //Check for appropriate prefixing values in addr
    genvar i;
    generate for (i = 0; i < 3; i = i + 1) begin 
        ram_block ram (.clk(clk), .addr(addr[15:2]), .d(data_in[8*i - 1: i]), .q(q[i]));
	end
    endgenerate

    assign data_valid = ~wr;
    assign data_out = {q[0], q[1], q[2], q[3]};

endmodule 