-- ==========================================================================================================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            12/06/2023
--
-- FILE:            uart.vhd
--
-- DESCRIPTION:     This file contains the implementation of a UART (Universal Asynchronous Receiver Transmitter) module in VHDL.
--                  The UART module is responsible for serial communication between a transmitter and a receiver using asynchronous communication protocol,
--                  It supports configurable data width, baud rate, and clock frequency. The module includes functionality for receiving and transmitting data
--                  streams, synchronization, filtering, and bit timing. The received data is stored in a buffer and can be read or processed when
--                  the data stream is stable. The module follows the start, data, stop bit format for transmitting and receiving data.
--                  This implementation is based on oversampling the incoming data to accurately detect the transmitted bits.
--                  The module also includes a baud generator to generate the appropriate baud rate ticks based on the input clock frequency and baud rate.
--                  The implementation uses synchronous processes and rising-edge triggered flip-flops to ensure proper timing and synchronization.
-- ==========================================================================================================================================================
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
-- ==========================================================================================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
use work.uart_pkg.all;

entity uart is
    generic (
        config:   uart_config := uart_default_config
    );
    port(
    -- =============================================================================================================================================================================================================
    -- |          Name          |     I/O type    |                      Data Type                    |                                                     Comment                                                |
    -- =============================================================================================================================================================================================================
        clk                     :       in          std_ulogic                                        ;
        reset                   :       in          std_ulogic                                        ;
        data_stream_in          :       in          std_ulogic_vector(config.data_bits - 1 downto 0)  ;
        data_stream_in_std      :       in          std_ulogic                                        ; --indicates whether valid data is present on the data_stream_in port
        rx                      :       in          std_ulogic                                        ;
        data_stream_out         :       out         std_ulogic_vector(config.data_bits - 1 downto 0)  ;
        data_stream_out_stb     :       out         std_ulogic                                        ; -- indicates the validity of the received data on the data_stream_out vector
        data_stream_in_ack      :       out         std_ulogic                                        ; -- acknowledges when the transmitter successfully receives and processes the valid data on data_stream_in
        tx                      :       out         std_ulogic
    -- =============================================================================================================================================================================================================
    );
end entity uart;

architecture rtl of uart is

    

    --=========================================================== Constants =========================================================--
    constant c_tx_div:        integer := config.clock_frequency / config.baud_rate;        -- 2605
    constant c_rx_div:        integer := config.clock_frequency / (config.baud_rate * 16); -- 163
    constant c_tx_div_width:  integer := integer(log2(real(c_tx_div))) + 1;
    constant c_rx_div_width:  integer := integer(log2(real(c_rx_div))) + 1;


    --=========================================================== Types =============================================================--
    type uart_rx_states is (rx_get_start_bit, rx_get_data, rx_get_stop_bit);
    type uart_tx_states is (tx_send_start_bit, tx_send_data, tx_send_stop_bit);

   
-- =====================================================================================================================================
-- |     Baud Generator Signals     |                                 Data Type                                    |       Value       |
-- =====================================================================================================================================
    signal tx_baud_counter          :     unsigned(c_tx_div_width - 1 downto 0)                                    := (others => '0');
    signal tx_baud_tick             :     std_ulogic                                                               := '0';
    signal rx_baud_counter          :     unsigned(c_rx_div_width - 1 downto 0)                                    := (others => '0');
    signal rx_baud_tick             :     std_ulogic                                                               := '0';
-- =====================================================================================================================================
-- |        uart_rx Signals         |                                 Data Type                                    |       Value       |
-- =====================================================================================================================================
    signal uart_rx_state            :     uart_rx_states                                                           := rx_get_start_bit;                          
    signal uart_rx_count            :     unsigned(integer(ceil(log2(real(config.data_bits)))) - 1 downto 0)       := (others => '0');
    signal uart_rx_data_vec         :     std_ulogic_vector(config.data_bits - 1 downto 0)                         := (others => '0');
    signal uart_rx_data_out_sb      :     std_ulogic                                                               := '0'; 
    signal uart_rx_data_sr          :     std_ulogic_vector(1 downto 0)                                            := (others => '1');
    signal uart_rx_bit              :     std_ulogic                                                               := '1';
    signal uart_rx_filter           :     unsigned(1 downto 0)                                                     := (others => '1');
    signal uart_rx_bit_spacing      :     unsigned(integer(ceil(log2(real(config.bit_spacing)))) - 1 downto 0)     := (others => '0');
    signal uart_rx_bit_tick         :     std_ulogic                                                               := '0';
