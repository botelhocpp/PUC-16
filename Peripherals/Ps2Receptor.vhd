LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Ps2Receptor IS
PORT (
    i_Ps2_Data : IN STD_LOGIC;
    i_Ps2_Clk : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    o_Ps2_Code : OUT t_Byte;
    o_Parity : OUT STD_LOGIC;
    o_Valid : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF Ps2Receptor IS
    TYPE t_Ps2State IS (s_IDLE, s_DATA, s_PARITY);
    
    SIGNAL r_State : t_Ps2State;
    
    SIGNAL r_Data_Counter : UNSIGNED(2 DOWNTO 0);
    SIGNAL r_Data_Done : STD_LOGIC;
    SIGNAL o_Odd_Parity : STD_LOGIC;
    SIGNAL w_Odd_Parity : STD_LOGIC;
    SIGNAL r_Ps2_Code : t_Byte;
BEGIN
    e_VALID_EDGE_DETECTOR: ENTITY WORK.EdgeDetector
    PORT MAP (
        i_Data => r_Data_Done,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Edge => o_Valid
    );
    e_PARITY_EDGE_DETECTOR: ENTITY WORK.EdgeDetector
    PORT MAP (
        i_Data => w_Odd_Parity,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Edge => o_Parity
    );
    e_PARITY_GENERATOR: ENTITY WORK.ParityGenerator
    PORT MAP (
        i_Data => r_Ps2_Code,
        o_Odd_Parity => w_Odd_Parity
    );
    
    o_Ps2_Code <= r_Ps2_Code;
    
    p_PS2_RECEPTOR_FSM:
    PROCESS(i_Ps2_Clk, i_Rst)
    BEGIN
        IF(i_Rst = '1') THEN
            r_State <= s_IDLE;
            r_Ps2_Code <= (OTHERS => '0');
            r_Data_Counter <= "000";
            r_Data_Done <= '0';
            o_Odd_Parity <= '0';
        ELSIF(FALLING_EDGE(i_Ps2_Clk)) THEN
            CASE r_State IS
                WHEN s_IDLE =>
                    IF(i_Ps2_Data = '0') THEN
                        r_State <= s_DATA;
                    END IF;
                    r_Data_Done <= '0';
                    o_Odd_Parity <= '0';
                WHEN s_DATA =>
                    IF(r_Data_Counter = "111") THEN
                        r_State <= s_PARITY;
                    END IF;
                    r_Ps2_Code(TO_INTEGER(r_Data_Counter)) <= i_Ps2_Data;
                    r_Data_Counter <= r_Data_Counter + 1;
                WHEN s_PARITY =>
                    IF(i_Ps2_Data = w_Odd_Parity) THEN
                        o_Odd_Parity <= '1';
                    ELSE
                        o_Odd_Parity <= '0';
                    END IF;
                    r_State <= s_IDLE;
                    r_Data_Done <= '1';
            END CASE;
        END IF;
    END PROCESS p_PS2_RECEPTOR_FSM;
END ARCHITECTURE;
