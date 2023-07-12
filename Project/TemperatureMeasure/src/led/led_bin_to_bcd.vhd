library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity led_bin_to_bcd is
	port (
		data_in:      in  std_logic_vector(7 downto 0);
		data_bcd_out: out std_logic_vector(9 downto 0)
	);
end led_bin_to_bcd;

architecture rtl of led_bin_to_bcd is

begin 
	process(data_in)
	variable bcd_decoded: std_logic_vector(17 downto 0);
	
	begin 
		for i in 0 to 17 loop	
			bcd_decoded(i):='0';
		end loop;
		
		bcd_decoded(10 downto 3):= data_in;
		for i in 0 to 4 loop
			if bcd_decoded(11 downto 8) > 4 then	
				bcd_decoded(11 downto 8) := bcd_decoded(11 downto 8 ) + 3;
			end if;
			if bcd_decoded(15 downto 12) > 4 then 
				bcd_decoded(15 downto 12) := bcd_decoded(15 downto 12) + 3;
			end if;
			bcd_decoded(17 downto 1 ):= bcd_decoded(16 downto 0);
		end loop;
		
		data_bcd_out <= bcd_decoded(17 downto 8);
	end process;
end architecture rtl;