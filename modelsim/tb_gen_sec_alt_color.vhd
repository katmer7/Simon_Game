library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_gen_sec_alt_color is   
end entity;

architecture tb of tb_gen_sec_alt_color is
  signal clk: std_logic;
  signal nRst: std_logic;
  signal pick_clr: std_logic;	
  signal clr_picked: std_logic_vector(1 downto 0);
  signal clr_ready: std_logic; 
  signal disponible_pick_clr: std_logic; 
  constant tclk: time := 20 ns;
  
  begin 
    
dut: entity work.gen_sec_alt_color(rtl)
port map(
    clk => clk,
    nRst => nRst,
    pick_clr => pick_clr,
    clr_picked => clr_picked,
    clr_ready => clr_ready
    );

process
begin
    clk <= '0';
    wait for tclk/2;
    clk <= '1';
    wait for tclk/2;
end process ;     

process
begin
  -- Inicizalización asíncrona
  nRst <= '0';
  pick_clr <= '0';
  wait for tclk*4;
  wait until clk'event and clk='1';
  nRst<='1';
  -- Fin inicialización asíncrona
  
  -- Inicialización síncrona
  wait until clk'event and clk= '1';
  wait until clk'event and clk= '1';
  wait until clk'event and clk= '1';
  wait until clk'event and clk= '1';  -- Generación de un color
  pick_clr <= '1';
  wait until clk'event and clk= '1';
  pick_clr <= '0';
  wait for tclk*10;
  wait until clk'event and clk = '1';

  wait for tclk*100;             
  wait until clk'event and clk = '1';
  
  wait until clk'event and clk= '1';  -- Generación de un color
  pick_clr <= '1';
  wait until clk'event and clk= '1';
  pick_clr <= '0';
  
  wait for tclk*50;                  
  wait until clk'event and clk = '1';
  
  wait until clk'event and clk= '1';  -- Generación de un color
  pick_clr <= '1';
  wait until clk'event and clk= '1';
  pick_clr <= '0';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  
  wait until clk'event and clk= '1';  -- Generación de un color
  pick_clr <= '1';
  wait until clk'event and clk= '1';
  pick_clr <= '0';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  
  wait until clk'event and clk= '1';  -- Generación de un color
  pick_clr <= '1';
  wait until clk'event and clk= '1';
  pick_clr <= '0';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  
  assert false
  report "done"
  severity failure;
  
end process ;
end architecture;