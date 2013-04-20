library ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY Banca_Prueba IS
END Banca_Prueba;
 
ARCHITECTURE behavior OF Banca_Prueba IS 
    COMPONENT TopLevel
    PORT(
         clk : IN  std_logic;
         TX : OUT  std_logic;
         RX : IN  std_logic
        );
    END COMPONENT;
    
   signal clk : std_logic := '0';
   signal RX : std_logic := '0';

   signal TX : std_logic;

   constant clk_period : time := 20 ns; 
BEGIN
   uut: TopLevel PORT MAP (
          clk => clk,
          TX => TX,
          RX => RX
        );

   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;
END;
