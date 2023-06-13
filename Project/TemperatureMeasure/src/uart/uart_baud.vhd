-- =============================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            12/06/2023
--
-- FILE:            uart_baud.vhd
--
-- DESCRIPTION:     UART Baud Rate Generator
--                  This file contains the implementation of a baud rate generator
--                  for UART communication. It generates clock ticks at the required
--                  baud rate based on the input clock frequency (50MHz) and desired 
--                  baud rate (19200). The generated ticks are used for synchronizing 
--                  the transmission and reception of data between UART devices. The 
--                  baud rate generator uses oversampling techniques to ensure accurate 
--                  timing and supports both transmit (tx_tick) and receive (rx_tick) clocks.
-- =============================================================================
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
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.uart_pkg.all;

entity uart_baud is
    generic (
        config:   uart_config := uart_default_config
    );
    port(
        clk:      in  std_ulogic;
        reset:    in  std_ulogic;
        rx_tick:  out std_ulogic;
        tx_tick:  out std_ulogic
    );
end entity uart_baud;

architecture rtl of uart_baud is
    --================================= Constants =====================================--
    constant c_tx_div:       integer := config.clock_frequency / config.baud_rate;        -- 2605
    constant c_rx_div:       integer := config.clock_frequency / (config.baud_rate * 16); -- 163
    constant c_tx_div_width: integer := integer(log2(real(c_tx_div))) + 1;
    constant c_rx_div_width: integer := integer(log2(real(c_rx_div))) + 1;

    --================================= Signals =====================================--
    signal tx_baud_counter: unsigned(c_tx_div_width - 1 downto 0) := (others => '0');
    signal tx_baud_tick:    std_ulogic                            := '0';
    signal rx_baud_counter: unsigned(c_rx_div_width - 1 downto 0) := (others => '0');
    signal rx_baud_tick:    std_ulogic                            := '0';
begin

    -- OVERSAMPLE_CLOCK_DIVIDER: Generate an oversampled tick (baud * 16)
    OVERSAMPLE_CLOCK_DIVIDER: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                rx_baud_counter <= (others => '0');
                rx_baud_tick <= '0';
            else
                if rx_baud_counter = c_rx_div then
                    rx_baud_counter <= (others => '0');
                    rx_baud_tick <= '1';
                else
                    rx_baud_counter <= rx_baud_counter + 1;
                    rx_baud_tick <= '0';
                end if;
            end if;
        end if;
    end process; -- OVERSAMPLE_CLOCK_DIVIDER

    -- TX_CLOCK_DIVIDER: Generate baud ticks at the required rate based on the input clock frequency and baud rate
    TX_CLOCK_DIVIDER: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                tx_baud_counter <= (others => '0');
                tx_baud_tick <= '0';
            else 
                if tx_baud_counter = c_tx_div then
                    tx_baud_counter <= (others => '0');
                    tx_baud_tick <= '1';
                else
                    tx_baud_counter <= tx_baud_counter + 1;
                    tx_baud_tick <= '0';
                end if;
            end if;
        end if;
    end process; -- TX_CLOCK_DIVIDER

    -- Connect IO
    rx_tick <= rx_baud_tick;
    tx_tick <= tx_baud_tick;
    
end architecture rtl;
