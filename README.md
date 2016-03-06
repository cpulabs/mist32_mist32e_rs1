MIST32 Type-E - Reference System - 1
==================

Open Design Computer Project - [http://open-arch.org/](http://open-arch.org/)

System Description
---
This system is open source computer reference system for MIST32 Type-E processor. 


Devices
---
  DEVICE_KEYBOARD							PS/2 Keyboard and mouse controller.

  DEVICE_DISPLAY							640x480 VGA display controller. 

  DEVICE_SCI								RS232C(only baudrate 115.2kbps) serial interface controller.  

  DEVICE_SD									MMC controller. 



Support FPGA Board
---
 Terasic DE2-115				Altera's FPGA

 Terasic DE0-CV					Altera's FPGA


Processor
---
Currently support MIST32E10FA processor. If you want synthesis this project, you must download that processor repository.

[MIST32E10FA](https://github.com/cpulabs/mist32e10fa)



License
---
BSD 2-Clause License

See ./LICENSE
  
  
Tool
---
We have validated the correctness of this design in the following tools.

***Simulator***

Modelsim
 
 
***Synthesis***

Quartus II(Altera) / Quartus Prime(Altera)

