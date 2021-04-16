// Addresses for routines 

module InterruptController(clk, rst_n, IO, ACK, INT, INT_INSTR, IMR_in);

    /**
    Addresses to where the interrupt service routines 
    are stored. Used to send jump instructions.

    All ISRs are 0.5KB at the most (about 100 instructions)

    First ISR is at 16'h0000
    Second is at    16'h
    **/
    parameter INSTR_IO_0 = 32'hA0000000; 
    parameter INSTR_IO_1 = 32'hA0000002; 
    parameter INSTR_IO_2 = 32'hA0000004; 
    parameter INSTR_IO_3 = 32'hA0000006; 
    parameter INSTR_IO_4 = 32'hA0000008; 
    parameter INSTR_IO_5 = 32'hA000000A; 
    parameter INSTR_IO_6 = 32'hA000000C; 
    parameter INSTR_IO_7 = 32'hA000000E; 
    parameter INSTR_NOOP = 32'h00000000;

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

    // States for the control logic stae machine 
    typedef enum reg [2:0] {IDLE, SERV_REQ, NOOPS, INSTR, WAIT, CLR} state_t;
	state_t state, next_state;

    reg [2:0] counter; // Counter for the NoOps to be sent out to the CPU

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

    State Descriptions:
    - IDLE: Waiting for an interrupt request 
    - SERV_REQ: Interrupt request has been received and 
                need to assert the INT signal to CPU
    - NOOPS: Sending 5 NoOps to flush the pipeline 
    - INSTR: Sending jump instruction to CPU
    - WAIT: Waiting for CPU to execute the service routine 
    - CLR: Clear interrupt request 
    */
    always_comb begin
        // Setting the default values to avoid infered latches 
        INT = 1'b0;
        next_state = IDLE;
        INT_INSTR = INSTR_NOOP;
        clr = 8'b0000000;

        case (state) 

            // Update to ISR: IDLE --> SERV_REQ
            IDLE : begin
                if (|ISR) begin 
                    next_state = SERV_REQ;
                end
            end

            // ACK == 0: SERV_REQ --> SERV_REQ 
            // ACK == 1: SERV_REQ --> NOOPS 
            SERV_REQ : begin
               INT = 1'b1;

               if (ACK == 1'b0) begin
                   next_state = SERV_REQ;
               end 
               else begin 
                   next_state = SERV_REQ;
               end 
            end

            // Have sent 5 Cycles of NoOps: NOOPS --> INSTR
            // Less than five NoOps sent:   NOOPS --> NOOPS
            NOOPS : begin
                INT_INSTR = INSTR_NOOP;
                if (counter == 3'b101) begin
                    INT_INSTR = INSTR_NOOP;
                end
                else begin
                    next_state = NOOPS;
                end
            end

            // Unconsitional transition after 1 cycle: INSTR --> WAIT
            INSTR : begin
                next_state = WAIT;
                clr = ISR;
                
            end

            // ACK == 0: WAIT --> WAIT 
            // ACK == 1: WAIT --> CLR 
            WAIT : begin
                if (ACK == 1'b0) begin
                   next_state = WAIT;
               end 
               else begin 
                   next_state = CLR;
               end 
            end

            // Unconsitional transition after 1 cycle: CLR --> IDLE
            CLR : begin
                next_state = WAIT;

                case (ISR)
                    8'b00000001 : INT_INSTR = INSTR_IO_0;
                    8'b00000010 : INT_INSTR = INSTR_IO_1;
                    8'b00000100 : INT_INSTR = INSTR_IO_2;
                    8'b00001000 : INT_INSTR = INSTR_IO_3;
                    8'b00010000 : INT_INSTR = INSTR_IO_4;
                    8'b00100000 : INT_INSTR = INSTR_IO_5;
                    8'b01000000 : INT_INSTR = INSTR_IO_6;
                    8'b10000000 : INT_INSTR = INSTR_IO_7;
                endcase
            end

        endcase

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

    /**
    Control logic Statem Machine Flip Flop
    ------
    This flip flop is used to clock synchronize the state machine
    in the control logic. (only update once a cycle)
    **/
    always_ff @(posedge clk, negedge rst_n) begin 
        if (~rst_n)
            state <= IDLE;
        else 
            state <= next_state;
    end 

    /**
    Counter for the NoOps 
    ------
    Used to count the cycles sending NoOps. 
    Counter won't go over 5 and it will only count when in the NOOP state.
    **/
    always @(posedge clk, negedge rst_n) begin 
        if (~rst_n)
            counter <= 3'b000;
        else 
            // Only count when the control logic is sending NoOps
            counter <= (state == NOOPS) ? ((counter == 3'b101) ? 3'b101 : (counter + 1'b1)) : 3'b000;
    end 

endmodule 