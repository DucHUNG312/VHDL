-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            pwm.vhd
--
-- @date:            14/06/2023
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

entity pwm is
    generic (
        config: project_config := default_config
    );
    port (
        clk_in:   in std_ulogic;
        ratio:    in std_ulogic_vector(config.data_bits - 1 downto 0);
        wave_out: out std_ulogic
    );
end entity pwm;

architecture rtl of pwm is
    signal clk: std_ulogic := '0';
    signal counter: unsigned(config.data_bits - 1 downto 0) := (others => '0');
begin
    CLOCK_DIVIDER: pwm_frequency_divider
    generic map (
        config         => config
    )
    port map (
        clk            => clk_in,
        frequency_out  => clk
    );

    -- COUNT_RISING_EDGE
    COUNT_RISING_EDGE: process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process COUNT_RISING_EDGE;
    
    -- Connect IO
    wave_out <= '1' when (counter < unsigned(ratio)) else '0';
end architecture rtl;

