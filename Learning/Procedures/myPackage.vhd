library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Note that the functions and the procedures can be defined in declaration parts of the 
-- entities and architectures; but the best place for defining these are in the packages. 

package myPackage is
	-- contant value to add 1 i.e. num1 + 1 
	constant S : signed (3 downto 0) := "0001";
	
	procedure sum2num(signal a : in signed(3 downto 0);
							signal b : in signed(3 downto 0);
							signal sum : out signed(3 downto 0));
	signal f : unsigned(2 downto 0) := (others => '0');
	type stateType is (startState, continueState, stopState);
end package;

package body myPackage is
	procedure sum2num(signal a : in signed(3 downto 0);
							signal b : in signed(3 downto 0);
							signal sum : out signed(3 downto 0)) is
	begin
		sum <= a + b;
	end sum2num;
end myPackage;

