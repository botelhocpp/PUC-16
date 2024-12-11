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
    i_Rst           : IN STD_LOGIC;
    o_Read_Data     : OUT t_Reg16;
    
    i_Ps2_Data      : IN STD_LOGIC;
    i_Ps2_Clk       : IN STD_LOGIC;

    o_Ssd_1         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Ssd_2         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    i_Buttons       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

    o_Lcd_Rs        : OUT STD_LOGIC;
    o_Lcd_Data      : OUT t_Nibble;
    o_Lcd_Rw        : OUT STD_LOGIC;
    o_Lcd_E         : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF InputOutputController IS 
    -- Constants
    CONSTANT c_BUTTONS_ADDRESS      : INTEGER := 0;
    CONSTANT c_KEYBOARD_ADDRESS     : INTEGER := 2;
    CONSTANT c_LEDS_ADDRESS         : INTEGER := 5;
    CONSTANT c_SSD_ADDRESS          : INTEGER := 6;
    CONSTANT c_LCD_DATA_ADDRESS     : INTEGER := 7;
    CONSTANT c_LCD_COMMAND_ADDRESS  : INTEGER := 8;
    
    -- Special Registers

    TYPE t_IORegisterArray IS ARRAY (0 TO 15) OF t_Reg16; 

    SIGNAL r_IO_Registers : t_IORegisterArray := (
        c_LCD_DATA_ADDRESS      => (OTHERS => '1'),
        c_LCD_COMMAND_ADDRESS   => (OTHERS => '1'),
        OTHERS                  => (OTHERS => '0')
    );

    -- Registers

    SIGNAL r_Lcd_Valid : STD_LOGIC := '0';
    SIGNAL r_Lcd_Data_Type : STD_LOGIC := '0';
    SIGNAL r_Leds : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    
    -- Wires

    SIGNAL w_Address : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL w_Lcd_Ready_Intemediary : STD_LOGIC := '0';
    SIGNAL w_Lcd_Ready : STD_LOGIC := '0';
    SIGNAL w_Lcd_Ready_Edge : STD_LOGIC := '0';
    SIGNAL w_Data_To_Lcd : t_Byte := (OTHERS => '0');   
    SIGNAL w_Lcd_Data_Intemediary : t_Byte := (OTHERS => '0');
    SIGNAL w_Lcd_Rs_Intemediary : STD_LOGIC := '0';
    SIGNAL w_Lcd_Valid_Intemediary : STD_LOGIC := '0';
    SIGNAL w_Ps2_Clk : STD_LOGIC := '0';
    SIGNAL w_Ps2_Code : t_Byte := (OTHERS => '0');
    SIGNAL w_Ps2_Parity : STD_LOGIC := '0';
    SIGNAL w_Ps2_Code_Valid : STD_LOGIC := '0';
    SIGNAL w_Ps2_Pressed_Code : t_Byte := (OTHERS => '0');
    SIGNAL w_Ps2_Data_Valid : STD_LOGIC := '0';
    SIGNAL w_Ps2_Char : t_Byte := (OTHERS => '0');
