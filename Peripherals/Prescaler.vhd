LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Prescaler IS
    GENERIC( g_DIVIDER : INTEGER := 400000 );
    PORT (
        i_Clk : IN STD_LOGIC;
        i_Rst : IN STD_LOGIC;
        o_Clk : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE RTL OF Prescaler IS 
    SIGNAL w_Clk : STD_LOGIC := '0';
BEGIN 
    o_Clk <= w_Clk;
                              
    PROCESS(i_Clk, i_Rst)
        VARIABLE v_Counter : INTEGER RANGE 0 TO g_DIVIDER := 0;
    BEGIN
        IF(i_Rst = '1') THEN
            v_Counter := 0;
            w_Clk <= '0';
        ELSIF(RISING_EDGE(i_Clk)) THEN 
            v_Counter := v_Counter + 1;

            IF(v_Counter = g_DIVIDER) THEN
                v_Counter := 0;
                w_Clk <= NOT w_Clk;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
