library ieee; 
use ieee.std_logic_1164.all;

entity sequence_detector_tb is
end entity;

architecture arch of sequence_detector_tb is
	signal T 													 : time := 20 ps;
	signal clk, reset 										 : std_logic;
	signal x 													 : std_logic;
	signal z_meanly_glitch, z_moore_glitch 		    : std_logic;
	signal z_meanly_glitch_free, z_moore_glitch_free : std_logic;
begin
	sequence_detector_unit : entity work.sequence_detector
	port map(
		clk=>clk, reset=>reset, x=>x, 
		z_meanly_glitch=>z_meanly_glitch, z_moore_glitch=>z_moore_glitch, 
		z_meanly_glitch_free=>z_meanly_glitch_free, z_moore_glitch_free=>z_moore_glitch_free
	);	
	
	-- continue clock
	process
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process;

	reset <= '1', '0' after T/2;
	
	x <= '0', '1' after T, '1' after 2*T, '1' after 3*T; 
end architecture;