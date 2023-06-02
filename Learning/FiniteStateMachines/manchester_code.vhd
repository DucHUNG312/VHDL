library ieee;
use ieee.std_logic_1164.all;

entity manchester_code is
	port(
		clk, din : in std_logic;
		dout     : out std_logic
	);
end manchester_code;

architecture arch of manchester_code is
begin
	-- glitch will occure on transition of signal din
	dout <= clk xor din;
end arch;