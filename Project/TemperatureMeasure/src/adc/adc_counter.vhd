-- ======================================================================================================
-- AUTHOR:              Le Vu Duc Hung
--
-- DATE:                13/06/2023
--
-- FILE:                adc_counter.vhd
--
-- DESCRIPTION:         This file defines a counter module that counts the number of rising edges of
--                      an input clock signal. The current count value is provided through the output 
--                      "count_out", and the "overflow" output indicates whether the counter has reached 
--                      its maximum value (2^state_bits - 1).
-- ======================================================================================================
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
-- ======================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.adc_pkg.all;

entity adc_counter is
    generic (
        config: adc_config := adc_default_config
    );
    port (
        clk:           in std_ulogic;
        reset:         in std_ulogic;
        enable:        in std_ulogic;
        count_out:     out std_ulogic_vector(config.state_bits - 1 downto 0);
        overflow:      out std_ulogic
    );
end entity adc_counter;

architecture rtl of adc_counter is

    --================================= Constants =====================================--
    constant max: integer := 2**config.state_bits - 1;

    --================================= Signals =====================================--
    signal count: unsigned(config.state_bits - 1 downto 0) := (others => '0');
begin
    ADC_COUNTER : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= (others => '0');
            elsif enable = '1' then
                count <= count + 1;
            end if;
        end if;
    end process ; -- ADC_COUNTER
    
    -- Connect IO
    count_out <= std_ulogic_vector(count);
    overflow <= enable when count = max else '0';
    
end architecture rtl;