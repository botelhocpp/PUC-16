LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY InputOutputController IS
PORT (
    i_Write_Data    : IN t_Reg16;
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Buttons       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Read_Data     : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF InputOutputController IS 
    CONSTANT c_BUTTONS_ADDRESS : INTEGER := 0;
    CONSTANT c_LEDS_ADDRESS : INTEGER := 5;
    
    TYPE t_IORegisterArray IS ARRAY (0 TO 15) OF t_Reg16; 
    SIGNAL r_IO_Registers : t_IORegisterArray := (OTHERS => (OTHERS => '0'));

    SIGNAL r_Leds : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 15 := 0;
BEGIN 
    o_Leds <= r_Leds;
    
    w_Address <= TO_INTEGER(t_UReg16(i_Address));

    p_REGISTERS_READ_WRITE_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            r_IO_Registers(c_BUTTONS_ADDRESS)(3 DOWNTO 0) <= i_Buttons;
            
            
            IF(w_Address < 16) THEN
                IF(
                    i_Write_Enable = '1' AND 
                    i_Address /= t_Reg16(TO_UNSIGNED(c_BUTTONS_ADDRESS, c_WORD_SIZE))
                ) THEN
                    r_IO_Registers(w_Address) <= i_Write_Data;
                ELSIF(i_Write_Enable = '0') THEN
                    o_Read_Data <= r_IO_Registers(w_Address);
                END IF;
            END IF;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;

    p_DEVICES_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            r_Leds <= r_IO_Registers(c_LEDS_ADDRESS)(3 DOWNTO 0);
        END IF;
    END PROCESS p_DEVICES_CONTROL;
END ARCHITECTURE;