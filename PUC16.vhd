LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY PUC16 IS
PORT (
    i_Clk       : IN STD_LOGIC;
    i_Rst       : IN STD_LOGIC;
    i_Buttons   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE Structural OF PUC16 IS
    -- Wires
    SIGNAL w_Data_To_Processor          : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_From_Input_Output     : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_From_Memory           : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Address                    : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_From_Processor        : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Write_Enable               : STD_LOGIC := '0';
    SIGNAL w_Memory_Write_Enable        : STD_LOGIC := '0';
    SIGNAL w_Input_Output_Write_Enable  : STD_LOGIC := '0';
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
    PORT MAP ( 
        i_Write_Data    => w_Data_From_Processor,
        i_Address       => w_Address,
        i_Write_Enable  => w_Memory_Write_Enable,
        i_Clk           => i_Clk,
        o_Read_Data     => w_Data_From_Memory
    );
    e_IO_CONTROLLER: ENTITY WORK.InputOutputController
    PORT MAP (
        i_Write_Data    => w_Data_From_Processor,
        i_Address       => w_Address, 
        i_Write_Enable  => w_Input_Output_Write_Enable, 
        i_Clk           => i_Clk, 
        i_Buttons       => i_Buttons,
        o_Leds          => o_Leds, 
        o_Read_Data     => w_Data_From_Input_Output
    );

    w_Memory_Write_Enable <= '1' WHEN (
        w_Write_Enable = '1' AND
        w_Address >= x"0010"
    ) ELSE '0';
    
    w_Input_Output_Write_Enable <= '1' WHEN (
        w_Write_Enable = '1' AND
        w_Address < x"0010"
    ) ELSE '0';

    w_Data_To_Processor <=  w_Data_From_Memory WHEN (w_Address >= x"0010") ELSE 
                            w_Data_From_Input_Output;
END ARCHITECTURE;