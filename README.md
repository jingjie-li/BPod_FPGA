# BPod_FPGA
This system is used for trainning the rodent to performance a behaviour decision-making task.

The firmwire contains a computer(Mac), a FPGA devices(Xilinx Basys 2) ans a B-Pod devices (LEDs, IR emitter, IR collector, Water Value and a Rig box).

Developed by Jingjie Li,
for more details, you can see ----
or contact me via jingjie.li@nyu.edu

Some source code and ideas come from Josh Sanders' BPOD project [LINK](https://github.com/sanworks/Bpod)

## Running Experiment Guidence
### 1) Connect the B-pod devices and the FPGA to the computer via serial port or USB.


### 2) Call start-bpod(portname) or simply call start-bpod to start connection
Usually, when using Mac OS computer, the port is /dev/tty.wchusbserial1420

### 3) Call run-exp(subjid) to start trainning
for example, you can call run-exp(1001) to start 1001's trainning.
For testing, you can call run-exp(Protocol Name,subjid,'test',1,'stage',1)

### 4) Using bottom on FPGA to end a session
In basys 2 FPGA, this bottom is N3 switch

### 5) Call close-bpod to close connection