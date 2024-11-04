# Task 1: Simulating a basic 8-bit binary counter

We are first asked to create a new System Verilog file `counter.sv` and populate it with the code below:

```SystemVerilog
module counter #(
    parameter WIDTH = 8
)(
    // interface signals
    input   logic               clk,    // clock
    input   logic               rst,    // reset
    input   logic               en,     // counter enable
    output  logic   [WIDTH-1:0] count   // count output
);

always_ff @ (posedge clk)
    if (rst) count <= {WIDTH{1'b0}};
    else     count <= count + {{WIDTH-1{1'b0}}, en};
    // else statement counts upwards by concating a WIDTH - 1 of 0 bits to en
    // ie append 00000001 or 00000000 based on whether enable is HIGH
endmodule
```

The module created is a simple 8-bit binary counter that increments by 1 on each rising clock edge when `en` is high. This is done by cleverly concatenating a string of 0 bits of length `WIDTH-1`, in this case 7, to the enable bit.

It also **synchronously** resets to 0 when `rst` is asserted. Note that it is synchronous because `rst` is not added to the `always_ff` sensitivity list. If it was to be asynchronous, the logic would be changed to:
```SystemVerilog
always_ff @ (posedge clk, posedge rst)
```

A testbench file `counter_tb.cpp` is then added for us to interact with the module:
```C++
#include "Vcounter.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env) {
    int i;
    int clk;

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vcounter* top = new Vcounter;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("counter.vcd");

    // initialize simulation inputs
    top->clk = 1;
    top->rst = 1;
    top->en = 0;

    // run simulation for many clock cycles
    for (i=0; i<300; i++) {

        // dump variables into VCD file and toggle clock
        for (clk=0; clk<2; clk++) {
            tfp->dump (2*i+clk);
            top->clk = !top->clk;
            top->eval ();
        }
        top->rst = (i < 2) | (i == 15);
        top->en = (i > 4);
        if (Verilated::gotFinish()) exit(0);
    }
    tfp->close();
    exit(0);
}
```

The testbench annotations can be found in the lab brief for more detail about the testbench. The script essentially simulates clock cycles for the module, where it dumps the signal trace from the module into `counter.vcd` for us to analyse in GTKWave.

Additionally, we note that the program sets `rst` to HIGH on clock cycles 0 to 1 and at clock cycle 15. `en` is set to high after clock cycle 4.

```C++
top->rst = (i < 2) | (i == 15);
top->en = (i > 4);
```

With this in mind, we can analyse the generated GTKWave file:
![wave](img/wave.png)