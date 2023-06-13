-- ==================================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            13/06/2023
--
-- FILE:            seven_segment_decoder.vhd
--
-- DESCRIPTION:     This file describes a seven-segment decoder component in VHDL. 
--                  The component takes an input ADC data and converts it into a 
--                  temperature value. The temperature value is then decoded into 
--                  individual digit segments for display on a seven-segment display. 
--                  The output display segment controls are provided through the 
--                  'display' port. Optionally, the 'inverted_out' generic can be 
--                  set to invert the display segments.
-- ==================================================================================
-- MIT License
-- Copyright (c) 2023 Le Vu Duc Hung
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ==================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segment_decoder is
    generic (
        inverted_out: boolean := false
    );
    port (
        clk:           in std_ulogic;
        reset:         in std_ulogic;
        adc_data_out:  in unsigned(7 downto 0);
        display:       out std_ulogic_vector(6 downto 0)
    );
end entity seven_segment_decoder;

architecture rtl of seven_segment_decoder is
    signal temperature:       unsigned(7 downto 0)          := (others => '0'); -- Temperature signal derived from ADC
    signal temperature_digit: unsigned(3 downto 0)          := (others => '0'); -- Individual digit of the temperature
    signal display_segment:   std_ulogic_vector(6 downto 0) := (others => '0'); -- Individual segment control for the display
begin
    SEVEN_SEGMENT_DECODER : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                display_segment <= (others => '0');
            else
                -- Convert ADC reading to temperature
                temperature <= adc_data_out;

                -- Convert temperature reading to individual digits
                temperature_digit <= temperature(7 downto 4);

                -- Decode the temperature digit to 7-segment representation
                case temperature_digit is
                    when "0000" =>
                        display_segment <= "0111111";  -- Display '0'
                    when "0001" =>
                        display_segment <= "0000110";  -- Display '1'
                    when "0010" =>
                        display_segment <= "1011011";  -- Display '2'
                    when "0011" =>
                        display_segment <= "1001111";  -- Display '3'
                    when "0100" =>
                        display_segment <= "1100110";  -- Display '4'
                    when "0101" =>
                        display_segment <= "1101101";  -- Display '5'
                    when "0110" =>
                        display_segment <= "1111101";  -- Display '6'
                    when "0111" =>
                        display_segment <= "0000111";  -- Display '7'
                    when "1000" =>
                        display_segment <= "1111111";  -- Display '8'
                    when "1001" =>
                        display_segment <= "1100111";  -- Display '9'
                    when others =>
                        display_segment <= "0000000";  -- Display '-' for unknown value
                end case;
            end if;
        end if;
    end process; -- SEVEN_SEGMENT_DECODER

    -- Connect IO
    display <= not display_segment when inverted_out else display_segment;

end architecture rtl;