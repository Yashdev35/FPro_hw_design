-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/17/2025 01:08:38 AM
-- Design Name: 
-- Module Name: tb_example1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versios: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
-- Testbench for my_fsm2
library IEEE;
use IEEE.std_logic_1164.all;

entity my_fsm2_tb is
end my_fsm2_tb;

architecture testbench of my_fsm2_tb is
    -- Component declaration
    component my_fsm2
        port (
            TOG_EN : in std_logic;
            CLK, CLR : in std_logic;
            Y, Z1 : out std_logic
        );
    end component;
    
    -- Signal declarations
    signal TOG_EN_tb : std_logic := '0';
    signal CLK_tb : std_logic := '0';
    signal CLR_tb : std_logic := '0';
    signal Y_tb : std_logic;
    signal Z1_tb : std_logic;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: my_fsm2
        port map (
            TOG_EN => TOG_EN_tb,
            CLK => CLK_tb,
            CLR => CLR_tb,
            Y => Y_tb,
            Z1 => Z1_tb
        );
    
    -- Clock generation process
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Stimulus process
    stim_process: process
    begin
        -- Test Case 1: Reset functionality
        report "Starting testbench for my_fsm2";
        report "Test Case 1: Reset functionality";
        CLR_tb <= '1';
        TOG_EN_tb <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Check initial state after reset
        assert (Y_tb = '0' and Z1_tb = '0') 
            report "Reset failed - Expected Y=0, Z1=0" 
            severity error;
        
        CLR_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test Case 2: Stay in ST0 with TOG_EN = '0'
        report "Test Case 2: Stay in ST0 with TOG_EN = 0";
        TOG_EN_tb <= '0';
        wait for CLK_PERIOD * 3;
        
        assert (Y_tb = '0' and Z1_tb = '0') 
            report "State ST0 failed - Expected Y=0, Z1=0" 
            severity error;
        
        -- Test Case 3: Transition from ST0 to ST1
        report "Test Case 3: Transition ST0 -> ST1";
        TOG_EN_tb <= '1';
        wait for CLK_PERIOD;
        
        assert (Y_tb = '1' and Z1_tb = '1') 
            report "Transition to ST1 failed - Expected Y=1, Z1=1" 
            severity error;
        
        -- Test Case 4: Transition from ST1 to ST0
        report "Test Case 4: Transition ST1 -> ST0";
        TOG_EN_tb <= '1';  -- TOG_EN = 1 in ST1 should go back to ST0
        wait for CLK_PERIOD;
        
        assert (Y_tb = '0' and Z1_tb = '0') 
            report "Transition to ST0 failed - Expected Y=0, Z1=0" 
            severity error;
        
        -- Test Case 5: Stay in ST1 with TOG_EN = '0'
        report "Test Case 5: Go to ST1 and stay with TOG_EN = 0";
        TOG_EN_tb <= '1';  -- Go to ST1
        wait for CLK_PERIOD;
        
        TOG_EN_tb <= '0';  -- Stay in ST1
        wait for CLK_PERIOD * 3;
        
        assert (Y_tb = '1' and Z1_tb = '1') 
            report "Stay in ST1 failed - Expected Y=1, Z1=1" 
            severity error;
        
        -- Test Case 6: Toggle behavior
        report "Test Case 6: Toggle between states";
        for i in 1 to 4 loop
            TOG_EN_tb <= '1';
            wait for CLK_PERIOD;
            
            if i mod 2 = 1 then
                -- Should be in ST0 after odd toggles from ST1
                assert (Y_tb = '0' and Z1_tb = '0') 
                    report "Toggle " & integer'image(i) & " failed - Expected ST0" 
                    severity error;
            else
                -- Should be in ST1 after even toggles from ST0
                assert (Y_tb = '1' and Z1_tb = '1') 
                    report "Toggle " & integer'image(i) & " failed - Expected ST1" 
                    severity error;
            end if;
        end loop;
        
        -- Test Case 7: Reset during operation
        report "Test Case 7: Reset during operation";
        CLR_tb <= '1';
        wait for CLK_PERIOD;
        
        assert (Y_tb = '0' and Z1_tb = '0') 
            report "Reset during operation failed - Expected Y=0, Z1=0" 
            severity error;
        
        CLR_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test Case 8: Multiple clock cycles with same input
        report "Test Case 8: Multiple cycles with TOG_EN = 0";
        TOG_EN_tb <= '0';
        wait for CLK_PERIOD * 5;
        
        assert (Y_tb = '0' and Z1_tb = '0') 
            report "Multiple cycles in ST0 failed" 
            severity error;
        
        report "Test Case 9: Multiple cycles in ST1";
        TOG_EN_tb <= '1';  -- Go to ST1
        wait for CLK_PERIOD;
        TOG_EN_tb <= '0';  -- Stay in ST1
        wait for CLK_PERIOD * 5;
        
        assert (Y_tb = '1' and Z1_tb = '1') 
            report "Multiple cycles in ST1 failed" 
            severity error;
        
        -- End simulation
        report "All test cases completed successfully!";
        wait;
    end process;
    
end testbench;
