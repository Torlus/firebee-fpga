%QUARTUS_ROOTDIR%\bin\quartus_cpf.exe -c firebee1.sof firebee1.rbf
objcopy -I binary -O srec --change-addresses 0xe0700000 firebee1.rbf fpga.s19
