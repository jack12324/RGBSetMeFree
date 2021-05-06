module CPU_interrupt_fsm (
    input clk,
    input rst_n,
    
    input INT,
    input [31:0] INT_INSTR,
    input [31:0] cpu_instr,

    input logic [31:0] current_PC, // the PC that is currently stored in the Fetch stage 
    input logic [31:0] current_LR, // Link regsiter currently in the Decode stage 
    input logic [1:0] current_FL, // Flag register currently in the decode stage 

    output logic ACK,

    // This inputs are stored when servicing an interrupt 
    output logic [31:0] PC_before_int,
    output logic [31:0] LR_before_int,
    output logic [1:0] FL_before_int,

    output logic use_INT_INSTR, // signal to use the injected instructions from the interrupt controller 
    output logic use_cpu_injection, // signal to use the injected instructions from this FSM 
    output logic [31:0] cpu_injection, // Injection from this state machine 

    output logic restore // signal to restore the special regs
    );

    parameter INSTR_NOOP = 32'h78000000;

    wire RIN;

    logic save; // signal to save the current special regs
    
    logic [2:0] counter; // counter for clears 

    // States for the control logic stae machine 
    typedef enum reg [2:0] {NORMAL_OPERATION, CLEAR_PIPELINE_INT, SAVE_REGS, ACK_INT, INJECTION, RESTORE_REGS, CLEAR_PIPELINE_RIN} state_t;
	state_t state, next_state;

    // State machine 
    always_comb begin

        // Set the default values to avoid latches
        next_state = NORMAL_OPERATION; 
        use_cpu_injection = 1'b0;
        use_INT_INSTR = 1'b0;
        cpu_injection = INSTR_NOOP;
        ACK = 1'b0;
        save = 1'b0;
        restore = 1'b0;

        case (state)
            
            // The COU fetches instructions normally 
            NORMAL_OPERATION : begin
                if (INT) 
                    next_state = CLEAR_PIPELINE_INT;
                else if (RIN)
                    next_state = CLEAR_PIPELINE_RIN;
            end 

            // This state machine injects 6 NoOps into the 
            // CPU pipeline to clear it              
            CLEAR_PIPELINE_INT : begin
                use_cpu_injection = 1'b1;
                if (counter == 3'b110) begin
                    next_state = SAVE_REGS;
                end
                else begin
                    next_state = CLEAR_PIPELINE_INT;
                end
            end 
            
            // The values of the special registers 
            // only one cycle
            SAVE_REGS : begin
                save = 1'b1;
                use_cpu_injection = 1'b1;
                next_state = ACK_INT;
            end 
            
            // Send acknowledge to the interrupt controller 
            ACK_INT : begin
                ACK = 1'b1;
                use_cpu_injection = 1'b1;
                next_state = INJECTION;
            end 

            // Interrupt controller injects instructions through INT_INSTR
            // here until the jump instruction 
            INJECTION : begin
                use_INT_INSTR = 1'b1;
                if (INT_INSTR[31:27] == 5'b10100)
                    next_state = NORMAL_OPERATION;
                else 
                    next_state = INJECTION;
            end
            
            // Restore the special registers afte the interrupt is serviced 
            RESTORE_REGS : begin
                restore = 1'b1;
                use_cpu_injection = 1'b1;
                next_state = NORMAL_OPERATION;
            end 
            
            // This state machine injects 6 NoOps into the 
            // CPU pipeline to clear it      
            CLEAR_PIPELINE_RIN : begin
                use_cpu_injection = 1'b1;                
                if (counter == 3'b110) begin
                    next_state = RESTORE_REGS;
                end
                else begin
                    next_state = CLEAR_PIPELINE_RIN;
                end

            end

        endcase
    end


    
    /**
    Interrupt logic Statem Machine Flip Flop
    ------
    This flip flop is used to clock synchronize the state machine
    in the control logic. (only update once a cycle)
    **/
    always_ff @(posedge clk, negedge rst_n) begin 
        if (~rst_n)
            state <= NORMAL_OPERATION;
        else 
            state <= next_state;
    end 

    /**
     Special Register Save Register
    ------
    **/
    always_ff @(posedge clk, negedge rst_n) begin 
        if (~rst_n) begin
            PC_before_int <= 32'h06002000; // this is where our instruction memory starts
            LR_before_int <= 32'h06002000; // this is where our instruction memory starts
            FL_before_int <= 2'b00; // no flags asserted
        end  
        else if (state == SAVE_REGS) begin  
            PC_before_int <= current_PC; 
            LR_before_int <= current_LR; 
            FL_before_int <= current_FL;
        end
    end 


    /**
    Counter for the NoOps 
    ------
    Used to count the cycles sending NoOps. 
    **/
    always @(posedge clk, negedge rst_n) begin 
        if (~rst_n)
            counter <= 3'b001;
        else 
            // Only count when the control logic is sending NoOps
            // starting at 1 so it noops 5 times
            counter <= (state == CLEAR_PIPELINE_RIN | state == CLEAR_PIPELINE_INT) ? ((counter == 3'b110) ? 3'b101 : (counter + 1'b1)) : 3'b001;
    end 

    assign RIN = cpu_instr[31:27] == 5'b11111 ? 1'b1 : 1'b0;

endmodule
