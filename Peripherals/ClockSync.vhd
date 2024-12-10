LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sync IS
PORT(
    A : IN STD_LOGIC;
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;
    B: OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF sync IS
	SIGNAL sync_B: STD_LOGIC_VECTOR(1 DOWNTO 0);	
BEGIN
	B <= sync_B(1);
	
    PROCESS(clk, rst) IS
	   BEGIN
	       IF(rst = '1') THEN
	           sync_B <= "00";
	       ELSIF RISING_EDGE(clk) THEN
	           sync_B <= sync_B(0) & A;
	       END IF;
	END PROCESS;
END ARCHITECTURE;
