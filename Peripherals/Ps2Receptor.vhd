LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ps2_receptor IS
PORT (
    ps2_data : IN STD_LOGIC;
    ps2_clk : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    code : OUT t_Byte;
    parity_ok : OUT STD_LOGIC;
    vo : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF ps2_receptor IS
    TYPE ps2_state IS (IDLE, DATA, PARITY);
    
    SIGNAL state : ps2_state;
    SIGNAL counter : UNSIGNED(2 DOWNTO 0);
    SIGNAL data_done : STD_LOGIC;
    SIGNAL odd_parity : STD_LOGIC;
    SIGNAL gen_parity : STD_LOGIC;
    SIGNAL ps2_code : t_Byte;
BEGIN
    VO_EDGE_DETECTOR_COMP: ENTITY WORK.edge_detector
    PORT MAP (
        A => data_done,
        clk => clk,
        rst => rst,
        posedge => vo
    );
    PARITY_EDGE_DETECTOR_COMP: ENTITY WORK.edge_detector
    PORT MAP (
        A => odd_parity,
        clk => clk,
        rst => rst,
        posedge => parity_ok
    );
    PARITY_GENERATOR_COMP: ENTITY WORK.parity_generator
    PORT MAP (
        data => ps2_code,
        odd_parity => gen_parity
    );
    
    code <= ps2_code;
    
    -- PS/2 FSM (at 30kHz)
    PROCESS(ps2_clk, rst)
    BEGIN
        IF(rst = '1') THEN
            state <= IDLE;
            ps2_code <= (OTHERS => '0');
            counter <= "000";
            data_done <= '0';
            odd_parity <= '0';
        ELSIF(FALLING_EDGE(ps2_clk)) THEN
            CASE state IS
                WHEN IDLE =>
                    IF(ps2_data = '0') THEN
                        state <= DATA;
                    END IF;
                    data_done <= '0';
                    odd_parity <= '0';
                WHEN DATA =>
                    IF(counter = "111") THEN
                        state <= PARITY;
                    END IF;
                    ps2_code(TO_INTEGER(counter)) <= ps2_data;
                    counter <= counter + 1;
                WHEN PARITY =>
                    IF(ps2_data = gen_parity) THEN
                        odd_parity <= '1';
                    ELSE
                        odd_parity <= '0';
                    END IF;
                    state <= IDLE;
                    data_done <= '1';
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;
