-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_top_tb.vhd
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
use ieee.math_real.all;
use work.uart_pkg.all;
use work.uart_pkg_tb.all;

entity uart_top_tb is
    generic (
        do_all_tests : boolean     := false;
        config       : uart_config := uart_default_test_config
    );
end entity uart_top_tb;

architecture sim of uart_top_tb is

    --================================= Constants =====================================--
    constant time_clk     : time     := (1 sec) / config.clock_frequency; -- 1MHz clock
    constant time_skew    : time     := time_clk / 50;                    -- Data skew
    constant time_bit     : time     := (1 sec) / config.baud_rate;       -- Duration of one UART bit
    constant loop_iter    : integer  := 20;                               -- Number of test loop iteration
    constant do_test_0    : boolean  := true;                             -- Test0: TX - single data word
    constant do_test_1    : boolean  := true;                             -- Test1: RX - single data word
    constant do_test_2    : boolean  := true;                             -- Test2: TX - double data word
    constant do_test_3    : boolean  := true;                             -- Test3: TX - random data
    constant do_test_4    : boolean  := true;                             -- Test4: RX - random data
    constant do_test_5    : boolean  := true;                             -- Test5: RX - provoke framing error

    --================================= Signals =====================================--
    signal clk:                                   std_ulogic; -- Clock, rising edge                                                                        
    signal reset:                                 std_ulogic; -- Asynchrony reset                                                                          
    signal rxd:                                   std_ulogic; -- Receive data; LSB first                                                                   
    signal txd:                                   std_ulogic; -- Transmit register output (START bit, DATA bits, PARITY bit, and STOP bits); LSB First     
    signal transmitter_holding_register_data_in:  std_ulogic_vector(config.data_bits - 1 downto 0); -- Transmitter Holding Register Data Input                                                   
    signal transmitter_holding_load:              std_ulogic; -- Transmitter Holding Register Load, one clock cycle high                                   
    signal receiver_holding_register_data_out:    std_ulogic_vector(config.data_bits - 1 downto 0); -- Receiver Holding Register Data Output                                                     
    signal parity_error:                          std_ulogic; -- Parity error                                                                              
    signal framing_error:                         std_ulogic; -- Framing error                                                                             
    signal data_received:                         std_ulogic; -- Data Received, one clock cycle high                                                       
    signal transmitter_holding_register_empty:    std_ulogic; -- Transmitter Holding Register Empty                                                        
    signal transmitter_register_empty:            std_ulogic; -- Transmitter Register Empty   
    signal clk_enable:                            std_ulogic := '1';          

