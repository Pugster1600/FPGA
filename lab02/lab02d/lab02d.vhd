library IEEE;
use IEEE.std_logic_1164.all;

entity lab02d is
  port (
    clk : in std_logic;
    btn : in STD_LOGIC_VECTOR(1 downto 0);
    led : out STD_LOGIC_VECTOR(1 downto 0)
  );
end lab02d;

architecture arch of lab02d is
  -- component declaration
  component bcounter is
    generic (
      NBITS : natural
    );
    port (
      clk: in std_logic;-- Clock input
      rst: in std_logic;-- Asynchronouse reset
      cin: in std_logic;-- Carry-in and run control
      cout: out std_logic;-- Carry-out for cascading
      bits: out std_logic_vector(NBITS-1 downto 0)
    );
  end component;

  component dffar is
    port (
      D: in  std_logic; -- Data input
		  C: in  std_logic; -- Clock input
		  R: in  std_logic; -- Asynchronouse reset
		  Q: out std_logic
    );
  end component;

  -- signals
  signal bits : std_logic_vector(23 downto 0);
  signal syncD : std_logic_vector(3 downto 0);
  signal prevEdge : std_logic := '0';
  signal isRising : std_logic;
  signal newCin : std_logic := '0';
  signal oldCin : std_logic;

begin
  -- sync circuit -> ask how can i make the connections more clear
  sync : for i in syncD'high - 1 downto syncD'low generate
    ff : dffar port map (d => syncD(i), c => clk, r => btn(1), q => syncD(i+1)); --syncD(syncD'high) is the current edge
  end generate;
  syncD(0) <= btn(0);

  -- edge detector circuit
  edgeDetector : dffar port map (d => syncD(syncD'high), c => clk, r => btn(1), q => prevEdge);
  
  -- cin memory
  cin : dffar port map (d => newCin, c => clk, r => btn(1), q => oldCin);

  counter : bcounter 
    generic map (
      NBITS => bits'high - bits'low + 1
    )
    port map (
      clk => clk,
      rst => btn(1), --reset counter is button 1
      cin => oldCin, --basically if button is high, then we add 1 since carry in is what is actually being added
      cout => open,
      bits => bits
    );
  
  isRising <= (not prevEdge) and syncD(syncD'high); -- if previous input = 0 and new input = 1, then we have rising edge
  newCin <= (oldCin xor isRising);
  led <= bits(bits'high downto bits'high - 1);
end arch;

-- here, btn 0 is the input to the cin pin 