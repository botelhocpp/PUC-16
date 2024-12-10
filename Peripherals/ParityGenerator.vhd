LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY parity_generator IS
PORT (
    data : IN t_Byte;
    odd_parity : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF parity_generator IS
BEGIN
    PROCESS(data)
        VARIABLE parity : STD_LOGIC;
    BEGIN
        parity := '0';
        FOR i IN 0 TO 7 LOOP
            IF(data(i) = '1') THEN
                parity := NOT parity;
            END IF;
        END LOOP;
        odd_parity <= NOT parity;
    END PROCESS;
END ARCHITECTURE;
