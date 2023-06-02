library ieee;
use ieee.std_logic_1164.all;

entity glitchEx is
	port(
		in0, in1, sel : in std_logic;
		z             : out std_logic
	);
end glitchEx;

architecture arch of glitchEx is
	signal not_sel            : std_logic;
	signal and_out1, and_out2 : std_logic;
begin
	not_sel <= not sel;
	and_out1 <= not_sel and in0;
	and_out2 <= sel and in1;
	z <= and_out1 and and_out2;

	-- Comment above line and uncomment below line to remove glitches
	-- z <= and_out1 or and_out2 or (in0 and in1); 
end arch;