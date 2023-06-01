library ieee; 
use ieee.std_logic_1164.all;

-- D flip flop with Enable port

entity D_FF is
	port(
		clk, reset, en :  in std_logic;
		d 					:  in std_logic;
		q 					: out std_logic
	);
end D_FF;

architecture arch of D_FF is
begin
	process(clk, reset)
	begin
		if (reset = '1') then
			q <= '0';
		-- check for rising edge of clock and enable port
		elsif (clk'event and clk = '1' and en = '1') then
			q <= d;
		else  -- note that else block is not required
				null;  -- do nothing
	   end if;
	end process;
end arch;