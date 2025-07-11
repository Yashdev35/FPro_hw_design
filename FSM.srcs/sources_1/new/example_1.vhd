----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2025 07:38:40 PM
-- Design Name: 
-- Module Name: example_1 - Behavioral
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
entity example_1 is
port(
tran_inp : in std_logic;
clk,clr : in std_logic;
o,st : out std_logic
);
end example_1;
architecture Behavioral of example_1 is
type state_type is (st0,st1);
signal ps,ns : state_type;
begin
     synchro : process(clk,ns,clr)
      begin 
        if(clr = '1') then 
          ps <= st0;
        elsif(rising_edge(clk)) then
          ps<= ns;
        else 
          ps<= st0;
        end if;
       end process synchro;
       
     combin : process(ps,tran_inp)
      begin
       o <= '1';
       case(ps) is 
         when st0 =>
           o <= '0';
           if(tran_inp = '1') then ns <= st1;
           else ns <= st0;
           end if;
         when st1 => 
           o <= '1';
           if(tran_inp = '1') then ns <= st0;
           else ns <= st1;
           end if;
         when others =>
           ns <= st0;
           o <= '0';
         end case;
        end process combin;
        
     with ps select 
     st <= '0' when st0,
           '1' when st1,
           '0' when others;
end Behavioral;
