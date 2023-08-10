library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex4 is
    port (
        e, r, s: in std_logic;
        q, q_not: out std_logic
    );
end entity ex4;

architecture rtl of ex4 is
    signal q_feedback: std_logic := '0';
    signal q_not_feedback: std_logic := '0';
begin
    q_feedback <= (e and r) nor q_not_feedback;
    q_not_feedback <= (e and r) nor q_feedback;

    q <= q_feedback;
    q_not <= q_not_feedback;
end architecture rtl;