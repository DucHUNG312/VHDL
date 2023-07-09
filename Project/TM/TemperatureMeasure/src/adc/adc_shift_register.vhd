-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            adc_shift_register.vhd
--
-- @date:            13/06/2023
--
-- @description:     This file represents an ADC (Analog-to-Digital Converter) shift register.
--                   It takes in serial input data and shifts it through the register on rising 
--                   edges of the clock. The output is the parallel data stored in the register.
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

entity adc_shift_register is
    generic (
        config: project_config := default_config
    );
    port (
        clk:           in std_logic;
        data_in:       in std_logic;
        data_out:      out std_logic_vector(config.data_bits - 1 downto 0)
    );
end entity adc_shift_register;

architecture rtl of adc_shift_register is
    signal data: std_logic_vector(config.data_bits - 1 downto 0) := (others => '0');
begin
    SHIFT_REGISTER : process(clk)
    begin
        if rising_edge(clk) then
            data(data'high - 1 downto 0) <= data(data'high downto 1); -- shift the data
            data(0) <= data_in;     
        end if;
    end process SHIFT_REGISTER; 
    
    -- Connect IO
    data_out <= data;

end architecture rtl;