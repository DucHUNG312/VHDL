-- Created by   :   Le Vu Duc Hung
-- Date         :   7-Jun-23

library ieee;
use ieee.std_logic_1164.all;

entity SerialDetector_tb is
end SerialDetector_tb;

architecture tb of SerialDetector_tb is
	 constant T : time := 20 ps;
    signal clk : std_logic;
    signal ASCII : std_logic_vector(7 downto 0) := "00000000";
    signal flag : std_logic;
begin
    -- connecting testbench signals with SerialDetector.vhd
    UUT : entity work.SerialDetector 
			 port map (clk => clk, ASCII => ASCII, flag => flag);
	
	-- continuous clock
	process
	begin
		clk <= '0';
	   wait for T/2;
	   clk <= '1';
	   wait for T/2;
	end process;

    ASCII <= "00000000", "01010110" after T, "01001000" after 2*T, "01000100" after 3*T, "01001101" after 4*T;    
end tb ;