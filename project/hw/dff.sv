/**
D-FlipFlop used for the pipelined signals 
in the main CPU file

Instantiation: dff  #(.WIDTH()) iDUT (.clk(clk), .rst_n(rst_n), .d(), .q());
**/
//synthesis doesn't like that this was named dff, must have their own dff module
module dfflop
    #(
    parameter WIDTH = 1 // This is the width of the DFF
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
            q <= {WIDTH{1'b0}};
        end
        else if (we) begin
            q <= d;
        end
    end

endmodule
