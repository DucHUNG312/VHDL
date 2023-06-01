library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- In hexToSevenSegment, we displayed the outputs on 7 segment display devices, but clocks are not used in the system. 
-- In this section, we will verify the designs with clocks, by visualizing the outputs on LEDs and seven segment displays on DE2 FPGA board. 
-- Since, 50 MHz clock is too fast to visualize the change in the output with eyes, therefore we use 
-- the 1 Hz clock frequency for mod-m counter, so that we can see the changes in the outputs.

-- DE2 provides clock with 50 MHz frequency, therefore it should count upto 5×10^7 to elapse 1 sec time 
-- i.e. 50MHz/5*10^7 = 1Hz = 1sec. Therefore M=50000000 will be used

-- We should visualize the the seven segment LED change after each 1s correspond to count number

entity modMCounter_VisualTest is
	generic(
		M : integer := 12; -- count from 0 to M-1
		N : integer := 4  -- N bits required to count upto M i.e. 2**N >= M
	);
	port(
		CLOCK_50, reset : in std_logic;
		HEX0 : out std_logic_vector(6 downto 0);
		LEDR : out std_logic_vector(1 downto 0);
		LEDG : out std_logic_vector(N-1 downto 0)
	);
end modMCounter_VisualTest;

architecture arch of modMCounter_VisualTest is
	signal clk_Pulse1s : std_logic;
	signal count : std_logic_vector(N-1 downto 0);
begin
	clock_1s : entity work.clockTick
	generic map (M=>50000000, N=>26)
	port map (clk=>CLOCK_50, reset=>reset, clkPulse=>clk_Pulse1s);
	
	-- display clock pulse of 1 s
	LEDR(0) <= clk_Pulse1s;
	
	-- modMCounter with 1 sec clock pulse
	modMCounter1s : entity work.modMCounter
	generic map (M=>M, N=>N)
	port map (clk=>clk_Pulse1s, reset=>reset, complete_tick=>LEDR(1), count=>count);
	
	-- display count on green LEDs
	LEDG <= count;
	
	-- display count on seven segment
	hexToSevenSegment0 : entity work.hexToSevenSegment
	port map (hexNumber=>count, sevenSegmentActiveLow=>HEX0);
end arch;
	