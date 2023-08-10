library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity ex4_3_b is
    port (
        x: in std_logic_vector(9 downto 0);
        y: out std_logic
    );
end entity ex4_3_b;

architecture rtl of ex4_3_b is
    signal x_tmp: std_logic := x(0);
    signal and_gate_output: std_logic := '0';

    component ex4_3_a is
	  port (
			x: in std_logic_vector(9 downto 0);
			y: out std_logic
	  );
    end component ex4_3_a;
begin
    EX43: ex4_3_a
    port map (
        x => x,
        y => and_gate_output
    );

    y <= not and_gate_output;
end architecture rtl;