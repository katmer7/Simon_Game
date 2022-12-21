-- Interfaz del módulo de memoria RAM de doble puerto
-- con entrada de habilitación de escritura (señal de validación del color)
-- dirección de escritura que coincide con el valor de números almacenados en la memoria
-- dirección de lectura que es controlada por el control del modo de juego 

 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity memoria_color is
  port (
	  clk:       				in     std_logic;
    nRst:      				in     std_logic;
    reset:     				in     std_logic; 
    nueva_lectura:	in 	   std_logic;                               -- Orden de iniciar una nueva lectura(desde el principio)
    rd:        				in     std_logic;                               -- Habilitación de lectura 1ciclo
    wr:        				in     std_logic;                               -- Habilitacion de escritura (clr_ready) 1ciclo
    d_in:      				in     std_logic_vector(1 downto 0);
    longitud_programada_bin:  in std_logic_vector(13 downto 0);   -- Longitud programada 

    num_colores: buffer std_logic_vector(13 downto 0);  -------------------------------------
    d_out: buffer std_logic_vector(1 downto 0);
    we_mem: buffer std_logic;                                      -- Indica que la escritura se ha realizado
    full_programado:	buffer std_logic;                             -- Indica que se ha llenado la memoria con toda la longitud programada
    fin_lectura_secuencia: buffer std_logic);                      -- Se termina de leer todos los valores almacenados en la memoria
end entity ; 

architecture rtl of memoria_color is
signal primera_wr: std_logic;
signal we_mem_reg: std_logic;
signal num_colores_wr: std_logic_vector(13 downto 0);
signal add_wr: std_logic_vector(13 downto 0);
signal add_rd:  std_logic_vector(13 downto 0);
signal rd_mem: std_logic;
begin

	-- Orden de escritura
  	we_mem <=  '1' when wr = '1' and rd_mem ='0' and num_colores /= longitud_programada_bin 
  	               else '0';
 	 	 
 	-- Dirección de escritura
	 add_wr <= num_colores_wr(13 downto 0);	
	 
	 	 process(clk, nRst)
	 begin
	   if nRst = '0' then
	     primera_wr <= '0';
	     num_colores_wr <= (others => '0');
	   
	   elsif clk'event and clk = '1' then
	     if reset = '1' then
	       num_colores_wr <= (others => '0');
	     elsif we_mem_reg = '1'  then          
	       num_colores_wr <= num_colores_wr + 1;	        
	     end if;
	   end if; 
 end process;
 
 
	 process(clk, nRst)
	 begin
	   if nRst = '0' then
	     we_mem_reg <= '0';
	   elsif clk'event and clk = '1' then
      we_mem_reg <= we_mem;
    end if;
 end process;
 
 		
	-- Cuenta de datos almacenados
	 process(clk, nRst)
	 begin
	   if nRst = '0' then
	     num_colores <= (others => '0');
	   elsif clk'event and clk = '1' then
	     if reset = '1' then
	       num_colores <= (others => '0');
	     elsif we_mem = '1'   then          
	       num_colores <= num_colores + 1;      
	     end if;
	   end if; 
 end process;
 
	-- Orden de lectura
	rd_mem <= '1' when rd ='1' and we_mem ='0' and (fin_lectura_secuencia ='0') 
	              else '0';
	
	-- Generación de direccion de lectura
	  process(clk, nRst)
	  begin
	    if nRst = '0' then
	      add_rd <= (others => '0');
	      
	    elsif clk'event and clk = '1' then
	      if reset = '1' or nueva_lectura = '1' then
	        add_rd <= (others => '0');

	      elsif rd_mem = '1' then -- Orden de lectura             
	        add_rd <= add_rd + 1;
	      end if;                 -- la direccion de lectura coincide con el numero de color por el que voy leyendo
	    end if;
	  end process;
	  
	-- Flags
	  full_programado <= '1' when add_wr - add_rd = 1  and num_colores = longitud_programada_bin 
	                         else '0';
	                           
	                           
	  fin_lectura_secuencia <=	'1' when add_wr - add_rd = 1 
	                         else '0';


  -- Emplazamiento de RAM de doble puerto
  U_MEM: entity work.ram_2port(syn)
         port map(clock     => clk,
                  data      => d_in,
                  rdaddress => add_rd,
                  wraddress => add_wr,
		              wren      => we_mem,
                  q         => d_out);

end architecture ; 