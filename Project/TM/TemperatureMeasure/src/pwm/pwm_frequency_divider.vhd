-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            pwm_frequency_divider.vhd
--
-- @date:            13/06/2023
--
-- @description:     This file defines an ADC frequency divider module. It takes an input clock signal
--                   (clk) and generates a divided frequency output (frequency_out) The module uses a 
--                   counter to divide the input clock frequency. The divided output waveform is 
--                   generated using a rising square wave and an optional falling square wave if the 
--                   configuration requires the ratio to be half.
-- ==================================================================================================================
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
-- ==================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.general_config.all;

entity pwm_frequency_divider is
    generic (
        config: project_config := default_config
    );
    port (
        clk:           in std_ulogic;
        frequency_out: out std_ulogic
    );
end entity pwm_frequency_divider;

architecture rtl of pwm_frequency_divider is

    --================================= Constants =====================================--
    constant max:         integer := config.pwm_clk_div - 1;
    constant half:        integer := max / 2;
    constant div_is_even: boolean := ((config.pwm_clk_div mod 2) = 0);

    --================================== Signals ======================================--
    signal counter:          integer range 0 to max  := 0;
    signal rise_square_wave: std_ulogic              := '0';
    signal fall_square_wave: std_ulogic              := '0';
begin
    PWM_FREQUENCY_DIVIDER : process(clk)
    begin
        if rising_edge(clk) then
            if counter = max then
                counter <= 0;
            elsif counter > half and counter < max then
                counter <= counter + 1;
                rise_square_wave <= '1';
            else
                counter <= counter + 1;
                rise_square_wave <= '0';
            end if;
        end if;

        if (not div_is_even) and config.ratio_must_be_half then
            if falling_edge(clk) then
                if counter > half then
                    fall_square_wave <= '1';
                else
                    fall_square_wave <= '0';
                end if;
            end if;
        end if;
    end process PWM_FREQUENCY_DIVIDER; 

    -- Connect IO
    frequency_out <= rise_square_wave when (div_is_even or (not config.ratio_must_be_half)) else (rise_square_wave or fall_square_wave);
    
end architecture rtl;