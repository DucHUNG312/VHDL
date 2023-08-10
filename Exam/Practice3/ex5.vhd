library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity ex5 is
    port (
        clk: in std_logic;
        d: in std_logic;
        q, q_not: out std_logic
    );
end entity ex5;

architecture rtl of ex5 is
    signal q_sr_1: std_logic := '0';
    signal q_not_sr_1: std_logic := '0';

    component ex4 is 
    port (
        e, r, s: in std_logic;
        q, q_not: out std_logic
    );
    end component ex4;
begin
    sr1: ex4
    port map (
        e => not clk,
        r => not d,
        s => d,
        q => q_sr_1,
        q_not => q_not_sr_1
    );

    sr2: ex4
    port map (
        e => clk,
        r => not q_sr_1,
        s => q_sr_1,
        q => q,
        q_not => q_not
    );
end architecture rtl;