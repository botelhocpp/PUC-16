LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY lcd_interface IS
PORT (
    din : IN t_byte;
    din_type : IN STD_LOGIC;
    vi : IN STD_LOGIC;
    i_ready : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    dout : OUT t_byte;
    o_ready : OUT STD_LOGIC;
    rs : OUT STD_LOGIC;
    vo : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF lcd_interface IS  
    -- Configuration sequence
    TYPE conf_sequence_t IS ARRAY (0 TO 4) OF t_byte;

    CONSTANT CONF_SEQUENCE : conf_sequence_t := (
        x"28", -- Function Set
        x"08", -- Display Off
        x"01", -- Clear
        x"06", -- Entry Mode Set
        x"0C"  -- Display On
    );

    TYPE lcd_state_data_t IS (
        INIT, 
        CONFIG, 
        USER_DATA
    );
    
    SIGNAL ready_posedge : STD_LOGIC := '0';
    SIGNAL state : lcd_state_data_t := INIT;
    SIGNAL counter : INTEGER RANGE 0 TO 150000000 := 0;
    SIGNAL config_it : INTEGER RANGE 0 TO CONF_SEQUENCE'LENGTH := 0;
    
    SIGNAL w_Register_Input : t_Reg16 := (OTHERS => '0');
BEGIN
    EDGE_DETECTOR_COMP: ENTITY WORK.edge_detector
    PORT MAP (
        A => i_ready,
        clk => clk,
        rst => rst,
        posedge => ready_posedge
    );
    
    o_ready <= i_ready WHEN (state = USER_DATA) ELSE '0';

    PROCESS(clk, rst)
    BEGIN
        IF(rst = '1') THEN
            state <= INIT;
            vo <= '0';
            dout <= (OTHERS => '0');
            rs <= '0';
            counter <= 0;
            config_it <= 0;
        ELSIF(RISING_EDGE(clk)) THEN
            CASE state IS
                WHEN INIT =>
                    IF(i_ready = '1') THEN
                        state <= CONFIG;
                    END IF;
                    
                WHEN CONFIG =>
                    IF(config_it = CONF_SEQUENCE'LENGTH) THEN
                        state <= USER_DATA;
                    ELSE
                        IF(i_ready = '1' AND config_it < CONF_SEQUENCE'LENGTH - 1) THEN
                            vo <= '1';
                        ELSE
                            vo <= '0';
                        END IF;
                        
                        IF(ready_posedge = '1') THEN
                            config_it <= config_it + 1;
                        END IF;
                        
                        rs <= '0';
                        dout <= CONF_SEQUENCE(config_it);
                    END IF;
                    
                WHEN USER_DATA =>
                    vo <= vi;
                    rs <= din_type;
                    dout <= din;

                WHEN OTHERS =>
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;