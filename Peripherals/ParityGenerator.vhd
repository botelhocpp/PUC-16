LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ParityGenerator IS
PORT (
    i_Data : IN t_Byte;
    o_Odd_Parity : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF ParityGenerator IS
BEGIN
    PROCESS(i_Data)
        VARIABLE v_Parity : STD_LOGIC := '0';
    BEGIN
        v_Parity := '0';
        FOR i IN 0 TO 7 LOOP
            IF(i_Data(i) = '1') THEN
                v_Parity := NOT v_Parity;
            END IF;
        END LOOP;
        o_Odd_Parity <= NOT v_Parity;
    END PROCESS;
END ARCHITECTURE;
