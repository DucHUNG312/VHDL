library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ADC_RS232 is
  port (
    clock : in std_logic;
    reset : in std_logic;
    adc_data : in std_logic_vector(7 downto 0);
    tx : out std_logic
  );
end ADC_RS232;

architecture behavioral of ADC_RS232 is
  signal baud_clock : std_logic;
  signal bit_counter : integer range 0 to 9 := 0;
  signal tx_shift_reg : std_logic_vector(9 downto 0) := (others => '1');
begin
  -- Baud rate generator process
  baud_generator : process (clock)
  begin
    if rising_edge(clock) then
      if reset = '1' then
        baud_clock <= '0';
      else
        baud_clock <= not baud_clock;
      end if;
    end if;
  end process baud_generator;

  -- UART transmitter process
  uart_transmitter : process (baud_clock)
  begin
    if reset = '1' then
      bit_counter <= 0;
      tx_shift_reg <= (others => '1');
    elsif rising_edge(baud_clock) then
      if bit_counter = 0 then
        tx <= '0';  -- Start bit
        tx_shift_reg <= '0' & adc_data & '1';  -- Data bits (8-bit ADC value)
        bit_counter <= bit_counter + 1;
      elsif bit_counter <= 9 then
        tx <= tx_shift_reg(bit_counter);
        bit_counter <= bit_counter + 1;
      else
        tx <= '1';  -- Stop bit
        bit_counter <= 0;
      end if;
    end if;
  end process uart_transmitter;
end behavioral;