BEGIN 
    e_CLOCK_SYNC: ENTITY WORK.ClockSync
    PORT MAP (
        i_Data  => i_Ps2_Clk,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Data  => w_Ps2_Clk
    );
    e_PS2_RECEPTOR: ENTITY WORK.Ps2Receptor
    PORT MAP (
        i_Ps2_Data  => i_Ps2_Data,
        i_Ps2_Clk   => w_Ps2_Clk,
        i_Clk       => i_Clk,
        i_Rst       => i_Rst,
        o_Ps2_Code  => w_Ps2_Code,
        o_Parity    => w_Ps2_Parity,
        o_Valid     => w_Ps2_Code_Valid
    );
    e_PS2_FILTER: ENTITY WORK.Ps2Filter
    PORT MAP (
        i_Data      => w_Ps2_Code,
        i_Valid     => w_Ps2_Code_Valid,
        i_Parity    => w_Ps2_Parity,
        i_Clk       => i_Clk,
        i_Rst       => i_Rst,
        o_Data      => w_Ps2_Pressed_Code,
        o_Valid     => w_Ps2_Data_Valid
    );
    e_PS2_CONVERTER: ENTITY WORK.Ps2Converter
    PORT MAP (
        i_Ps2_Code  => w_Ps2_Pressed_Code,
        o_Ps2_Char  => w_Ps2_Char
    );
    e_LCD_INTERFACE: ENTITY WORK.LcdInterface
    PORT MAP (
        i_Data      => w_Data_To_Lcd,
        i_Data_Type => r_Lcd_Data_Type,
        i_Valid     => r_Lcd_Valid,
        i_Ready     => w_Lcd_Ready_Intemediary,
        i_Clk       => i_Clk,
        i_Rst       => i_Rst,
        o_Data      => w_Lcd_Data_Intemediary,
        o_Ready     => w_Lcd_Ready,
        o_Data_Type => w_Lcd_Rs_Intemediary,
        o_Valid     => w_Lcd_Valid_Intemediary
    );
    e_LCD_DRIVER: ENTITY WORK.LcdDriver
    PORT MAP (
        i_Data      => w_Lcd_Data_Intemediary,
        i_Data_Type => w_Lcd_Rs_Intemediary,
        i_Valid     => w_Lcd_Valid_Intemediary,
        i_Clk       => i_Clk,
        i_Rst       => i_Rst,
        o_Ready     => w_Lcd_Ready_Intemediary,
        o_Lcd_Rs    => o_Lcd_Rs,
        o_Lcd_Data  => o_Lcd_Data,
        o_Lcd_Rw    => o_Lcd_Rw,
        o_Lcd_E     => o_Lcd_E
    );
    e_SSD_DRIVER: ENTITY WORK.SsdDriver
    PORT MAP(
		i_Value => r_IO_Registers(c_SSD_ADDRESS)(7 DOWNTO 0),
		i_Clk   => i_Clk,
        i_Rst   => i_Rst,
		o_Ssd_1 => o_Ssd_1,
		o_Ssd_2 => o_Ssd_2
	);
    e_READY_EDGE_DETECTOR: ENTITY WORK.EdgeDetector
    PORT MAP (
        i_Data  => w_Lcd_Ready,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Edge  => w_Lcd_Ready_Edge
    );

    o_Leds <= r_Leds;
    
    w_Address <= TO_INTEGER(t_UReg16(i_Address));

    w_Data_To_Lcd <= r_IO_Registers(c_LCD_DATA_ADDRESS)(7 DOWNTO 0) WHEN (r_Lcd_Data_Type = '1') ELSE
                     r_IO_Registers(c_LCD_COMMAND_ADDRESS)(7 DOWNTO 0);

    p_REGISTERS_READ_WRITE_CONTROL:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_IO_Registers <= (
                c_LCD_DATA_ADDRESS => (OTHERS => '1'),
                c_LCD_COMMAND_ADDRESS => (OTHERS => '1'),
                OTHERS => (OTHERS => '0')
            );
            o_Read_Data <= (OTHERS => '0');
        ELSIF(RISING_EDGE(i_Clk)) THEN
            r_IO_Registers(c_BUTTONS_ADDRESS)(3 DOWNTO 0) <= i_Buttons;
            
            IF(w_Ps2_Data_Valid = '1') THEN
                r_IO_Registers(c_KEYBOARD_ADDRESS)(7 DOWNTO 0) <= w_Ps2_Char;
            END IF;
            
            IF(w_Lcd_Ready_Edge = '1') THEN
                r_IO_Registers(c_LCD_DATA_ADDRESS) <= (OTHERS => '0');
                r_IO_Registers(c_LCD_COMMAND_ADDRESS) <= (OTHERS => '0');
            END IF;

            IF(w_Address < 16) THEN
                -- Write operation
                IF(
                    i_Write_Enable = '1' AND 
                    w_Address /= c_BUTTONS_ADDRESS AND
                    w_Address /= c_KEYBOARD_ADDRESS AND (
                        ((w_Address = c_LCD_DATA_ADDRESS OR w_Address = c_LCD_COMMAND_ADDRESS) AND w_Lcd_Ready = '1') OR
                        (w_Address /= c_LCD_DATA_ADDRESS AND w_Address /= c_LCD_COMMAND_ADDRESS)
                    )
                ) THEN
                    r_IO_Registers(w_Address) <= i_Write_Data;

                -- Zero PS/2 register on read operation
                ELSIF(
                    i_Write_Enable = '0' AND 
                    w_Address = c_KEYBOARD_ADDRESS
                ) THEN
                    r_IO_Registers(c_KEYBOARD_ADDRESS) <= (OTHERS => '0');
                END IF;

                -- Read operation
                o_Read_Data <= r_IO_Registers(w_Address);
            END IF;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;

    p_DEVICES_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            r_Leds <= r_IO_Registers(c_LEDS_ADDRESS)(3 DOWNTO 0);

            r_Lcd_Valid <= '0';

            IF(
                i_Write_Enable = '1' AND 
                w_Lcd_Ready = '1' AND (
                w_Address = c_LCD_DATA_ADDRESS OR 
                w_Address = c_LCD_COMMAND_ADDRESS) 
            ) THEN
                r_Lcd_Valid <= '1';
                
                IF(w_Address = c_LCD_DATA_ADDRESS) THEN
                    r_Lcd_Data_Type <= '1';
                ELSIF(w_Address = c_LCD_COMMAND_ADDRESS) THEN
                    r_Lcd_Data_Type <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS p_DEVICES_CONTROL;
END ARCHITECTURE;