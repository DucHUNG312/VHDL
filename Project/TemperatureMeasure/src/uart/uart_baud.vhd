-- =========================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_baud.vhd
--
-- @date:            14/06/2023
--
-- @description:     This file defines the entity `uart_baud` which represents a UART (Universal Asynchronous 
--                   Receiver-Transmitter) baud rate generator. It generates the necessary signals for transmitting
--                   and receiving data at a specific baud rate. The module operates on a clock signal (`clk`) and 
--                   receives a `reset` signal for initialization. The module provides various output signals for 
--                   controlling the data transfer process, including `busy` to indicate activity, `shift_register_load` 
--                   for parallel loading of the shift register, `shift_register_begin` and `shift_register_middle` 
--                   for shifting the bits in the shift register during transmission or reception, and 
--                   `shift_register_capture` for capturing received bits. The module implements a finite state machine 
--                   to control the data transfer process based on the current state and input signals.
-- =========================================================================================================================
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
-- =========================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.uart_pkg.all;

entity uart_baud is
    generic (
        config: uart_config := uart_default_config
    );
    port (
        clk:                        in  std_ulogic; -- clock, rising edge
        reset:                      in  std_ulogic; -- reset
        start:                      in  std_ulogic; -- start interaction

        busy:                       out std_ulogic; -- transfer is activing
        shift_register_load:        out std_ulogic; -- load parallel input of shift register
        shift_register_begin:       out std_ulogic; -- shift pulse TBIT (time per bit) begin
        shift_register_middle:      out std_ulogic; -- shift pulse TBIT (time per bit) middle
        shift_register_capture:     out std_ulogic  -- all bits in shift register transfered
    );
end entity uart_baud;

architecture rtl of uart_baud is

    --================================= Constants =====================================--
    constant bit_counter_width:  integer := integer(ceil(log2(real(config.num_bits + 1)))); -- bit counter for shift register
    constant baud_counter_width: integer := integer(ceil(log2(real(config.clk_div + 1))));   -- haft clock counter width

    --================================= Types =====================================--
    type uart_baud_bit is (idle, transfer, transfer_end);

    --================================= Signal =====================================--

-- ======================================================================================================================================================================================
-- |      Baud Counter Signals      |                                 Data Type                                    |       Value       |                   Description                  |
-- ======================================================================================================================================================================================
    signal baud_counter_count       :     unsigned(baud_counter_width - 1 downto 0)                                := (others => '0')  ;   -- double baud rate counter count            |
    signal baud_counter_reset       :     std_ulogic                                                               := '0'              ;   -- clear baud counter value                  |
    signal baud_counter_preset      :     std_ulogic                                                               := '0'              ;   -- preload with half clock divider value     |
    signal baud_counter_enable      :     std_ulogic                                                               := '0'              ;   -- enable baut counter                       |
    signal baud_half_period         :     std_ulogic                                                               := '0'              ;   -- distinguish first/second half period      |                         
    signal baud_half_period_enable  :     std_ulogic                                                               := '0'              ;   -- enable toggle Flip-Flop                   |
    signal baud_counter_is_zero     :     std_ulogic                                                               := '0'              ;   -- has zero count                            |
-- ======================================================================================================================================================================================
-- |      Bit Counter Signals       |                                 Data Type                                    |       Value       |                   Description                  |
-- ======================================================================================================================================================================================
    signal bit_counter_count        :     unsigned(bit_counter_width - 1 downto 0)                                 := (others => '0')  ;   -- bit counter, needed for FSMs end of shift |
    signal bit_counter_preset       :     std_ulogic                                                               := '0'              ;   -- preload bit counter                       |
    signal bit_counter_is_zero      :     std_ulogic                                                               := '0'              ;   -- has zero count                            |
    signal bit_counter_enable       :     std_ulogic                                                               := '0'              ;   -- enable counters decrement                 |
-- ======================================================================================================================================================================================
-- |  Finite State Machine Signals  |                                 Data Type                                    |       Value       |                   Description                  |
-- ======================================================================================================================================================================================
    signal current_state            :     uart_baud_bit                                                            := idle             ;   -- FSM state                                 |               
    signal next_state               :     uart_baud_bit                                                            := idle             ;   -- next state                                |
-- ======================================================================================================================================================================================