begin

    UART_TEST: uart_top 
        generic map (
            config   => config
        )
        port map (
            clk                                     => clk,                                                                                                         
            reset                                   => reset,                                  
            rxd                                     => rxd,                                                                                                     
            txd                                     => txd,                                       
            transmitter_holding_register_data_in    => transmitter_holding_register_data_in,                                                  
            transmitter_holding_load                => transmitter_holding_load,                                              
            receiver_holding_register_data_out      => receiver_holding_register_data_out,                                                    
            parity_error                            => parity_error,                           
            framing_error                           => framing_error,                          
            data_received                           => data_received,                                                                                
            transmitter_holding_register_empty      => transmitter_holding_register_empty,                                                              
            transmitter_register_empty              => transmitter_register_empty                      
        );

    SIMULATE: process
        variable good:          boolean                        := true;
        variable buf:           std_ulogic_vector(9 downto 0)  := (others => '0');
        variable temp:          std_ulogic_vector(7 downto 0)  := (others => '0');
        variable seed1, seed2:  positive;
        variable rand:          real;
    begin

        -- Init
        Report "Init...";
        reset                                   <= '1';
        rxd                                     <= '1';
        transmitter_holding_register_data_in    <= (others => 'X');
        transmitter_holding_load                <= '0';
        wait for 5 * time_clk;
        wait until rising_edge(clk); wait for time_skew;
        reset   <=  '0';
        wait until rising_edge(clk); wait for time_skew;
        wait until rising_edge(clk); wait for time_skew;

        -- Test0: TX - single data word
        if do_all_tests or do_test_0 then
            Report "Test0: TX - single data word";
            wait until rising_edge(clk); wait for time_skew;
            -- Idle setting
            assert (txd = '1') report "Error: TXD not idle" severity failure;
            if not (txd = '1') then good := false; end if;
            assert (transmitter_holding_register_empty = '1') report "Error: Transmitter Holding Register Not Empty " severity failure;
            if not (transmitter_holding_register_empty = '1') then good := false; end if;
            assert (transmitter_register_empty = '1') report "Error: Transmitter Register Not Empty" severity failure;
            if not (transmitter_register_empty = '1') then good := false; end if;
            -- Start transfer
            transmitter_holding_register_data_in    <= x"55";
            transmitter_holding_load                <= '1';
            wait until rising_edge(clk); wait for time_skew;
            transmitter_holding_register_data_in    <= (others => 'X');
            transmitter_holding_load                <= '0';
            -- Wait for start
            wait until falling_edge(txd);
            -- Start sampling
            wait for (time_bit / 2);
            for i in buf'low to buf'high loop
                buf(i) := txd;
                if (i /= buf'high) then -- allows triggering on next start bit
                    wait for time_bit;     -- next bit
                end if;
            end loop;
            assert ((buf(buf'left) = '1') and (buf(buf'right) = '0')) report "Error: Data Frame" severity failure;
            if not ((buf(buf'left) = '1') and (buf(buf'right) = '0')) then good := false; end if;
            assert (buf(buf'left - 1 downto buf'right + 1) = x"55") report "Error: Data Value" severity failure;
            if not (buf(buf'left - 1 downto buf'right + 1) = x"55") then good := false; end if;
            while (transmitter_register_empty = '0') loop
                wait until rising_edge(clk); wait for time_skew;
            end loop; 
            wait for 10 * time_clk;
        end if;

        -- Test1: RX - single data word
        if do_all_tests or do_test_1 then
            Report "Test1: RX - single data word";
            wait until rising_edge(clk); wait for time_skew;
            -- Idle setting
            assert (receiver_holding_register_data_out = x"00") report "Error: Receive Hold Register" severity failure;
            if not (receiver_holding_register_data_out = x"00") then good := false; end if;
            assert (parity_error  = '0') report "Error: Parity Error" severity failure;
            if not (parity_error  = '0') then good := false; end if;
            assert (framing_error = '0') report "Error: Framing Error" severity failure;
            if not (framing_error = '0') then good := false; end if;
            assert (data_received = '0') report "Error: Data Received Error" severity failure;
            if not (data_received = '0') then good := false; end if;
            -- Create test data
            buf := '1' & x"AA" & '0'; -- Reverse order cause in UART is LSB send as first
            for i in buf'low to buf'high loop
                rxd <= buf(i);  -- set bit
                wait for time_bit; -- next bit
            end loop;
            assert (framing_error = '0') report "Error: Framing Error" severity failure;
            if not (framing_error = '0') then good := false; end if;
            assert (receiver_holding_register_data_out = x"AA") report "Error: Receive Hold Register" severity failure;
            if not (receiver_holding_register_data_out = x"AA") then good := false; end if;
            wait for 10 * time_clk;
        end if;

        -- Test2: TX - double data word
        if do_all_tests or do_test_2 then
            Report "Test2: TX - double data word";
            wait until rising_edge(clk); wait for time_skew;
            -- First data word
            transmitter_holding_register_data_in <= x"47";
            transmitter_holding_load             <= '1';
            wait until rising_edge(clk); wait for time_skew;
            transmitter_holding_register_data_in <= (others => '0');
            transmitter_holding_load             <= '0';
            wait until rising_edge(clk); wait for time_skew;
            -- Second data word
            transmitter_holding_register_data_in <= x"11";
            transmitter_holding_load             <= '1';
            wait until rising_edge(clk); wait for time_skew;
            transmitter_holding_register_data_in <= (others => '0');
            transmitter_holding_load             <= '0';
            wait until rising_edge(clk); wait for time_skew;
            -- Wait for start bit
            if txd = '1' then
                while txd = '1' loop
                    wait until rising_edge(clk); wait for time_skew; 
                end loop; 
            end if;
            wait for time_bit / 2;
            -- Record first data word and check
            for i in buf'low to buf'high loop
                buf(i) := txd;
                if (i /= buf'high) then -- allows triggering on next start bit
                    wait for time_bit;     -- next bit
                end if;
            end loop;
            assert ((buf(buf'left) = '1') and (buf(buf'right) = '0')) report "Error: Data Frame Val1" severity failure;
            if not ((buf(buf'left) = '1') and (buf(buf'right) = '0')) then good := false; end if;
            assert (buf(buf'left - 1 downto buf'right + 1) = x"47") report "Error: Data Value Val1" severity failure;
            if not (buf(buf'left - 1 downto buf'right + 1) = x"47") then good := false; end if;
            -- Record second data word and check
            wait until falling_edge(txd);   -- wait for startbit
            wait for time_bit / 2;
            for i in buf'low to buf'high loop
                buf(i) := txd;
                if (i /= buf'high) then -- allows triggering on next start bit
                    wait for time_bit;     -- next bit
                end if;
            end loop;
            assert ((buf(buf'left) = '1') and (buf(buf'right) = '0')) report "Error: Data Frame Val1" severity failure;
            if not ((buf(buf'left) = '1') and (buf(buf'right) = '0')) then good := false; end if;
            assert (buf(buf'left - 1 downto buf'right + 1) = x"11") report "Error: Data Value Val1" severity failure;
            if not (buf(buf'left - 1 downto buf'right + 1) = x"11") then good := false; end if;
            while transmitter_register_empty = '0' loop
                wait until rising_edge(clk); wait for time_skew; 
            end loop ;
            wait for 10 * time_clk;
        end if;

        -- Test3: TX - random data
        if do_all_tests or do_test_3 then
            Report "Test3: TX - random data";
            wait until rising_edge(clk); wait for time_skew;
            uniform(seed1, seed2, rand); -- dummy read, otherwise first rand is zero
            -- performs multi word send
            for i in 0 to loop_iter - 1 loop
                -- rand  data
                uniform(seed1, seed2, rand); -- random nummber
                temp := std_ulogic_vector(to_unsigned(integer(round(rand * (2.0**temp'length - 1.0))), temp'length));
                -- fill in first data word
                transmitter_holding_register_data_in <= temp;
                transmitter_holding_load <= '1';
                wait until rising_edge(clk); wait for time_skew;
                transmitter_holding_register_data_in <= (others => 'X');
                transmitter_holding_load <= '0';
                -- Wait for start bit
                wait until (txd = '0');
                wait for time_bit / 2;
                -- Record and check
                for j in buf'low to buf'high loop
                    buf(j) := txd;
                    if (j /= buf'high) then
                        wait for time_bit;
                    end if;
                end loop;
                assert ((buf(buf'left) = '1') and (buf(buf'right) = '0')) report "Error: Data Frame" severity failure;
                if not ((buf(buf'left) = '1') and (buf(buf'right) = '0')) then good := false; end if;
                assert (buf(buf'left - 1 downto buf'right + 1) = temp) report "Error: Data Value" severity failure;
                if not (buf(buf'left - 1 downto buf'right + 1) = temp) then good := false; end if;
                while transmitter_register_empty = '0' loop
                    wait until rising_edge(clk); wait for time_skew; 
                end loop;
                wait for 10 * time_clk;
            end loop;
        end if;

        -- Test4: RX - random data
        if do_all_tests or do_test_4 then
            Report "Test4: RX - random data";
            wait until rising_edge(clk); wait for time_skew;
            uniform(seed1, seed2, rand); -- dummy read, otherwise first rand is zero
            for i in 0 to loop_iter - 1 loop
                -- rand  data
                uniform(seed1, seed2, rand); -- random nummber
                temp   := std_ulogic_vector(to_unsigned(integer(round(rand * (2.0**temp'length - 1.0))), temp'length));
                buf := '1' & temp & '0';
                for j in buf'low to buf'high loop
                    buf(j) := txd;
                    if (j /= buf'high) then
                        wait for time_bit;
                    end if;
                end loop;
                wait until rising_edge(data_received);
                assert (receiver_holding_register_data_out = temp) report "Error: Data Value" & integer'image(i) severity failure;
                if not (receiver_holding_register_data_out = temp) then good := false; end if;
                assert (framing_error = '0') report "Error: Framing error frame " & integer'image(i) severity failure;
                if not (framing_error = '0') then good := false; end if;
            end loop;
            wait for 10 * time_clk;
        end if;

        -- Test5: RX - provoke framing error
        if do_all_tests or do_test_5 then
            Report "Test5: RX - provoke framing error";
            wait until rising_edge(clk); wait for time_skew;
            for i in 0 to 10 loop
                rxd <= '0';
                wait for time_bit;
            end loop;
            assert (receiver_holding_register_data_out = x"00") report "Error: Data Value" severity failure;
            if not (receiver_holding_register_data_out = x"00") then good := false; end if;
            assert (framing_error = '1') report "Error: Framing error expected" severity failure;
            if not (framing_error = '1') then good := false; end if;
            wait for 10 * time_clk;
        end if;

        Report "End TB...";     -- sim finished
        if (good) then
            Report "Test SUCCESSFUL";
        else
            Report "Test FAILED" severity failure;
        end if;
        wait until falling_edge(clk); wait for time_skew;
        clk_enable <= '0';
        wait;                   -- stop process continuous run
        
    end process SIMULATE;
    
    P_CLK : process
    variable v_clk : std_ulogic := '0';
    begin
        while (clk_enable = '1') loop
            clk <= v_clk;
            v_clk := not v_clk;
            wait for time_clk/2;
        end loop;
        wait;
    end process P_CLK; 
    
end architecture sim;