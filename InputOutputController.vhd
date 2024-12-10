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

    i_Buttons       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- /ps2 keyboard
    ps2_data : IN STD_LOGIC;
    ps2_clk : IN STD_LOGIC;

    -- /lcd
    lcd_rs : OUT STD_LOGIC;
    lcd_data : OUT t_Nibble;
    lcd_rw : OUT STD_LOGIC;
    lcd_e : OUT STD_LOGIC;
    
    j1 : OUT STD_LOGIC_VECTOR(3 downto 0);
    j2 : OUT STD_LOGIC_VECTOR(3 downto 0)
);
END ENTITY;

ARCHITECTURE RTL OF InputOutputController IS 
    CONSTANT c_BUTTONS_ADDRESS : INTEGER := 0;
    CONSTANT c_KEYBOARD_ADDRESS : INTEGER := 2;
    CONSTANT c_LEDS_ADDRESS : INTEGER := 5;
    CONSTANT c_SSD_ADDRESS : INTEGER := 6;
    CONSTANT c_LCD_DATA_ADDRESS : INTEGER := 7;
    CONSTANT c_LCD_COMMAND_ADDRESS : INTEGER := 8;
    
    TYPE t_IORegisterArray IS ARRAY (0 TO 15) OF t_Reg16; 
    SIGNAL r_IO_Registers : t_IORegisterArray := (
        c_LCD_DATA_ADDRESS => (OTHERS => '1'),
        c_LCD_COMMAND_ADDRESS => (OTHERS => '1'),
        OTHERS => (OTHERS => '0')
    );

    SIGNAL r_Leds : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 16 := 0;

    -- Signals

    SIGNAL ps2_sync_clk : STD_LOGIC := '0';
    SIGNAL parity_ok : STD_LOGIC := '0';
    SIGNAL data_done : STD_LOGIC := '0';
    SIGNAL load_reg : STD_LOGIC := '0';
    SIGNAL lcd_ready : STD_LOGIC := '0';
    SIGNAL lcd_is_ready : STD_LOGIC := '0';
    SIGNAL lcd_is_ready_edge : STD_LOGIC := '0';
    
    SIGNAL code : t_Byte := (OTHERS => '0');
    SIGNAL pressed_code : t_Byte := (OTHERS => '0');
    SIGNAL char : t_Byte := (OTHERS => '0');
    SIGNAL reg_value : t_Byte := (OTHERS => '0');
    
    SIGNAL w_Lcd_Data : t_Byte := (OTHERS => '0');
    SIGNAL r_Lcd_Data_Loaded : STD_LOGIC := '0';
    SIGNAL r_Lcd_Valid : STD_LOGIC := '0';
    SIGNAL r_Lcd_Data_Type : STD_LOGIC := '0';
    
    SIGNAL lcd_data_intemediary : t_Byte := (OTHERS => '0');
    SIGNAL lcd_rs_intemediary : STD_LOGIC := '0';
    SIGNAL lcd_vo_intemediary : STD_LOGIC := '0';
    
    SIGNAL IO_ps2kb: t_Byte := (OTHERS => '0');
    SIGNAL IO_7seg: t_Byte := (OTHERS => '0');
    
    CONSTANT zero_byte : t_byte := (others => '0');
