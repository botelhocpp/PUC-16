LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ClockSync IS
PORT(
    i_Data : IN STD_LOGIC;
    i_Clk: IN STD_LOGIC;
    i_Rst: IN STD_LOGIC;
    o_Data: OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF ClockSync IS
	SIGNAL r_Sync_Data : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');	
BEGIN
	o_Data <= r_Sync_Data(1);
	
    PROCESS(i_Clk, i_Rst) IS
	   BEGIN
	       IF(i_Rst = '1') THEN
	           r_Sync_Data <= (OTHERS => '0');
	       ELSIF (RISING_EDGE(i_Clk)) THEN
	           r_Sync_Data <= r_Sync_Data(0) & i_Data;
	       END IF;
	END PROCESS;
END ARCHITECTURE;
