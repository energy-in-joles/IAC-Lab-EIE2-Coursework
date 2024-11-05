# 4-bit LFSR and Pseudo Random Binary Sequence

In this task, we are interested in generating Pseudo Random Binary Sequence (PRBS) using linear feedback shift registers (LFSR). In this example, we are interested in building a four bit sequence, where we require 4 contigous registers.

Instead of designing individual register modules, we can create a logic variable `sreg` of size 4 to represent the LFSR values. We then follow the primitive polynomial of $1 + X^3 + X^4$ to design the module:

```SystemVerilog
module lfsr(
    input   logic       clk,
    input   logic       rst,
    input   logic       en,
    output  logic [3:0] data_out
);

    logic [4:1] sreg;

    always_ff @ (posedge clk, posedge rst)
        if (rst)
            sreg <= 4'b1;
        else if (en)
            sreg <= {sreg[3:1], sreg[4] ^ sreg[3]};

    assign data_out = sreg;
endmodule
```

As we can see, the value of `sreg` changes each cycle, by shifting the bits down by 1, filling bit 1 (LSB) with the XOR result of bit 3 and bit 4, and finally dropping bit 4.

In this case, we build the module with an asynchronous reset by adding it to the sensitivity list of `always_ff`.

To test the module, we run a testbench script that runs GTest on our module.

Taking a look at the testbench file, we see that the testbench essentially compares our values with the groundtruth PRBS to test if our module is compliant:

```C++
TEST_F(TestDut, SequenceTest)
{
    std::vector<int> expected = {
        0b0001,
        0b0010,
        0b0100,
        0b1001,
        0b0011,
        0b0110,
        0b1101,
        0b1010,
        0b0101,
        0b1011,
        0b0111,
        0b1111,
        0b1110,
        0b1100,
        0b1000,
        0b0001};

    for (int exp : expected)
    {
        EXPECT_EQ(top->data_out, exp);
        runSimulation();
    }
}
```

As seen below, our test runs as expected:

```bash
[==========] Running 3 tests from 1 test suite.
[----------] Global test environment set-up.
[----------] 3 tests from TestDut
[ RUN      ] TestDut.InitialStateTest
[       OK ] TestDut.InitialStateTest (0 ms)
[ RUN      ] TestDut.SequenceTestMini
[       OK ] TestDut.SequenceTestMini (0 ms)
[ RUN      ] TestDut.SequenceTest
[       OK ] TestDut.SequenceTest (0 ms)
[----------] 3 tests from TestDut (0 ms total)

[----------] Global test environment tear-down
[==========] 3 tests from 1 test suite ran. (0 ms total)
[  PASSED  ] 3 tests.
```

### Test Yourself Challenge

For our challenge, we are asked to design a `lfsr_7.sv` module to generate a 7-bit PRBS. We are given the 7th order primitive polynomial as $1 + X^3 + X^7$.

This works similar to our 4-bit PRBS generator. In this case, however, after shifting the bits down by 1, we fill bit 1 (LSB) with the XOR result of bit 7 and bit 3, before dropping bit 7:

```SystemVerilog
module lfsr_7 (
    input   logic       clk,
    input   logic       rst,
    input   logic       en,
    output  logic [6:0] data_out
);
    logic [7:1] sreg;

    always_ff @ (posedge clk, posedge rst)
        if (rst)
            sreg <= 7'b1;
        else if (en)
            sreg <= {sreg[6:1], sreg[7] ^ sreg[3]};

    assign data_out = sreg;
endmodule
```

On running the new testbench `verify_7.cpp` on the module, we find that we also pass the GTest provided!