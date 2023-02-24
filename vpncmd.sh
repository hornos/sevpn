#!/usr/bin/env bash

DATA_DIR=${PWD}/data

_HELP='
Purpose:
  SoftEther VPN Command Line Management Utility Developer Edition

Description:
  The 'vpncmd' program is a utility that allows you to manage SoftEther VPN software by using command lines. By using vpncmd, you can connect to a VPN Client, a VPN Server or VPN Bridge 
  that is running on a local or remote computer and manage these services. Moreover, by using VPN Tools mode, you can call the Network Traffic Speed Test Tool and the certificate creation 
  function. These can be used even when not connected to the VPN Server or VPN Client. 
  When using vpncmd, if the file name is specified by using the /IN and /OUT parameter, the command can be executed in a batch according to a file in which the executable commands are 
  enumerated and the execution results can be written to a file. Normally a command prompt will appear after vpncmd is launched but when an input file is specified by the /IN parameter, 
  the program will automatically terminate after the execution of all lines in the input file is complete. Also, when a command to execute is specified by the /CMD parameter, the program 
  will automatically terminate after the execution of that command is complete. You cannot specify the /IN parameter and the /CMD parameter at the same time. The termination code of the 
  vpncmd program will be the error code of the last executed command (0 in the case of successful execution). 
  Under a Windows environment, when vpncmd is launched once or more by a user with administrator privileges, it is possible to simply input 'vpncmd' to a Windows command prompt or [Run...]
  window to launch vpncmd. To achieve the same result under a UNIX system, you can manually set, as appropriate, the PATH environment variable.

Usage:
  vpncmd [host:port] [/CLIENT|/SERVER|/TOOLS] [/HUB:hub] [/ADMINHUB:adminhub] [/PASSWORD:password] [/IN:infile] [/OUT:outfile] [/CMD commands...]

Parameters:
  host:port    - By specifying parameters in the format "host name:port number", a connection will automatically be made to that host. If this is not specified, a prompt will appear to 
                 input the connection destination. When connecting to a VPN Client, you cannot specify a port number.
  /CLIENT      - This will connect to VPN Client to do management. You cannot specify it together with /SERVER.
  /SERVER      - This will connect to VPN Server or VPN Bridge to do management. You cannot specify it together with /CLIENT.
  /TOOLS       - This will enables use of VPN Tools commands. VPN Tools include the simple certificate creation tool (MakeCert command) and the Network Traffic Speed Test Tool (SpeedTest 
                 command).
  /HUB         - When connecting to the VPN Server by "Virtual Hub Admin Mode", this specifies the Virtual Hub name 'hub'. If you specify the host name but not the /HUB parameter, 
                 connection will be by "Server Admin Mode".
  /ADMINHUB    - This will specify the name of the Virtual Hub 'adminhub' that is automatically selected after connecting to the VPN Server. If the /HUB parameter was specified, the 
                 Virtual Hub will be selected automatically and this specification will not be necessary.
  /PASSWORD    - If the administrator password is required when connecting, specify the password 'password'. When the password is not specified, a prompt to input the password will be 
                 displayed.
  /IN          - This will specify the text file 'infile' that contains the list of commands that are automatically executed after the connection is completed. If the /IN parameter is 
                 specified, the vpncmd program will terminate automatically after the execution of all commands in the file are finished. If the file contains multiple-byte characters, the
                 encoding must be Unicode (UTF-8). This cannot be specified together with /CMD (if /CMD is specified, /IN will be ignored).
  /OUT         - You can specify the text file 'outfile' to write all strings such as onscreen prompts, message, error and execution results. Note that if the specified file already 
                 exists, the contents of the existing file will be overwritten. Output strings will be recorded using Unicode (UTF-8) encoding.
  /CMD         - If the optional command 'commands...' is included after /CMD, that command will be executed after the connection is complete and the vpncmd program will terminate after 
                 that. This cannot be specified together with /IN (if specified together with /IN, /IN will be ignored). Specify the /CMD parameter after all other vpncmd parameters.
  /CSV         - You can specify this option to enable CSV outputs. Results of each command will be printed in the CSV format. It is useful for processing the results by other programs.
  /PROGRAMMING - There is no description for this parameter.
'


NAME=${1:-sevpn}
shift
MODE=${1:-/SERVER}
shift

opts=""
if [ -r ${DATA_DIR}/admin.txt ] ; then
  pass=$(cat ${DATA_DIR}/admin.txt)
  opts="/PASSWORD:$pass"
fi

docker exec -it $NAME /usr/local/libexec/softether/vpncmd/vpncmd localhost $MODE $opts $*
