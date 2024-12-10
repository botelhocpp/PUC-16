LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ps2_filter IS
PORT (
    din : IN t_Byte;
    vi : IN STD_LOGIC;
    parity_ok : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    dout : OUT t_Byte;
    vo : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF ps2_filter IS
    TYPE code IS (PRESSED, F0);
BEGIN
    dout <= din;

    PROCESS(clk, rst)
        VARIABLE state : code;
    BEGIN
        IF(rst = '1') THEN
            state := PRESSED;
            vo <= '0';
        ELSIF(RISING_EDGE(clk)) THEN
            vo <= '0';
            
            CASE state IS
                WHEN PRESSED =>
                    IF(vi = '1') THEN
                        IF(parity_ok = '1') THEN
                            if din = "11110000" then
                                state := F0;
                            else
                                vo <= '1';
                            end if;
                        END IF;
                    END IF;
                WHEN F0 =>
                    IF(vi = '1') THEN
                        state := PRESSED;
                    END IF;
            END CASE;   
        END IF;
    END PROCESS;
END ARCHITECTURE;
