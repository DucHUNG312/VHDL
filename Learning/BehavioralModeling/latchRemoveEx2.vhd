library ieee; 
use ieee.std_logic_1164.all;

-- Another method remove the unintended memories is the use of ‘default values’. Here we can defined, all the outputs 
-- at the beginning of the process statement (Line 19). Then, we can overwrite the values in different statements
-- e.g. value of ‘large’ is modified in Line 23.

entity latchRemoveEx2 is 
	port(
		a, b         : in std_logic;
		large, small : out std_logic
	);
end latchRemoveEx2;

architecture arch of latchRemoveEx2 is
begin
	process(a, b)
	begin
		-- use default values : no need to define output in each if-elsif-else part
		large <= '0';
		small <= '0';
		if (a > b) then
			large <= a;
		elsif (a < b) then
			small <= a;
		end if;
	end process;
end arch;