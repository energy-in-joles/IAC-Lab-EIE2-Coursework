module f1_clktick #(
        parameter   N_WIDTH = 16
)(
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   en,
    input   logic [N_WIDTH-1:0]       N,
    output  logic [7:0]             dout
);

    logic tick;

clktick #(N_WIDTH) CLKTICK (
    .clk (clk),
    .rst (rst),
    .en (en),
    .N (N),
    .tick(tick)

);

f1_fsm F1_FSM (
    .rst(rst),
    .en(tick),
    .clk (clk),
    .data_out (dout)
);

endmodule
