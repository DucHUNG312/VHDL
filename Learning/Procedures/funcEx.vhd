library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ‘Functions’ are similar to ‘procedures’ but can have input-ports only and return only one value.

entity funcEx is
	generic(N: integer := 2);
	port(
		x, y :  in unsigned(N-1 downto 0);
		s    : out unsigned(N-1 downto 0)
	);
end funcEx;

architecture arch of funcEx is
	function sum2num(
		-- list all input here
		signal a : in unsigned(N-1 downto 0);
		signal b : in unsigned(N-1 downto 0)
	)
	-- only one value can be return
	return unsigned is variable sum : unsigned(N-1 downto 0);
	begin
		sum := a + b;
		return sum;
	end sum2num;
begin
	s <= sum2num(a=>x, b=>y);
end arch;