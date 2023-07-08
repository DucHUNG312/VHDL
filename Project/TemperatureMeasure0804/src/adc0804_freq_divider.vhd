library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc0804_freq_divider is
    port (
        clk: in std_ulogic;
        frequency_out: out std_ulogic
    );
end entity adc0804_freq_divider;

architecture rtl of adc0804_freq_divider is
    constant max: integer := 80;
    constant half: integer := max / 2;

    signal counter: integer range 0 to max := 0;
    signal square_wave: std_ulogic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = max then
                counter <= 0;
            elsif counter > half and counter < max then
                counter <= counter + 1;
                square_wave <= '1';
            else
                counter <= counter + 1;
                square_wave <= '0';
            end if;
        end if;
    end process; 

    frequency_out <= square_wave;
    
end architecture rtl;