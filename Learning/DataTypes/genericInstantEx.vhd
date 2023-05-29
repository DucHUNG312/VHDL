library ieee; 
use ieee.std_logic_1164.all;

entity genericInstantEx is
	port(
		x, y : in std_logic_vector(3 downto 0);
		z    : out std_logic
	);
end genericInstantEx;

architecture arch of genericInstantEx is
begin
	-- N=>4 will override the default value of N i.e. N=2. 
	-- Also, generic ‘M’ is not mapped, therefore default value of M will be used
	compare4bit: entity work.genericEx
		generic map (N => 4) -- generic mapping for 4 bit
      port map (a=>x, b=>y, eq=>z); -- port mapping
end arch;