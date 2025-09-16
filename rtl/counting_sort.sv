`timescale 1ns / 1ps

module counting_sort 
#(
    parameter DATA_WIDTH = 5,
    parameter DATA_SIZE = 4,
    parameter MAX = 32
)(
    input   logic [0:0]                       clk_i,
    input   logic [0:0]                       rst_i,

    input   logic [0:0]                       write_valid_i,
    output  logic [0:0]                       write_ready_o,
    input   logic [DATA_WIDTH-1:0]            write_data_i,

    input   logic [0:0]                       read_ready_i,
    output  logic [0:0]                       read_valid_o,
    output  logic [DATA_WIDTH-1:0]            read_data_o
);

logic [DATA_WIDTH-1:0] IN    [DATA_SIZE];
logic [DATA_WIDTH-1:0] OUT   [DATA_SIZE];
logic [DATA_WIDTH-1:0] COUNT [MAX];



logic [1:0] state_d, state_q;
logic [$clog2(DATA_SIZE):0] addr_inc_d, addr_inc_q;

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= 0;
        addr_inc_q <= '0;
        addr_dec_q <= DATA_SIZE - 1;
        sum_q <= 1;
        read_valid_o <= 0;
        COUNT <= '{default: '0};
    end else begin
        state_q <= state_d;
        addr_inc_q <= addr_inc_d;
        addr_dec_q <= addr_dec_d;
        sum_q <= sum_d;
        read_valid_o <= read_valid_d;
        if (inc_en) COUNT[temp_l] <= COUNT[temp_l] + 1;
        else if (sum_ready) COUNT[sum_q] <= COUNT[sum_q] + COUNT[sum_q - 1];
        else if (dec_en) begin
            OUT[COUNT[IN[addr_dec_q]] - 1] <= IN[addr_dec_q];
            COUNT[IN[addr_dec_q]] <= COUNT[IN[addr_dec_q]] - 1;
        end
    end
end


logic [DATA_WIDTH-1:0] temp_l;
logic inc_en;
always_comb begin
    state_d = state_q; 
    write_ready_o = 0;
    addr_inc_d = addr_inc_q;
    temp_l = 0;
    inc_en = 0;

    case (state_q) 
        0 : begin
            write_ready_o = 1;
            state_d = 0;
            
            if (write_valid_i && write_ready_o) begin
                IN[addr_inc_q] = write_data_i;
                if (addr_inc_q == DATA_SIZE - 1) begin
                    addr_inc_d = '0;
                    state_d = 1;

                end else begin
                    addr_inc_d = addr_inc_q + 1;
                    write_ready_o = 0;
                    state_d = 0;

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
            if (read_valid_o) begin
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
logic read_valid_d;
logic [$clog2(DATA_SIZE):0] addr_dec_d, addr_dec_q;

always_comb begin
    dec_en = 0;
    addr_dec_d = addr_dec_q;
    read_valid_d = 0;
    if (state_q == 3) begin
        dec_en = 1;
        if (addr_dec_q == 0) begin
            dec_en = 1;
            addr_dec_d = DATA_SIZE - 1;
            read_valid_d = 1;

        end else begin
            dec_en = 1;
            addr_dec_d = addr_dec_q - 1;
        end
    end
end

endmodule


