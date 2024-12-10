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
        16 => "0000000000000111", -- lcd_test.asm:13: main:   mov r0, 7
        17 => "0000000100010000", -- lcd_test.asm:14:         mov r1, low(@msg1)
        18 => "0001000100010000", -- lcd_test.asm:15:         movt r1, high(@msg1)
        19 => "0100001000010000", -- lcd_test.asm:17:         ldr r2, [r1, 0]
        20 => "0000110000000111", -- lcd_test.asm:18: _wait1: mov r12, @ldr
        21 => "0100110011000000", -- lcd_test.asm:19:         ldr r12, [r12]
        22 => "0000000000000101", -- lcd_test.asm:20:         mov r0, @led
        23 => "0000000100000001", -- lcd_test.asm:21:         mov r1, 0x1
        24 => "0101000100000000", -- lcd_test.asm:22:         str r1, [r0]
        25 => "1001110011000000", -- lcd_test.asm:23:         mov r12, r12
        26 => "0010001011111001", -- lcd_test.asm:24:         bnz @_wait1
        27 => "0000110000000111", -- lcd_test.asm:25:         mov r12, @ldr
        28 => "0101001011000000", -- lcd_test.asm:26:         str r2, [r12]
        29 => "0000000000000101", -- lcd_test.asm:28:         mov r0, @led
        30 => "0000000100000011", -- lcd_test.asm:29:         mov r1, 0x3
        31 => "0101000100000000", -- lcd_test.asm:30:         str r1, [r0]
        32 => "0100001000010001", -- lcd_test.asm:32:         ldr r2, [r1, 1]
        33 => "0000110000000111", -- lcd_test.asm:33: _wait2: mov r12, @ldr
        34 => "0100110011000000", -- lcd_test.asm:34:         ldr r12, [r12]
        35 => "0000000000000101", -- lcd_test.asm:35:         mov r0, @led
        36 => "0000000100000010", -- lcd_test.asm:36:         mov r1, 0x2
        37 => "0101000100000000", -- lcd_test.asm:37:         str r1, [r0]
        38 => "1001110011000000", -- lcd_test.asm:38:         mov r12, r12
        39 => "0010001011111001", -- lcd_test.asm:39:         bnz @_wait2
        40 => "0000110000000111", -- lcd_test.asm:40:         mov r12, @ldr
        41 => "0101001011000000", -- lcd_test.asm:41:         str r2, [r12]
        42 => "0000000000000101", -- lcd_test.asm:43:         mov r0, @led
        43 => "0000000100000011", -- lcd_test.asm:44:         mov r1, 0x3
        44 => "0101000100000000", -- lcd_test.asm:45:         str r1, [r0]
        45 => "0010000011111111", -- lcd_test.asm:47: halt:   b @halt
      4112 => "0000000001110111", -- lcd_test.asm:51: msg1:   .dw "w"
      4113 => "0000000001100101", -- lcd_test.asm:51:         .dw "e"
      4114 => "0000000001101100", -- lcd_test.asm:51:         .dw "l"
      4115 => "0000000001100011", -- lcd_test.asm:51:         .dw "c"
      4116 => "0000000001101111", -- lcd_test.asm:51:         .dw "o"
      4117 => "0000000001101101", -- lcd_test.asm:51:         .dw "m"
      4118 => "0000000001100101", -- lcd_test.asm:51:         .dw "e"
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
