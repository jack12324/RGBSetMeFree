/*  ram_block v1.0 
 *  Instantiates 16kb register (CAUTION: May not synthesize)
 *
*/
module ram_block (
    input clk,
    input logic [13:0] addr,
    input logic [7:0] d,
    input logic WrEn,
    output logic [7:0] q
);

    reg [7:0] mem [16383:0];

    always_ff @( posedge clk ) begin : RAM
        if(WrEn) mem[addr] <= d;
        else q <= mem[addr];
    end
    
endmodule