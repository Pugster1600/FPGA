library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab06 is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		srx: out   std_logic;-- PIC pin 9 RS-232
		stx: in    std_logic;-- PIC pin 10 RS-232
		nss: out   std_logic;-- PIC pin 11 SPI
		sck: out   std_logic;-- PIC pin 12 SPI
		sdi: out   std_logic;-- PIC pin 4 SPI
		sdo: in    std_logic;-- PIC pin 3 SPI
		scl: inout std_logic;-- PIC pin 6 I2C
		sda: inout std_logic -- PIC pin 5 I2C
	);
end lab06;

architecture arch of lab06 is
  type uart_state is (IDLE, START, DATA, STOP);
	component lab06_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(7 downto 0);
			data_i: in  std_logic_vector(7 downto 0);
			trig_o: out std_logic
		);
	end component;
	signal data_o:    std_logic_vector(7 downto 0);
	signal data_i:    std_logic_vector(7 downto 0);
	signal trig:      std_logic;

  signal tx_current_bit : unsigned(3 downto 0) := to_unsigned(0,4); --only 8 data states
  signal tx_current_state : uart_state := IDLE;
  signal tx_counter : unsigned(7 downto 0) := to_unsigned(0,8);

  signal rx_current_bit : unsigned(3 downto 0) := to_unsigned(0,4); --only 8 data states
  signal rx_current_state : uart_state := IDLE;
  signal rx_counter : unsigned(7 downto 0) := to_unsigned(0, 8);

  signal stx_sig : std_logic_vector(2 downto 0) := "000";

begin
	gui: lab06_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i,trig_o=>trig);

	-- Example default state of FPGA outputs
	-- srx<='1';
  -- non UART pins driven to idle state bc the constraint file has all of these in use
	 nss<='1';
	 sck<='0';
	 sdi<='0';
	 scl<='Z';
	 sda<='Z';
-- tx fsm

-- actually trig might be for the rx fsm
process (clk)
begin
  if rising_edge(clk) then
    --metastability -> 1. FIRST SUGGESTION 1.1 make sure everything is clocked or use a pipeline in order to ensure timing
    stx_sig(0) <= stx;
    stx_sig(1) <= stx_sig(0);
    stx_sig(2) <= stx_sig(1);
    case tx_current_state is
      when IDLE =>
        srx <= '1'; --THINGS THAT WE WANT TO ONLY CHANGE DURING A RISING EDGE WE SHOULD PUT IN A CLOCKED PROCESS
        if trig = '1' then --basically the ready flag for sending data -> also only doing it once per trigger so we dont put it in sensitivty list!
          -- also we should ignore it for all other states which is why only in IDLE state!
          tx_counter <= to_unsigned(0, 8); --idk the syntax
          tx_current_bit <= to_unsigned(0, 4);
          tx_current_state <= START;
        end if;

      when START =>
        -- bit is high throughout enetire state
        srx <= '0'; --pull low to indicate start condition
        if tx_counter > 104 then --need to change the type
          tx_current_state <= DATA;
          tx_counter <= to_unsigned(0, 8); --same here change the type
          tx_current_bit <= to_unsigned(0,4);
        else
          tx_counter <= tx_counter + 1;
        end if;

      when DATA =>
        srx <= data_o(to_integer(tx_current_bit)); 
        if tx_counter > 104 then
          if tx_current_bit + 1 >= 8 then --finished all data, reset all counters
            tx_current_state <= STOP;
            tx_current_bit <= to_unsigned(0,4);
            tx_counter <= to_unsigned(0,8);
          else 
            tx_current_bit <= tx_current_bit + 1;
            tx_counter <= to_unsigned(0,8);
          end if;
        else
          tx_counter <= tx_counter + 1;
        end if;

      when STOP => --current state
        srx <= '1'; --output
        if tx_counter > 104 then --transition logic
          tx_current_state <= IDLE;
          tx_counter <= to_unsigned(0,8);
          tx_current_bit <= to_unsigned(0,4);
        else
          tx_counter <= tx_counter + 1;
        end if;

      when others =>
        null;
      end case;
  end if;
