LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Ps2Filter IS
PORT (
    i_Data      : IN t_Byte;
    i_Valid     : IN STD_LOGIC;
    i_Parity    : IN STD_LOGIC;
    i_Clk       : IN STD_LOGIC;
    i_Rst       : IN STD_LOGIC;
    o_Data      : OUT t_Byte;
    o_Valid     : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF Ps2Filter IS
BEGIN
    o_Data <= i_Data;

    PROCESS(i_Clk, i_Rst)
        TYPE t_Code IS ( s_PRESSED, s_F0, s_RELEASE );
        VARIABLE v_State : t_Code := s_PRESSED;
    BEGIN
        IF(i_Rst = '1') THEN
            v_State := s_PRESSED;
            o_Valid <= '0';
        ELSIF(RISING_EDGE(i_Clk)) THEN
            o_Valid <= '0';
            
            CASE v_State IS
                WHEN s_PRESSED =>
                    IF(i_Valid = '1') THEN
                        IF(i_Parity = '1') THEN
                            o_Valid <= '1';
                        END IF;
                        v_State := s_F0;
                    END IF;
                WHEN s_F0 =>
                    IF(i_Valid = '1') THEN
                        v_State := s_RELEASE;
                    END IF;
                WHEN s_RELEASE =>
                    IF(i_Valid = '1') THEN
                        v_State := s_PRESSED;
                    END IF;
            END CASE;   
        END IF;
    END PROCESS;
END ARCHITECTURE;
