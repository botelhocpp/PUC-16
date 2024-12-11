LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY LcdDriver IS
PORT (
    i_Data : IN t_Byte;
    i_Data_Type : IN STD_LOGIC;
    i_Valid : IN STD_LOGIC;
    
    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    
    o_Ready : OUT STD_LOGIC;
    o_Lcd_Rs : OUT STD_LOGIC;
    o_Lcd_Data : OUT t_Nibble;
    o_Lcd_Rw : OUT STD_LOGIC;
    o_Lcd_E : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF LcdDriver IS
    CONSTANT c_MAX_NUMBER_CYCLES : INTEGER := 750000;
    
    TYPE t_SequenceElement IS RECORD
        Data : t_Nibble;
        E : STD_LOGIC;
        Count : INTEGER RANGE 0 TO c_MAX_NUMBER_CYCLES;
    END RECORD;
    
    TYPE t_InitSequence IS ARRAY (0 TO 8) OF t_SequenceElement;
    
    CONSTANT INIT_SEQUENCE : t_InitSequence := (
        ("0000", '0', 750000),  -- 15ms
        ("0011", '1', 12),      -- 240ns
        ("0000", '0', 205000),  -- 4.1 ms 
        ("0011", '1', 12),      -- 240ns
        ("0000", '0', 5000),    -- 100 μs
        ("0011", '1', 12),      -- 240ns
        ("0000", '0', 2000),    -- 40μs
        ("0010", '1', 12),      -- 240ns
        ("0000", '0', 2000)     -- 40μs
    );
    
    TYPE t_LcdProtocolState IS (
        s_INIT_SETUP,
        s_IDLE,
        s_SEND_HIGH_NIBBLE, 
        s_PULSE_EN_01, 
        s_DELAY_01, 
        s_SEND_LOW_NIBBLE,
        s_PULSE_EN_02, 
        s_DELAY_02
    );
    SIGNAL r_State : t_LcdProtocolState := s_INIT_SETUP;
    
    SIGNAL r_Counter : INTEGER RANGE 0 TO c_MAX_NUMBER_CYCLES := 0;
    SIGNAL r_Init_It : INTEGER RANGE 0 TO INIT_SEQUENCE'LENGTH := 0;
BEGIN
    o_Lcd_Rw <= '0';
    
    PROCESS(i_Clk, i_Rst)
    BEGIN
        IF(i_Rst = '1') THEN
            r_State <= s_INIT_SETUP;
            r_Counter <= 0;
            r_Init_It <= 0;
            
            o_Ready <= '0';
            o_Lcd_Rs <= '0';
            o_Lcd_E <= '0';
            o_Lcd_Data <= "0000";
        ELSIF(RISING_EDGE(i_Clk)) THEN
            -- Default
            o_Lcd_Rs <= i_Data_Type;
            
            CASE r_State IS
                WHEN s_INIT_SETUP =>
                    o_Lcd_Rs <= '0';
                    IF(r_Init_It = INIT_SEQUENCE'LENGTH) THEN
                        r_State <= s_IDLE;
                    ELSE
                        IF(r_Counter < INIT_SEQUENCE(r_Init_It).Count) THEN
                            o_Lcd_Data <= INIT_SEQUENCE(r_Init_It).Data;
                            o_Lcd_E <= INIT_SEQUENCE(r_Init_It).E;
                            r_Counter <= r_Counter + 1;
                        ELSE
                            r_Counter <= 0;
                            r_Init_It <= r_Init_It + 1;
                        END IF;
                    END IF;
                
                WHEN s_IDLE =>
                    o_Lcd_E <= '0';
                    IF(i_Valid = '1') THEN
                        r_State <= s_SEND_HIGH_NIBBLE;
                        o_Ready <= '0';
                    ELSE
                        o_Ready <= '1';
                    END IF;    
                    
                WHEN s_SEND_HIGH_NIBBLE => 
                    o_Lcd_Data <= i_Data(7 DOWNTO 4);
                    o_Lcd_E <= '0';
                    o_Ready <= '0';
                    
                    -- Wait 40ns
                    IF(r_Counter < 2) THEN
                        r_Counter <= r_Counter + 1;
                    ELSE
                        r_Counter <= 0;
                        r_State <= s_PULSE_EN_01;
                    END IF;
                    o_Lcd_E <= '0';
                    
                WHEN s_PULSE_EN_01 =>
                    -- Wait 240ns
                    IF(r_Counter < 12) THEN
                        r_Counter <= r_Counter + 1;
                    ELSE
                        r_Counter <= 0;
                        r_State <= s_DELAY_01;
                    END IF;
                    o_Lcd_E <= '1'; 
                    
                WHEN s_DELAY_01 =>
                    -- Wait 1us
                    IF(r_Counter < 50) THEN
                        r_Counter <= r_Counter + 1;
                    ELSE
                        r_Counter <= 0;
                        r_State <= s_SEND_LOW_NIBBLE;
                    END IF;
                    o_Lcd_E <= '0';
                    
                WHEN s_SEND_LOW_NIBBLE =>
                    -- Wait 40ns
                    IF(r_Counter < 2) THEN
                        r_Counter <= r_Counter + 1;
                    ELSE
                        r_Counter <= 0;
                        r_State <= s_PULSE_EN_02;
                    END IF;
                    o_Lcd_E <= '0';      
                    o_Lcd_Data <= i_Data(3 DOWNTO 0);
                    
                WHEN s_PULSE_EN_02 =>
                    -- Wait 240ns
                    IF(r_Counter < 12) THEN
                        r_Counter <= r_Counter + 1;
                    ELSE
                        r_Counter <= 0;
                        r_State <= s_DELAY_02;
                    END IF;
                    o_Lcd_E <= '1'; 
                    
                WHEN s_DELAY_02 =>
                    IF(i_Data = x"01") THEN
                        -- Wait 1.64ms
                        IF(r_Counter < 82000) THEN
                            r_Counter <= r_Counter + 1;
                        ELSE
                            r_Counter <= 0;
                            r_State <= s_IDLE;
                        END IF;
                    ELSE
                        -- Wait 40us
                        IF(r_Counter < 2000) THEN
                            r_Counter <= r_Counter + 1;
                        ELSE
                            r_Counter <= 0;
                            r_State <= s_IDLE;
                        END IF;
                    END IF;
                    o_Lcd_E <= '0';
            END CASE;
        END IF;
    END PROCESS;    
END ARCHITECTURE;