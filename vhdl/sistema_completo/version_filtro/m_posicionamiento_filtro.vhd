----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:13:51 04/27/2022 
-- Design Name: 
-- Module Name:    m_posicionamiento_filtro - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity m_posicionamiento_filtro is
	port (
	rst : in std_logic; 
   clk : in std_logic;
	 
	instruction : in std_logic_vector(1 downto 0);
	activate : in std_logic;
	ended : out std_logic;
	final_stop_left : in std_logic;
	final_stop_right : in std_logic;
	motor_pulse : out std_logic;
	motor_dir : out std_logic
	);
	 
end m_posicionamiento_filtro;

architecture Behavioral of m_posicionamiento_filtro is

	signal aux_activate : std_logic;
	signal posicion : std_logic_vector(1 downto 0);
	signal aux_posicion: std_logic_vector(1 downto 0);
	signal actual_pos: std_logic_vector(1 downto 0);
	
	signal cuenta_motor : unsigned (4 downto 0);
	signal ta : unsigned (4 downto 0);
	signal dir : std_logic;
	
begin

-----------------------------------------------------------
-- Maquina de estados para cambiar de posicion
ME_posiciones : process(rst, clk)
	begin
		if rst='1' then
			-- Ir a posicion incial
			ta <= "00000";
			dir <= '1';
		elsif clk' event and clk='1' then
			case actual_pos is 
				when "00" => -- Partir de posicion inicial
					case instruction is
						when "01" => -- Ir al primer filtro
							ta <= "00000";
							dir <= '0';
						when "10" => -- Ir al segundo filtro
							ta <= "00000";
							dir <= '0';
						when "11" => -- Ir al tercer filtro
							ta <= "00000";
							dir <= '0';
						when others => -- Quieto
							ta <= "00000";
							dir <= '0';
					end case;
				when "01" => -- Partir del primer filtro
					case instruction is
						when "00" => -- Ir a la posicion inicial
							ta <= "00000";
							dir <= '1';
						when "10" => -- Ir al segundo filtro
							ta <= "00000";
							dir <= '0';
						when "11" => -- Ir al tercer filtro
							ta <= "00000";
							dir <= '0';
						when others => -- Quieto
							ta <= "00000";
							dir <= '0';
					end case;
				when "10" => -- Partir del segundo filtro
					case instruction is
						when "00" => -- Ir a la posicion inicial
							ta <= "00000";
							dir <= '1';
						when "01" => -- Ir al primer filtro
							ta <= "00000";
							dir <= '1';
						when "11" => -- Ir al tercer filtro
							ta <= "00000";
							dir <= '0';
						when others => -- Quieto
							ta <= "00000";
							dir <= '0';
					end case;
				when "11" => -- Partir del tercer filtro
					case instruction is
						when "00" => -- Ir a la posicion inicial
							ta <= "00000";
							dir <= '1';
						when "01" => -- Ir al primer filtro
							ta <= "00000";
							dir <= '1';
						when "10" => -- Ir al segundo filtro
							ta <= "00000";
							dir <= '1';
						when others => -- Quieto
							ta <= "00000";
							dir <= '0';
					end case;
				when others => -- Volver a la posicion del filtro original
					ta <= "00000";
					dir <= '1';
			end case;
		end if;
	end process;

-----------------------------------------------------------
-- Biestable para almacenar el filtro al que debe ir
biest_posicion : process(rst, clk)
    begin
        if rst='1' then
            aux_posicion <="00";
        elsif clk' event and clk='1' then
				if activate = '1' then -- Llega nueva instruccion
					aux_posicion <= instruction ;
				else -- Nuevo ciclo sin instruccion
					aux_posicion <= aux_posicion ;
				end if;
      end if;
    end process;  
 posicion <= aux_posicion;
 
-----------------------------------------------------------
-- Proceso para mover el motor durante un tiempo ta
Proceso_mover_filtro : process (clk, rst)
	begin
		if rst = '1' then 
			-- Mover filtro a pos 0
		elsif clk' event and clk = '1' then
			-- Motor activo y finales de carrera desactivados
			if aux_activate = '1' and final_stop_left = '0' and final_stop_right = '0' then 
				-- Cuando me toca hacer un step
			  if cuenta_motor = ta-1 then  -- llegar a la posicion
				 cuenta_motor <= (others =>'0');
				 actual_pos <= posicion;
			  else
				 cuenta_motor <= cuenta_motor + 1;
			  end if;
			else
			  cuenta_motor <= (others =>'0');
			end if;          
      end if;
  end process;

-----------------------------------------------------------

end Behavioral;