begin
    
    --================================= BAUD_COUNTER & CONTROL =====================================--
    -- Register
    BAUD_COUNTER : process(clk, reset)
    begin
        if reset = '1' then
            baud_counter_count <= (others => '0'); -- double baud rate counter
            baud_half_period   <= '1';             -- toggle Flip-Flop
        elsif rising_edge(clk) then
            -- Baud generator
            if baud_counter_reset = '1' then 
                baud_counter_count <= (others => '0');
            elsif baud_counter_preset = '1' then
                baud_counter_count <= to_unsigned(config.clk_div - 1, baud_counter_count'length);
            elsif baud_counter_enable = '1' then
                baud_counter_count <= baud_counter_count - 1;
            end if;
            -- Baud half period
            if baud_counter_reset = '1' then 
                baud_half_period <= '1'; -- marks first half period of TBIT
            elsif baud_half_period_enable = '1' then
                baud_half_period <= not baud_half_period;
            end if;
        end if;
    end process BAUD_COUNTER;

    -- Control
    with current_state select                       -- clear counter
        baud_counter_reset      <= '1' when idle,   -- nothing to do
                                   '0' when others; -- counter run
    with current_state select                                          -- clear counter
        baud_counter_preset     <= baud_counter_is_zero when transfer, -- next half period cycle
                                                    '0' when others;
    with current_state select                             -- enable
        baud_counter_enable     <= '1' when transfer,     -- count to achieve targe baud rate
                                   '1' when transfer_end, -- last half baud cycle
                                   '0' when others; 
    with current_state select                                          -- toggle
        baud_half_period_enable <= baud_counter_is_zero when transfer, -- marks first/second half period
                                                    '0' when others;
    
    -- Flags
    baud_counter_is_zero <= '1' when (to_01(baud_counter_count) = 0) else '0';


    --================================= BIT_COUNTER & CONTROL =====================================--
    -- Register
    BIT_COUNTER : process(clk, reset)
    begin
        if reset = '1' then
            bit_counter_count <= (others => '0');
        elsif rising_edge(clk) then
            if bit_counter_preset = '1' then
                bit_counter_count <= to_unsigned(config.num_bits - 1, bit_counter_count'length);
            elsif bit_counter_enable = '1' then
                bit_counter_count <= bit_counter_count - 1;
            end if;
        end if;
    end process BIT_COUNTER; 

    -- Control
    with current_state select                                                                                  -- reload
        bit_counter_preset <= bit_counter_is_zero and baud_counter_is_zero and baud_half_period when transfer, -- start of cycke, reload output shift register
                                                                                            '0' when others;     
    with current_state select
        bit_counter_enable <= baud_counter_is_zero and baud_half_period                         when transfer, -- baud cycle complete generated, next bit
                                                                                            '0' when others;  
    
    -- Flags
    bit_counter_is_zero <= '1' when (to_01(bit_counter_count) = 0) else '0';


    --============================================= FSM ===========================================--
    -- FSM Register
    FSM_RESIGER : process(clk, reset)
    begin
        if reset = '1' then
            current_state <= idle;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process FSM_RESIGER;

    -- Next state
    STATE_NEXT : process(current_state, start, baud_counter_is_zero, bit_counter_is_zero, baud_half_period)
    begin
        next_state <= current_state;
        
        case current_state is

            when idle =>
                if start = '1' then
                    next_state <= transfer;
                else
                    next_state <= idle;
                end if;

            when transfer =>
                if (baud_counter_is_zero = '1') and (bit_counter_is_zero = '1') and (baud_half_period = '0') then
                    if start = '1' then -- new data is available, run in next cycle
                        next_state <= transfer;
                    else
                        if config.skip_last_bit then -- RX mode
                            next_state <= idle;
                        else                         -- TX mode
                            next_state <= transfer_end;
                        end if;
                    end if;
                else
                    next_state <= transfer;
                end if;

            when transfer_end =>
                if baud_counter_is_zero = '1' then
                    next_state <= idle;
                else 
                    next_state <= transfer_end;
                end if;
                
            when others =>
                next_state <= idle;
                
        end case;
    end process STATE_NEXT;


    -- Connect IO
    shift_register_load    <= bit_counter_preset;                                                       -- parallel load of TX shift register
    shift_register_capture <= baud_counter_preset and (not baud_half_period) and bit_counter_is_zero;   -- capture RX shift register in parallel register
    shift_register_begin   <= baud_counter_preset and baud_half_period;                                 -- TX shift register: shift forward, begin of baud period
    shift_register_middle  <= baud_counter_preset and (not baud_half_period);                           -- RX shift register: shift forward, middle of baud period
    busy                   <= '0' when current_state = idle else '1';                                   -- signal activity

end architecture rtl;