end process;

--rx fsm
process(clk)
begin
  if rising_edge(clk) then
    -- ONLY LATCH AT ONE INSTANCE so say when count = 50 or something. Try to latch at the middle
    case rx_current_state is
      when IDLE =>
        -- using sig because cannot read directly from input i guess
        if stx_sig(2) = '0' then -- ACTUALLY IT IS THE READING OF THE RX LINE BEING PULLED LOW!!
          rx_current_state <= START;
          rx_counter <= to_unsigned(0,8);
          rx_current_bit <= to_unsigned(0,4);
        end if;
      when START =>
        if rx_counter > 104 then
          rx_current_state <= DATA;
          rx_counter <= to_unsigned(0,8);
          rx_current_bit <= to_unsigned(0,4);
        else
          rx_counter <= rx_counter + 1;
        end if;

      when DATA =>
        if rx_counter > 104 then
          if rx_current_bit + 1 >= 8 then -- maybe the stop condition here should be seeing that the line is pulled low again or something?
            rx_current_bit <= to_unsigned(0, 4);
            rx_current_state <= STOP;
            rx_counter <= to_unsigned(0,8);
          else 
            rx_current_bit <= rx_current_bit + 1;
            rx_counter <= to_unsigned(0,8);
          end if;
          
        elsif rx_counter = 52 then --104 / 2 = 52
          data_i(to_integer(rx_current_bit)) <= stx_sig(2);
          rx_counter <= rx_counter + 1;
        
        else
          rx_counter <= rx_counter + 1;
        end if;

      when STOP =>
        if rx_counter > 104 then
          rx_current_state <= IDLE;
          rx_counter <= to_unsigned(0,8);
          rx_current_bit <= to_unsigned(0,4);
        else 
          rx_counter <= rx_counter + 1;
        end if;

      when others =>
        null;
    end case;
  end if;
end process;
--IMPORTNAT: rx does not know when tx ends just the configuratoin
-- this makes sense since tx signals an end with the line being pulled low BUT that could be confused for a data bit
-- unlike tx which we konw idle = 1 then it pulls the line low
end arch;
----------------------------------------------------
WE ARE GOING TO HAVE A DEDICATED BAUDER
- this makes code way more concise

---------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab07 is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		srx: out   std_logic;-- PIC pin 9 RS-232
		stx: in    std_logic;-- PIC pin 10 RS-232
		nss: out   std_logic;-- PIC pin 11 SPI
		sck: out   std_logic;-- PIC pin 12 SPI
		sdi: out   std_logic;-- PIC pin 4 SPI
		sdo: in    std_logic;-- PIC pin 3 SPI
		scl: inout std_logic;-- PIC pin 6 I2C
		sda: inout std_logic -- PIC pin 5 I2C
	);
end lab07;

architecture arch of lab07 is
	--perspective of GUI so trig_o is out of gui
	component lab07_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(7 downto 0);
			data_i: in  std_logic_vector(7 downto 0);
			trig_o: out std_logic
		);
	end component;
	signal data_o:    std_logic_vector(7 downto 0);
	signal data_i:    std_logic_vector(7 downto 0);
	signal trig:      std_logic;

	type SPI_STATE is (IDLE_STATE, SELECT_STATE, DATA_STATE, RISING_EDGE_STATE, FALLING_EDGE_STATE, DESELECT_STATE);
	signal current_state : SPI_STATE := IDLE_STATE;
	signal trig_meta : std_logic_vector(2 downto 0) := "000";
	signal clk_counter : unsigned(7 downto 0) := to_unsigned(0, 8); --
	signal current_tx_bit : unsigned(3 downto 0) := to_unsigned(7,4); --MSB first
	signal current_rx_bit : unsigned(3 downto 0) := to_unsigned(7,4); --MSB first

	constant clk_size : integer := 8;
	constant full_period : integer := 120; -- 12mhz /100000 = 12
	constant half_period : integer := 60;
	--constant sdi_idle_state : std_logic := '0';
	--constant sck_idle_state : std_logic := '0';
	--constant nss_idle_state : std_logic := '1';
