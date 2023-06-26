library ieee;
use ieee.std_logic_1164.all; 

LiBRARY std; 
USE std.standard.all; 

LIBRARY work;
USE work.all;


entity freqdiv is 
port ( 
	f : OUT STD_LOGIC;
	clk : in std_LOGIC
);
end freqdiv ;

architecture freqdiv_arch of freqdiv is
signal temp : std_LOGIC := '0';

begin

f <= temp;

process (clk)
variable counter : integer range 0 to 5000001 := 0;
begin

if rising_edge(clk) then
	counter := counter + 1;
	if(counter = 5000000) then
		counter := 0;
		temp <= not temp;
	end if;	
end if;

end process;


end freqdiv_arch;