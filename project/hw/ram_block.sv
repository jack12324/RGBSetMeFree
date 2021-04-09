/*  ram_block v1.0 
 *  Instantiates 16kb register (CAUTION: May not synthesize)
 *
*/
module ram_block (
    input clk,
    input addr [13:0],
    input d [7:0],
    input WrEn,
    output q[7:0]
);

    reg [7:0] mem [16383:0];

    always_ff @( posedge clk ) begin : RAM
        if(WrEn) mem[addr] <= d;
        else q <= mem[addr];
    end
    
endmodule