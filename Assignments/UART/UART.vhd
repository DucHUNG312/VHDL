library ieee; 
use ieee.std_logic_1164.all;

entity UART is
	port (
		data_in      : in std_logic_vector(7 downto 0);
		clk, start   : in std_logic;
		tx           : out std_logic
	);
end UART;

architecture arch of UART is
	type tx_state is (idle, start_bit, data_bit, stop_bit);
	signal state     : tx_state := idle;
	signal data_temp : std_logic_vector(7 downto 0) := "01000110";
begin
	process(clk)
	variable count : integer range 0 to 5300 := 0;
	variable trans : std_logic := '0';
	variable i     : integer range 0 to 10   := 0;
	begin
		if (rising_edge(clk)) then
			case state is 
				when idle =>
					if(trans = '1') then
						trans := '0';
					end if;
					tx <= '1';
					if(start = '0' and trans = '0') then
						trans := '1';
						state <= start_bit;	
					end if;
				when start_bit =>
					tx <= '0';
					count := count + 1;
					if (count >= 5200) then
							state <= data_bit;
							count := 0;
					end if;
				when data_bit =>
					tx <= data_temp(i);
					count := count + 1;
					if (count >= 5200) then
							i := i + 1;
							count := 0;
							if (i >= 8) then
								i := 0;
								state <= stop_bit;
							end if;
					end if;
				when stop_bit =>
					tx <= '1';
					count := count + 1;
					if (count >= 5200) then
							state <= start_bit;
							count := 0;
					end if;
				when others => null;
			end case;
		end if;
	end process;
end arch;