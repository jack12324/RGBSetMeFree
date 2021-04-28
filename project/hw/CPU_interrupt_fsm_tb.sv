module CPU_interrupt_fsm_tb();

    logic clk;
    logic rst_n;

    logic INT;
    logic [31:0] INT_INSTR;
    logic [31:0] cpu_instr;

    logic [31:0] current_PC; // the PC that is currently stored in the Fetch stage 
    logic [31:0] curretn_LR; // Link regsiter currently in the Decode stage 
    logic [1:0] current_FL; // Flag register currently in the decode stage 

    logic ACK;

// This s are stored when servicing an interrupt 
    logic [31:0] PC_before_int;
    logic [31:0] LR_before_int;
    logic [1:0] FL_before_int;

    logic use_INT_INSTR; // signal to use the injected instructions from the interrupt controller 
    logic use_cpu_injection; // signal to use the injected instructions from this FSM 
    logic [31:0] cpu_injection; // Injection from this state machine 

    logic restore; // signal to restore the special regs

    CPU_interrupt_fsm iDUT(
        clk,
        rst_n,
        INT,
        INT_INSTR,
        cpu_instr,
        current_PC, // the PC that is currently stored in the Fetch stage 
        curretn_LR, // Link regsiter currently in the Decode stage 
        current_FL, // Flag register currently in the decode stage 
        ACK,
        // This inputs are stored when servicing an interrupt 
        PC_before_int,
        LR_before_int,
        FL_before_int,
        use_INT_INSTR, // signal to use the injected instructions from the interrupt controller 
        use_cpu_injection, // signal to use the injected instructions from this FSM 
        cpu_injection, // Injection from this state machine 
        restore // signal to restore the special regs
    );


    initial begin
        clk = 1;
        rst_n = 0;
        INT = 0;
        INT_INSTR = 32'hA0000002;
        cpu_instr = 32'h00000000;
        current_PC = 32'hAAAA0000;
        curretn_LR= 32'h11111111;
        current_FL = 2'b01; 
        
        @(posedge clk);
        @(posedge clk);
        rst_n = 1;

        @(posedge clk);
        INT = 1;

        @(posedge clk);
        INT = 0;
        cpu_instr = 32'hF8000000;

        repeat (25) begin 
            @(posedge clk);
            if (restore) cpu_instr = 32'h00000000;
        end 

        $stop();
    end


    always #5 assign clk = ~clk;

endmodule