begin
	gui: lab07_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i,trig_o=>trig);

	-- Example default state of FPGA outputs
	-- 1. DRIVE ALL NON SPI pins to some other state
	-- NOTE: these are all outputs so we are driving some certain inputs to certain states
	-- the input signals we can just safely ignore regardless of the protocl which is why we dont include them down here
	--nss<='1';
	--sck<='0';
	--sdi<='0';
	scl<='Z';
	sda<='Z';
	srx<='Z';

process (clk)
begin
	if rising_edge(clk) then
		-- metastability for trig
		trig_meta(0) <= trig;
		trig_meta(1) <= trig_meta(0);
		trig_meta(2) <= trig_meta(1);
		
		--bc tx and rx both rely on the same clk, maybe 1 fsm is better since they both react to the same clk 
		-- and that clk is generated by the process in here not external process
		-- global counter -> better for small fsm or when timing does not need to be super precise like here
		-- did not do this is uart -> more messy but honestly easier to follow code
		-- not doing it here because might make code writing more complex though more compact
		--if current_state /= IDLE_STATE then
		--	clk_counter <= clk_counter + 1;
		--end if;

		case current_state is
			when IDLE_STATE =>
				-- start sending data out
				sdi <= '0';
				nss <= '1';
				sck <= '0';
				if trig_meta(2) = '1'  then
					current_state <= SELECT_STATE;
					clk_counter <= to_unsigned(0, clk_size);

					current_tx_bit <= to_unsigned(7,4);
					current_rx_bit <= to_unsigned(7,4);
				end if;

			when SELECT_STATE =>
				-- should you change nss also in IDLE_STATE?
				-- wait one clk cycle technically just need long enough before moving to data state
				nss <= '0';
				sck <= '0';
				sdi <= '0';
				if to_integer(clk_counter) >= half_period then --arbitrary hold time for nss that is at least > t_setup
					clk_counter <= to_unsigned(0, clk_size); --better to use const just like programming
					current_state <= DATA_STATE;
				else
					clk_counter <= clk_counter + 1;
				end if;

			when DATA_STATE => 
				-- spit out data, then wait for rising edge (clk = low)
				sck <= '0';
				sdi <= data_o(to_integer(current_tx_bit));

				clk_counter <= clk_counter + 1;
				-- 
				if to_integer(current_tx_bit) > 0 then
					current_tx_bit <= current_tx_bit - 1;
					current_state <= RISING_EDGE_STATE;
				else 
					current_state <= DESELECT_STATE;
				end if;
			
			-- rx samples at the rising_edge! LOOK AT THE TIMING DIAGRAM
			when RISING_EDGE_STATE =>
				clk_counter <= clk_counter + 1;
				if to_integer(clk_counter) >= half_period then -- 6000 ticks
					sck <= '1';
					current_state <= FALLING_EDGE_STATE;

					data_i(to_integer(current_rx_bit)) <= sdo;
					-- DONT FORGET TO CONVERT
					if to_integer(current_rx_bit) /= 0 then
						current_rx_bit <= current_rx_bit - 1;
					end if;
				end if;

			when FALLING_EDGE_STATE =>
				--clk_counter <= clk_counter + 1; --fine to have mutliple drivers in this just not different processes!
				if to_integer(clk_counter) >= full_period then --120 ticks
					sck <= '0';
					clk_counter <= to_unsigned(0, clk_size);
					
					current_state <= DATA_STATE;

				else
					clk_counter <= clk_counter + 1;
				end if;

			when DESELECT_STATE =>
			--wait for half period before deselect
				if to_integer(clk_counter) >= half_period then 
					sdi <= '0';
					nss <= '1';
					sck <= '0';
					current_state <= IDLE_STATE;
					clk_counter <= to_unsigned(0, clk_size);

					current_tx_bit <= to_unsigned(7,4);
					current_rx_bit <= to_unsigned(7,4);
				else
					clk_counter <= clk_counter + 1;
				end if;
			when others =>
				null;
		end case;
	end if;
