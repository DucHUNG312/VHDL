-- =============================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            12/06/2023
--
-- FILE:            uart_tx.vhd
--
-- DESCRIPTION:     UART Transmitter
--                  This VHDL file contains the implementation of a UART transmitter.
--                  It takes in data to be transmitted (data_stream_in) and generates
--                  the corresponding serial data stream (tx) at the desired baud rate.
--                  The transmitter sends the data one bit at a time, starting with a
--                  start bit (0), followed by the data bits (lsb first), and ending
--                  with a stop bit (1). The baud rate is controlled by the input clock
--                  (clk) and the baud tick (tx_baud_tick).
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

entity uart_tx is
    generic(
        config: uart_config := uart_default_config
    );
    port (
        clk:                  in std_ulogic;
        reset:                in std_ulogic;
        tx_baud_tick:         in std_ulogic;
        data_stream_in:       in std_ulogic_vector(config.data_bits - 1 downto 0);
        data_stream_in_std:   in std_ulogic;  -- indicates whether valid data is present on the data_stream_in port
        data_stream_in_ack:   out std_ulogic; --  acknowledges the reception of valid data when the transmitter successfully receives and processes the valid data on data_stream_in
        tx:                   out std_ulogic
    );
end entity uart_tx;

architecture rtl of uart_tx is
    type uart_tx_states is (tx_send_start_bit, tx_send_data, tx_send_stop_bit);

-- =====================================================================================================================================
-- |          Signals               |                                 Data Type                                    |       Value        |
-- =====================================================================================================================================
    signal uart_tx_state            :     uart_tx_states                                                           := tx_send_start_bit;                          
    signal uart_tx_count            :     unsigned(integer(ceil(log2(real(config.data_bits)))) - 1 downto 0)       := (others => '0');
    signal uart_tx_data             :     std_ulogic                                                               := '1';
    signal uart_tx_data_vec         :     std_ulogic_vector(config.data_bits - 1 downto 0)                         := (others => '0');
    signal uart_rx_data_in_ack      :     std_ulogic                                                               := '0'; 
-- =====================================================================================================================================
begin

    -- UART_SEND_DATA
    UART_SEND_DATA : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_tx_data <= '1';
                uart_tx_data_vec <= (others => '0');
                uart_tx_count <= (others => '0');
                uart_tx_state <= tx_send_start_bit;
                uart_rx_data_in_ack <= '0';
            else 
                uart_rx_data_in_ack <= '0';
                case uart_tx_state is
                    when tx_send_start_bit =>
                        if tx_baud_tick = '1' and data_stream_in_std = '1' then
                            uart_tx_data <= '0';
                            uart_tx_state <= tx_send_data;
                            uart_tx_count <= (others => '0');
                            uart_rx_data_in_ack <= '1';
                            uart_tx_data_vec <= data_stream_in;
                        end if;
                    when tx_send_data =>
                        if tx_baud_tick = '1' then
                            uart_tx_data <= uart_tx_data_vec(0);
                            uart_tx_data_vec(uart_tx_data_vec'high - 1 downto 0) <= uart_tx_data_vec(uart_tx_data_vec'high downto 1);
                            if uart_tx_count < config.data_bits - 1 then
                                uart_tx_count <= uart_tx_count + 1;
                            else 
                                uart_tx_count <= (others => '0');
                                uart_tx_state <= tx_send_stop_bit;
                            end if;
                        end if;
                    when tx_send_stop_bit =>
                        if tx_baud_tick = '1' then
                            uart_tx_data <= '1';
                            uart_tx_state <= tx_send_start_bit;
                        end if;
                    when others =>
                        uart_tx_data <= '1';
                        uart_tx_state <= tx_send_start_bit;
                end case;
            end if;
        end if;
    end process ; -- UART_SEND_DATA

    -- Connect IO
    data_stream_in_ack <= uart_rx_data_in_ack;
    tx                 <= uart_tx_data;
    
end architecture rtl;


