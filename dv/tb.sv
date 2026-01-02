module tb;
icebreak_runner icebreak_runner();

localparam NumTests = 4;

initial begin
    $dumpfile("dump.fst");
    $dumpvars(0, tb);  // dump everything under tb
end

always begin
    $display( "Begin simulation." );
    $urandom(100);

    // repeat(3)@(negedge icebreak_runner.clk_i);
    @(negedge icebreak_runner.rst_i);

    repeat (NumTests) begin
        icebreak_runner.send_data();
        @(posedge icebreak_runner.s_tready);
        @(negedge icebreak_runner.clk_i);
        
    end

    // @(negedge icebreak_runner.m_tvalid);
    repeat(75000)@(negedge icebreak_runner.clk_i);
    // @(negedge icebreak_runner.uart_inst.sort_inst.read_valid_o);
    repeat(2)@(negedge icebreak_runner.clk_i);

    // repeat(50)@(negedge icebreak_runner.counting_sort_inst.clk_i);

    $display( "End simulation." );
    $finish;
end

endmodule