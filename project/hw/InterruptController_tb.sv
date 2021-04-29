module InterruptController_tb();

    /**
    Instructions to where the interrupt service routines 
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
    parameter INSTR_NOOP = 32'h78000000;

    // inputs to iDUT 
    reg clk; // System clock 
    reg rst_n; // Active low reset   

    reg ACK; // Interrupt Acknowledge signal from the CPU 
    reg [7:0] IO; // IO request signals. Direct connection to IO device. Connect all unused bits to GND (0)
    reg [7:0] IMR_in; // input to the IMR register. If unused, connect to VCC (1)

    // outputs to iDUT
    reg INT; // Interrupt service request signal to the CPU
    reg [31:0] INT_INSTR; // Used to inject Instructions into the CPU pipeline 

    integer errors; // error count. should be 0 to pass all tests
    
    reg[32:0] expected_jump; // explected jump istruction for the io device 

    // initialize interrupt controller 
    InterruptController iDUT(.clk(clk), .rst_n(rst_n), .IO(IO), .ACK(ACK), .INT(INT), .INT_INSTR(INT_INSTR), .IMR_in(IMR_in)); 

    initial begin 
        clk = 1;
		rst_n = 0;
        ACK = 0;
        IO = 7'b0000000;
        IMR_in = 8'b11111111;
        errors = 0; 

        // wait 2 clk cycles to de-assert the rst
        @(negedge clk);

        // check that the rst work

        @(negedge clk);
        @(negedge clk);
        rst_n = 1;

        // Run through all of the dirrent IO devices and check that the 
        // Instruction sent is correct 

        //////////////////////////////// IO Device TEST //////////////////////////////////
        for (int i=0; i<8; i=i+1) begin

            @(negedge clk);
            IO = 8'b0000001<<i;

            // set expected jump 
                case (IO)
                    8'b00000001 : expected_jump = INSTR_IO_0;
                    8'b00000010 : expected_jump = INSTR_IO_1;
                    8'b00000100 : expected_jump = INSTR_IO_2;
                    8'b00001000 : expected_jump = INSTR_IO_3;
                    8'b00010000 : expected_jump = INSTR_IO_4;
                    8'b00100000 : expected_jump = INSTR_IO_5;
                    8'b01000000 : expected_jump = INSTR_IO_6;
                    8'b10000000 : expected_jump = INSTR_IO_7;
                endcase


            @(negedge clk);
            IO = 7'b0000000;

            @(negedge clk);
            
            @(posedge clk);
            @(negedge clk);
            // The Interrupt controller should have asserted the INT signal
            if (~INT) begin 
                errors++;
                $display ("ERROR: INT signal expected to be asserted.");
            end 

            // Simulate sending an ACK signal to be 
            ACK = 1;
            @(posedge clk);
            ACK = 0;

            // Check each of the instructions int eh setup sequence
            // NoOp x5
            // Proper jump instruction
            if (INT_INSTR != INSTR_NOOP) begin 
                errors++;
                $display ("ERROR: Missed Noop 1 for device %d.", i);
            end 

            @(negedge clk);
            @(posedge clk);
            if (INT_INSTR != INSTR_NOOP) begin 
                errors++;
                $display ("ERROR: Missed Noop 2 for device %d.", i);
            end 

            @(negedge clk);
            @(posedge clk);
            if (INT_INSTR != INSTR_NOOP) begin 
                errors++;
                $display ("ERROR: Missed Noop 3 for device %d.", i);
            end 

            @(negedge clk);
            @(posedge clk);
            if (INT_INSTR != INSTR_NOOP) begin 
                errors++;
                $display ("ERROR: Missed Noop 4 for device %d.", i);
            end 

            @(negedge clk);
            @(posedge clk);
            if (INT_INSTR != INSTR_NOOP) begin 
                errors++;
                $display ("ERROR: Missed Noop 5 for device %d.", i);
            end 

            @(negedge clk);
            @(posedge clk);
            @(negedge clk);
            if (INT_INSTR != expected_jump) begin 
                errors++;
                $display ("ERROR: Wrong jump instruction for device %d. Expected %h, but got %h.", i, expected_jump, INT_INSTR);
            end 


            // Send ACK to clear Interrupt
            @(negedge clk);
            ACK = 1;

            @(negedge clk);
            @(negedge clk);
            @(negedge clk);
            @(posedge clk);
            // Int should've been cleared 
            if (INT) begin 
                errors++;
                $display ("ERROR: INT signal expected to be Low after interrupt is cleared.");
            end 
        end
        ////////////////////////////////////////////////////////////////////////////////


        ///////////////////////////////// PRIORITY TESTING ///////////////////////////////
        // Pass through the ammount of cycles necesarry 
        @(negedge clk);
        IO = 8'b0010101;
        expected_jump = INSTR_IO_0;
        @(negedge clk);
        IO = 7'b0000000;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        // The Interrupt controller should have asserted the INT signal
        if (~INT) begin 
            errors++;
            $display ("ERROR: INT signal expected to be asserted.");
        end 
        // Simulate sending an ACK signal to be 
        ACK = 1;
        @(posedge clk);
        ACK = 0;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        if (INT_INSTR != expected_jump) begin 
            errors++;
            $display ("ERROR: Wrong jump instruction. Expected %h, but got %h.", expected_jump, INT_INSTR);
        end 
        // Send ACK to clear Interrupt
        @(negedge clk);
        ACK = 1;
        @(negedge clk);
        @(negedge clk);

        // -------------- Second priority 
         expected_jump = INSTR_IO_2;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        // The Interrupt controller should have asserted the INT signal
        if (~INT) begin 
            errors++;
            $display ("ERROR: INT signal expected to be asserted.");
        end 
        // Simulate sending an ACK signal to be 
        ACK = 1;
        @(posedge clk);
        ACK = 0;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        if (INT_INSTR != expected_jump) begin 
            errors++;
            $display ("ERROR: Wrong jump instruction. Expected %h, but got %h.", expected_jump, INT_INSTR);
        end 
        // Send ACK to clear Interrupt
        @(negedge clk);
        ACK = 1;
        @(negedge clk);
        @(negedge clk);

        // -------------- Third Priority 
        expected_jump = INSTR_IO_4;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        // The Interrupt controller should have asserted the INT signal
        if (~INT) begin 
            errors++;
            $display ("ERROR: INT signal expected to be asserted.");
        end 
        // Simulate sending an ACK signal to be 
        ACK = 1;
        @(posedge clk);
        ACK = 0;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        if (INT_INSTR != expected_jump) begin 
            errors++;
            $display ("ERROR: Wrong jump instruction. Expected %h, but got %h.", expected_jump, INT_INSTR);
        end 
        // Send ACK to clear Interrupt
        @(negedge clk);
        ACK = 1;
        @(negedge clk);
        @(negedge clk);
        //////////////////////////////////////////////////////////////////////////////////

        //////////////////////////////// Test Masking ///////////////////////////////////
        IMR_in = 8'b11111110;
        @(negedge clk);
        IO = 8'b0000001;
        expected_jump = INSTR_IO_0;
        @(negedge clk);
        IO = 7'b0000000;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        // The Interrupt controller should have asserted the INT signal
        if (INT) begin 
            errors++;
            $display ("ERROR: INT signal expected to not be asserted for masked interrupt request.");
        end 
        // Simulate sending an ACK signal to be 
        ACK = 1;
        @(posedge clk);
        ACK = 0;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        if (INT_INSTR == expected_jump) begin 
            errors++;
            $display ("ERROR: Masked interrupt executed. Instr given %h.", INT_INSTR);
        end 
        // Send ACK to clear Interrupt
        @(negedge clk);
        ACK = 1;
        @(negedge clk);
        @(negedge clk);
        /////////////////////////////////////////////////////////////////////////////////

        if (errors == 0) begin
            $display("Yahoo! Test passed");
	        $stop();
        end
        else begin
            $display("Big sad, try again. Errors: %d.", errors);
	        $stop();
        end
        


    end

    // system clock
    always #5 clk = ~clk;
endmodule