----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/11/2025 04:51:27 PM
-- Design Name: 
-- Module Name: binary_to_BCD - arch
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

entity binary_to_BCD is
generic( w : integer := 13;
         c_w : integer := 4);
port(
rst,clk : in std_logic;
start : in std_logic;
bin : in std_logic_vector(12 downto 0);
done_tick : out std_logic;
ready : out std_logic;
bcd0, bcd1, bcd2, bcd3 : out std_logic_vector(3 downto 0)
);
end binary_to_BCD;
architecture arch of binary_to_BCD is
type states is (idle, op, done);
signal cur_state, next_state : states;
signal cnt, next_cnt : unsigned(c_w downto 0);
signal inp, next_inp : std_logic_vector(w-1 downto 0);
signal bcd0_reg,next_bcd0 : unsigned(c_w-1 downto 0);
signal bcd1_reg,next_bcd1 : unsigned(c_w-1 downto 0);
signal bcd2_reg,next_bcd2 : unsigned(c_w-1 downto 0);
signal bcd3_reg,next_bcd3 : unsigned(c_w-1 downto 0);
signal temp0, temp1, temp2, temp3 : unsigned(c_w-1 downto 0);
begin

state_reg : process(clk, rst)
begin 
     if(rst = '1') then 
            cur_state <= idle;
            bcd0_reg <= (others => '0');
            bcd1_reg <= (others => '0');
            bcd2_reg <= (others => '0');
            bcd3_reg <= (others => '0');
            cnt <= (others => '0');
            inp <= (others => '0');
    elsif(rising_edge(clk)) then
            cur_state <= next_state;
            cnt <= next_cnt;
            inp <= next_inp;
            bcd0_reg <= next_bcd0;
            bcd1_reg <= next_bcd1;
            bcd2_reg <= next_bcd2;
            bcd3_reg <= next_bcd3;
    end if;
end process state_reg;

next_state_logic : process(cur_state, cnt, inp, bcd0_reg,
 bcd1_reg, bcd2_reg, bcd3_reg, next_cnt, next_inp, temp0, temp1, temp2, temp3)
begin   
next_state <= cur_state;
ready <= '0';
next_cnt <= (others => '0');
next_inp <= (others => '0');
next_bcd0 <= (others => '0'); 
next_bcd1 <= (others => '0'); 
next_bcd2 <= (others => '0'); 
next_bcd3 <= (others => '0'); 
  
  case cur_state is 
          when idle => 
                ready <= '1';
                if(start = '1') then 
                        next_cnt <= "1101";
                        next_inp <= bin;
                        next_bcd0 <= (others => '0'); 
                        next_bcd1 <= (others => '0'); 
                        next_bcd2 <= (others => '0'); 
                        next_bcd3 <= (others => '0'); 
                end if;
         when op =>
         --sequence of these operation is same as in the algo
                next_inp <= inp(w-2 downto 0) & '0';
                next_bcd0 <= temp0(c_w-2 downto 0) & inp(w-1);
                next_bcd1 <= temp1(c_w-2 downto 0) & temp0(3);
                next_bcd2 <= temp2(c_w-2 downto 0) & temp1(3);
                next_bcd3 <= temp3(c_w-2 downto 0) & temp2(3);
                next_cnt <= cnt -1;
                if(next_cnt = 0) then 
                         next_state <= done;
                end if;
         when done =>
                done_tick <= '1';
                next_state <= idle;
         end case;
end process next_state_logic;
     
-- Compare and add            
temp0 <= bcd0_reg + 3 when bcd0_reg > 4 else bcd0_reg;
temp1 <= bcd1_reg + 3 when bcd1_reg > 4 else bcd1_reg;
temp2 <= bcd2_reg + 3 when bcd2_reg > 4 else bcd2_reg;
temp3 <= bcd3_reg + 3 when bcd3_reg > 4 else bcd3_reg;

--output assign 
bcd0 <= std_logic_vector(bcd0_reg);
bcd1 <= std_logic_vector(bcd1_reg);
bcd2 <= std_logic_vector(bcd2_reg);
bcd3 <= std_logic_vector(bcd3_reg);

end arch;
