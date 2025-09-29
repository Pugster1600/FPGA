library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

-- Professional counter simulation test bench

entity counter_sim is
end counter_sim;

architecture arch of counter_sim is
	-- sim_print(): Print simple message string
	procedure sim_print(constant str:string) is
		variable buf:line;
	begin
		write(buf,str);
		writeline(output,buf);
	end procedure;
	-- sim_step(): Simulate for 1/4 of clock period
	procedure sim_step(constant stp:time) is
	begin
		wait for stp;
	end procedure;
	-- sim_clock(): Simulate for 1 clock period
	procedure sim_clock(signal clk:out std_logic;constant stp:time) is
	begin
		wait for stp;
		clk<='0';
		wait for stp;
		wait for stp;
		clk<='1';
		wait for stp;
	end procedure;
	-- sim_assert(): Check that count_o and carry_o are as expected
	procedure sim_assert(
		signal   cnt_s:in std_logic_vector;
		constant cnt_c:std_logic_vector;
		signal   cry_s:in std_logic;
		constant cry_c:std_logic) is
		variable buf:line;
		variable err:integer;
	begin
		err:=0;
		write(buf,string'("         count_o="));
		write(buf,to_bitvector(cnt_s));
		write(buf,string'(" carry_o="));
		write(buf,to_bit(cry_s));
		writeline(output,buf);
		if (cnt_s/=cnt_c) then
			err:=err+1;
		end if;
		if (cry_s/=cry_c) then
			err:=err+2;
		end if;
		if (err/=0) then
			write(buf,string'("Expected count_o="));
			write(buf,to_bitvector(cnt_c));
			write(buf,string'(" carry_o="));
			write(buf,to_bit(cry_c));
			writeline(output,buf);
		end if;
		if (err=1) then
			report "count_o incorrect" severity failure;
		end if;
		if (err=2) then
			report "carry_o incorrect" severity failure;
		end if;
		if (err=3) then
			report "count_o and carry_o incorrect" severity failure;
		end if;
	end procedure;
	-- counter component declaration
	component counter
		generic(
			NBITS: natural;-- Counter size
			INITC: natural -- Power-on reset
		);
		port(
			clock_i: in  std_logic; -- Input clock
			reset_i: in  std_logic; -- Asynchronous reset
			load_i:  in  std_logic; -- Synchronous load
			beg_i:   in  std_logic_vector(NBITS-1 downto 0); -- Start count
			inc_i:   in  std_logic_vector(NBITS-1 downto 0); -- Increment
			end_i:   in  std_logic_vector(NBITS-1 downto 0); -- End count
			count_i: in  std_logic_vector(NBITS-1 downto 0); -- Count in
			carry_i: in  std_logic; -- Carry-in for cascading
			count_o: out std_logic_vector(NBITS-1 downto 0); -- Count out
			carry_o: out std_logic  -- Carry-out for cascading
		);
	end component;
	-- Local constants and signals
	constant nbits: natural:=3;
	constant initc: natural:=2;
	constant tstep: time:=20 ns;
	signal clock_i: std_logic;
	signal reset_i: std_logic;
	signal load_i:  std_logic;
	signal beg_i:   std_logic_vector(nbits-1 downto 0);
	signal inc_i:   std_logic_vector(nbits-1 downto 0);
	signal end_i:   std_logic_vector(nbits-1 downto 0);
	signal count_i: std_logic_vector(nbits-1 downto 0);
	signal carry_i: std_logic;
	signal count_o: std_logic_vector(nbits-1 downto 0);
	signal carry_o: std_logic;
begin
	------------------------------------------------------------------
	-- counter instantiation                                        --
	------------------------------------------------------------------
	dut: counter
		generic map(
			NBITS=>nbits,    -- Counter size
			INITC=>initc     -- Power-on reset
		)port map(
			clock_i=>clock_i,-- Input clock
			reset_i=>reset_i,-- Asynchronous reset
			load_i=>load_i,  -- Synchronous load
			beg_i=>beg_i,    -- Start count
			inc_i=>inc_i,    -- Increment
			end_i=>end_i,    -- End count
			count_i=>count_i,-- Count in
			carry_i=>carry_i,-- Carry-in for cascading
			count_o=>count_o,-- Count out
			carry_o=>carry_o -- Carry-out for cascading
		);

	------------------------------------------------------------------
	-- simulation                                                   --
	------------------------------------------------------------------
	process
	begin
		sim_print("Starting simulation...");
		--------------------------------------------------------------
		-- Set initial signal states and initialize counter         --
		--------------------------------------------------------------
		clock_i<='1';
		reset_i<='1';
		load_i<='0';
		beg_i<=b"001";
		inc_i<=b"000";
		end_i<=b"111";
		count_i<=b"011";
		carry_i<='0';
		sim_step(tstep);
		reset_i<='0';
		sim_step(tstep);
		--------------------------------------------------------------
		-- Simple counter increment test                            --
		--                                                          --
		-- Increment is 1 and carry in is 0                         --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Counter increment test                       |");
		sim_print("| beg_i=1, inc_i=1, end_i=7, carry_i=0         |");
		sim_print("+----------------------------------------------+");
		beg_i<=b"001";
		inc_i<=b"001";
		end_i<=b"111";
		carry_i<='0';
		sim_assert(count_o,b"010",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"011",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"100",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"101",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"110",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"111",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"001",carry_o,'0');
		--------------------------------------------------------------
		-- Simple counter increment test                            --
		--                                                          --
		-- Increment is 0 and carry in is 1                         --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Counter increment test                       |");
		sim_print("| beg_i=1, inc_i=0, end_i=7, carry_i=1         |");
		sim_print("+----------------------------------------------+");
		beg_i<=b"001";
		inc_i<=b"000";
		end_i<=b"111";
		carry_i<='1';
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"010",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"011",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"100",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"101",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"110",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"111",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"001",carry_o,'0');
		--------------------------------------------------------------
		-- Simple counter increment test                            --
		--                                                          --
		-- Increment is 1 and carry in is 1                         --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Counter increment test                       |");
		sim_print("| beg_i=1, inc_i=1, end_i=7, carry_i=1         |");
		sim_print("+----------------------------------------------+");
		beg_i<=b"001";
		inc_i<=b"001";
		end_i<=b"111";
		carry_i<='1';
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"011",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"101",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"111",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"010",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"100",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"110",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"001",carry_o,'0');
		--------------------------------------------------------------
		-- Simple counter increment test                            --
		--                                                          --
		-- Increment is 6 and carry in is 0                         --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Counter decrement test                       |");
		sim_print("| beg_i=1, inc_i=6, end_i=7, carry_i=0         |");
		sim_print("+----------------------------------------------+");
		beg_i<=b"001";
		inc_i<=b"110";
		end_i<=b"111";
		carry_i<='0';
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"111",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"110",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"101",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"100",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"011",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"010",carry_o,'1');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"001",carry_o,'0');
		--------------------------------------------------------------
		-- Counter load test                                        --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Counter load test                            |");
		sim_print("+----------------------------------------------+");
		beg_i<=b"001";
		inc_i<=b"000";
		end_i<=b"111";
		carry_i<='0';
		load_i<='1';
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"011",carry_o,'0');
		load_i<='0';
		--------------------------------------------------------------
		-- Check that carry_o is combinatorial                      --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Carry out test                               |");
		sim_print("+----------------------------------------------+");
		reset_i<='0';
		load_i<='0';
		beg_i<=b"001";
		inc_i<=b"111";
		end_i<=b"111";
		carry_i<='0';
		sim_step(tstep);
		sim_assert(count_o,b"011",carry_o,'1');
		--------------------------------------------------------------
		-- Check reset behavior                                     --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Reset test                                   |");
		sim_print("+----------------------------------------------+");
		reset_i<='1';
		load_i<='0';
		inc_i<=b"000";
		sim_step(tstep);
		sim_assert(count_o,b"010",carry_o,'0');
		inc_i<=b"111";
		sim_step(tstep);
		sim_assert(count_o,b"010",carry_o,'0');
		--------------------------------------------------------------
		-- Check load behavior                                      --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| Load test                                   |");
		sim_print("+----------------------------------------------+");
		reset_i<='0';
		load_i<='1';
		inc_i<=b"000";
		sim_step(tstep);
		sim_assert(count_o,b"010",carry_o,'0');
		inc_i<=b"111";
		sim_step(tstep);
		sim_assert(count_o,b"010",carry_o,'0');
		sim_clock(clock_i,tstep);
		sim_assert(count_o,b"011",carry_o,'0');
		load_i<='0';
		sim_step(tstep);
		sim_assert(count_o,b"011",carry_o,'1');
		--------------------------------------------------------------
		-- End of simulation                                        --
		--------------------------------------------------------------
		sim_print("+----------------------------------------------+");
		sim_print("| End of simulation, all tests passed          |");
		sim_print("+----------------------------------------------+");
		-- All done
		report "Test complete." severity failure;
		wait;
	end process;
	
end arch;