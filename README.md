# MajorProject
Verilog-based APB to AXI Bridge design that facilitates communication between APB peripherals and AXI systems. Includes dynamic signal routing based on protocol selection input..

This project implements a Dual Bus Interconnect system in Verilog that supports dynamic communication between a master and two types of slave protocols: AXI (Advanced eXtensible Interface) and APB (Advanced Peripheral Bus). The design enables seamless data transfer by utilizing a protocol_select signal, which routes common master inputs (like addresses and data) to either the AXI or APB-specific paths based on the selected protocol.

The interconnect allows the master to send:

Read and write addresses

Write data

Read data reception from slaves

The AXI interface includes full support for valid/ready handshakes and response signals, while the APB side handles basic write and enable signals. The bridge intelligently disables unused protocol signals to avoid conflicts.

This design is suitable for SoC integration, enabling shared master-slave communication with minimal control logic. It can be extended or embedded in more complex systems that require flexible peripheral access using multiple protocols.
