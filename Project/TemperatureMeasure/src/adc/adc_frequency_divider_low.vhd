-- =================================================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            13/06/2023
--
-- FILE:            adc_frequency_divider_low.vhd
--
-- DESCRIPTION:     This file defines an ADC frequency divider module with a low output signal.
--                  The module takes an input clock signal (clk) and generates a divided frequency
--                  output (frequency_out). The module uses a counter to divide the input clock 
--                  frequency. The divided output waveform keeps the output signal in a low state 
--                  most of the time. For only one cycle of the input clock, the output clock is 
--                  in a high state.
-- =================================================================================================
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
-- =================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.adc_pkg.all;

entity adc_frequency_divider_low is
    generic (
        config: adc_config := adc_default_config
    );
    port (
        clk:           in std_ulogic;
        reset:         in std_ulogic;
        frequency_out: out std_ulogic
    );
end entity adc_frequency_divider_low;

architecture rtl of adc_frequency_divider_low is

    --================================= Constants =====================================--
    constant max: integer := config.sampling_div - 1;

    --================================= Signals =====================================--
    signal counter:   integer range 0 to max := 0;
    signal frequency: std_ulogic             := '0';
begin
    FREQUENCY_DIVIDER_LOW: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                frequency <= '0';
            else
                if counter = max then
                    counter <= 0;
                    frequency <= '1';
                else
                    counter <= counter + 1;
                    frequency <= '0';
                end if;
            end if;
        end if;
    end process ; -- FREQUENCY_DIVIDER_LOW
    
    -- Connect IO
    frequency_out <= frequency;

end architecture rtl;