----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2025 03:55:50 AM
-- Design Name: 
-- Module Name: debouncing - rt_methodology
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

entity debouncing_module is
generic( n : integer := 22);
port(
clk,rst : in std_logic;
sw : in std_logic;
de_tick : out std_logic;
de_level : out std_logic
);
end debouncing_module;
architecture rt_methodology of debouncing_module is
type states is (zero, wait_1, one, wait_0);
signal cur_state, next_state : states;
signal q_cur, q_next : unsigned(n-1 downto 0);
signal q_zero, q_dec, q_load : std_logic;

begin

--sync state register 
sync : process(clk,rst,next_state)
begin
      if(rst = '1') then 
           q_cur <= (others => '0');
           cur_state <= zero;
      elsif(rising_edge(clk)) then 
           q_cur <= q_next;
           cur_state <= next_state;
      end if;
end process sync;

--data path
q_next <= (others => '1') when( q_load = '1') else 
          q_next-1 when (q_dec = '1') else
          q_next;
          
q_zero <= '1' when q_next = 0 else '0';
-- next state logic control path
combi : process(cur_state,sw,q_zero) 
begin 
de_tick <= '0';
next_state <= cur_state;
q_dec <= '0';
q_load<= '0';

case cur_state is 
        when zero =>
               de_level <= '0';
               if(sw = '1') then 
                     next_state <= wait_1;
                     q_load <= '1';
               end if;
         when wait_1 =>
               de_level <= '0';
               if(sw = '1') then 
                     q_dec <= '1';
                        if(q_zero = '1') then 
                               next_state <= one;
                               de_tick <= '1';
                        end if;
                else  
                        next_state <= zero;
                end if;
         when one =>
                 de_level <= '1';
                 if(sw <= '0') then 
                       next_state <= wait_0;
                       q_load <= '1';
                 end if;
         when wait_0 =>
                 de_level <= '1';
                 if( sw = '1') then 
                        q_dec <= '1';
                        if(q_zero = '1') then 
                                next_state <= zero;
                        else
                                next_state <= wait_1;
                        end if;
                 else 
                        next_state <= one;
                 end if;
          when others =>
                 next_state <= zero;
          end case;    
end process combi;

end rt_methodology;