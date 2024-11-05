# Task 2: Sine and Cosine Dual Wave Generation

We are instructed to generate two simultaneous sinusoid signals with different phases, where the phase offset is determined by the rotary encoder on Vbuddy.

We are told to use a dual-port ROM to achieve this.

Following the example in the lecture slides, we write the following module for our dual-port rom:
```SystemVerilog
module rom2ports #(
    parameter    ADDRESS_WIDTH = 8,
                DATA_WIDTH = 8
)(
    input logic                             clk,
    input logic     [ADDRESS_WIDTH-1:0]     addr1,
    input logic     [ADDRESS_WIDTH-1:0]     addr2,
    output logic    [DATA_WIDTH-1:0]        dout1,
    output logic    [DATA_WIDTH-1:0]        dout2
);

logic   [DATA_WIDTH-1:0] rom_array  [2**ADDRESS_WIDTH-1:0];

initial begin
        $display("Loading rom.");
        $readmemh("sinerom.mem", rom_array);
end;

always_ff @(posedge clk)
    begin
    dout1 <= rom_array [addr1];
    dout2 <= rom_array [addr2];
    end
    
endmodule
```

We observe that we have two addresses and two output variables. This way we can receive the stored data values in two addresses in one clock cycle. 

We edit the "top-level" `sinegen` module to work with the new dual-port rom and to also include an input `offset`. This offset allows us to dictate the phase offset by offsetting the address value from one wave to another. This `offset` input can then be assigned to Vbuddy's rotary encoder value for us to adjust the offset with the rotary encoder.

```SystemVerilog
module sinegen #(
        parameter   A_WIDTH = 8,
                    D_WIDTH = 8
)(
    input   logic                   clk,
    input   logic                   rst,
    input   logic   [A_WIDTH-1:0]   offset, // include a new input offset
    input   logic                   en,
    input   logic   [D_WIDTH-1:0]   incr,
    output  logic   [D_WIDTH-1:0]   dout1,
    output  logic   [D_WIDTH-1:0]   dout2
);

    logic   [A_WIDTH-1:0]           address;

counter addrCounter(
    .clk (clk),
    .rst (rst),
    .en (en),
    .incr (incr),
    .count (address)
);

rom2ports sineRom ( // 
    .clk (clk),
    .addr1 (address),
    .addr2 (address - offset), // offset the address of wave2 by "offset"
    .dout1 (dout1),
    .dout2 (dout2)
);

endmodule
```

We then adjust our testbench to assign the new module input `offset` to `vbdValue()` in the main for loop:

```C++
top->offset = vbdValue();
```

Finally, we recompile and run the program:

![two_waves](../images/two_waves.gif)

As seen in the gif, when the rotary encoder is set at 64 offset, we observe the waves to be 90 degrees out of phase as expected. When I turn the rotary encoder, we observe the change in phase offset as well.