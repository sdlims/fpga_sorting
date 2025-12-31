module icebreak_runner ();

localparam DATA_WIDTH = 8;
localparam DATA_SIZE = 4;

localparam ClockPeriod = 21.0526316ns;

logic clk_i, rst_i;
logic write_valid_i, read_ready_i;
logic [DATA_WIDTH-1:0] write_data_i;

counting_sort #() 
counting_sort_inst (
    .clk_i,
    .rst_i,
    .write_valid_i,
    .write_data_i,
    .write_ready_o(),
    .read_ready_i,
    .read_valid_o(),
    .read_data_o()
);

initial begin
    clk_i = 1'b0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

initial begin
    rst_i = 1'b1;
    @(negedge clk_i);
    @(negedge clk_i);
    rst_i = 1'b0;
end

task automatic send_data;
    write_valid_i <= 1'b0;
    write_data_i <= '0;
    @(negedge clk_i);
    write_valid_i <= 1'b1;
    write_data_i <= $urandom_range(1, 9);
    @(negedge clk_i);
    write_valid_i <= 1'b0;
endtask

endmodule