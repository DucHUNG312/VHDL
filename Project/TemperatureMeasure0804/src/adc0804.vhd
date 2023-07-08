library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity adc0804 is
    port (
      clk_in: in std_logic;
      intr_ack: in std_logic;
		adc_data_in: in std_logic_vector(7 downto 0);

		read_ack: out std_logic;
		write_ack: out std_logic;
		adc_data_out_int: out integer range 0 to 255;
		adc_data_out: out std_logic_vector(7 downto 0);
		adc_chip_select: out std_logic
    );
end entity adc0804;

architecture rtl of adc0804 is
	signal clk: std_logic := '0';
begin
	adc0804_freq_divider: entity work.adc0804_freq_divider
	port map (
		clk => clk_in,
		frequency_out => clk
	);

	process(clk, adc_data_in)
		variable counter: integer := 0;
	begin
		if rising_edge(clk) then
			if counter = 0 then
				write_ack <= '0';
				read_ack <= '1';
				adc_chip_select <= '0';
				counter := counter + 1;
			elsif counter = 1 then
				write_ack <= '1';
				adc_chip_select <= '1';
				if intr_ack = '0' then
					counter := counter + 1;
				end if;	
			elsif counter >= 2 and counter < 9 then
				adc_chip_select <= '0';
				read_ack <= '0';
				counter := counter + 1;
			elsif counter = 9 then
				adc_data_out_int <= to_integer(unsigned(adc_data_in));
				adc_data_out <= adc_data_in;
				read_ack <= '1';
				adc_chip_select <= '1';
				counter := counter + 1;
			elsif counter = 10 then
				counter := 0;
			end if;
		end if;
	end process;
end architecture rtl;
