-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            adc_top.vhd
--
-- @date:            13/06/2023
--
-- @description:     This file contains the top-level entity and architecture for the ADC0832 module. It implements
--                   the interface and functionality of the ADC module, including clock division, sampling,
--                   state management, data shifting, and output generation. The measured values are output through 
--                   "measured_values_1" and "measured_values_2" ports. 
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
use work.adc_pkg.all;

entity adc_top is
    generic (
        config: adc_config := adc_default_config
    );
    port (
        clk_in:                 in std_ulogic; 
        adc_data_out:           in std_ulogic;

        adc_data_in:            out std_ulogic;
        adc_chip_select:        out std_ulogic;
        adc_clk:                out std_ulogic;
        clk_sampling:           out std_ulogic; -- Sampling clock (not used by the chip, but may be used to synchronize to other hardware blocks, such as controllers). When this signal is zero, the chip is sampling
        measured_values_1:      out std_ulogic_vector(config.data_bits - 1 downto 0);
        measured_values_2:      out std_ulogic_vector(config.data_bits - 1 downto 0);
        measured_values_ack:    out std_ulogic
    );
end entity adc_top;

architecture rtl of adc_top is

-- ===================================================================================================================
-- |        Signals          |                                   Data Type                    |         Value        |
-- ===================================================================================================================
    signal clk               :       std_ulogic                                               := '0';
    signal sampling          :       std_ulogic                                               := '0';
    signal state             :       std_ulogic_vector(3 downto 0)                            := (others => '0');
    signal reset             :       std_ulogic                                               := '0';
    signal end_reception     :       std_ulogic                                               := '0';
    signal end_reception_ack :       std_ulogic                                               := '0';
    signal shifting_bytes    :       std_ulogic_vector(config.data_bits - 1 downto 0)         := (others => '0');
    signal channel           :       std_ulogic                                               := '0';
    signal data_in           :       std_ulogic                                               := '0';
-- ===================================================================================================================

begin
    end_reception <= '1' when (unsigned(state) = to_unsigned(config.end_reception_state, config.state_bits)) else '0';

    --======================================== FREQUENCY_DIVIDER_INSTANCE ==========================================--
    CLOCK_DIVIDER: adc_frequency_divider
    generic map (
        config         => config
    )
    port map (
        clk            => clk_in,
        frequency_out  => clk
    );


    --======================================= FREQUENCY_DIVIDER_LOW_INSTANCE ========================================--
    SAMPLING_DIVIDER: adc_frequency_divider_low
    generic map (
        config         => config
    )
    port map (
        clk            => clk,
        frequency_out  => sampling
    );

    --============================================ ADC_COUNTER_INSTANCE ===============================================--
    COUNTER: adc_counter 
    generic map (
        config         => config
    )
    port map (
        clk            => clk,
        reset          => reset,
        enable         => not end_reception,
        count_out      => state,
        overflow       => open
    );

    
    --========================================= ADC_SHIFT_REGISTER_INSTANCE ============================================--
    SHIFT_REGISTER: adc_shift_register
    generic map (
        config         => config
    )
    port map (
        clk            => clk,
        data_in        => adc_data_out,
        data_out       => shifting_bytes
    );

    -- RESET_SIGNAL
    RESET_SIGNAL: process(clk)
    begin
        if rising_edge(clk) then
            -- reset when ADC is in sampling state or reception process has ended for the current channel and it's not the last channel
            reset <= sampling or (end_reception and (not channel)); 
        end if;
    end process RESET_SIGNAL; 
    
   
    -- STORE_DATA
    STORE_DATA: process(end_reception)
    begin
        if rising_edge(end_reception) then
            end_reception_ack <= '1'; 
            if channel = '0' then
                measured_values_1 <= shifting_bytes;
            else
                measured_values_2 <= shifting_bytes;
            end if;
            channel <= not channel; -- alternately stored data in the 2 channels
        end if;
    end process STORE_DATA; 

    -- ADC_STATE
    ADC_STATE: process(clk)
    begin
        if rising_edge(clk) then
            if unsigned(state) = to_unsigned(0, config.state_bits) then
                data_in <= '1'; -- start bit
            elsif unsigned(state) = to_unsigned(1, config.state_bits) then
                data_in <= '1'; -- SGL/DIF
            elsif unsigned(state) = to_unsigned(2, config.state_bits) then
                data_in <= channel; -- ODD/SIGN
            else
                data_in <= 'X';
            end if;
        end if; 
    end process ADC_STATE; 

    -- Connect IO
    adc_clk <= clk;
    adc_chip_select <= reset;
    adc_data_in <= data_in;
    clk_sampling <= sampling;
    measured_values_ack <= end_reception_ack;

end architecture rtl;