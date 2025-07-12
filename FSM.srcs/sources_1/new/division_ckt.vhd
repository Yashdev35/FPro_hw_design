----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2025 07:54:54 PM
-- Design Name: 
-- Module Name: division_ckt - div_ckt
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

entity division_ckt is
generic(w : integer := 8;
      w_cnt : integer := 4);
port(
clk,rst : in std_logic;
start : in std_logic;
dvsr, dvnd : in std_logic_vector(w-1 downto 0);
ready : out std_logic;
done_tick : out std_logic;
quo, rmdr : out std_logic_vector(w-1 downto 0)
);
end division_ckt;
architecture div_ckt of division_ckt is
type states is (idle, op, last, done);
signal cur_state, next_state : states;
signal rl_reg, next_rl : std_logic_vector(w-1 downto 0);
signal rh_reg, next_rh : unsigned(w-1 downto 0);
signal rh_temp : unsigned(w-1 downto 0);
signal dvsr_reg, next_dvsr : unsigned(w-1 downto 0);
signal cnt, next_cnt : unsigned(w_cnt downto 0);
signal unknown_bit : std_logic;
begin

state_reg : process(clk, rst)
begin 
     if(rst = '1') then 
           cur_state <= idle;
           rl_reg <= (others => '0');
           rh_reg <= (others => '0');
           dvsr_reg<= (others => '0');
           cnt <= (others => '0');
     elsif(rising_edge(clk)) then 
           cur_state <= next_state;
           rl_reg <= next_rl;
           rh_reg <= next_rh;
           dvsr_reg <= next_dvsr;
           cnt <= next_cnt;
     end if;
end process state_reg;

next_state_logic_cp : process(cur_state, rl_reg, rh_reg, dvsr_reg, cnt, rh_temp, 
                              dvsr, dvnd, unknown_bit, next_cnt, start)
begin
      next_state <= cur_state;
      next_rh <= (others => '0');
      next_rl <= (others => '0');
      cnt <= (others => '0');
      dvsr_reg <= (others => '0');
      unknown_bit <= '0';
      
      case cur_state is  
            when idle =>
                     ready <= '1';
                     if(start = '1') then 
                             next_rh <= (others =>'0');
                             next_rl <= dvnd;
                             next_dvsr <= unsigned(dvsr);
                             next_cnt <= to_unsigned(w+1, w_cnt);
                             next_state <= op;
                     end if;
            when op => 
                     next_rh <= rh_temp(w-2 downto 0) & rl_reg(w-1);
                     next_rl <= rl_reg(w-2 downto 0) & unknown_bit;         
                     next_cnt <= cnt -1;
                     if(next_cnt = 1) then 
                               next_state <= last;
                     end if;
            when last => 
                     next_rh <= rh_temp;
                     next_rl <= rl_reg(w-2 downto 0) & unknown_bit;
                     next_state <= done;
            when done =>
                     done_tick <= '1';
                     next_state <= idle;
            end case;
end process next_state_logic_cp;

--logic for compare and sub
comp_n_sub : process(rh_reg, dvsr_reg)
begin 
    if(dvsr_reg <= rh_reg) then
           rh_temp <= rh_reg - dvsr_reg;
           unknown_bit <= '1';
    else    
           rh_temp <= rh_reg;
           unknown_bit <= '0';
    end if;
end process comp_n_sub;

--output assignment 
quo <= rl_reg;
rmdr <= std_logic_vector(rh_reg);
end div_ckt;
