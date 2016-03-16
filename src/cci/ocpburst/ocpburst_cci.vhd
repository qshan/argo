--------------------------------------------------------------------------------
-- License: MIT License - Copyright (c) 2016 Mathias Herlev
--------------------------------------------------------------------------------
-- Title   	: OCPBurst Clock Crossing Interface
-- Type		: Entity
-- Developers  : Mathias Herlev (Lead) - s103060@student.dtu.dk
--				 Christian Poulsen     - s103050@student.dtu.dk
-- Description : Top level for Clock Domain Crossing interface
-- TODO	:
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY work;
USE work.OCPInterface.all;
USE work.OCPBurstCCI_types.all;
USE work.ocp.all;
ENTITY OCPBurstCCI IS
	PORT(   input   : IN	OCPBurstCCIIn_r;
			output  : OUT   OCPBurstCCIOut_r
	);
END ENTITY OCPBurstCCI;

ARCHITECTURE rtl OF OCPBurstCCI IS

	COMPONENT OCPBurstCCI_A IS
	    PORT(   clk         : IN    std_logic;
	            rst         : IN    std_logic;
	            syncIn      : IN    ocp_burst_m;
	            syncOut     : OUT   ocp_burst_s;
	            asyncOut    : OUT   AsyncBurst_A_r;
	            asyncIn     : IN    AsyncBurst_B_r
	    );
	END COMPONENT OCPBurstCCI_A;

	COMPONENT OCPBurstCCI_B IS
	    PORT(   clk         : IN    std_logic;
	            rst         : IN    std_logic;
	   		 	syncIn      : IN    ocp_burst_s;
	            syncOut     : OUT   ocp_burst_m;
	            asyncOut    : OUT   AsyncBurst_B_r;
	            asyncIn     : IN    AsyncBurst_A_r
	     );
	END COMPONENT OCPBurstCCI_B;

	SIGNAL async_A : AsyncBurst_A_r;
	SIGNAL async_B : AsyncBurst_B_r;

BEGIN

	CCI_A  : OCPBurstCCI_A
	PORT MAP(input.clk_A,
	input.rst_A,
	input.OCPB_master,
	output.OCPB_A,
	async_A,
	async_B);

	CCI_B   : OCPBurstCCI_B
	PORT MAP(input.clk_B,
	input.rst_B,
	input.OCPB_slave,
	output.OCPB_B,
	async_B,
	async_A);

END ARCHITECTURE rtl;
