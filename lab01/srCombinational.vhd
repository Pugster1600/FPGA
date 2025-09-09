library IEEE;
use IEEE.std_logic_1164.all;

entity srCombinational is
    port (
        nS: in std_logic;
        nR: in std_logic;
        Q: out std_logic
    );
end srCombinational;

architecture combinational of srCombinational is
    signal q_i: std_logic;          
    signal nq_i: std_logic;         
    begin                           
        -- literally define the wire
        Q<=q_i;                     
        q_i<=(not nq_i) or (not nS);
        nq_i<=(not q_i) or (not nR);
end combinational;