BEGIN 
    SYNC_COMP: ENTITY WORK.sync
    PORT MAP (
        A => ps2_clk,
        clk => i_Clk,
        rst => i_Rst,
        B => ps2_sync_clk
    );
    PS2_RECEPTOR_COMP: ENTITY WORK.ps2_receptor
    PORT MAP (
        ps2_data => ps2_data,
        ps2_clk => ps2_sync_clk,
        clk => i_Clk,
        rst => i_Rst,
        code => code,
        parity_ok => parity_ok,
        vo => data_done
    );
    PS2_FILTER_COMP: ENTITY WORK.ps2_filter
    PORT MAP (
        din => code,
        vi => data_done,
        parity_ok => parity_ok,
        clk => i_Clk,
        rst => i_Rst,
        dout => pressed_code,
        vo => load_reg
    );
    PS2_CONVERTER_COMP: ENTITY WORK.ps2_converter
    PORT MAP (
        code => pressed_code,
        char => IO_ps2kb
    );
    LCD_INTERFACE_COMP: ENTITY WORK.lcd_interface
    PORT MAP (
        din => w_Lcd_Data,
        din_type => r_Lcd_Data_Type,
        vi => r_Lcd_Valid,
        i_ready => lcd_ready,
        clk => i_Clk,
        rst => i_Rst,
        dout => lcd_data_intemediary,
        o_ready => lcd_is_ready,
        rs => lcd_rs_intemediary,
        vo => lcd_vo_intemediary
    );
    LCD_DRIVER_COMP: ENTITY WORK.lcd_driver
    PORT MAP (
        data => lcd_data_intemediary,
        rs => lcd_rs_intemediary,
        vi => lcd_vo_intemediary,
        clk => i_Clk,
        rst => i_Rst,
        ready => lcd_ready,
        lcd_rs => lcd_rs,
        lcd_data => lcd_data,
        lcd_rw => lcd_rw,
        lcd_e => lcd_e
    );
	SSD_DRIVER: ENTITY WORK.driver
    PORT MAP(
		cnt => r_IO_Registers(c_SSD_ADDRESS)(7 DOWNTO 0),
		CLK_50MHZ => i_Clk,
		J1 => J1,
		J2 => J2
	);
    EDGE_DETECTOR_COMP: ENTITY WORK.edge_detector
    PORT MAP (
        A => lcd_is_ready,
        clk => i_clk,
        rst => i_rst,
        posedge => lcd_is_ready_edge
    );

    o_Leds <= r_Leds;
    
    w_Address <= TO_INTEGER(t_UReg16(i_Address)) WHEN (i_Address < x"0010") ELSE 16;

    w_Lcd_Data <=   r_IO_Registers(c_LCD_DATA_ADDRESS)(7 DOWNTO 0) WHEN (r_Lcd_Data_Type = '1') ELSE
                    r_IO_Registers(c_LCD_COMMAND_ADDRESS)(7 DOWNTO 0);

    p_REGISTERS_READ_WRITE_CONTROL:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_IO_Registers <= (OTHERS => x"0000");
            o_Read_Data <= x"0000";
            r_Lcd_Valid <= '0';
        ELSIF(RISING_EDGE(i_Clk)) THEN
            r_Lcd_Valid <= '0';

            r_IO_Registers(c_BUTTONS_ADDRESS)(3 DOWNTO 0) <= i_Buttons;
            r_IO_Registers(c_KEYBOARD_ADDRESS)(7 DOWNTO 0) <= IO_ps2kb;

            IF(lcd_is_ready_edge = '1') THEN
                r_IO_Registers(c_LCD_DATA_ADDRESS) <= x"0000";
                r_IO_Registers(c_LCD_COMMAND_ADDRESS) <= x"0000";
            ELSE     
                IF(w_Address < 16) THEN
                    IF(
                        i_Write_Enable = '1' AND 
                        w_Address /= c_BUTTONS_ADDRESS AND
                        w_Address /= c_KEYBOARD_ADDRESS
                    ) THEN
                        IF(w_Address = c_LCD_DATA_ADDRESS) THEN
                            IF(lcd_is_ready = '1') THEN
                                r_Lcd_Valid <= '1';
                                r_IO_Registers(w_Address) <= i_Write_Data;
                            END IF;
                        ELSE
                            r_IO_Registers(w_Address) <= i_Write_Data;
                        END IF;
                    ELSIF(i_Write_Enable = '0') THEN
                        IF(w_Address = c_KEYBOARD_ADDRESS) THEN
                            r_IO_Registers(c_KEYBOARD_ADDRESS) <= (OTHERS => '0');
                        END IF;
                    END IF;

                    o_Read_Data <= r_IO_Registers(w_Address);
                END IF;
            END IF;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;

    p_DEVICES_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            --r_Lcd_Valid <= '0';
            
            IF(
                i_Write_Enable = '1' AND
                (w_Address = c_LCD_DATA_ADDRESS OR 
                w_Address = c_LCD_COMMAND_ADDRESS)
            ) THEN
                --r_Lcd_Valid <= '1';

                IF(w_Address = c_LCD_DATA_ADDRESS) THEN
                    r_Lcd_Data_Type <= '1';
                ELSIF(w_Address = c_LCD_COMMAND_ADDRESS) THEN
                    r_Lcd_Data_Type <= '0';
                END IF;
            END IF;

            r_Leds <= r_IO_Registers(c_LEDS_ADDRESS)(3 DOWNTO 0);
        END IF;
    END PROCESS p_DEVICES_CONTROL;
END ARCHITECTURE;