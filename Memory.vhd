LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Memory IS
PORT (
    i_Write_Data    : IN t_Reg16;
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    o_Read_Data     : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF Memory IS 
    SIGNAL r_Contents : t_MemoryArray := (        
        16 => "0000000000000000", -- btn_led.asm: 6:           mov r0, @btn_addr
        17 => "0100000100000000", -- btn_led.asm: 7:           ldr r1, [r0]
        18 => "0000000000000101", -- btn_led.asm: 9:           mov r0, @led_addr
        19 => "0000001000001111", -- btn_led.asm:10:           mov r2, 0xf
        20 => "1010010100010010", -- btn_led.asm:11:           sub r5, r1, r2
        21 => "0010000100000011", -- btn_led.asm:12:           bz @_led_on
        22 => "0000001000000000", -- btn_led.asm:15:           mov r2, 0
        23 => "0101001000000000", -- btn_led.asm:16:           str r2, [r0]
        24 => "0011000000010000", -- btn_led.asm:17:           jmp @main
        25 => "0000001000001111", -- btn_led.asm:20:           mov r2, 0xf
        26 => "0101001000000000", -- btn_led.asm:21:           str r2, [r0]
        27 => "0011000000010000", -- btn_led.asm:22:           jmp @main
        OTHERS => (OTHERS => '0')
    );
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 2**c_WORD_SIZE - 1 := 0;
BEGIN 
    w_Address <= TO_INTEGER(t_UReg16(i_Address));
    
    p_MEMORY_READ_WRITE_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            IF(w_Address < c_MEMORY_SIZE) THEN
                IF(i_Write_Enable = '1') THEN
                    r_Contents(w_Address) <= i_Write_Data;
                END IF;
                
                o_Read_Data <= r_Contents(w_Address);
            END IF;
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
