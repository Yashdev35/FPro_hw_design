----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2025 03:57:59 PM
-- Design Name: 
-- Module Name: fib_module - main
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

entity fib_module is
port(
clk,rst : in std_logic;
i : in std_logic_vector(4 downto 0);
start :in std_logic;
ready : out std_logic;
fib : out std_logic_vector(19 downto 0);
done_tick : out std_logic
);
end fib_module;
architecture main of fib_module is
type states is (idle, op, done);
signal cur_state,next_state : states;
signal t0, next_t0 : unsigned(19 downto 0);
signal t1, next_t1 : unsigned(19 downto 0);
signal cnt, next_cnt : unsigned(4 downto 0);
begin

sync : process(clk, rst) 
begin
     if(rst = '1') then 
           t0 <= (others =>'0');
           t1 <= (others => '0');
           cnt <= unsigned(i);
     else 
           t0 <= next_t0;
           t1 <= next_t1;
           cnt <= next_cnt;
     end if;
end process sync;

next_state_logic: process(cur_state, t0, t1, i, cnt, next_cnt, start)
begin
--these signals are reassigned in every iteration at the start but only assignment matters 
--is at the end of the process 
next_state <= cur_state;
next_t0 <= (others => '0');
next_t1 <= (0 => '1',others => '0');
next_cnt <= unsigned(i);
ready <= '0';
done_tick <= '0';

case cur_state is 
          when idle =>
                ready <= '1';
                if(start = '1') then 
                        next_state <= op;
                        next_t0 <= (others => '0');
                        next_t1 <= (0 => '1',others => '0');
                        next_cnt <= unsigned(i);
                end if;
           when op =>
                -- = 0 for edge case when i is = 0 
                if(cnt = 0) then 
                        next_t1 <= (others => '0');
                        next_state <= done;
                elsif(cnt = 1) then 
                        next_state <= done;
                else 
                        next_t1 <= t0 + t1;
                        next_t0 <= t1;
                        next_cnt <= cnt -1;
                end if;
            when done =>
                done_tick <= '1';
                next_state <= idle;
            end case;
end process next_state_logic;

--output assign 
fib <= std_logic_vector(t1);

end main;
