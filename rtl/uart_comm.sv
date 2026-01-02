module uart_comm (
    input clk_i,
    input rst_i,

    input rx_i,
    output tx_o
);
// Control Signals for ready and valid
// write_valid_i == 1 iff write_addr != DATA_SIZE
    // write_addr resets when negedge of read_valid_o
// read_ready_i == 1 basically if not write_valid_i

localparam DATA_SIZE = 4;
localparam DATA_WIDTH = 8;
localparam PRESCALE = 35;

logic [DATA_WIDTH - 1:0] write_data_i;

logic [1:0] state_d, state_q;

logic [0:0] write_valid_i, read_ready_i;
logic [0:0] read_valid_o, write_ready_o;
logic [DATA_WIDTH - 1:0] sort_data_o;
counting_sort sort_inst(
    .clk_i,
    .rst_i,
    .write_valid_i,
    .write_ready_o,
    .write_data_i(rx_data_o),
    .write_done_i(rx_valid_o),
    .read_ready_i,
    .read_valid_o(read_valid_o),
    .read_done_i((!tx_busy_d && tx_busy_q)),
    .read_data_o(sort_data_o)
);

logic [0:0] rx_valid_o;
logic [DATA_WIDTH - 1:0] rx_data_o;
uart_rx rx_inst(
    .clk(clk_i),
    .rst(rst_i),
    .m_axis_tdata(rx_data_o), //out
    .m_axis_tvalid(rx_valid_o), //out
    .m_axis_tready(write_ready_o), //in
    .rxd(rx_i),

    .busy(),
    .overrun_error(),
    .frame_error(),

    .prescale(PRESCALE)
);

logic [0:0] tx_ready_o, tx_busy_d, tx_busy_q;
uart_tx tx_inst(
    .clk(clk_i),
    .rst(rst_i),
    .s_axis_tdata(sort_data_o), //in
    .s_axis_tvalid(!tx_busy_q), //in
    .s_axis_tready(tx_ready_o), //out
    .txd(tx_o),

    .busy(tx_busy_d),

    .prescale(PRESCALE)
);

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        tx_busy_q <= 1'b0;
    end else begin
        tx_busy_q <= tx_busy_d;
    end
end

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= 2'b00;
    end else begin
        state_q <= state_d;
    end
end

logic [$clog2(DATA_SIZE):0] addr_d, addr_q;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        addr_q <= '0;
    end else begin
        addr_q <= addr_d;
    end
end

always_comb begin
    state_d = state_q;
    addr_d = addr_q;

    write_valid_i = 1'b0;
    read_ready_i = 1'b0;

    case (state_q)
        0 : begin
            state_d = 2'b00;
            if (addr_q == DATA_SIZE - 1) begin
                state_d = 2'b01;
            end else if (rx_valid_o && (addr_q != DATA_SIZE - 1)) begin
                write_valid_i = 1'b1;
                addr_d = addr_q + 1;
            end
        end

        1 : begin
            state_d = 2'b01;
            read_ready_i = 1'b1;
            if (addr_q == 0) begin
                read_ready_i = 1'b0;
                state_d = 2'b00;
            end else if ((!tx_busy_d && tx_busy_q) && (addr_q != 0)) begin
                addr_d = addr_q - 1;
            end
        end

        2 : begin
            ;
        end

        3 : begin
            ;
        end
    endcase
end

endmodule