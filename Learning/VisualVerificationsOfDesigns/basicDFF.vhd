library ieee; 
use ieee.std_logic_1164.all;

-- The basic D flip flop is designed with reset button. Output of the flip flop is set to zero if reset value is ‘1’,
-- otherwise output has the same value as input. Further, change in the output value occurs during ‘positive edge’ of the clock. 

entity basicDFF is
	port(
		clk, reset :  in std_logic;
		d          :  in std_logic;
		q          : out std_logic
	);
end basicDFF;

architecture arch of basicDFF is
begin
	process(clk, reset)
	begin
		if(reset = '1') then
			q <= '0';
		-- check for rising edge of clock
		elsif (clk'event and clk ='1') then
			q <= d;
		else
			null;
		end if;
	end process;
end arch;