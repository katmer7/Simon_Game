
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_memoria_color is
end entity;

architecture tb of tb_memoria_color is
  signal clk:                         std_logic;
  signal nRst:                        std_logic;
  signal reset:                       std_logic;
  signal rd:                          std_logic;
  signal wr:                          std_logic;
  signal nueva_lectura:               std_logic;
  signal d_in:                        std_logic_vector(1 downto 0);  
  signal longitud_programada:      std_logic_vector(13 downto 0); 
  signal d_out:                       std_logic_vector(1 downto 0);  
  signal num_colores:                 std_logic_vector(13 downto 0); 
  signal full_programado:             std_logic;                                                 
  signal fin_lectura_secuencia:       std_logic;

  constant tclk:   time := 20 ns; 

begin
  process
  begin
    clk <= '0';
    wait for tclk/2;
    clk <= '1';
    wait for tclk/2;
  end process;


  dut: entity work.memoria_color(rtl)
  port map (
    ------------entradas-----------------
    clk                   => clk,
    nRst                  => nRst,
    reset                 => reset,
    rd                    => rd,
    wr                    => wr,
    nueva_lectura         => nueva_lectura,
    d_in                  => d_in,
    longitud_programada=> longitud_programada,
    -------------------------------------
    d_out                 => d_out,
    num_colores           => num_colores, 
    full_programado       => full_programado,                                           
    fin_lectura_secuencia =>fin_lectura_secuencia
    );

  process
  begin
    -- Inicialización síncrona
    nRst <= '0';
    d_in <= "01";
    reset <= '0';
    nueva_lectura <= '0';
    wr <= '0'; 
    rd <= '0';   
    longitud_programada<= "00000000001010" ;  
    wait for tclk*4;
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    -- Fin iniciacilización asíncrona
    
    -- Inicialización síncrona                                     
 
    -- Escribo 5 colores
    wait until clk'event and clk = '1';
    wr <= '1';           --1
    d_in <= "01";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --2
    d_in <= "10";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --3
    d_in <= "11";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --4
    d_in <= "10";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --5
    d_in <= "11";
    wait until clk'event and clk = '1';
    wr <= '0';
    
    -- Leo 5 colores con 6 lecturas: COMBROBAR ERROR DE LECUTRA CUANDO ESTA FINALIZADA LA LECTURA
    wait until clk'event and clk = '1';     --LEE
    rd <= '1';
    wait until clk'event and clk = '1';
    rd <= '0';           --FIN LEE
    wait until clk'event and clk = '1';     --LEE
    rd <= '1';
    wait until clk'event and clk = '1';
    rd <= '0';           --FIN LEE
    wait until clk'event and clk = '1';     --LEE
    rd <= '1';
    wait until clk'event and clk = '1';
    rd <= '0';           --FIN LEE
    wait until clk'event and clk = '1';     --LEE
    rd <= '1';
    wait until clk'event and clk = '1';
    rd <= '0';           --FIN LEE
    wait until clk'event and clk = '1';     --LEE
    rd <= '1';
    wait until clk'event and clk = '1';
    rd <= '0';           --FIN LEE
    wait until clk'event and clk = '1';     --LEE
    rd <= '1';
    wait until clk'event and clk = '1';
    rd <= '0';           --FIN LEE

    wait until clk'event and clk = '1';     --Preparo una Nueva Lectura Futura
    nueva_lectura                 <= '1';
    wait until clk'event and clk = '1';
    nueva_lectura                 <= '0';

    -- Escribo 6 colores: COMPRUEBO ERROR DE LLENADO POR EXCESO
    wait until clk'event and clk = '1';
    wr <= '1';           --1
    d_in <= "01";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --2
    d_in <= "10";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --3
    d_in <= "11";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --4
    d_in <= "10";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --5
    d_in <= "11";
    wait until clk'event and clk = '1';
    wr <= '0';
    wait until clk'event and clk = '1';
    wr <= '1';           --6
    d_in <= "10";
    wait until clk'event and clk = '1';
    wr <= '0';
    
    lectura : for i in 1 to 12 loop
        wait until clk'event and clk = '1';     --LEE
        wait until clk'event and clk = '1';     --LEE
        rd                    <= '1';
        wait until clk'event and clk = '1';
        rd                    <= '0';           --FIN LEE
    end loop ; 

    wait for 5*tclk;
    wait until clk'event and clk='1';
     
    assert false
    report "fone"
    severity failure;

  end process;
end tb;