end process;
end arch;

for some reason loopback takes 2 clicks but with arduino it takes 3
- probably some processing with the arduino

prob tips
1. ask is it a constant or funciton
2. if it looks like a certain distirbution try to force it to that
- like add extra terms to make it look like that
- use heuristics
3. bounds and support matters a lot

try to convert the math term into something that is more concrete like an actual example of it
- this is the connection you are trying to make

is there a function such that
- ie is there a function with a certain property
- like integration has a special property
- functions are just generalized forms of things
- matrices have certain properties
- or how can i arrange the information on a matrix so that we have this property
- or what equaiton is good to model something ie the x can encode the indepedent var and stuff

expand out the thing to see pattern matching stuff

-----------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab07 is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		srx: out   std_logic;-- PIC pin 9 RS-232
		stx: in    std_logic;-- PIC pin 10 RS-232
		nss: out   std_logic;-- PIC pin 11 SPI
		sck: out   std_logic;-- PIC pin 12 SPI
		sdi: out   std_logic;-- PIC pin 4 SPI
		sdo: in    std_logic;-- PIC pin 3 SPI
		scl: inout std_logic;-- PIC pin 6 I2C
		sda: inout std_logic -- PIC pin 5 I2C
	);
end lab07;

architecture arch of lab07 is
	--perspective of GUI so trig_o is out of gui
	component lab07_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(7 downto 0);
			data_i: in  std_logic_vector(7 downto 0);
			trig_o: out std_logic
		);
	end component;
	signal data_o:    std_logic_vector(7 downto 0);
	signal data_i:    std_logic_vector(7 downto 0);
	signal trig:      std_logic;

	type SPI_STATE is (IDLE_STATE, SELECT_STATE, SETUP_STATE, DATA_STATE, RISING_EDGE_STATE, FALLING_EDGE_STATE, DESELECT_STATE);
	signal current_state : SPI_STATE := IDLE_STATE;
	signal trig_meta : std_logic_vector(2 downto 0) := "000";
	signal clk_counter : unsigned(7 downto 0) := to_unsigned(0, 8); --
	signal current_tx_bit : unsigned(3 downto 0) := to_unsigned(7,4); --MSB first
	signal current_rx_bit : unsigned(3 downto 0) := to_unsigned(7,4); --MSB first

	constant clk_size : integer := 8;
	constant full_period : integer := 120; -- 12mhz /100000 = 12
	constant half_period : integer := 60;
	constant stability_period : integer := 55;
	--signal reset_clk : std_logic := '0';
	--constant sdi_idle_state : std_logic := '0';
	--constant sck_idle_state : std_logic := '0';
	--constant nss_idle_state : std_logic := '1';
begin
	gui: lab07_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i,trig_o=>trig);

	-- Example default state of FPGA outputs
	-- 1. DRIVE ALL NON SPI pins to some other state
	-- NOTE: these are all outputs so we are driving some certain inputs to certain states
	-- the input signals we can just safely ignore regardless of the protocl which is why we dont include them down here
	--nss<='1';
	--sck<='0';
	--sdi<='0';
	scl<='Z';
	sda<='Z';
	srx<='0';

