----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2025 09:22:08 PM
-- Design Name: 
-- Module Name: low_freq_counter - arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity low_freq_counter is
port(
clk, rst : in std_logic;
start : in std_logic;
si : in std_logic;
bcd0, bcd1, bcd2, bcd3 : out std_logic_vector(3 downto 0)
);
end low_freq_counter;
architecture arch of low_freq_counter is
type states is (idle, per, freq, b2b);
signal cur_state, next_state : states ;
signal period : std_logic_vector(9 downto 0);
signal dvnd, dvsr, quo : std_logic_vector(19 downto 0);
signal prd_start, prd_done_tick : std_logic;
signal div_start, div_done_tick : std_logic;
signal b2b_start : std_logic;
signal b2b_done_tick : std_logic;
begin
--********************
--compoenet instances 
--********************
-- period counter
prd_unit : entity work.period_counter
port map(
clk => clk,
rst => rst,
start => prd_start,
si => si,
ready => open,
per => period,
done_tick => prd_done_tick
);

-- div ckt
div_unit : entity work.division_ckt
generic map(
    w => 20,
    w_cnt => 5
)
port map (
clk => clk,
rst => rst,
start => div_start,
dvsr => dvsr,
dvnd => dvnd,
quo => quo,
ready => open,
rmdr => open,
done_tick =>div_done_tick
);

-- binary to bcd converter
b2b_unit : entity work.binary_to_BCD
port map(
clk => clk,
rst => rst,
start => b2b_start,
bin => quo(12 downto 0),
done_tick => b2b_done_tick,
ready => open,
bcd0 => bcd0, bcd1 => bcd1, 
bcd2 => bcd2, bcd3 => bcd3
);
--**************************

--intermidiate signals 
dvnd <= std_logic_vector(TO_UNSIGNED(100000, 20));
dvsr <= "0000000" & period;

---*********************************
--MAIN LOGIC OF THE LOW FREQ COUNTER 
--**********************************
-- State register process
process(clk, rst)
begin
    if rst = '1' then
        cur_state <= idle;
    elsif (clk'event and clk = '1') then
        cur_state <= next_state;
    end if;
end process;

-- Next-state logic
process(cur_state, start, prd_done_tick, div_done_tick, b2b_done_tick)
begin
    -- Default assignments
    next_state <= cur_state;
    prd_start <= '0';
    div_start <= '0';
    b2b_start <= '0';

    case cur_state is
        when idle =>
            if start = '1' then
                next_state <= per;
                prd_start <= '1';
            end if;

        when per =>
            if prd_done_tick = '1' then
                div_start <= '1';
                next_state <= freq;
            end if;

        when freq =>
            if div_done_tick = '1' then
                b2b_start <= '1';
                next_state <= b2b;
            end if;

        when b2b =>
            if b2b_done_tick = '1' then
                next_state <= idle;
            end if;

        when others =>
            next_state <= idle;
    end case;
end process;
end arch;
