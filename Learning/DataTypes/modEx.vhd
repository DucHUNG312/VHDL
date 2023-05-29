library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- mod is applicable to integers and it's subtype only

-- examples
-- 1 mod 10 = 1
-- 15 mod 10 = 5

entity modEx is 
	port(
		clk : in std_logic;
		-- input values are taken from switch
		SW : in std_logic_vector(3 downto 0);
		-- output value (i.e. SW mod 10) is displayed on LEDG
		LEDG : out std_logic_vector(3 downto 0)
	);
end modEx;

architecture arch of modEx is 
	signal a, b : natural := 10;
begin
   -- MOD operation with type conversion
	b <= to_integer(unsigned(SW)) mod a; -- type conversion to integer
	LEDG <= std_logic_vector(to_signed(b, 4)); -- convert b into 4 bit signed
end arch;