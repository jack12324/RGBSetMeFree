/**
D-FlipFlop used for the pipelined signals 
in the main CPU file

resets to nops. Minimum 5 bits 

Instantiation: dff_nop  #(.WIDTH()) iDUT (.clk(clk), .rst_n(rst_n), .d(), .q());
**/
module dff_nop
    #(
    parameter WIDTH = 5 // This is the width of the DFF
                         // Change to the corrct value when instantiating the module 
    )(
    // Inputs 
    input clk, // system clock 
    input rst_n, // Active low re
    input [WIDTH-1:0] d, // input to the FF
    input we,

    // Outputs 
    output logic [WIDTH-1:0] q // output of the FF 
    );
    /**
    Simple DFF.
    Will update every clock cycle.
    Resets signals to 0s
    **/
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            q <= {WIDTH{1'b0}} + (5'b01111 << (WIDTH - 5));
        end
        else if (we) begin
            q <= d;
        end
    end

endmodule 
