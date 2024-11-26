LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Testbench IS
END ENTITY;

ARCHITECTURE Structural OF Testbench IS
    CONSTANT c_CLOCK_50MHZ_PERIOD : TIME := 20ns;

    -- Input Signals
    SIGNAL i_Clk : STD_LOGIC := '0';
    SIGNAL i_Rst : STD_LOGIC := '0';
    
    -- Wires
    SIGNAL w_Data_To_Processor   : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Address             : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_From_Processor : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Write_Enable        : STD_LOGIC := '0';
BEGIN
    e_PROCESSOR: ENTITY WORK.processor
    PORT MAP ( 
        i_Data_In       => w_Data_To_Processor,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        o_Write_Enable  => w_Write_Enable,
        o_Address       => w_Address,
        o_Data_Out      => w_Data_From_Processor
    );
    e_MEMORY: ENTITY WORK.Memory
    GENERIC MAP (  g_CONTENTS_FILE => "memory.txt" )
    PORT MAP ( 
        i_Write_Data => w_Data_From_Processor,
        i_Address => w_Address,
        i_Write_Enable => w_Write_Enable,
        i_Clk => i_Clk,
        o_Read_Data => w_Data_To_Processor
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_50MHZ_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_50MHZ_PERIOD/4;
END ARCHITECTURE;