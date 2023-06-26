-- =============================================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_top.vhd
--
-- @date:            15/06/2023
--
-- @description:     This file contains the VHDL implementation of a UART (Universal Asynchronous Receiver Transmitter) top-level entity.
--                   The UART top-level entity includes the necessary components and signals to implement a serial UART interface for
--                   communication. It supports both transmitting and receiving data over a serial interface. The entity includes clock and
--                   reset signals, serial UART interface signals (RXD and TXD), and parallel interface signals for data transmission and
--                   reception. The entity provides features such as baud/bit sequencing, shift registers for data transmission and reception,
--                   error detection (framing error and parity error), and various status signals indicating the state of the UART interface.
--                   The implementation includes configurable parameters such as clock frequency, baud rate, data width, stop bit, parity,
--                   and debouncing stages.
-- =============================================================================================================================================
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
-- =============================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.uart_pkg.all;

entity uart_top is
    generic (
        config: uart_config := uart_default_config
    );
    port (
    -- =================================================================================================================================================================================================================================
    -- |               Clock/Reset               |        I/O Type       |                         Data Type                        |                                              Description                                         |
    -- =================================================================================================================================================================================================================================
        clk                                      :          in              std_ulogic                                              ;     -- Clock, rising edge                                                                        |
        reset                                    :          in              std_ulogic                                              ;     -- Asynchrony reset                                                                          |
    -- =================================================================================================================================================================================================================================
    -- |          Serial UART Interface          |        I/O Type       |                         Data Type                        |                                              Description                                         |
    -- =================================================================================================================================================================================================================================
        rxd                                      :          in              std_ulogic                                              ;     -- Receive data; LSB first                                                                   |
        txd                                      :          out             std_ulogic                                              ;     -- Transmit register output (START bit, DATA bits, PARITY bit, and STOP bits); LSB First     |
    -- =================================================================================================================================================================================================================================
    -- |            Parallel Interface           |        I/O Type       |                         Data Type                        |                                              Description                                         |
    -- =================================================================================================================================================================================================================================
        transmitter_holding_register_data_in     :          in              std_ulogic_vector(config.data_bits - 1 downto 0)        ;     -- Transmitter Holding Register Data Input                                                   |
        transmitter_holding_load                 :          in              std_ulogic                                              ;     -- Transmitter Holding Register Load, one clock cycle high                                   |
        receiver_holding_register_data_out       :          out             std_ulogic_vector(config.data_bits - 1 downto 0)        ;     -- Receiver Holding Register Data Output                                                     |
        parity_error                             :          out             std_ulogic                                              ;     -- Parity error                                                                              |
        framing_error                            :          out             std_ulogic                                              ;     -- Framing error                                                                             |
        data_received                            :          out             std_ulogic                                              ;     -- Data Received, one clock cycle high                                                       |
        transmitter_holding_register_empty       :          out             std_ulogic                                              ;     -- Transmitter Holding Register Empty                                                        |
        transmitter_register_empty               :          out             std_ulogic                                              ;     -- Transmitter Register Empty                                                                |
        busy                                     :          out             std_ulogic                                                    --                                                                                           |
    -- ================================================================================================================================================================================================================================= 
    );
end entity uart_top;

architecture rtl of uart_top is
    
    --=========================================== Constants ===========================================--
    constant baud_clkdiv: integer := integer(round(real(config.clock_frequency)/real(2*config.baud_rate))); -- TBIT / 2 clock divider

    --============================================ Signals ============================================--

