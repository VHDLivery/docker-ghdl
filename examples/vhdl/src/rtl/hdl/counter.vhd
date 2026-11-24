library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic (
        WIDTH : positive := 8
    );
    port (
        clk_i   : in  std_logic;
        rst_i   : in  std_logic;
        en_i    : in  std_logic;
        count_o : out std_logic_vector(WIDTH - 1 downto 0)
    );
end entity counter;

architecture rtl of counter is

    signal count : unsigned(WIDTH - 1 downto 0) := (others => '0');

begin

    counter_proc : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                count <= (others => '0');
            elsif en_i = '1' then
                count <= count + 1;
            end if;
        end if;
    end process counter_proc;

    count_o <= std_logic_vector(count);

end architecture rtl;