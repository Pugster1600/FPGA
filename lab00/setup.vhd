--This file is the vhdl code NOT the test bench

library IEEE;
use IEEE.std_logic_1164.all;

-- 1. Entity: defines the interface
-- NOTE: Entity is everything facing the outside world
-- Think of this as the black box
-- defines input and output
-- like it defines what an adder is
entity andGateArbName is
    port( --port just says these are the pins
        A: in std_logic; -- input var A -> can set deafult with A : in std_logc := '0';
        B: in std_logic; -- input var B
        Y: out std_logic -- output var Y
    );
end andGateArbName;

-- Architecture: defines the logic
-- NOTE: this is everything internal NOT facing the outside world
-- it says how do we implement the adder
-- so ripple carry vs carry look ahead
architecture andGateArbNameArch of andGateArbName is
    --signal and component between architecture
    --signal definitions
    --components within the architecture
    --look at the setup_tb.vhd file
begin
    Y <= A and B; -- <= is signal assign, so we are saying Y = A * B
end andGateArbNameArch;

--/*
--we can defined constraints
--they basically say hey this signal is from/going elsewhere
--like the signal is from say IO
--*/