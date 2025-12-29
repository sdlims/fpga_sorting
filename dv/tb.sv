module tb;
icebreak_runner icebreak_runner();

localparam NumTests = 4;

always begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);

    @(negedge icebreak_runner.rst_i);
    repeat (NumTests) begin
        // $display("Sending Data");
        icebreak_runner.send_data();
        // $display("State: %0d", icebreak_runner.counting_sort_inst.state_q);
    end
    // $display("\n");
    // $display("State: %0d", icebreak_runner.counting_sort_inst.state_q);
    // $display("Read Valid: %0d", icebreak_runner.counting_sort_inst.read_valid_o);
    // $display("read_o: %0d", icebreak_runner.counting_sort_inst.read_o);
    // $display("out_addr: %0d", icebreak_runner.counting_sort_inst.out_addr_q);

    // $display("\n State 1 ");
    // while (icebreak_runner.counting_sort_inst.state_q == 1) begin
    //     $display("Addr Inc: %0d", icebreak_runner.counting_sort_inst.addr_inc_q);
    // end
    @(negedge icebreak_runner.counting_sort_inst.read_valid_o);

    // repeat(50)@(negedge icebreak_runner.counting_sort_inst.clk_i);

    $display( "End simulation." );
    $finish;
end

endmodule