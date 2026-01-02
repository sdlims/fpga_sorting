module icebreak_runner ();

localparam DATA_WIDTH = 8;
localparam DATA_SIZE = 4;

localparam ClockPeriod = 21.0526316ns;
localparam PRESCALE = 35;

logic clk_i, rst_i;
logic write_valid_i, read_ready_i;
logic [DATA_WIDTH-1:0] write_data_i;

// counting_sort #() 
// counting_sort_inst (
//     .clk_i,
//     .rst_i,
//     .write_valid_i,
//     .write_data_i,
//     .write_ready_o(),
//     .read_ready_i,
//     .read_valid_o(),
//     .read_data_o()
// );

logic [0:0] tready, m_tvalid;
logic [DATA_WIDTH - 1:0] rx_data_o;
uart_rx rx_inst(
    .clk(clk_i),
    .rst(rst_i),
    .m_axis_tdata(rx_data_o), //out
    .m_axis_tvalid(m_tvalid), //out
    .m_axis_tready(tready), //in
    .rxd(receive_rx),

    .busy(),
    .overrun_error(),
    .frame_error(),

    .prescale(PRESCALE)
);

// logic [DATA_WIDTH - 1:0] ;
logic [0:0] s_tvalid, s_tready;
uart_tx tx_inst(
    .clk(clk_i),
    .rst(rst_i),
    .s_axis_tdata(write_data_i), //in
    .s_axis_tvalid(s_tvalid), //in
    .s_axis_tready(s_tready), //out
    .txd(transmit_tx),

    .busy(),

    .prescale(PRESCALE)
);


logic [0:0] transmit_tx, receive_rx;
uart_comm uart_inst(
    .clk_i,
    .rst_i,

    .rx_i(transmit_tx),
    .tx_o(receive_rx)
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
    repeat(10)@(negedge clk_i);
    rst_i = 1'b0;
end

task automatic send_data;
    s_tvalid <= 1'b0;
    write_data_i <= '0;
    @(negedge clk_i);
    s_tvalid <= 1'b1;
    write_data_i <= $urandom_range(1, 9);
    @(negedge clk_i);
    s_tvalid <= 1'b0;
endtask

endmodule