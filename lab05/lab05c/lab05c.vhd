library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab05c is
	port(
		clk:      in  std_logic;
		rx:       in  std_logic;
		tx:       out std_logic;
		vaux12_n: in  std_logic;
		vaux12_p: in  std_logic;
		btn:      in  std_logic;
		square:   out std_logic
	);
end lab05c;

architecture arch of lab05c is
	component lab05c_gui is
		generic(
			SAMPLES: natural
		);
		port(
			clk_i:   in  std_logic;
			rx_i:    in  std_logic;
			tx_o:    out std_logic;
			thrsh_o: out std_logic_vector(11 downto 0);
			addr_o:  out std_logic_vector(9 downto 0);
			data_i:  in  std_logic_vector(11 downto 0)
		);
	end component;
	component lab05_adc is
		port(
			clk_i:     in  std_logic;
			vaux12n_i: in  std_logic;
			vaux12p_i: in  std_logic;
			rdy_o:     out std_logic;
			data_o:    out std_logic_vector(11 downto 0)
		);
	end component;
	component lab05_ram is
		port(
			clka_i:  in  std_logic;
			wea_i:   in  std_logic;
			addra_i: in  std_logic_vector(9 downto 0);
			dataa_i: in  std_logic_vector(35 downto 0);
			dataa_o: out std_logic_vector(35 downto 0);
			clkb_i:  in  std_logic;
			web_i:   in  std_logic;
			addrb_i: in  std_logic_vector(9 downto 0);
			datab_i: in  std_logic_vector(35 downto 0);
			datab_o: out std_logic_vector(35 downto 0)
		);
	end component;
	component lab05_cmt is
		port(
			clk_i: in  std_logic;
			clk_o: out std_logic
		);
	end component;
	constant samples: natural:=200;
	signal fclk:  std_logic;
	signal rdy:   std_logic;
	signal thrsh: std_logic_vector(11 downto 0);
	signal addra: std_logic_vector(9 downto 0);
	signal dataa: std_logic_vector(35 downto 0);
	signal addrb: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0,10));
	signal datab: std_logic_vector(35 downto 0);

	signal btnSync : std_logic_vector(2 downto 0);
	signal counting : std_logic := '0';

	--signal threshold_count : unsigned(3 downto 0) := to_unsigned(0,4);
	type shift_reg is array (2 downto 0) of std_logic_vector(35 downto 0);
	signal threshold_shift_reg : shift_reg := (others => (others => '0'));
	signal ready : std_logic := '0';
	signal threshold_met : std_logic := '0';
	--signal threshold_passed : std_logic := '0';

	constant period : integer := 1039;
	signal square_wave : std_logic := '0';
	signal counter : unsigned(11 downto 0) := to_unsigned(0, 12);
begin
	gui: lab05c_gui generic map (SAMPLES=>samples) port map(clk_i=>clk,
		rx_i=>rx,tx_o=>tx,thrsh_o=>thrsh,addr_o=>addra,
		data_i=>dataa(11 downto 0));
	cmt: lab05_cmt port map(clk_i=>clk,clk_o=>fclk); --input of 12 mhz, output of 52 mhz
	adc: lab05_adc port map(clk_i=>fclk,vaux12n_i=>vaux12_n,
		vaux12p_i=>vaux12_p,rdy_o=>rdy,data_o=>datab(11 downto 0));
	ram: lab05_ram port map(clka_i=>clk,wea_i=>'0',addra_i=>addra,
		dataa_i=>(others=>'0'),dataa_o=>dataa,clkb_i=>fclk,
		web_i=>ready,addrb_i=>addrb,datab_i=>threshold_shift_reg(2),datab_o=>open); --web_i is write enable b input

-- problem is with timing of trigger
-- if press button and not triggered, it will wait till it gets triggered which is fine
-- behavior: when connected to 3.3 v, then we press button that is when it starts to jump
-- this is cause it has not seen the threshold! -> so the ready is still ready even though threshold not met
-- so it keeps writing to 0 since its ready but not incrementing
-- solution is to start writing when by rdy, started counting and threshold met
-- NOTE: might have to pipeline because some of these combinational logic are really big so timing might not be met
		square <= square_wave;

process(clk)
begin
	if rising_edge(clk) then
		if to_integer(counter) >= period then
			counter <= to_unsigned(0,12);
			square_wave <= not square_wave;
		else
			counter <= counter + 1;
		end if;
end if;
end process;

process(fclk)
begin
  if rising_edge(fclk) then
    -- 1. button sync
    btnSync(0) <= btn;
    btnSync(1) <= btnSync(0);
    btnSync(2) <= btnSync(1);
    -- start counting on rising edge of button
    if btnSync(2) = '1' and counting = '0' then
        counting <= '1';
    end if;

		-- 2. shift register
		if counting = '1' and rdy = '1' then
			threshold_shift_reg(2) <= threshold_shift_reg(1);
			threshold_shift_reg(1) <= threshold_shift_reg(0);
			threshold_shift_reg(0) <= datab;
		end if;

		-- 3. check if threshold met
		if counting = '1' and rdy = '1' then
			if (unsigned(threshold_shift_reg(1)) <= unsigned(thrsh)) and (unsigned(threshold_shift_reg(0)) >= unsigned(thrsh)) then
				addrb <= std_logic_vector(unsigned(addrb) + to_unsigned(1,addrb'length));
				threshold_met <= '1';
			end if;
		end if;

		-- 4.0 ready to write
		ready <= counting and rdy and threshold_met;

		-- 4. start actually writing data
		if ready = '1' then
			if addrb = std_logic_vector(to_unsigned(199, addrb'length)) then
        addrb <= (others => '0');
        counting <= '0';
        threshold_met <= '0';
      else
        addrb <= std_logic_vector(unsigned(addrb) + 1);
      end if;
		end if;

	end if;

end process;


	datab(35 downto 12)<=(others=>'0');
end arch;