LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY memory IS
    GENERIC (
        START_ADDR : t_Reg16 := (OTHERS => '0');
        CONTENTS_FILE : STRING := "none"
    );
    PORT (
        data_in : IN t_Reg16;
        address : IN t_Reg16;
        we : IN STD_LOGIC;
        oe : IN STD_LOGIC;
        bw : IN STD_LOGIC;
        i_Clk : IN STD_LOGIC;
        data_out : OUT t_Reg16
    );
END memory;

ARCHITECTURE behavioral OF memory IS 
    SIGNAL contents : t_MemoryArray := f_InitMemory(CONTENTS_FILE);
    
    SIGNAL memory_address : t_UReg16;
    SIGNAL address_integer : INTEGER;
BEGIN 
    memory_address <= t_UReg16(address) - t_UReg16(START_ADDR);
    address_integer <= TO_INTEGER( memory_address );
    
    PROCESS(i_Clk, address_integer, oe, we)
    BEGIN
        IF(address_integer >= 0 AND address_integer < c_MEMORY_SIZE) THEN
            IF(oe = '1') THEN        
                data_out(7 DOWNTO 0) <= contents(address_integer);            
                data_out(15 DOWNTO 8) <= contents(address_integer + 1);
                data_out(23 DOWNTO 16) <= contents(address_integer + 2);
                data_out(31 DOWNTO 24) <= contents(address_integer + 3);
            ELSIF(RISING_EDGE(i_Clk) AND we = '1') THEN
                IF(bw = '0') THEN
                    contents(address_integer + 1) <= data_in(15 DOWNTO 8);
                    contents(address_integer + 2) <= data_in(23 DOWNTO 16);
                    contents(address_integer + 3) <= data_in(31 DOWNTO 24);
                END IF;
                contents(address_integer) <= data_in(7 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
END behavioral;