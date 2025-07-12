----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2025 03:43:42 PM
-- Design Name: 
-- Module Name: period_counter - arch
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

entity period_counter is
generic( CONST : integer := 100000);
port(
clk, rst, start : in std_logic;
si : in std_logic;
ready : out std_logic;
per : out std_logic_vector(9 downto 0);
done_tick : out std_logic
);
end period_counter;
architecture arch of period_counter is
type states is (idle, det_ed, count, done);
signal cur_state, next_state : states;
signal cur_t, next_t : unsigned(16 downto 0);
signal cur_p, next_p : unsigned(9 downto 0);
signal inp : std_logic;
signal edge_det : std_logic;
begin

state_reg : process(clk, rst) 
begin 
     if(rst = '1') then 
               cur_state <= idle;
               cur_t <= (others => '0');
               cur_p <= (others => '0');
               inp <= '0';
     elsif(rising_edge(clk)) then 
               cur_state <= next_state;
               cur_t <= next_t;
               cur_p <= next_p;
               inp <= si;
     end if;
end process state_reg;

-- edge detection 
edge_det <= '1' when(rising_edge(inp)) else '0';

--next state logic 
next_state_logic : process(cur_state, cur_t, cur_p, inp, edge_det)
begin 
-- default values for next states need to be asserted when merging control 
-- path(next state logic) and datapath
next_state <= cur_state;
next_t <= (others => '0');
next_p <= (others => '0');
ready <= '0';
done_tick <= '0';

case cur_state is 
          when idle => 
                  ready <= '0';
                  if(start = '0') then 
                          next_state <= det_ed;
                          next_t <= (others => '0');
                          next_p <= (others => '0');
                  end if;
          when det_ed=>
                  if(edge_det = '1') then 
                          next_state <= count;
                  end if;
          when count =>
                  if(edge_det = '1') then 
                          next_state <= done;
                  elsif( next_t = CONST -1) then  
                          next_t <= (others =>'0');
                          next_p <= cur_p +1;
                  else
                          next_t <= cur_t +1;
                  end if;
          when done => 
                  done_tick <= '1';
                  next_state <= idle;
     end case;
end process next_state_logic;

--output 
per <= std_logic_vector(cur_p);
end arch;
