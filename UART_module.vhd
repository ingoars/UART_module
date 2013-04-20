----------------------------------------------------------------------------------
-- Create Date:    19:35:10 04/15/2013 
-- Design Name: 
-- Module Name:    UART_module - Behavioral 
-- Project Name: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package UART_module_pack is
   component UART_module is
   Port (CLK : in  STD_LOGIC;
			Tx : out  STD_LOGIC := '1';
			Din : in  STD_LOGIC_VECTOR (7 downto 0);
         Rx:   in  STD_LOGIC;
         Dout: out STD_LOGIC_VECTOR (7 downto 0);
         Trig : in  STD_LOGIC);
   end component;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_module is
	 Port ( 	CLK : in  STD_LOGIC;
				Tx : out  STD_LOGIC := '1';
				Din : in  STD_LOGIC_VECTOR (7 downto 0);
				Rx:   in  STD_LOGIC;
				Dout: out STD_LOGIC_VECTOR (7 downto 0);
				Trig : in  STD_LOGIC);
				
end UART_module;

architecture Behavioral of UART_module is
   
	--señales Rx
	signal Prescaler_Rx: std_logic_vector(12 downto 0) := (others => '0');
   signal Prescaler_Rx_Listo: std_logic;
   constant retardo_bit_Rx: std_logic_vector(Prescaler_Rx'range) := 
				std_logic_vector(to_unsigned(50000000/9600 -1, Prescaler_Rx'length));
   constant retardo_inicio_Rx: std_logic_vector(Prescaler_Rx'range) :=
				std_logic_vector(to_unsigned(50000000/2/9600 -1, Prescaler_Rx'length));
 
   type 	Estado_Rx is (Er_Espera, Er_Inicio, Er_Datos, Er_Paro);
   signal Estado_actual_Rx: Estado_Rx := Er_Espera;
 
   signal Buffer_Rx: std_logic_vector(7 downto 0) := (others => '0');
   signal Conteo_Datos_Rx: std_logic_vector(2 downto 0) := (others => '0');
	
	--señales Tx 
	signal Prescaler_Tx: STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
	signal Prescaler_Tx_Listo: STD_LOGIC; 

	type Estado_Tx is (Et_silencio, Et_arranque, Et_datos, Et_parada);
	signal Estado_actual_Tx: Estado_Tx := Et_silencio;

	signal Buffer_Tx: std_logic_vector(7 downto 0) := (others => '0');
	signal Conteo_Datos_Tx : STD_LOGIC_VECTOR (2 downto 0);
	
	--control de botones
	signal TrigA : STD_LOGIC := '0'; 
	signal ConteoPrescTrig : STD_LOGIC_VECTOR (18 downto 0) := (others => '0');
	signal TrigCLKen : STD_LOGIC; 
	signal TrigEn: STD_LOGIC;
	
begin
	
	--begin Rx
	Prescaler_Rx_Listo <= '1' when Prescaler_Rx = 0 else '0';
   process (CLK)
   begin
      if rising_edge(CLK) then
         if Prescaler_Rx_Listo = '1' then
            case Estado_actual_Rx is
            when Er_Espera =>
               if Rx = '0' then
                  Prescaler_Rx <= retardo_inicio_Rx;
                  Estado_actual_Rx <= Er_Inicio;
               end if;
            when Er_Inicio =>
               Conteo_Datos_Rx <= (others => '0');
               Estado_actual_Rx <= Er_Datos;
					Prescaler_Rx <= retardo_bit_Rx;
            when Er_Datos =>
               Buffer_Rx <= RX & Buffer_Rx(7 downto 1);
               if Conteo_Datos_Rx = 7 then
                  Estado_actual_Rx <= Er_Paro;
               end if;
               Conteo_Datos_Rx <= Conteo_Datos_Rx + 1;
					Prescaler_Rx <= retardo_bit_Rx;
            when Er_Paro =>
               Estado_actual_Rx <= Er_Espera;
            end case;
         else
            Prescaler_Rx <= Prescaler_Rx - 1;
         end if;
      end if;
   end process;
	Dout <= Buffer_Rx;
	
	--begin Tx
	ConteoPrescTrig <= ConteoPrescTrig +1 when rising_edge(CLK);
	TrigCLKen <= '1' when ConteoPrescTrig = 0 else '0'; 
	TrigA <= Trig when rising_edge(CLK) and TrigCLKen = '1'; 

	process (CLK)
	begin
		if rising_edge(CLK) then
			--if TrigCLKen = '1' and TrigA = '0' and Trig = '1' then
         if Trig = '1' then
				TrigEn <= '1';
            Buffer_Tx <= Din;
			elsif Prescaler_Tx_Listo = '1' and Estado_actual_Tx = Et_silencio then
			   TrigEn <= '0';
			end if;
		end if;
	end process;

	process (CLK)
	begin
		if rising_edge(CLK) then
			if Prescaler_Tx = 5207 then
			   Prescaler_Tx <= (others => '0');
			else
				Prescaler_Tx <= Prescaler_Tx + 1;
			end if;
		end if;
	end process;

	Prescaler_Tx_Listo <= '1' when Prescaler_Tx = 0 else '0';

	process (CLK)
	begin
		if rising_edge(CLK) and Prescaler_Tx_Listo = '1' then
			case Estado_actual_Tx is
			when Et_silencio =>
				if TrigEn = '1' then
				   Estado_actual_Tx <= Et_arranque;
				end if;
			when Et_arranque =>
				Estado_actual_Tx <= Et_datos;
				Conteo_Datos_Tx <= (others => '0');
			when Et_datos =>
				Conteo_Datos_Tx <= Conteo_Datos_Tx + 1;
				if Conteo_Datos_Tx = 7 then
					Estado_actual_Tx <= Et_parada;
				end if;
			when Et_parada => 
				Estado_actual_Tx <= Et_silencio;
			end case;
		end if;
	end process;

	process (Estado_actual_Tx, Buffer_Tx, Conteo_Datos_Tx)
	begin
		case Estado_actual_Tx is
		when Et_silencio =>
			Tx <= '1';
		when Et_arranque =>
			Tx <= '0';
		when Et_datos =>
			Tx <= Buffer_Tx(conv_integer(Conteo_Datos_Tx));
		when Et_parada => 
			Tx <= '1';
		end case;
	end process;

--   PrescBaudios <= PrescBaudios + 1 when rising_edge(clk) and PrescBaudios < 5207 else
--                 	(others => '0') when rising_edge(clk);
	
end Behavioral;

