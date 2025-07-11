----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/17/2025 03:48:31 AM
-- Design Name: 
-- Module Name: example_2 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity example_2 is
port(
inp,s,clk : in std_logic;
oput : out std_logic;
st : out std_logic_vector(0 to 1)
);
end example_2;
architecture Behavioral of example_2 is
type state_type is (st0,st1,st2);
signal ns,ps : state_type;
begin
synch : process(ns,clk,s)
begin 
  if(s ='1') then 
   ps <= st0;
  elsif(rising_edge(clk)) then 
   ps <= ns;
  else
   ps <= st0;
  end if;
end process synch;
  
combi : process(ps,inp)
begin 
oput <= '0';
  case ps is 
    when st0 =>
     oput <= '0';
     if(inp = '1') then ns <= st1;
     else ns <= st0;
     end if;
    when st1 =>
      oput <= '0';
      if(inp = '1') then ns <= st2;
      elsif ( inp = '0') then ns <= st0;
      else ns <= st0;
      end if;
    when st2 =>
      if(inp = '1') then ns <= st2; oput <= '1';
      else ns <= st0; oput <= '0';
      end if;
    when others =>
      ns <= st0;oput <= '0';
  end case;
 end process combi;
 
 with ps select 
 st <= "00" when st0,
      "10" when st1,
      "11" when st2,
      "00" when others;
end Behavioral;