process (clk)
begin
	if rising_edge(clk) then
		-- metastability for trig
		trig_meta(0) <= trig;
		trig_meta(1) <= trig_meta(0);
		trig_meta(2) <= trig_meta(1);
		
		--bc tx and rx both rely on the same clk, maybe 1 fsm is better since they both react to the same clk 
		-- and that clk is generated by the process in here not external process
		-- global counter -> better for small fsm or when timing does not need to be super precise like here
		-- did not do this is uart -> more messy but honestly easier to follow code
		-- not doing it here because might make code writing more complex though more compact
		--if current_state /= IDLE_STATE then
		--	clk_counter <= clk_counter + 1;
		--end if;
		-- global clock
		if current_state /= IDLE_STATE then
			-- if 1 process drives something twice then you wont get multiple errors
			-- vhdl structures code such that the final assignment gets highest priority (if statements is the other way) kinda like default arg
			-- hardware structured in this way
			clk_counter <= clk_counter + 1;
		end if;

		-- THE CURRENT DATA WE RECIEVED IS WHAT WAS LOADED INTO THE DATA REGISTER OF THE SLAVE LAST SEND CYCLE!
		case current_state is
			when IDLE_STATE =>
				-- start sending data out
				sdi <= '0';
				nss <= '1';
				sck <= '0';

				if (trig_meta(2) = '1') then
					current_state <= SELECT_STATE;

					clk_counter <= to_unsigned(0, clk_size);
					current_tx_bit <= to_unsigned(7,4);
					current_rx_bit <= to_unsigned(7,4);
				end if;

			when SELECT_STATE =>
				nss <= '0';
				sck <= '0';
				current_state <= SETUP_STATE;

			when SETUP_STATE =>
				nss <= '0';
				sck <= '0';
    		if clk_counter >= 5 then   -- wait 5 clk cycles
    		    current_state <= FALLING_EDGE_STATE;
    		    clk_counter <= to_unsigned(0, clk_size);
    		end if;
			
			-- output mosi at falling edge -> both mosi and miso change data at falling edge
			when FALLING_EDGE_STATE =>
				nss <= '0';
				if to_integer(clk_counter) >= half_period then
					sck <= '0';
					current_state <= RISING_EDGE_STATE;
					clk_counter <= to_unsigned(0,clk_size);
					sdi <= data_o(to_integer(current_tx_bit));
				end if;

			-- sample miso at rising edge
			when RISING_EDGE_STATE =>
				nss <= '0';
				if to_integer(clk_counter) >= half_period then
					sck <= '1';
					data_i(to_integer(current_rx_bit)) <= sdo;
					current_state <= DATA_STATE;
					clk_counter <= to_unsigned(0,clk_size);
				end if;

			when DATA_STATE => 
				-- updating data at the end ensures that the tx and rx current bits are synced!
				nss <= '0';
				if ((to_integer(current_tx_bit) = 0) and (to_integer(current_rx_bit) = 0)) then
					current_state <= DESELECT_STATE;
				else
					current_tx_bit <= current_tx_bit - 1;
					current_rx_bit <= current_rx_bit - 1;
					current_state <= FALLING_EDGE_STATE;
				end if;

			when DESELECT_STATE =>
				nss <= '0';
				if to_integer(clk_counter) >= half_period then
					current_rx_bit <= to_unsigned(7,4);
					current_tx_bit <= to_unsigned(7,4);
					clk_counter <= to_unsigned(0,clk_size);
					nss <= '1';
					sdi <= '0';
					sck <= '0';
					current_state <= IDLE_STATE;
				end if;

			when others =>
				null;
		end case;
	end if;
end process;
end arch;

49431
49524

R&D Software/Firmware Engineering


------------------------
jtag

used for boundary scanning
- through the jtag you can monitor what is happening at the pins
- some digital ICs give you more look into the internal signals
- can also do it in serial bus

start off as whatever programming pins then into GPIO pins
- so after bottup they will turn into GPIO pins

quad spi is 4 pins for data
- so spi but with 4 data lines
- 

spi flash is on the serial port
- so you cant do it in real time
can instead use the jtag which is what is typically used
- jtag programs the sram
- whereas spi flash is to the actual chip iteself

