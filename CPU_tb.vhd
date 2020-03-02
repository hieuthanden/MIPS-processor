-- Student name: your name goes here
-- Student ID number: your student id # goes here

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity CPU_tb is
end CPU_tb;

architecture CPU_test of CPU_tb is
-- component declaration
	-- CPU (you just built)
    component CPU is
  	port (
    	clk     : in std_logic;
    	reset_N : in std_logic);            -- active-low signal for reset
    end component;

-- component specification


-- signal declaration
	-- You'll need clock and reset.
    SIGNAL clk_s: std_logic := '1';
    SIGNAL reset_N_s : std_logic;

begin

    CPU_com: CPU PORT MAP (
	clk => clk_s,
    	reset_N => reset_N_s
    );

    ClkProcess: PROCESS
    begin
	   clk_s <= not clk_s ;
	   WAIT FOR CLK_PERIOD/2;
    end process Clkprocess;

    mainProcess: PROCESS
    begin
	reset_N_s <= '0';
	WAIT UNTIL clk_s = '1' AND clk_s'EVENT;  
	reset_N_s <= '1';
	wAIT;

    end process mainProcess;


end CPU_test;
