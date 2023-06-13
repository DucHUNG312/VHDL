-- ===========================================================================================
-- AUTHOR:          Le Vu Duc Hung
--
-- DATE:            12/06/2023
--
-- FILE:            uart_top.vhd
--
-- DESCRIPTION:     This file describes the top-level entity for UART system. It instantiates
--                  the UART loopback component and provides interfaces for the clock, reset,
--                  rxd (receive data), and txd (transmit data) signals.
-- ===========================================================================================
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
-- ===========================================================================================

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
        clk          : in std_ulogic;
        user_reset   : in std_ulogic;
        rs232_rxd    : in std_ulogic;  
        rs232_txd    : out std_ulogic 
    );
end entity uart_top;

architecture rtl of uart_top is

    --================================= UART_LOOPBACK ===================================--
    component uart_loopback is
        generic(
            config: uart_config := uart_default_config
        );
        port (
            clk:   in std_ulogic;
            reset: in std_ulogic;
            rx:    in std_ulogic;
            tx:    out std_ulogic
        );
    end component uart_loopback;

-- ===================================================================
-- |    Signals        |         Data Type      |       Value        |
-- ===================================================================
    signal tx          :        std_ulogic;                         
    signal rx          :        std_ulogic;
    signal rx_sync     :        std_ulogic;
    signal reset       :        std_ulogic;
    signal reset_sync  :        std_ulogic;
-- ===================================================================

begin
    --================================= UART_LOOPBACK_INSTANCE ===================================--
    UART_LOOPBACK_INSTANCE : uart_loopback
    generic map (
        config      => config
    )
    port map (
        clk         => clk,
        reset       => reset,
        rx          => rx,
        tx          => tx
    );

    --================================= DEGLITCH INPUTS ===================================--
    DEGLITCH : process(clk)
    begin
        if rising_edge(clk) then
            rx_sync    <= rs232_rxd;
            rx         <= rx_sync;
            reset_sync <= user_reset;
            reset      <= reset_sync;
            rs232_txd  <= tx;
		  end if;
    end process; -- DEGLITCH
    
end architecture rtl;