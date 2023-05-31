library ieee; 
use ieee.std_logic_1164.all;

-- Note that two latches are created in the design. Latches are introduced in the circuit, because we did not define the complete set of outputs in the conditions, 
-- e.g. we did no specify the value of ‘small’ when ‘a > b’ at Line 18. Therefore, a latch is created to store the previous value of ‘small’ for this condition.

entity latchEx is 
	port(
		a, b         : in std_logic;
		large, small : out std_logic
	);
end latchEx;

architecture arch of latchEx is
begin
	process(a, b)
	begin
		if (a > b) then
			large <= a;
		elsif (a < b) then
			small <= a;
		end if;
	end process;
end arch;