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

    @(negedge icebreak_runner.rst_i);
    repeat (NumTests) begin
        icebreak_runner.send_data();
        
    end

    @(negedge icebreak_runner.counting_sort_inst.read_valid_o);
    repeat(2)@(negedge icebreak_runner.counting_sort_inst.clk_i);

    // repeat(50)@(negedge icebreak_runner.counting_sort_inst.clk_i);

    $display( "End simulation." );
    $finish;
end

endmodule