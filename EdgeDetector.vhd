LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EdgeDetector IS
PORT (
    i_Data : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    o_Edge : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF EdgeDetector IS
    SIGNAL data : STD_LOGIC := '0';
BEGIN
    o_Edge <= (NOT data) AND i_Data;

    -- Flip-Flop
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            data <= '0';
        ELSIF(RISING_EDGE(i_Clk)) THEN
            data <= i_Data;
        END IF;
    END PROCESS;
END ARCHITECTURE;