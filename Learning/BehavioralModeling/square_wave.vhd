-- Note that, in VHDL/Verilog designs the code-size has nothing to do with the design size. Remember, the well defined design 
--(code may be very lengthy) can be easily understood by the synthesizer and will be implemented using less number of components.

-- An square wave generator is implemented whose on/off duration is programmable
-- Code is small but design is large
-- High : on_duration * time_scale
-- Low  : off_duration * time_scale

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity square_wave is
	port(
		clk, reset                : in std_logic;
		on_duration, off_duration : in unsigned(2 downto 0);
		out_wave                  : out std_logic
	);
end square_wave;

architecture arch of square_wave is
	signal count_on, count_off : unsigned(2 downto 0);
	constant time_scale : unsigned(7 downto 0) := unsigned(to_signed(2, 8)); -- scales the desired duration to a larger range
	begin
		process(clk, reset)
		begin
			if reset = '1' then
				out_wave  <= '0';
				count_on  <= (others => '0');
				count_off <= (others => '0');
			elsif rising_edge(clk) then
				if count_on < on_duration * time_scale then
					out_wave <= '1';
					count_on <= count_on + 1;
				-- The reason for subtracting 1 is to account for the initial clock cycle when count_off is initialized to 0 at the start of the "LOW" state. 
				-- By subtracting 1 from the scaled duration, the condition count_off < off_duration * time_scale - 1 will be true for the exact number 
				-- of clock cycles needed to achieve the desired "LOW" state duration. In short, the minus 1 stand for the initialize time at "LOW" state.
				elsif count_off < off_duration * time_scale - 1 then
					out_wave <= '0';
					count_off <= count_off + 1;
				else
					count_on  <= (others => '0');
					count_off <= (others => '0');
				end if;
			end if;
		end process;
end arch;