library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity led_bin_to_bcd is
	port (
        b: in std_logic_vector(7 downto 0);
        p : out std_logic_vector(9 downto 0)
	);
end led_bin_to_bcd;

architecture led_bin_to_bcd_arch of led_bin_to_bcd is

begin 
	process(b)
	variable z: std_logic_vector(17 downto 0);
	
	begin 
		for i in 0 to 17 loop	
					z(i):='0';
		end loop;
		
		z(10 downto 3):= b;
		for i in 0 to 4 loop
			if z(11 downto 8)>4 then	
					z(11 downto 8) := z(11 downto 8 )+3;
			end if;
			if z(15 downto 12)> 4 then 
				z(15 downto 12) := z(15 downto 12)+3;
			end if;
			z(17 downto 1 ):= z(16 downto 0);
		end loop;
		
		P<= z(17 downto 8);
		end process;
	end led_bin_to_bcd_arch;