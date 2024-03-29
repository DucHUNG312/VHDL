-- structure component style
library ieee;
use ieee.std_logic_1164.all;

entity comparator2BitStructComponent is 
	port(
		a, b : in std_logic_vector(1 downto 0);
		eq   : out std_logic
	);
end comparator2BitStructComponent;

architecture structure of comparator2BitStructComponent is
	component comparator1Bit
		port(
			x, y : in std_logic;
			eq   : in std_logic
		);
	end component;
	signal s0, s1: std_logic;
begin
	eq_bit0: comparator1Bit
		port map (x=>a(0), y=>b(0), eq=>s0);
	eq_bit1: comparator1Bit
		port map (x=>a(1), y=>b(1), eq=>s1);
		
	eq <= s0 and s1;
end structure;