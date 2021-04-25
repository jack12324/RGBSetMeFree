/*  ram_block v1.0 
 *  Instantiates 256 line Register array of size defined by parameter 
 *
*/
module ram_block (
    parameter  size = 32,
    input rst_n,
    input clk,
    input logic [13:0] addr,
    input logic [size-1:0] d,
    input logic WrEn,
    output logic [size-1:0] q
);

    reg [size-1:0] mem [255:0];

    always_ff @( posedge clk ) begin : RAM
        if(~rst_n) mem[i] = '0;
        if(rst_n && WrEn) mem[addr] = d;
        else q = (WrEn | ~rst_n) ? 0 : mem[addr];
    end
    
endmodule