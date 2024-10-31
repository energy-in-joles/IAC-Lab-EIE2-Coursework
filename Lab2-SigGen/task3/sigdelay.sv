module sigdelay #(
        parameter   A_WIDTH = 9,
                    D_WIDTH = 8
)(
    input   logic   [D_WIDTH-1:0]   offset,
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   wr,
    input   logic                   rd,
    input   logic   [D_WIDTH-1:0]   mic_signal,
    output  logic   [D_WIDTH-1:0]   delayed_signal
);

    logic   [A_WIDTH-1:0]           address;

counter #(A_WIDTH) addrCounter(
    .clk (clk),
    .rst (rst),
    .count (address)
);

ram2ports #(A_WIDTH, D_WIDTH) audioRom (
    .clk (clk),
    .wr_en(wr),
    .rd_en(rd),
    .wr_addr (address),
    .rd_addr (address - offset),
    .din (mic_signal),
    .dout (delayed_signal)
);

endmodule