-- =================================================================================================================================================================================================================
-- |            TX Signals            |                                               Data Type                                           |                                 Description                            |
-- =================================================================================================================================================================================================================
    signal tx_hold_empty              :     std_ulogic                                                                                    ;  -- Signals empty of TX hold register                                  |
    signal tx_hold_new                :     std_ulogic                                                                                    ;  -- New data to transmit flag                                          |
    signal tx_hold                    :     std_ulogic_vector(transmitter_holding_register_data_in'range)                                 ;  -- TX hold register                                                   |
    signal tx_shift_register          :     std_ulogic_vector(config.data_bits + 1 + numParBit(config.parity_inhibit) - 1 downto 0)       ;  -- +1: start bit; stop bits skipped, '1' is idle                      |
    signal tx_shift_register_load     :     std_ulogic                                                                                    ;  -- Preload serial shift out register                                  |                         
    signal tx_shift_register_shift    :     std_ulogic                                                                                    ;  -- Shift forward                                                      |
    signal tx_busy                    :     std_ulogic                                                                                    ;  -- Transmission active                                                |
-- =================================================================================================================================================================================================================
-- |            RX Signals            |                                               Data Type                                           |                                 Description                            |
-- =================================================================================================================================================================================================================
    signal rx_shift_register          :     std_ulogic_vector(config.data_bits + 1 + numParBit(config.parity_inhibit) - 1 downto 0)       ;  -- +1: start bit; stop bit skipped, direct evaluated (framing error)  |
    signal rx_shift_register_shift    :     std_ulogic                                                                                    ;  -- Shift forward                                                      |
    signal rx_shift_register_capture  :     std_ulogic                                                                                    ;  -- Load RR reg                                                        |
    signal rx_bit                     :     std_ulogic                                                                                    ;  -- Voted rx-bit                                                       |
    signal rx_bit_delayed             :     std_ulogic                                                                                    ;  -- One clock cycle delayed rx, start bit detection                    |
    signal rx_falling_edge            :     std_ulogic                                                                                    ;  -- In rxd stream negative edge detected                               |
    signal rx_busy                    :     std_ulogic                                                                                    ;  -- Receive active                                                     |
    signal framing_error_combination  :     std_ulogic                                                                                    ;  -- Calculated framing error                                           |
    signal parity_error_combination   :     std_ulogic                                                                                    ;  -- Calculated parity                                                  |
-- =================================================================================================================================================================================================================

begin
    -- Synthesis/Simulator Messages
    -- Core settings
    assert not true
    report                                                                                                                        character(LF) &
        "UART configuration:"                                                                                                   & character(LF) &
        "  Clock rate       : " & integer'image(config.clock_frequency)                                             & " Hz"     & character(LF) &
        "  Baud rate [set]  : " & integer'image(config.baud_rate)                                                   & " Bps"    & character(LF) &
        "  Baud rate [is]   : " & integer'image(integer(round(real(config.clock_frequency)/real(2*baud_clkdiv))))   & " Bps"    & character(LF) &
        "  Data width       : " & integer'image(config.data_bits)                                                               & character(LF) &
        "  Stop bit         : " & integer'image(config.stop_bit)                                                                & character(LF) &
        "  Parity enable    : " & boolean'image(not config.parity_inhibit)                                                      & character(LF) &
        "  Parity even      : " & boolean'image(config.even_parity)                                                             & character(LF) &
        "  Debounce stages  : " & integer'image(config.debouncer_stage)                                                         & character(LF) &
        "  TBIT/2 clock div : " & integer'image(baud_clkdiv)
    severity note;
    -- oversampling rate check
    assert (2 * baud_clkdiv > 15)    --! rate too low
    report                                                                 character(LF) &
        "Oversampling Rate too low"                                      & character(LF) &
        "  Oversampling [is]        : " & integer'image(2*baud_clkdiv)   & character(LF) &
        "  Oversampling [recommend] : " & integer'image(16)
    severity warning;

    --=========================================== UART_TX_PATH ===========================================--
    TX : if config.tx_impl = true generate

        -- Baud/bit sequencing generator
        TX_BAUD_BIT_GEN: uart_baud
        generic map (
            config                     => config
        )
        port map (
            clk                        => clk,                     -- clock, rising edge
            reset                      => reset,                   -- reset
            start                      => tx_hold_new,             -- start interaction

            busy                       => tx_busy,                 -- transfer is activing
            shift_register_load        => tx_shift_register_load,  -- load parallel input of shift register
            shift_register_begin       => tx_shift_register_shift, -- shift pulse TBIT (time per bit) begin
            shift_register_middle      => open,                    -- shift pulse TBIT (time per bit) middle
            shift_register_capture     => open                     -- all bits in shift register transfered
        );

        -- Register
        TX_REG : process(clk, reset)
        begin
            if reset = '1' then
                tx_hold           <= (others => '0'); -- data hold register
                tx_hold_empty     <= '1';             -- waiting for data
                tx_hold_new       <= '0';             -- new data to send
                tx_shift_register <= (others => '1'); -- idle level
            elsif rising_edge(clk) then
                -- RSFF to handle new data input and request
                if transmitter_holding_load = '1' then
                    tx_hold       <= transmitter_holding_register_data_in; -- capture parallel input
                    tx_hold_empty <= '0';
                    tx_hold_new   <= '1';
                elsif tx_shift_register_load = '1' then
                    tx_hold_empty <= '1';
                    tx_hold_new   <= '0';
                end if;
                -- TX Shift register
                if tx_shift_register_load = '1' then
                    if config.parity_inhibit then -- skip parity
                        tx_shift_register <= '0' & reverse(tx_hold); -- Start bit, Data bits, Stop bits shift in '1'
                    else                          -- implement parity
                        tx_shift_register <= '0' & reverse(tx_hold) & parity(tx_hold, config.even_parity);
                    end if;
                elsif tx_shift_register_shift = '1' then
                    tx_shift_register <= tx_shift_register(tx_shift_register'left - 1 downto tx_shift_register'right) & '1'; -- shift left, '1' UART idle
                end if;
            end if;
        end process TX_REG; 

        -- Output Assignment
        transmitter_holding_register_empty <= tx_hold_empty;                             -- hold register empty
        busy                               <= tx_busy;
        transmitter_register_empty         <= not tx_busy;                               -- transmitter register empty
        txd                                <= tx_shift_register(tx_shift_register'left); -- serial uart data

    end generate TX;

    --============================================= SKIP_TX =============================================--
    SKIP_TX : if config.tx_impl = false generate
        
        transmitter_holding_register_empty <= '0'; -- hold register empty
        transmitter_register_empty         <= '0'; -- transmitter register empty
        txd                                <= '1'; -- serial uart data

    end generate SKIP_TX;

    --=========================================== UART_RX_PATH ===========================================--
    RX: if config.rx_impl = true generate
        -- Sync & Debounce
        FILTER: uart_filter
        generic map (
            config                     => config
        )
        port map (
            clk                        => clk,   -- clock, rising edge
            reset                      => reset, -- asynchronous reset
            data_in                    => rxd,   -- serial in
            data_out                   => rx_bit -- synced & voted input bit
        );

        -- Baud/bit sequencing generator
        RX_BAUD_BIT_GEN: uart_baud
        generic map (
            config                     => config
        )
        port map (
            clk                        => clk,                       -- clock, rising edge
            reset                      => reset,                     -- reset
            start                      => rx_falling_edge,           -- start interaction

            busy                       => rx_busy,                   -- transfer is activing
            shift_register_load        => open,                      -- load parallel input of shift register
            shift_register_begin       => open,                      -- shift pulse TBIT (time per bit) begin
            shift_register_middle      => rx_shift_register_shift,   -- shift pulse TBIT (time per bit) middle
            shift_register_capture     => rx_shift_register_capture  -- all bits in shift register transfered
        );

        -- Register
        RX_REG : process(clk, reset)
        begin
            if reset = '1' then
                receiver_holding_register_data_out <= (others => '0');
                framing_error                      <= '0';
                data_received                      <= '0';
                rx_bit_delayed                     <= '1';
                rx_shift_register                  <= (others => '0');
            elsif rising_edge(clk) then
                -- DFF
                rx_bit_delayed <= rx_bit;
                data_received  <= rx_shift_register_capture;
                -- Shift Register
                if rx_shift_register_shift = '1' then -- last captured bit (stop) is direct evaluated without feeding shift register
                    rx_shift_register <= rx_shift_register(rx_shift_register'left - 1 downto rx_shift_register'right) & rx_bit;
                end if;
                -- Data Hold Register
                if rx_shift_register_capture = '1' then
                    receiver_holding_register_data_out <= reverse(rx_shift_register(rx_shift_register'left - 1 downto rx_shift_register'left - 1 - config.data_bits + 1));
                    framing_error                      <= framing_error_combination;
                end if;
            end if;
        end process RX_REG; 

        -- Glue Logic
        -- misc
        rx_falling_edge <= (not rx_bit) and rx_bit_delayed and (not rx_busy);                          -- falling edge detection, only active if not busy
        framing_error_combination <= not ((not rx_shift_register(rx_shift_register'left)) and rx_bit); -- start bit: left, stop bit shift register input
        -- parity calc & check
        PE : if config.parity_inhibit = false generate
            parity_error_combination <= parity(rx_shift_register(rx_shift_register'left - 1 downto rx_shift_register'left - 1 - config.data_bits + 1), config.even_parity) xor rx_shift_register(rx_shift_register'right); -- rx_shift_register(rx_shift_register'right) represent parity bit
        end generate PE;

        -- parity always zero
        PE_ZERO : if config.parity_inhibit = true generate
            parity_error <= '0';
        end generate PE_ZERO;

    end generate RX;

    --=========================================== SKIP_RX ===========================================--
    SKIP_RX : if config.rx_impl = false generate

        receiver_holding_register_data_out <= (others => '0');
        framing_error                      <= '0';
        parity_error                       <= '0';
        data_received                      <= '0';
        
    end generate SKIP_RX;

end architecture rtl;