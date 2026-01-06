library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab05b is
	port(
		clk:      in  std_logic;
		rx:       in  std_logic;
		tx:       out std_logic;
		vaux12_n: in  std_logic;
		vaux12_p: in  std_logic;
		btn:      in  std_logic;
		square:   out std_logic
	);
end lab05b;

architecture arch of lab05b is
	component lab05b_gui is
		generic(
			SAMPLES: natural
		);
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			addr_o: out std_logic_vector(9 downto 0);
			data_i: in  std_logic_vector(11 downto 0)
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
	constant samples: natural:=200;
	signal rdy:   std_logic;
	signal addra: std_logic_vector(9 downto 0);
	signal dataa: std_logic_vector(35 downto 0);
	signal addrb: std_logic_vector(9 downto 0);
	signal datab: std_logic_vector(35 downto 0);

	signal btnSync : std_logic_vector(2 downto 0);
	signal counting : std_logic := '0';
	signal ready : std_logic;

	constant period : integer := 1039;
	signal square_wave : std_logic := '0';
	signal counter : unsigned(11 downto 0) := to_unsigned(0, 12);

begin
	gui: lab05b_gui generic map (SAMPLES=>samples) port map(clk_i=>clk,
		rx_i=>rx,tx_o=>tx,addr_o=>addra,data_i=>dataa(11 downto 0));
	adc: lab05_adc port map(clk_i=>clk,vaux12n_i=>vaux12_n,
		vaux12p_i=>vaux12_p,rdy_o=>rdy,data_o=>datab(11 downto 0));
	ram: lab05_ram port map(clka_i=>clk,wea_i=>'0',addra_i=>addra,
		dataa_i=>(others=>'0'),dataa_o=>dataa,clkb_i=>clk,
		web_i=>ready,addrb_i=>addrb,datab_i=>datab,datab_o=>open);

		ready <= counting and rdy;
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

process (clk)
begin
	if rising_edge(clk) then
		btnSync(0) <= btn;
		btnSync(1) <= btnSync(0);
		btnSync(2) <= btnSync(1);

		if btnSync(2) = '1' and counting = '0' then
			-- write the thing 200 times
			-- so a flagged process or something
			counting <= '1';
		end if;
		
		if counting = '1' then
		case to_integer(unsigned(addrb)) is --must be discrete types ie not an array of bits
			when 0 =>
				if rdy = '1' then --else hold, this does not infer latch cause inside a clocked process
					addrb <= std_logic_vector(unsigned(addrb) + to_unsigned(1,addrb'length));
				end if;
				--addrb <= addr()
			when 199 =>
				if rdy = '1' then
					addrb <= std_logic_vector(to_unsigned(0, addrb'length));
					counting <= '0';
				end if;
			when others =>
				if rdy = '1' then
					addrb <= std_logic_vector(unsigned(addrb) + to_unsigned(1,addrb'length));
				end if;
			end case;
		end if;
	end if;
end process;

	datab(35 downto 12)<=(others=>'0');
end arch;