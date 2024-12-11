LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY LcdInterface IS
PORT (
    i_Data : IN t_Byte;
    i_Data_Type : IN STD_LOGIC;
    i_Valid : IN STD_LOGIC;
    i_Ready : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    o_Data : OUT t_Byte;
    o_Ready : OUT STD_LOGIC;
    o_Data_Type : OUT STD_LOGIC;
    o_Valid : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF LcdInterface IS  
    TYPE t_ConfigurationSequence IS ARRAY (0 TO 4) OF t_Byte;

    CONSTANT c_CONFIGURATION_SEQUENCE : t_ConfigurationSequence := (
        x"28", -- Function Set
        x"08", -- Display Off
        x"01", -- Clear
        x"06", -- Entry Mode Set
        x"0C"  -- Display On
    );

    TYPE t_LcdState IS (
        s_INIT, 
        s_CONFIG, 
        s_USER_DATA
    );
    
    SIGNAL w_Ready_Posedge : STD_LOGIC := '0';
    SIGNAL r_State : t_LcdState := s_INIT;
BEGIN
    e_READY_EDGE_DETECTOR: ENTITY WORK.EdgeDetector
    PORT MAP (
        i_Data => i_Ready,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Edge => w_Ready_Posedge
    );
    
    o_Ready <= i_Ready WHEN (r_State = s_USER_DATA) ELSE '0';

    PROCESS(i_Clk, i_Rst)
        VARIABLE v_Config_It : INTEGER RANGE 0 TO c_CONFIGURATION_SEQUENCE'LENGTH := 0;
    BEGIN
        IF(i_Rst = '1') THEN
            r_State <= s_INIT;
            o_Valid <= '0';
            o_Data <= (OTHERS => '0');
            o_Data_Type <= '0';
            v_Config_It := 0;
        ELSIF(RISING_EDGE(i_Clk)) THEN
            CASE r_State IS
                WHEN s_INIT =>
                    IF(i_Ready = '1') THEN
                        r_State <= s_CONFIG;
                    END IF;
                    
                WHEN s_CONFIG =>
                    IF(v_Config_It = c_CONFIGURATION_SEQUENCE'LENGTH) THEN
                        r_State <= s_USER_DATA;
                    ELSE
                        IF(i_Ready = '1' AND v_Config_It < c_CONFIGURATION_SEQUENCE'LENGTH - 1) THEN
                            o_Valid <= '1';
                        ELSE
                            o_Valid <= '0';
                        END IF;
                        
                        IF(w_Ready_Posedge = '1') THEN
                            v_Config_It := v_Config_It + 1;
                        END IF;
                        
                        o_Data_Type <= '0';
                        o_Data <= c_CONFIGURATION_SEQUENCE(v_Config_It);
                    END IF;
                    
                WHEN s_USER_DATA =>
                    o_Valid <= i_Valid;
                    o_Data_Type <= i_Data_Type;
                    o_Data <= i_Data;

                WHEN OTHERS =>
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;