library ieee;
use ieee.std_logic_1164.all;

-- If ‘no delay’ or delay of ‘0 ns’ is specified in the statement, 
-- then delta delay is assumed in the design. These two delays are shown below

entity deltaDelayEx is
	port(
		x : inout std_logic;
		z : out std_logic
	);
end deltaDelayEx;

architecture dataflow of deltaDelayEx is
	signal s : std_logic;
begin
-- in first Δt time, value of ‘s’ will change and in next Δt time, the value of 
-- ‘s’ will be assigned to ‘z’. In general, code will execute until there is no further change in the signals.
	z <= s;
	s <= x after 0 ns;
-- z <= x and s; -- error: multiple signal assignment not allowed
end dataflow;