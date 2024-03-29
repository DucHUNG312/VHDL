package serial_package is
  subtype stop_type is natural range 1 to 2;
  type parity_type is (none, mark, space, odd, even);
  type parity_length_type is array (parity_type) of natural range 0 to 1;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.serial_package.all;

-- bits per second (bps) = clk_in frequency / div
-- bytes per second = clk_in frequency / (div * (data_bits + stop_bits + parity + 1))
entity uart_top is
  generic (
    div: natural;
    data_bits: natural := 8;
    parity: parity_type := none;
    stop_bits: stop_type := 1
  );
  port (
    clk_in:   in std_logic;
    data_in:  in std_logic_vector((data_bits-1) downto 0);
    tx:       out std_logic
  );
end entity;

architecture rtl of uart_top is
  constant parity_length: parity_length_type := (0, 1, 1, 1, 1);
  constant last_state: natural := data_bits + stop_bits + parity_length(parity);
  signal state: natural range 0 to last_state := 0;
  signal clk: std_logic := '0';
  signal data: std_logic_vector(data_in'range) := (others => '0');
  signal parity_bit: std_logic := '0';
begin
  clock_divider: entity work.frequency_divider
    generic map ( div => div )
    port map (
      clk_in => clk_in,
      clk_out => clk
    );
     
  process(clk)
  begin  
    if rising_edge(clk) then
      if state = 0 then 
        tx <= '1';
        parity_bit <= '0'; -- reset parity
        state <= state + 1;
        data <= data_in;
      elsif state = 1 then
        state <= state + 1;
        tx <= '0'; -- start bit
      elsif state = last_state then
        state <= 0;
        if last_state = data_bits + 1 then
          tx <= data(state-2);
          parity_bit <= parity_bit xor data(state-2);
        elsif parity_length(parity) = 1 and last_state = data_bits + 2  then
          if parity = mark then
            tx <= '1';
          elsif parity = space then
            tx <= '0';
          elsif parity = odd then
            tx <= parity_bit;
          else -- even
            tx <= not parity_bit;
          end if;
        else
          tx <= '1';
        end if;
      elsif parity_length(parity) = 1 and state = (data_bits + 2) then
        state <= state + 1;
        if parity = mark then
          tx <= '1';
        elsif parity = space then
          tx <= '0';
        elsif parity = odd then
          tx <= parity_bit;
        else -- even
          tx <= not parity_bit;
        end if;
      else -- data bits
        state <= state + 1;
        tx <= data(state-2);
        parity_bit <= parity_bit xor data(state-2);
      end if;
    end if;
  end process;
end architecture rtl;