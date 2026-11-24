library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_counter is
  generic (
    runner_cfg : string
  );
end entity tb_counter;

architecture sim of tb_counter is

    constant CLK_PERIOD : time     := 10 ns;
    constant WIDTH      : positive := 8;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal en    : std_logic := '0';
    signal count : std_logic_vector(WIDTH - 1 downto 0);

begin

    dut : entity work.counter
        generic map (
            WIDTH => WIDTH
        )
        port map (
            clk_i   => clk,
            rst_i   => rst,
            en_i    => en,
            count_o => count
        );

    ---------------------------------------------------------------------------
    -- Clock generation
    ---------------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;

            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process clk_process;

    ---------------------------------------------------------------------------
    -- VUnit test process
    ---------------------------------------------------------------------------
    main : process
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop

            -------------------------------------------------------------------
            -- Reset test
            -------------------------------------------------------------------
            if run("reset") then

                rst <= '1';
                en  <= '0';

                wait until rising_edge(clk);
                wait until rising_edge(clk);

                rst <= '0';

                wait for 1 ns;

                check_equal(
                    unsigned(count),
                    to_unsigned(0, WIDTH),
                    "Counter should be zero after reset"
                );

            -------------------------------------------------------------------
            -- Counting test
            -------------------------------------------------------------------
            elsif run("count") then

                rst <= '1';
                en  <= '0';

                wait until rising_edge(clk);
                wait until rising_edge(clk);

                rst <= '0';

                wait until rising_edge(clk);

                en <= '1';

                for i in 1 to 10 loop
                    wait until rising_edge(clk);
                    wait for 1 ns;

                    check_equal(
                        unsigned(count),
                        to_unsigned(i, WIDTH),
                        "Unexpected counter value"
                    );
                end loop;

            -------------------------------------------------------------------
            -- Enable test
            -------------------------------------------------------------------
            elsif run("enable") then

                rst <= '1';
                en  <= '0';

                wait until rising_edge(clk);
                wait until rising_edge(clk);

                rst <= '0';

                wait until rising_edge(clk);

                en <= '1';

                for i in 1 to 5 loop
                    wait until rising_edge(clk);
                end loop;

                wait for 1 ns;

                check_equal(
                    unsigned(count),
                    to_unsigned(5, WIDTH)
                );

                en <= '0';

                for i in 1 to 5 loop
                    wait until rising_edge(clk);
                end loop;

                wait for 1 ns;

                check_equal(
                    unsigned(count),
                    to_unsigned(5, WIDTH),
                    "Counter changed while enable was low"
                );

            end if;

        end loop;

        test_runner_cleanup(runner);

        wait;
    end process main;

end architecture sim;
