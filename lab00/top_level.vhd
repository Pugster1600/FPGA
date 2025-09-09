----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/30/2025 02:02:23 PM
-- Design Name: 
-- Module Name: top_level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
--  Port ( );
    -- ======= 1. define ports for top_level ======
    port (
        buttonTopLevel : in std_logic;
        ledTopLevel : out std_logic
    );
end top_level;

architecture Behavioral of top_level is
    -- =========== 2. define signals
    -- =========== 3. define components to use inside of this entity
    -- remember that component is direct copy and paste from bufferGate 
    -- only change entity to component
    component bufferGate 
        port (
            button : in std_logic; 
            led : out std_logic
        );
    end component;
    
begin
    -- ========= component => signal / entity
    bufferInit : bufferGate
        port map(
            button => buttonTopLevel,
            led => ledTopLevel
        );
end Behavioral;
