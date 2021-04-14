module InterruptController(clk, rst_n, IO, ACK, INT, INT_INSTR, IMR_in);

    input clk; // System clock 
    input rst_n; // Active low reset   
    input ACK; // Interrupt Acknowledge signal from the CPU 
    input [7:0] IO; // IO request signals. Direct connection to IO device 
    input [7:0] IMR_in; // input to the IMR register

    output INT; // Interrupt service request signal to the CPU
    output [31:0] INT_INSTR; // Used to inject Instructions into the CPU pipeline 

    reg [7:0] IMR; // Interrupt Mask Register (more information on ff block)
    reg [7:0] IRR; // Interrupt Request Register(more information on ff block)
    reg [7:0] ISR; // Interrupt Service Register (more ingormation of ff block)
    reg [7:0] ISR_in; // Input to the ISR register. Set by priority logic 
    reg [7:0] clr; // This signal clears the Signal request in the IRR

    /** 
    Priority Logic
    -----
    The priority of this controller is determined by the 
    order in which they are connected. 
        IO[0] ---> Highest Priority
        IO[1] ---> Next Highest Priority
        .
        .
        . 
        IO[7] ---> Lowest Priority
    Depending on which IO devices have requested an interrupt 
    and where they are physically connected, determine the ISR_in signal.
    **/
    always_comb begin
        // Only service one interrupt at a time 
        if (IRR[0] == 1'b1) 
            ISR_in = 8'b00000001;
        else if (IRR[1] == 1'b1) 
            ISR_in = 8'b00000010;
        else if (IRR[2] == 1'b1) 
            ISR_in = 8'b00000100;
        else if (IRR[3] == 1'b1) 
            ISR_in = 8'b00001000;
        else if (IRR[4] == 1'b1) 
            ISR_in = 8'b000010000;
        else if (IRR[5] == 1'b1) 
            ISR_in = 8'b00100000;
        else if (IRR[6] == 1'b1) 
            ISR_in = 8'b01000000;
        else if (IRR[7] == 1'b1) 
            ISR_in = 8'b10000000;        
    end

    /** 
    Control Logic 
    ------
    This logic block is a big state machine to determine 
    the outputs of the 
    */
    always_comb begin
        
    end

    /**
     Interrupt Mask Register
    ------
    When the bits of this register are set to 0 
    this means the interrupt for the respective IO 
    Device are disabled.

    This register is reset to all 1s (all enebled) and it \
    is set by the IMR_in input.
    **/
    always_ff @(posedge clk, negedge rst_n) begin 
        if (~rst_n)
            IMR <= {7{1'b1}};
        else
            IMR <= IMR_in;
    end 

    /**
     Interrupt Request Register
    ------
    This register stores which IO devices are requesting
    and interrupt. 

    This register is reset to all 0s, no requests.
    **/
    always_ff @(posedge clk, negedge rst_n) begin 
        if (~rst_n)
            IRR <= {7{1'b0}};
        else if (|IO) begin 
            // Assert the bit, but do not remove if called again
            IRR[0] <= (IO[0] == 1'b1) ? ( (IRR[0] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[0]);
            IRR[1] <= (IO[1] == 1'b1) ? ( (IRR[1] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[1]);
            IRR[2] <= (IO[2] == 1'b1) ? ( (IRR[2] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[2]);
            IRR[3] <= (IO[3] == 1'b1) ? ( (IRR[3] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[3]);
            IRR[4] <= (IO[4] == 1'b1) ? ( (IRR[4] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[4]);
            IRR[5] <= (IO[5] == 1'b1) ? ( (IRR[5] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[5]);
            IRR[6] <= (IO[6] == 1'b1) ? ( (IRR[6] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[6]);
            IRR[7] <= (IO[7] == 1'b1) ? ( (IRR[7] == 1'b1) ? 1'b1 : 1'b0 ) : (IRR[7]);
        end 
        else if (|clr) begin
            // Clears the interrupts asserted in clear and leaves others
            // unaffected
            IRR <= IRR & ~(clr);
        end
    end 

    /**
     Interrupt Service Register
    ------
    A bit asserted in this register means that the respective 
    interrupt must be serviced next.

    Usually only one bit of the bits will be asserted.
    **/
    always_ff @(posedge clk, negedge rst_n) begin 
        if (~rst_n)
            ISR <= {7{1'b0}};
        else
            ISR <= ISR_in;
    end 

endmodule 