-- =====================================================================================================================================
-- |        uart_tx Signals         |                                 Data Type                                    |       Value       |
-- =====================================================================================================================================
    signal uart_tx_state            :     uart_tx_states                                                           := tx_send_start_bit;                          
    signal uart_tx_count            :     unsigned(integer(ceil(log2(real(config.data_bits)))) - 1 downto 0)       := (others => '0');
    signal uart_tx_data             :     std_ulogic                                                               := '1';
    signal uart_tx_data_vec         :     std_ulogic_vector(config.data_bits - 1 downto 0)                         := (others => '0');
    signal uart_rx_data_in_ack      :     std_ulogic                                                               := '0'; 
-- =====================================================================================================================================

begin
    -- Connect IO
    data_stream_out     <= uart_rx_data_vec;
    data_stream_out_stb <= uart_rx_data_out_sb;
    data_stream_in_ack  <= uart_rx_data_in_ack;
    tx                  <= uart_tx_data;

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


    -- RXD_SYNCHRONIZE: Synchronize the incoming received data (rxd) with the oversampled baud rate. It ensures that the received 
    -- data is sampled at the correct time to extract the transmitted bits accurately.
    RXD_SYNCHRONIZE : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_rx_data_sr <= (others => '1');
            else
                if rx_baud_tick = '1' then
                    uart_rx_data_sr(0) <= rx;
                    uart_rx_data_sr(1) <= uart_rx_data_sr(0);
                end if;
            end if;
        end if;
    end process; -- RXD_SYNCHRONIZE


    -- RXD_FILTER: Filters the received data and determines the logic level of each received bit. 
    -- It improves noise immunity, enhances bit detection reliability, and enables accurate interpretation of the transmitted data.
    RXD_FILTER : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_rx_filter <= (others => '1');
                uart_rx_bit <= '1';
            else 
                if rx_baud_tick = '1' then
                    -- filter rxd
                    if uart_rx_data_sr(1) = '1' and uart_rx_filter < 3 then
                        uart_rx_filter <= uart_rx_filter + 1;
                    elsif uart_rx_data_sr(1) = '0' and uart_rx_filter > 0 then
                        uart_rx_filter <= uart_rx_filter - 1;
                    end if;
                    -- set the rx bit
                    if uart_rx_filter = 3 then
                        uart_rx_bit <= '1';
                    elsif uart_rx_filter = 0 then
                        uart_rx_bit <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process; -- RXD_FILTER 


    -- RX_BIT_SPACING: Provided UART receiver implementation is responsible for tracking the 
    -- spacing between received bits (each bit is sampled 16 times) and determining the timing of each bit.
    RX_BIT_SPACING : process(clk)
    begin
        if rising_edge(clk) then
            uart_rx_bit_tick <= '0';
            if rx_baud_tick = '1' then
                if uart_rx_bit_spacing = config.bit_spacing - 1 then
                    uart_rx_bit_tick <= '1';
                    uart_rx_bit_spacing <= (others => '0');
                else 
                    uart_rx_bit_spacing <= uart_rx_bit_spacing + 1;
                end if;
                if uart_rx_state = rx_get_start_bit then
                    uart_rx_bit_spacing <= (others => '0');
                end if;
            end if;
        end if;
    end process; -- RX_BIT_SPACING


    -- UART_RECEIVE_DATA
    UART_RECEIVE_DATA : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_rx_state <= rx_get_start_bit;
                uart_rx_data_vec <= (others => '0');
                uart_rx_count <= (others => '0');
                uart_rx_data_out_sb <= '0';
            else 
                uart_rx_data_out_sb <= '0';
                case uart_rx_state is
                    when rx_get_start_bit =>
                        if rx_baud_tick = '1' and uart_rx_bit = '0' then
                            uart_rx_state <= rx_get_data;
                        end if;
                    when rx_get_data =>
                        if uart_rx_bit_tick = '1' then
                            uart_rx_data_vec(uart_rx_data_vec'high) <= uart_rx_bit; -- receive uart_rx_bit
                            uart_rx_data_vec(uart_rx_data_vec'high - 1 downto 0) <= uart_rx_data_vec(uart_rx_data_vec'high downto 1); -- shift the data
                            if uart_rx_count < config.data_bits - 1 then
                                uart_rx_count <= uart_rx_count + 1;
                            else 
                                uart_rx_count <= (others => '0');
                                uart_rx_state <= rx_get_stop_bit;
                            end if;
                        end if;
                    when rx_get_stop_bit =>
                        if uart_rx_bit_tick = '1' then 
                            if uart_rx_bit = '1' then
                                uart_rx_state <= rx_get_start_bit;
                                uart_rx_data_out_sb <= '1';
                            end if;
                        end if;
                    when others =>
                        uart_rx_state <= rx_get_start_bit;      
                end case;
            end if;
        end if;
    end process; -- UART_RECEIVE_DATA


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
    
end architecture rtl;