it stores the bitsream permantetly
- on power up, fpga auto loads config from flash 
- use jtag for debugging and temporary programming
 qspi to store your desing for standalone boot

 generate memory configuration file
 update constraint file to place the bit file into flash memory

 -------------
 harmonizing simulation and implementation
 --------------
 package is another vhdl file 
 kinda like bringing funcitons over from like a header file or another c file as long as something is compiled against it 

 component 

 there is a different syntax for pacakages
 ----------------
 vhdl library
 collection of modules including a package with component delarations for every entity

 at the start of simulation, all processes will be evaluated at least once thus wait should be after -> if the process doesnt have a sensitivty list

 for combinatoral logic, wait for length does not really matter
 - just make sure its not to osmall so that you don thave to zoom in so far to see what is going on

 ---------------------------------
 ALWAYS DOCUMENT
 1. we wanted to make the rc cutoff higher in frequency like the noise filtering
 to do so, for some reason we use 1k r_l and for the rc ressitor
 this is by the equation

 2. for the op amp, you want about a 20db gain

 systems integration: different impedances to ensure max voltage transfer
 blocks : basic signals and systems

 -----------------------
 IMPORTANT STUFF ABOUT PROB
 1. convolution only works for sum of independet RVs

 2. if symmetric then it is exchangable
 - ie if the pdf is symmetric
 - this also means the support of each must be the same
 - exchangeability is really good for sampling without replacement

 ex: by exchagnability
 what is the porbability the X_52 = king
 since this is sampling without replacement, we can do X_1 = king = X_52 = \frac{1}{13}

 3. difference between mass and density
 - a probability is a mass
 - dividing by h gives the density

 4. systematic approach
 - if given "all" probelm, do complement

 5. by exchangability we can do a lot of basic results
 such as 
 P(X < Y) = 1 - (P(X = Y) + P(X > Y))

 by exchangeability, X < Y = Y > X
 this means 
 P(X < Y) = 1 - P(X = Y) - P(X < Y)

 if we extend this to multiple 

 P(X_1 < X_2 < X_3) = 1 - (P(X_1 = X_2 = X_3) + P(X_3 < X_2 < X_>1) + P(X_3 < X_1 < X_>2) + ...)
 6P(X_1 < X_2 < _3) = 1

 assuming this is a density not a mass function

 6. expectations are linear
 - ie E(X_1+X_2) = E(X_1) + E(X_2)

 7. breaking up into sums
 - the very important hting is to apply expectations lienarly 
 - so say I have 
 1R, 3B, 2P, 4Z

 i draw 3

 expected number of unique

 so we can do 
 ()/(10,3)

 ALSO LOTP is very important

 8. with covariance
 - this relates how much a variance in x leads to a variance of y
 - so it say show much the two rvs depend on each other
 - if we generate sample points in accordance to the distribution, you will get like a 2d graph
 - the more spread out they are, it means that a test sample point, the deviation is (mean - point)
 - if we take the average this for one variable, we get the expected value aka variance
 - BUT if we get the variance of both ie how much a change in var x changes var y, you get the covariance

 important properties
 - if independent, then E(XY) - E(X)E(Y) = 0
 - this means you get linearity of variance
 - variance = E((X-E(X))(X-E(X))) this means that covariance with itself is just the variance
 - if X and Y are independent, COV = 0
 BUT if COV = 0,this does not mean that they are independent
 - Var (X+Y) = Var(X) + Var(Y) +2COV(X,Y) 

integrating a density gives probabilityd5

try to do it by the definition
- because all of this has soem sort of mathematical basis to it

9. very important: E(XY) or something does not require solving the new RV!!
- it only requires using the law of the unconcious statistician
- also, problems will always require using some sort of trick
- they are not meant to be long and you always have enough information so make use of it!!

10. REMEMBER THE FORMULAS

11. law of total expectation and law of total variance are for conditional expectationand conditional variance

12. if not given a distribution, then it usually means using exchangability so the solution is really nice

types of probelms
1. jacobian
2. conditional expectation
3. conditional variance
4. covariance
5. compound variables -> basically using conditiona lexpectation
6. exchangability
7. ordered stats
8. inequalities
9. estimation

classify the type of problems that you get wrong