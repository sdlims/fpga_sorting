`timescale 1ns / 1ps
// Could be optimized as we should be overwritting IN data. Send IN to RAM, overwrite later
module counting_sort 
#(
    parameter DATA_WIDTH = 8,
    parameter DATA_SIZE = 4,
    parameter MAX = 16 // equal to 1 << DATA_SIZE
)(
    input   logic [0:0]                       clk_i,
    input   logic [0:0]                       rst_i,

    input   logic [0:0]                       write_valid_i,
    output  logic [0:0]                       write_ready_o,
    input   logic [0:0]                       write_done_i,
    input   logic [DATA_WIDTH-1:0]            write_data_i,

    input   logic [0:0]                       read_ready_i,
    output  logic [0:0]                       read_valid_o,
    input   logic [0:0]                       read_done_i,
    output  logic [DATA_WIDTH-1:0]            read_data_o
);

logic [DATA_WIDTH-1:0] IN    [DATA_SIZE];
// logic [DATA_WIDTH-1:0] OUT   [DATA_SIZE];
logic [DATA_WIDTH-1:0] COUNT [MAX];


logic [1:0] state_d, state_q;
logic [$clog2(DATA_SIZE):0] addr_inc_d, addr_inc_q;


  ram_1r1w_sync #(.width_p(DATA_WIDTH), .depth_p(1 << DATA_SIZE)) 
  ram_inst 
  (.clk_i(clk_i), 
  .reset_i(rst_i), 
  .wr_valid_i(dec_en), 
  .wr_data_i(IN[addr_dec_q]), 
  .wr_addr_i(COUNT[IN[addr_dec_q]] - 1), 
  .rd_valid_i(read_o), 
  .rd_addr_i(out_addr_q), 
  .rd_data_o(read_data_o)
  );


always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= 0;
        addr_inc_q <= '0;
        addr_dec_q <= DATA_SIZE - 1;
        sum_q <= 1;
        for (int i = 0; i < MAX; i++)
            COUNT[i] <= '0;
    end else begin
        state_q <= state_d;
        addr_inc_q <= addr_inc_d;
        addr_dec_q <= addr_dec_d;
        sum_q <= sum_d;
        // if (state_q == 0 && write_valid_i && write_ready_o) IN[addr_inc_q] <= write_data_i;
        if (state_q == 0) IN[addr_inc_q] <= write_data_i;
        if (inc_en) COUNT[temp_l] <= COUNT[temp_l] + 1;
        else if (sum_ready) COUNT[sum_q] <= COUNT[sum_q] + COUNT[sum_q - 1];
        else if (dec_en) begin
            // OUT[COUNT[IN[addr_dec_q]] - 1] <= IN[addr_dec_q];
            COUNT[IN[addr_dec_q]] <= COUNT[IN[addr_dec_q]] - 1;
        end
    end
end

logic [0:0] read_o, read_en, read_val;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        read_o <= 1'b0;
    end else if (read_en) begin
        read_o <= read_val;
    end
end

logic [$clog2(DATA_SIZE):0] out_addr_q, out_addr_d;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        out_addr_q <= '0;
    end else if (state_q == 0) begin
        out_addr_q <= out_addr_d;
    end
end

always_comb begin
    read_en = 1'b0;
    read_val = 1'b0;

    if ((state_q == 0) && (out_addr_q == DATA_SIZE-1)) begin
        read_en = 1'b1;
        read_val = 1'b0;
    end else if ((state_q == 3) && addr_dec_q == 0) begin
        read_en = 1'b1;
        read_val = 1'b1;
    end
end

logic [DATA_WIDTH-1:0] temp_l;
logic [0:0] inc_en;
always_comb begin
    state_d = state_q; 
    write_ready_o = 0;
    out_addr_d = out_addr_q;
    addr_inc_d = addr_inc_q;
    temp_l = 0;
    inc_en = 0;

    // read_data_o = '0;

    case (state_q) 
        0 : begin
            write_ready_o = 1;
            state_d = 0;
            if (read_o) begin
                if (out_addr_q == DATA_SIZE) begin
                    out_addr_d = '0;
                    // read_data_o = '0;
                end else if (read_done_i) begin
                    // read_data_o = OUT[out_addr_q];
                    out_addr_d = out_addr_q + 1;
                end
            end
            else begin
                if (write_valid_i && write_ready_o) begin
                    addr_inc_d = addr_inc_q + 1;
                    state_d = 0;
                end else if ((addr_inc_q == DATA_SIZE - 1) && write_done_i) begin
                    write_ready_o = 0;
                    addr_inc_d = '0;
                    state_d = 1;
                end
            end
        end
        
        1 : begin
            state_d = 1;
            if (addr_inc_q == DATA_SIZE) begin
                addr_inc_d = DATA_SIZE - 1;
                state_d = 2;

            end else begin
                inc_en = 1;
                temp_l = IN[addr_inc_q];
                addr_inc_d = addr_inc_q + 1; 
                state_d = 1;

            end
        end

        2 : begin
            state_d = 2;
            if (sum_valid) state_d = 3;
            else state_d = 2;
        end 

        3 : begin
            state_d = 3;
            if (addr_dec_q == 0) begin
                state_d = 0;
            end
        end
        
        default : ;
    endcase
end


// STATE 2 LOGIC =====================
logic sum_valid, sum_ready;
logic [$clog2(MAX):0] sum_d, sum_q;
always_comb begin
    sum_d = sum_q;
    sum_valid = 0;
    sum_ready = 0;
    if (state_q == 2) begin
        sum_ready = 1;
        if (sum_q != MAX - 1) begin
            sum_d = sum_q + 1;

        end else begin
            sum_d = 1;
            sum_valid = 1;

        end
    end
end

// STATE 3 LOGIC ====================
logic dec_en;
logic [$clog2(DATA_SIZE):0] addr_dec_d, addr_dec_q;

always_comb begin
    dec_en = 0;
    addr_dec_d = addr_dec_q;
    if (state_q == 3) begin
        dec_en = 1;
        if (addr_dec_q == 0) begin
            dec_en = 1;
            addr_dec_d = DATA_SIZE - 1;

        end else begin
            dec_en = 1;
            addr_dec_d = addr_dec_q - 1;
        end
    end
end

endmodule


