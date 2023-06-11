library ieee;
use ieee.std_logic_1164.all;

-- if generic value is change, then go to rand_num_generator for further modification

entity rand_num_generator_visualTest is
	generic(N : integer := 3);
	port(
		CLOCK_50, reset : in std_logic;
		LEDR 				 : out std_logic_vector(N downto 0)
	);
end entity;

architecture arch of rand_num_generator_visualTest is
	signal clk_Pulse1s : std_logic;
begin
	-- clock 1 s
	clock_1s : entity work.clockTick
	generic map(M=>50000000, N=>26)
	port map(clk=>CLOCK_50, reset=>reset, clkPulse=>clk_Pulse1s);
	
	-- rand_num_generator testing with 1 sec clock pulse
	rand_num_generator_1s : entity work.rand_num_generator
	port map(clk=>clk_Pulse1s, reset=>reset, q=>LEDR);
end architecture;