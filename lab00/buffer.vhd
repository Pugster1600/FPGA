--=========1. includes==============
library IEEE;
use IEEE.std_logic_1164.all;

--=========2. entity defintion=======
--this defines the IO aka black box
entity bufferGate is 
    port (
        button : in std_logic; --default 0 with std_logic := '0' BUT not in entity only in testbenc
        led : out std_logic
    );
end bufferGate;

--=========3. architecture definition====
--defines what is going on in the black box
architecture behavior of bufferGate is 
begin
    led <= button;
end behavior;
