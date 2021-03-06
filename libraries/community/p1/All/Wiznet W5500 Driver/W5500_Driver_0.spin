''  WIZnet W5500 Driver Ver. 1.0
''
''  Original source: W5200_Driver.spin 
''  W5500 changes/adaptations: Benjamin Yaroch   
''
''Description:
''
''      This is a SPI Assembly language driver for the W5500.
''      This driver requires the SCLK, /SCS, MOSI, and MISO signals.
''      The /INT signal is not used in this driver and /RESET is optional.
''
''      The functions are mostly implemented in ASM for fast access. There is high level access
''      to the SPI, but going through SPIN to do many of the functions adds considerable round trip time.
''      Routines could be completely coded in ASM for faster operation.
''
''      The program that calls this driver will need to set up variables for the following:
''              byte  myMAC[6]          '6 element array contianing MAC or source hardware address ex. "02:00:00:01:23:45"
''              byte  myGateway[4]      '4 element array containing gateway address ex. "192.168.0.1"
''              byte  mySubnet[4]       '4 element array contianing subnet mask ex. "255.255.255.0"
''              byte  myIP[4]           '4 element array containing IP address ex. "192.168.0.13"
''
''      WIZ550io module info: http://wizwiki.net/wiki/doku.php?id=products:wiz550io:allpages
''
''SPI Data Structure:
''      Address (16 bits), Control (8 bits), Data (8 bits) == 32 bits
''      This driver uses Variable Length Data Mode (VDM) which is the preference per the datasheet.
''
''Revision Notes:
''      1.0 - Initial Release
''      1.0.1 - Updated Reset time to >500us per datasheet
''      1.0.2 - rxUDP payload pckstart was incorrect, added offset for UDP header 
''
CON
  
  ' W5500 Common Offset Adress Definitions
  
  _MR           = $0000         'Mode Register
  _GAR0         = $0001         'Gateway Address Register
  _GAR1         = $0002
  _GAR2         = $0003
  _GAR3         = $0004
  _SUBR0        = $0005         'Subnet Mask Address Register
  _SUBR1        = $0006
  _SUBR2        = $0007
  _SUBR3        = $0008
  _SHAR0        = $0009         'Source Hardware Address Register (MAC)
  _SHAR1        = $000A
  _SHAR2        = $000B
  _SHAR3        = $000C
  _SHAR4        = $000D
  _SHAR5        = $000E
  _SIPR0        = $000F         'Source IP Address Register
  _SIPR1        = $0010
  _SIPR2        = $0011
  _SIPR3        = $0012
  _INTLEVEL0    = $0013
  _INTLEVEL1    = $0014
  _IR           = $0015         'Interrupt Register
  _IMR          = $0016         'Socket Interrupt Mask Register
  _SIR          = $0017         'Retry Time Register
  _SIMR         = $0018                                
  _RTR0         = $0019         'Retry Time Registers 
  _RTR1         = $001A
  _RCR          = $001B         'Retry Count Register
  _PTIMER       = $001C         'PPP LCP Request Timer
  _PMAGIC       = $001D         'PPP LCP Magic Number
  _PHAR0        = $001E         'PPP Destination MAC Address
  _PHAR1        = $001F
  _PHAR2        = $0020
  _PHAR3        = $0021
  _PHAR4        = $0022
  _PHAR5        = $0023
  _PSID0        = $0024
  _PSID1        = $0025
  _PRMU0        = $0026
  _PRMU1        = $0027
  _UIPR0        = $0028         'Unreachable IP Address
  _UIPR1        = $0029
  _UIPR2        = $002A
  _UIPR3        = $002B
  _UPORT0       = $002C         'Unreachable Port
  _UPORT1       = $002D
  _PHYCFGR      = $002E
  'Reserved space  $002F - $0038
  _VERSIONIR    = $0039         'Chip version
  
  ' W5500 Socket Offset Address Definitions
  
  _Sn_MR        = $0000         'Socket Mode Register
  _Sn_CR        = $0001         'Socket Command Register
  _Sn_IR        = $0002         'Socket Interrupt Register
  _Sn_SR        = $0003         'Socket Status Register
  _Sn_PORT0     = $0004         'Socket Source Port Register
  _Sn_PORT1     = $0005
  _Sn_DHAR0     = $0006         'Socket Destination Hardware Address Register
  _Sn_DHAR1     = $0007
  _Sn_DHAR2     = $0008
  _Sn_DHAR3     = $0009
  _Sn_DHAR4     = $000A
  _Sn_DHAR5     = $000B
  _Sn_DIPR0     = $000C         'Socket Destination IP Address Register
  _Sn_DIPR1     = $000D
  _Sn_DIPR2     = $000E
  _Sn_DIPR3     = $000F
  _Sn_DPORT0    = $0010         'Socket Destination Port Register
  _Sn_DPORT1    = $0011
  _Sn_MSSR0     = $0012         'Socket Maximum Segment Size Register
  _Sn_MSSR1     = $0013
  'Reserved space $0014         'Socket Protocol in IP Raw Mode Register
  _Sn_TOS       = $0015         'Socket IP TOS Register
  _Sn_TTL       = $0016         'Socket IP TTL Register
  'Reserved space $0017 - $001D
  _Sn_RXBUF_SIZE = $001E
  _Sn_TXBUT_SIZE = $001F  
  Sn_TX_FSR0    = $0020         'Socket TX Free Size Register
  _Sn_TX_FSR1   = $0021
  _Sn_TX_RD0    = $0022         'Socket TX Read Pointer Register
  _Sn_TX_RD1    = $0023
  _Sn_TX_WR0    = $0024         'Socket TX Write Pointer Register
  _Sn_TX_WR1    = $0025
  _Sn_RX_RSR0   = $0026         'Socket RX Received Size Register
  _Sn_RX_RSR1   = $0027
  _Sn_RX_RD0    = $0028         'Socket RX Read Pointer Register
  _Sn_RX_RD1    = $0029
  _Sn_RX_WR0    = $002A
  _Sn_RX_WR1    = $002B
  _Sn_IMR       = $002C
  _Sn_FRAG0     = $002D
  _Sn_FRAG1     = $002E
  _Sn_KPALVTR   = $002F
  'Reserved space $0030 - $FFFF
  
  ' W5500 Register Masks & Values Defintions  

  'Used in the mode register (MR)
  _RSTMODE      = %1000_0000    'If 1, internal registers are initialized
  _WOLMODE      = %0010_0000    'WOL, 1 is enabled
  _PBMODE       = %0001_0000    'Ping block mode, 1 is enabled
  _PPPOEMODE    = %0000_1000    'PPPoE mode, 1 is enabled
  _FARPMODE     = %0000_0010    'Force ARP. 1 is enabled

  'Used in the Interrupt Register (IR) & Interrupt Mask Register (IMR) & SOCKET Interrupt Register (IR2)
  _CONFLICTM    = %1000_0000    'IP Conflict
  _UNREACHM     = %0100_0000    'Destination unreachable
  _PPPoEM       = %0010_0000    'PPPoE Connection Close
  _MPM          = %0001_0000    'Magic Packet

  _S7_INTM      = %1000_0000    'Socket 7 interrupt bit mask (1 = interrupt)  
  _S6_INTM      = %0100_0000    'Socket 6 interrupt bit mask (1 = interrupt)  
  _S5_INTM      = %0010_0000    'Socket 5 interrupt bit mask (1 = interrupt)  
  _S4_INTM      = %0001_0000    'Socket 4 interrupt bit mask (1 = interrupt)  
  _S3_INTM      = %0000_1000    'Socket 3 interrupt bit mask (1 = interrupt)
  _S2_INTM      = %0000_0100    'Socket 2 interrupt bit mask (1 = interrupt)
  _S1_INTM      = %0000_0010    'Socket 1 interrupt bit mask (1 = interrupt)
  _S0_INTM      = %0000_0001    'Socket 0 interrupt bit mask (1 = interrupt)

  _S7_IMRM      = %1000_0000    'Socket n(Sn_INT) Interrupt Mask
  _S6_IMRM      = %0100_0000    '1: Enable Socket n Interrupt
  _S5_IMRM      = %0010_0000
  _S4_IMRM      = %0001_0000
  _S3_IMRM      = %0000_1000
  _S2_IMRM      = %0000_0100
  _S1_IMRM      = %0000_0010
  _S0_IMRM      = %0000_0001
  
  'Used in the Phy configuration status Register (PHYCFGR)
  _RESET        = %1000_0000    'Reset [R/W]
  _OPMD         = %0100_0000    'Configure PHY Operation Mode
  _OPMDC        = %0011_1000    'Operation Mode Configuration Bit[R/W]
  _DPX          = %0000_0100    'Duplex Status [Read Only]
  _SPD          = %0000_0010    'Speed Status [Read Only]
  _LINK         = %0000_0001    'Link Status [Read Only] (0=down, 1=up)

  'Used in the socket n mode register (Sn_MR)
  _MULTIM       = %1000_0000    'Enable/disable multicasting in UDP
  _BCASTBM      = %0100_0000
  _ND_MCM       = %0010_0000    'Enable/disable No Delayed ACK option
  _UCASTBM      = %0001_0000
  _PROTOCOLM    = %0000_1111    'Registers for setting protocol

  'Used in the socket n command register (Sn_CR)
  _OPEN         = $01           'Initialize a socket
  _LISTEN       = $02           'In TCP mode, waits for request from client
  _CONNECT      = $04           'In TCP mode, sends connect request to server
  _DISCON       = $08           'In TCP mode, request to disconnect
  _CLOSE        = $10           'Closes socket
  _SEND         = $20           'Transmits data
  _SEND_MAC     = $21           'In UDP mode, like send, but uses MAC
  _SEND_KEEP    = $22           'In TCP mode, check connection status by sending 1 byte
  _RECV         = $40           'Receiving is processed

  _CLOSEDPROTO  = %0000         'Closed  
  _TCPPROTO     = %0001         'TCP
  _UDPPROTO     = %0010         'UDP
  _IPRAWPROTO   = %0011         'IPRAW
  _MACRAW       = %0100         'MACRAW (used in socket 0)
  _PPPOEPROTO   = %0101         'PPPoE (used in socket 0)

   'Used in socket n interrupt register (Sn_IR)
  _SEND_OKM     = %0001_0000    'Set to 1 if send operation is completed
  _TIMEOUTM     = %0000_1000    'Set to 1 if timeout occured during transmission
  _RECVM        = %0000_0100    'Set to 1 if data is received
  _DISCONM      = %0000_0010    'Set to 1 if connection termination is requested
  _CONM         = %0000_0001    'Set to 1 if connection is established

  'Used in socket n status register (Sn_SR)
  _SOCK_CLOSED    = $00
  _SOCK_INIT      = $13
  _SOCK_LISTEN    = $14
  _SOCK_ESTAB     = $17
  _SOCK_CLOSE_WT  = $1C
  _SOCK_UDP       = $22
  _SOCK_MACRAW    = $42
  _SOCK_SYNSENT   = $15
  _SOCK_SYNRECV   = $16
  _SOCK_CLOSING   = $1A
  _SOCK_TIME_WAIT = $1B
  _SOCK_LAST_ACK  = $1D

  'Used in socket buffer size register (Sn_RXBUF_SIZE/Sn_TXBUF_SIZE)
  _1KB          = $01           '1KB memory size
  _2KB          = $02           '2KB memory size
  _4KB          = $04           '4KB memory size
  _8KB          = $08           '8KB memory size
  _16KB         = $0F           '16KB memory size

  'RX & TX definitions
  _Common_Reg   = %00000        'Common Register for W5500 
  _Register_0   = %00001        'Socket 0 Register Buffer 
  _TX_Buffer_0  = %00010        'Socket 0 TX Buffer
  _RX_Buffer_0  = %00011        'Socket 0 RX Buffer
  _TX_mask      = $7FF          'Mask for default 2K buffer for each socket (2047)
  _RX_mask      = $7FF          'Mask for default 2K buffer for each socket (2047)

  _UDP_header   = 8             '8 bytes of data in the UDP header from the W5500

  ' Command Definitions for ASM W5500 SPI Routine
  _reserved     = 0             'This is the default state - means ASM is waiting for command
  _readSPI      = 1 << 16       'High level access to reading from the W5500 via SPI
  _writeSPI     = 2 << 16       'High level access to writing to the W5500 via SPI
  _SetMAC       = 3 << 16       'Set the MAC ID in the W5500
  _SetGateway   = 4 << 16       'Set the gateway address in the W5500
  _SetSubnet    = 5 << 16       'Set the subnet address in the W5500
  _SetIP        = 6 << 16       'Set the IP address in the W5500
  _ReadMAC      = 7 << 16       'Recall the MAC ID in the W5500
  _ReadGateway  = 8 << 16       'Recall the gateway address in the W5500
  _ReadSubnet   = 9 << 16       'Recall the subnet address in the W5500
  _ReadIP       = 10 << 16      'Recall the IP address in the W5500
  _PingBlock    = 11 << 16      'Enable/disable ping response
  _rstHW        = 12 << 16      'Reset the W5500 IC via hardware
  _rstSW        = 13 << 16      'Reset the W5500 IC via hardware
  _Sopen        = 14 << 16      'Open a socket
  _Sdiscon      = 15 << 16      'Disconnect a socket
  _Sclose       = 16 << 16      'Close a socket  
  _lastCmd      = 17 << 16      'Place holder for last command

  ' Driver Flag Definitions
  _Flag_ASMstarted = |< 1       'Flag to indicated asm routine is started succesfully

VAR

  long  cog                     'cog flag/id               

DAT              

        'Command setup
        command         long    0               'stores command and arguments for the ASM driver
        lock            byte    255             'Mutex semaphore

PUB start(_scs, _sclk, _mosi, _miso, _rst) : okay

''  Initializes the I/O and registers based on parameters.
''  After initilization another cog is started which is the
''  cog responsible for the SPI communication to the W5500.
''
''  The W5500 SPI cog will allow only one instance of itself
''  to run and the it consumes only 1 cog.
''
''  params:  the four pins required for SPI plus reset
''  return:  value of cog if started or zero if not started

  'Keeps from two cogs running
  stop

  'Initialize the I/O for writing the mask data to the memory area that will be copied into a COG.
  'This routine assumes SPI connection, SPI_EN should be tied high on W5500 and isn't controlled by this driver.
  SCSmask   := |< _scs
  SCLKmask  := |< _sclk
  MOSImask  := |< _mosi
  MISOmask  := |< _miso
  RESETmask := |< _rst

  'Counter values setup before calling the ASM cog that will use them.
  'CounterX     mode  PLL         BPIN        APIN
  ctramode :=  %00100_000 << 23 +  0   << 9 +  _sclk
  ctrbmode :=  %00100_000 << 23 +  0   << 9 +  _mosi

  'Clear the command buffer - be sure no commands were set before initializing
  command := 0

  'Start a cog to execute the ASM routine
  okay := cog := cognew(@Entry, @command) + 1

PUB stop    

'' Stop the W5500 SPI Driver cog if one is running.
'' Only a single cog can be running at a time.

  if cog                                                'Is cog non-zero?
    cogstop(cog~ - 1)                                   'Yes, stop the cog and then make value zero
    longfill(@SCSmask, 0, 5)                            'Clear all masks

PUB InitAddresses( _block, _macPTR, _gatewayPTR, _subnetPTR, _ipPTR)

'' Initialize all four addresses.
''
''  params:  _block if true will wait for ASM routine to send before returning from this function
''           _mac, _gateway, _subnet, _ip are pointers to appropriate size byte arrays

  'Checks on if the ASM cog is running is done in each of the following routines
  WriteMACaddress(_block, _macPTR)
  WriteGatewayAddress(_block, _gatewayPTR)
  WriteSubnetMask(_block, _subnetPTR)
  WriteIPaddress(_block, _ipPTR)

PUB WriteMACaddress( _block, _macPTR)

'' Write the specified MAC address to the W5500.
''
''  params:  _block if true will wait for ASM routine to send before continuing
''           The pointer should point to a 6 byte array.
''           byte[0] = highest octet and byte[5] = lowest octet
''           example 02:00:00:01:23:45 where byte[0] = $02 and byte[5] = $45
''
   
  'Send the command
  command := _SetMAC + _macPTR
   
  'wait for the command to complete or just move on
  if _block
    repeat while command

PUB WriteGatewayAddress(_block, _gatewayPTR)

'' Write the specified gateway address to the W5500.
''
''  params:  _block if true will wait for ASM routine to send before continuing
''           The pointer should point to a 4 byte array.
''           byte[0] = highest octet and byte[3] = lowest octet
''           example 192.168.0.1 where byte[0] = 192 and byte[3] = 1
''
''  return:  none

  'Send the command
  command := _SetGateway + _gatewayPTR
   
  'wait for the command to complete or just move on
  if _block
    repeat while command
   

PUB WriteSubnetMask(_block, _subnetPTR)

'' Write the specified Subnet mask to the W5500.
''
''  params:  _block if true will wait for ASM routine to send before continuing
''           The pointer should point to a 4 byte array.
''           byte[0] = highest octet and byte[3] = lowest octet
''           example 255.255.255.0 where byte[0] = 255 and byte[3] = 0
''
   
  'Send the command
  command := _SetSubnet + _subnetPTR
   
  'wait for the command to complete or just move on
  if _block
    repeat while command
   

PUB WriteIPaddress(_block, _ipPTR)

'' Write the specified IP address to the W5500.
''
''  params:  _block if true will wait for ASM routine to send before continuing
''           The pointer should point to a 4 byte array.
''           byte[0] = highest octet and byte[3] = lowest octet
''           example 192.168.0.13 where byte[0] = 192 and byte[3] = 13

  'Send the command
  command := _SetIP + _ipPTR
   
  'wait for the command to complete or just move on
  if _block
    repeat while command

PUB ReadMACaddress(_macPTR)

'' Read the MAC address from the W5500.
''
''  return:  The pointer should point to a 6 byte array.
''           byte[0] = highest octet and byte[5] = lowest octet
''           example 02:00:00:01:23:45 where byte[0] = $02 and byte[5] = $45

  'Send the command
  command := _ReadMAC + _macPTR
   
  'wait for the command to complete
  repeat while command
   
PUB ReadGatewayAddress(_gatewayPTR)

'' Read the gateway address from the W5500.
''
''  return:  The pointer should point to a 4 byte array.
''           byte[0] = highest octet and byte[3] = lowest octet
''           example 192.168.0.1 where byte[0] = 192 and byte[3] = 1

  'Send the command
  command := _ReadGateway + _gatewayPTR
   
  'wait for the command to complete
  repeat while command
   
PUB ReadSubnetMask(_subnetPTR)

'' Read the specified Subnet mask from the W5500
''
''  return:  The pointer should point to a 4 byte array.
''           byte[0] = highest octet and byte[3] = lowest octet
''           example 255.255.255.0 where byte[0] = 255 and byte[3] = 0

  'Send the command
  command := _ReadSubnet + _subnetPTR
   
  'wait for the command to complete
  repeat while command

PUB ReadIPaddress(_ipPTR)

'' Read the specified IP address from the W5500
''
''  return:  The pointer should point to a 4 byte array.
''           byte[0] = highest octet and byte[3] = lowest octet
''           example 192.168.0.13 where byte[0] = 192 and byte[3] = 13
 
  'Send the command
  command := _ReadIP + _ipPTR
   
  'wait for the command to complete
  repeat while command

PUB PingBlock(_block, _bool)

'' Enable/disable if the W5500 responds to pings.
''
''  params:  _block if true will wait for ASM routine to send before continuing
''           _bool is a bool, true is W5500 will NOT respond, false W5500 will respond
   
  'Send the command
  command := _pingBlock + @_bool
   
  'wait for the command to complete or just move on
  if _block
    repeat while command

PUB ResetHardware(_block)

'' Reset the W5500 via hardware
''
''  params:  _block if true will wait for ASM routine to send before continuing

  'Send the command
  command := _rstHW
   
  'wait for the command to complete or just move on
  if _block
    repeat while command

PUB ResetSoftware(_block)

'' Reset the W5500 via software
''
''  params:  _block if true will wait for ASM routine to send before continuing

  'Send the command
  command := _rstSW
   
  'wait for the command to complete or just move on
  if _block
    repeat while command

PUB SocketOpen(_socket, _mode, _srcPort, _destPort, _destIP)

'' Open the specified socket in the specified mode on the W5500.
'' The mode can be either TCP or UDP.
''
''  params:  _socket is a value of 0 to 7 - eight sockets on the W5500
''           _mode is one of the constants specifing closed, TCP, UDP, IPRaw etc
''           _srcPort, _destPort are the ports to use in the connection pass by value
''           _destIP is a pointer to the destination IP byte array (use the @ on the variable)

  'Send the command
  command := _Sopen + @_socket
   
  'wait for the command to complete
  repeat while command

PUB SocketClose(_socket)

'' Closes the specified socket on the W5500.
''
''  params:  _socket is a value of 0 to 7 - eight sockets on the W5500

  'Send the command
  command := _Sclose + @_socket
   
  'wait for the command to complete
  repeat while command
   
PUB SocketTCPlisten(_socket) | temp0, blockoffset

'' Check if a socket is TCP and open and if so then set the socket to listen on the W5500
''
''  params: _socket is a value of 0 to 7 - eight sockets on the W5500

  blockoffset := (4*_socket)

  'Check if the socket is TCP and open by looking at socket status register
  readSPI((blockoffset + _Register_0), _Sn_SR, @temp0, 1)
   
  if temp0.byte[0] <> _SOCK_INIT
    return
   
  'Tell the W5500 to listen on the particular socket
  temp0 := _LISTEN
  writeSPI(true, (blockoffset + _Register_0), _Sn_CR, @temp0, 1)

PUB SocketTCPconnect(_socket) | temp0, blockoffset

'' Check if the socket is TCP and open by looking at socket status register
''
''  params: _socket is a value of 0 to 7 - 8 sockets on the W5500

  blockoffset := (4*_socket)

  readSPI((blockoffset + _Register_0), _Sn_SR, @temp0, 1)
   
  if temp0.byte[0] <> _SOCK_INIT
    return
   
  'Tell the W5500 to connect to a particular socket
  temp0 := _CONNECT
  writeSPI(true, (blockoffset + _Register_0), _Sn_CR, @temp0, 1)
     
PUB SocketTCPestablished(_socket) | temp0, blockoffset

'' Check if a socket has established a TCP connection
''
''  params: _socket is a value of 0 to 7 - eight sockets on the W5500
''  return: True if established, false if not

  blockoffset := (4*_socket)
  
  readSPI((blockoffset + _Register_0), _Sn_SR, @temp0, 1)
   
  if temp0.byte[0] <> _SOCK_ESTAB
    return false
  else
    return true

  return false 'end of SocketTCPestablished

PUB SocketTCPdisconnect(_socket)

'' Disconnects the specified socket on the W5500.
''
''  params:  _socket is a value of 0 to 7 - 8 sockets on the W5500

  'Send the command
  command := _Sdiscon + @_socket
   
  'wait for the command to complete
  repeat while command
   
PUB rxTCP(_socket, _dataPtr) | temp0, RSR, pcktptr, rolloverpoint, pcktoffset, blockoffset, pcktstart

'' Receive TCP data on the specified socket.  Most of the heavy lifting of receiving data is handled by the ASM routine,
'' but for effeciency in coding the SPIN routine walks through the process of receiving data such as verifying and manipulating
'' the various register.  NOTE: This routine could be completely coded in ASM for faster operation.
''
'' The receive routine streams over the TCP data.  The data streamed over is based on the W5500 receive register size.
''
''  params:  _socket is a value of 0 to 7 - 8 sockets on the W5500
''           _dataPtr is a pointer to the byte array to be written to in HUBRAM (use the @ in front of the byte variable)
''  return:  Non-zero value indicating the number of bytes read from W5500 or zero if no data is read
''

  blockoffset := (4*_socket)
    
  'Check if there is data to be received from the W5500
  readSPI((blockoffset + _Register_0), _Sn_RX_RSR0, @temp0, 2)                      ' Get recieved data buffer length
  RSR.byte[1] := temp0.byte[0]                                                  ' Combine Data length bytes into a word
  RSR.byte[0] := temp0.byte[1]

  'Bring over the data if there is data
  if RSR.word[0] > 0
   
    'Determine the offset and location to read data from in the W5500
    readSPI((blockoffset + _Register_0), _Sn_RX_RD0, @temp0, 2)                    ' Get Socket RX Read Pointer
    pcktptr.byte[1] := temp0.byte[0]                                           ' Combine Read pointer bytes into a word  
    pcktptr.byte[0] := temp0.byte[1]
    pcktoffset := pcktptr & _RX_mask
    pcktstart := pcktptr
   
    'Read the data of the packet
    if (pcktoffset + RSR.word[0]) > constant(_RX_mask + 1)                      'Buffer rolls over so process the data in two parts       
      rolloverpoint := constant(_RX_mask + 1) - pcktoffset                      'Calculate number of bytes until end of buffer
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, _dataPtr, rolloverpoint)       'Collect data to end of buffer
      pcktstart := 0
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, (_dataPtr + rolloverpoint), (RSR.word[0] - rolloverpoint))
   
    else                                                                        'Buffer doesn't roll over process the data in one part 
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, _dataPtr, RSR.word[0])

    'Update the W5500 registers, the packet pointer
    temp0 := (pcktptr + RSR.word[0])
    pcktptr.byte[1] := temp0.byte[0]
    pcktptr.byte[0] := temp0.byte[1]
    writeSPI(true, (blockoffset + _Register_0), _Sn_RX_RD0, @pcktptr, 2)   
   
    'Tell the W5500 we received a packet
    temp0 := _RECV
    writeSPI(true, (blockoffset + _Register_0), _Sn_CR, @temp0, 1)
   
    return RSR.word[0]        'bugfix /Q

  else
    return 0 'end of rxTCP

PUB txTCP(_socket, _dataPtr, _size) | temp0, freespace, pcktptr, rolloverpoint, chunksize, pcktoffset, blockoffset, pcktstart

'' Transmit TCP data on the specified socket and port.  Most of the heavy lifting of transmitting data is handled by the ASM routine,
'' but for effeciency in coding the SPIN routine walks through the process of transmitting data such as verifying and manipulating
'' the various registers.  This routine could be completely coded in ASM for faster operation.
''
'' The transmit routine sends only the amount of data specified by _size.  This routine waits for room in the W5500 to send the packet.
''
''  params:  _socket is a value of 0 to 7 - eight sockets on the W5500
''           _dataPtr is a pointer to the byte(s) of data to read from HUBRAM and sent (use the @ in front of the byte variable)
''           _size it the length in bytes of the data to be sent from HUBRAM
''  return:  True if data was put in W5500 and told to be sent, otherwise false
''

  'Initialize
  freespace := 0
  pcktptr:= 0

  blockoffset := (4 * _socket)              
       
  repeat while _size > 0
    'wait for room in the W5500 to send some of the data
    repeat until (freespace.word[0] > 0)
      readSPI((blockoffset + _Register_0), Sn_TX_FSR0, @temp0, 2)
      freespace.byte[1] := temp0.byte[0]
      freespace.byte[0] := temp0.byte[1]
    chunksize := _size <# freespace.word[0]
   
    'Get the place where to start writing the packet in the W5500
    readSPI((blockoffset + _Register_0), _Sn_TX_WR0, @temp0, 2)
    pcktptr.byte[1] := temp0.byte[0]
    pcktptr.byte[0] := temp0.byte[1]
    pcktoffset := pcktptr & _TX_mask
    pcktstart := pcktptr
   
    'Write the data based on rolling over in the buffer or not
    if (pcktoffset + chunksize) > constant(_TX_mask + 1)
      'process the data in two parts because the buffers rolls over
      rolloverpoint := constant(_TX_mask + 1) - pcktoffset
      writeSPI(true, ((blockoffset  + _TX_Buffer_0)), pcktstart, _dataPtr, rolloverpoint)
      pcktstart := 0
      writeSPI(true, ((blockoffset  + _TX_Buffer_0)), pcktstart, (_dataPtr + rolloverpoint), (chunksize - rolloverpoint))
   
    else
      'process the data in one part
      writeSPI(true, ((blockoffset  + _TX_Buffer_0)), pcktstart, _dataPtr, chunksize)
   
    'Calculate the packet pointer for the next go around and save it
    temp0 := pcktptr + chunksize
    pcktptr.byte[1] := temp0.byte[0]
    pcktptr.byte[0] := temp0.byte[1]
    writeSPI(true, (blockoffset + _Register_0), _Sn_TX_WR0, @pcktptr, 2)
   
    'Tell the W5500 to send the packet
    temp0 := _SEND
    writeSPI(true, (blockoffset + _Register_0), _Sn_CR, @temp0, 1)
   
    _size    -= chunksize
    _dataPtr += chunksize

PUB rxUDP(_socket, _dataPtr) | blockoffset, temp0, RSR, pcktsize, pcktoffset, rolloverpoint, pcktstart, pcktptr

'' Receive UDP data on the specified socket.  Most of the heavy lifting of receiving data is handled by the ASM routine,
'' but for effeciency in coding the SPIN routine walks through the process of receiving data such as verifying and manipulating
'' the various registers.  NOTE: This routine could be completely coded in ASM for faster operation.
''
'' The receive routine brings over only 1 packet of UDP data at a time.  The packet is based on the size of data read in the packet
'' header and NOT the W5200 receive register size.
''
''  params:  _socket is a value of 0 to 7 - only four sockets on the W5200
''           _dataPtr is a pointer to the byte array to be written to in HUBRAM (use the @ in front of the byte variable)
''  return:  Non-zero value indicating bytes read from W5200 or zero if no data is read
''
''  The data returned is the complete packet as provided by the W5200.  This means the following:
''  data[0]..[3] is the source IP address, data[4],[5] is the source port, data[6],[7] is the payload size and data[8] starts the payload

  blockoffset := (4*_socket)
  
  'Check if there is data to receive from the W5200
  readSPI((blockoffset + _Register_0), _Sn_RX_RSR0, @temp0, 2)
  RSR.byte[1] := temp0.byte[0]
  RSR.byte[0] := temp0.byte[1]
   
  'Bring over the data if there is data
  if RSR.word[0] > 0
   
    'Determine the offset and location to read data from in the W5200
    readSPI((blockoffset + _Register_0), _Sn_RX_RD0, @temp0, 2)
    pcktptr.byte[1] := temp0.byte[0]
    pcktptr.byte[0] := temp0.byte[1]
    pcktoffset := pcktptr & _RX_mask
    pcktstart := pcktptr
   
    'Read the header of the packet - the first 8 bytes
    if (pcktoffset + _UDP_header) > constant(_RX_mask + 1)
      'process the header in two parts because the buffers rolls over
      rolloverpoint := constant(_RX_mask + 1) - pcktoffset
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, _dataPtr, rolloverpoint)  
      pcktstart := 0
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, (_dataPtr + rolloverpoint), (_UDP_header - rolloverpoint))
      
    else
      'process the header in one part
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, _dataPtr, _UDP_header)
   
    'Get the size of the payload portion
    pcktsize := 0                                     'Must be initialized as ASM routine isn't masking the value so a greater than $FF could cause problems
    pcktsize.byte[1] := byte[_dataPtr][6]
    pcktsize.byte[0] := byte[_dataPtr][7]
   
    pcktoffset := (pcktptr + _UDP_header) & _RX_mask
    pcktstart := pcktptr + _UDP_header  
    _dataPtr += _UDP_header
   
    'Read the data of the packet
    if (pcktoffset + pcktsize.word[0]) > constant(_RX_mask + 1)
      'process the data in two parts because the buffers rolls over
      rolloverpoint := constant(_RX_mask + 1) - pcktoffset
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, _dataPtr, rolloverpoint)       
      pcktstart := 0
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, (_dataPtr + rolloverpoint), (pcktsize.word[0] - rolloverpoint))
      
    else
      'process the data in one part
      readSPI((blockoffset + _RX_Buffer_0), pcktstart, _dataPtr, pcktsize.word[0])  
   
    'Update the W5200 registers, the packet pointer
    temp0 := (pcktptr + _UDP_header + pcktsize.word[0])
    pcktptr.byte[1] := temp0.byte[0]
    pcktptr.byte[0] := temp0.byte[1]
    writeSPI(true, (blockoffset + _Register_0), _Sn_RX_RD0, @pcktptr, 2)
   
    'Tell the W5200 we received a packet
    temp0 := _RECV
    writeSPI(true, (blockoffset + _Register_0), _Sn_CR, @temp0, 1)
   
    return (pcktsize.word[0] + _UDP_header)

  else
    return 0 'end of rxUDP
  
PUB txUDP(_socket, _dataPtr) | temp0, payloadsize, freespace, pcktptr, rolloverpoint, pcktoffset, blockoffset, pcktstart

'' Transmit UDP data on the specified socket and port.  Most of the heavy lifting of transmitting data is handled by the ASM routine,
'' but for effeciency in coding the SPIN routine walks through the process of transmitting data such as verifying and manipulating
'' the various register.  This routine could be completely coded in ASM for faster operation.
''
'' The transmit routine sends only 1 packet of UDP data at a time.  The packet is based on the size of data read in the packet
'' header.  This routine waits for room in the W5500 to send the packet.
''
''  params:  _socket is a value of 0 to 7 - eight sockets on the W5500
''           _dataPtr is a pointer to the byte(s) of data to read from HUBRAM and sent (use the @ in front of the byte variable)
''  return:  True if data was put in W5500 and told to be sent, otherwise false
''
''  The data packet passed to this routine should be of the form of the following:
''  data[0]..[3] is the destination IP address, data[4],[5] is the destination port, data[6],[7] is the payload size and data[8] starts the payload

  blockoffset := (4*_socket)

  repeat
    readSPI((blockoffset + _Register_0), _Sn_SR, @temp0, 1)
  until temp0.byte[0] & $CF <> $01                            '$11, $21, $31 documented ARP states, $01 undocumented
  'Make sure the socket is open for UDP business
  if temp0.byte[0] <> _SOCK_UDP
    return false
   
  'Get the size of the packet to be sent; this doesn't include the header info
  payloadsize := 0
  freespace := 0  
  payloadsize.byte[1] := byte[_dataPtr][6]                  'hi-byte
  payloadsize.byte[0] := byte[_dataPtr][7]                  'lo-byte
   
  'wait for room in the W5500 to send data
  repeat until (freespace.word[0] > payloadsize.word[0])
    readSPI((blockoffset + _Register_0), Sn_TX_FSR0, @temp0, 2)
    freespace.byte[1] := temp0.byte[0]
    freespace.byte[0] := temp0.byte[1]
   
  'Tell the W5500 the destination address and destination socket
  writeSPI(true, (blockoffset + _Register_0), _Sn_DIPR0, _dataPtr, 6)               ' Write destination IP and Port (6 bytes)
  _dataPtr += _UDP_header                                                       ' Increment data pointer beyond header (8 bytes)
   
  'Get the place where to start writing the packet in the W5500
  readSPI((blockoffset + _Register_0), _Sn_TX_WR0, @temp0, 2)                       ' Get Socket TX Write Pointer   
  pcktptr.byte[1] := temp0.byte[0]
  pcktptr.byte[0] := temp0.byte[1]
  pcktoffset := pcktptr & _TX_mask
  pcktstart := pcktptr
   
  'Write the data based on rolling over in the buffer or not
  if (pcktoffset + payloadsize.word[0]) > constant(_TX_mask + 1)
    'process the data in two parts because the buffers rolls over
    rolloverpoint := constant(_TX_mask + 1) - pcktoffset                        ' Calculate number of bytes before we jump to buffer start
    writeSPI(true, ((blockoffset  + _TX_Buffer_0)), pcktstart, _dataPtr, rolloverpoint)                                                                                
    pcktstart := 0                                                                ' Jump to start of buffer 
    writeSPI(true, ((blockoffset  + _TX_Buffer_0)), pcktstart, (_dataPtr + rolloverpoint), payloadsize.word[0] - rolloverpoint)
   
  else
    'process the data without rollover
    writeSPI(true, ((blockoffset  + _TX_Buffer_0)), pcktstart, _dataPtr, payloadsize.word[0])
   
  'Calculate the packet pointer for the next go around and save it
  'Update the W5500 registers, the packet pointer
  temp0 := (pcktptr + payloadsize.word[0])
  pcktptr.byte[1] := temp0.byte[0]
  pcktptr.byte[0] := temp0.byte[1]
  writeSPI(true, (blockoffset + _Register_0), _Sn_TX_WR0, @pcktptr, 2)
   
  'Tell the W5500 to send the packet
  temp0 := _SEND
  writeSPI(true, (blockoffset + _Register_0), _Sn_CR, @temp0, 1)

PUB mutexInit

'' Initialize mutex lock semaphore. Called once at driver initialization if application level locking is needed.
''
'' Returns -1 if no more locks available.

  lock := locknew
  return lock

PUB mutexLock

'' Waits until exclusive access to driver guaranteed.

  repeat until not lockset(lock)

PUB mutexRelease

'' Release mutex lock.

  lockclr(lock)

PUB mutexReturn

'' Returns mutex lock to semaphore pool.

  lockret(lock)

PUB readSPI(_blockSelect, _offsetAddress, _dataPtr, _Numbytes)

'' High level access to SPI routine for reading from the W5500.
'' Note for faster execution of functions code them in assembly routine like the examples of setting the MAC/IP addresses.
''
''  params:  _blockSelect is the 5 bit register or block.
''           _offsetAddress is the 2 byte offset address. See the constant block with register definitions
''           _dataPtr is the place to return the byte(s) of data read from the W5500 (use the @ in front of the byte variable)
''           _Numbytes is the number of bytes to read

  'Send the command
  command := _readSPI + @_blockSelect
   
  'wait for the command to complete
  repeat while command
   
PUB writeSPI(_block, _blockSelect, _offsetAddress,  _dataPtr, _Numbytes)

'' High level access to SPI routine for writing to the W5500.
'' Note for faster execution of functions code them in assembly routine like the examples of setting the MAC/IP addresses.
''
''  params:  _block if true will wait for ASM routine to send before continuing
''           _blockSelect is the 5 bit register or block.
''           _offsetAddress is the 2 byte offset address. See the constant block with register definitions
''           _dataPtr is a pointer to the byte(s) of data to be written (use the @ in front of the byte variable)
''           _Numbytes is the number of bytes to write

  'Send the command
  command := _writeSPI + @_blockSelect
   
  'wait for the command to complete or just move on
  if _block
    repeat while command
   
DAT

''  Assembly language driver for W5500
 
        org
'-----------------------------------------------------------------------------------------------------
'Start of assembly routine
'-----------------------------------------------------------------------------------------------------
Entry
              'Upon starting the ASM cog the first thing to do is set the I/O states and directions.  SPIN already
              'setup the masks for each pin in the defined data section of the routine before starting the COG.

              'Set the initial state of the I/O, unless listed here, the output is initialized as off/low
              mov       outa,   SCSmask         'W5500 SPI slave select is initialized as high

                                                'Remaining outputs initialized as low including reset
                                                'NOTE: the W5500 is held in reset because the pin is low

              'Next set up the I/O with the masks in the direction register...
              '...all outputs pins are set up here because input is the default state
              mov       dira,   SCSmask         'Set to an output and clears cog dira register
              or        dira,   SCLKmask        'Set to an output
              or        dira,   MOSImask        'Set to an output
              or        dira,   RESETmask       'Set to an output
                                                'NOTE: MISOpin isn't here because it is an input

              mov       t0,     _rstTime        'Time to hold IC in reset
              add       t0,     cnt             'Add in the current system counter
              waitcnt   t0,     _UnrstTime      'Wait 2.5 us

              or        outa,   RESETmask       'Finally - make the reset line high for the W5500 to come out of reset
              waitcnt   t0,     _UnrstTime      'Time to wait to come out of reset - 250 ms

              'While the W5500 is coming out of reset initialize COG counter values
              mov       frqb,   #0              'Counter B is used as a special register. Frq is set to 0 so there isn't accumulation.
              mov       ctrb,   ctrbmode        'This turns Counter B on. The main purpose is to have phsb[31] bit appear on the MOSI line.

'-----------------------------------------------------------------------------------------------------
'Main loop
'wait for a command to come in and then process it.
'-----------------------------------------------------------------------------------------------------
CmdWait
              rdlong    cmdAdrLen, par      wz  'Check for a command being present
        if_z  jmp       #CmdWait                'If there is no command (zero), check again

              mov       t1, cmdAdrLen           'Take a copy of the command/address combo to work on
              rdlong    paramA, t1              'Get parameter A value
              add       t1, #4                  'Increment the address pointer by four bytes
              rdlong    paramB, t1              'Get parameter B value
              add       t1, #4                  'Increment the address pointer by four bytes
              rdlong    paramC, t1              'Get parameter C value
              add       t1, #4                  'Increment the address pointer by four bytes
              rdlong    paramD, t1              'Get parameter D value
              add       t1, #4                  'Increment the address pointer by four bytes
              rdlong    paramE, t1              'Get parameter E value

              mov       t0, cmdAdrLen           'Take a copy of the command/address combo to work on
              shr       t0, #16            wz   'Get/Isolate the command (shift right 16)
              cmp       t0, #(_lastCmd>>16)+1 wc'Check for valid command
  if_z_or_nc  jmp       #:CmdExit               'Command is invalid so exit loop
  
              shl       t0, #1                  'Shift left (aka multiply by two)
              add       t0, #:CmdTable-2        'add in the "call" address
              jmp       t0                      'Jump to the command

              'The table of commands that can be called
:CmdTable     call      #rSPIcmd                'Read a byte from the W5500 - high level call
              jmp       #:CmdExit
              call      #wSPIcmd                'Write a byte to the W5500 - high level call
              jmp       #:CmdExit
              call      #wMAC                   'Write the MAC ID
              jmp       #:CmdExit
              call      #wGateway               'Write the Gateway address
              jmp       #:CmdExit
              call      #wSubnet                'Write the Subnet address
              jmp       #:CmdExit
              call      #wIP                    'Write the IP address
              jmp       #:CmdExit
              call      #rMAC                   'Read the MAC ID
              jmp       #:CmdExit
              call      #rGateway               'Read the Gateway address
              jmp       #:CmdExit
              call      #rSubnet                'Read the Subnet address
              jmp       #:CmdExit
              call      #rIP                    'Read the IP Address
              jmp       #:CmdExit
              call      #pingBlk                'Enable/disable a ping response
              jmp       #:CmdExit
              call      #rstHW                  'Hardware reset of W5500
              jmp       #:CmdExit
              call      #rstSW                  'Software reset of W5500
              jmp       #:CmdExit
              call      #sOPEN                  'Open a socket
              jmp       #:CmdExit
              call      #sDISCON                'Disconnect a socket
              jmp       #:CmdExit
              call      #sCLOSE                 'Close a socket
              jmp       #:CmdExit
              call      #LastCMD                'PlaceHolder for last command
              jmp       #:CmdExit
:CmdTableEnd

              'End of processing a command
:CmdExit      wrlong    _zero,  par             'Clear the command status
              jmp       #CmdWait                'Go back to waiting for a new command

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to READ a REGISTER from the W5500 - a high level call
'-----------------------------------------------------------------------------------------------------
rSPIcmd
              mov       bsb,    paramA          'Move the register address into a variable for processing
              mov       osa,    ParamB          'Move the offset address into a varaiable for processing     
              mov       ram,    ParamC          'Move the address of the returned byte into a variable for processing
              mov       ctr,    ParamD          'Set up a counter for number of bytes to process (aka data length)

              call      #ReadMulti              'Read the byte from the W5500

rSPIcmd_ret ret                                 'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to WRITE a REGISTER in the W5500 - a high level call
'-----------------------------------------------------------------------------------------------------
wSPIcmd
              mov       bsb,    paramA          'Move the register address into a variable for processing
              mov       osa,    ParamB          'Move the offset address into a varaiable for processing
              mov       ram,    paramC          'Move the data byte into a variable for processing
              mov       ctr,    ParamD          'Set up a counter for number of bytes to process (aka data length)

              call      #WriteString            'Write the byte to the W5500

wSPIcmd_ret ret                                 'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to WRITE the MAC ID in the W5500
'-----------------------------------------------------------------------------------------------------
wMAC
              mov       bsb,    #_Common_Reg
              mov       osa,    #_SHAR0         'Move the MAC ID register address into a variable for processing 
              mov       ram,    cmdAdrLen       'Move the address of the MAC ID array into a variable for processing
              mov       ctr,    #6              'Set up a counter of 6 bytes

              call      #WriteString            'Write the bytes out to the W5500

wMAC_ret ret                                    'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to WRITE the Gateway Address in the W5500
'-----------------------------------------------------------------------------------------------------
wGateway
              mov       bsb,    #_Common_Reg
              mov       osa,    #_GAR0          'Move the gateway register address into a variable for processing
              mov       ram,    cmdAdrLen       'Move the address of the gateway address array into a variable for processing
              mov       ctr,    #4              'Set up a counter of 4 bytes

              call      #WriteString            'Write the bytes out to the W5500

wGateway_ret ret                                'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to WRITE the Subnet Address in the W5500
'-----------------------------------------------------------------------------------------------------
wSubnet
              mov       bsb,    #_Common_Reg
              mov       osa,    #_SUBR0         'Move the subnet register address into a variable for processing
              mov       ram,    cmdAdrLen       'Move the address of the subnet address array into a variable for processing
              mov       ctr,    #4              'Set up a counter of 4 bytes

              call      #WriteString            'Write the bytes out to the W5500

wSubnet_ret ret                                 'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to WRITE the IP Address in the W5500
'-----------------------------------------------------------------------------------------------------
wIP
              mov       bsb,    #_Common_Reg
              mov       osa,    #_SIPR0         'Move the IP register address into a variable for processing
              mov       ram,    cmdAdrLen       'Move the address of the IP address array into a variable for processing
              mov       ctr,    #4              'Set up a counter of 4 bytes

              call      #WriteString            'Write the bytes out to the W5500

wIP_ret ret                                     'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to READ the MAC ID in the W5500
'-----------------------------------------------------------------------------------------------------
rMAC
              mov       bsb,    #_Common_Reg
              mov       osa,    #_SHAR0         'Move the MAC ID register address into a variable for processing
              mov       ram,    cmdAdrLen       'Move the address of the MAC ID array into a variable for processing
              mov       ctr,    #6              'Set up a counter of 6 bytes

              call      #ReadMulti              'Read the bytes from the W5500

rMAC_ret ret                                    'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to READ the Gateway Address in the W5500
'-----------------------------------------------------------------------------------------------------
rGateway
              mov       bsb,    #_Common_Reg
              mov       osa,    #_GAR0          'Move the gateway register address into a variable for processing
              mov       ram,    cmdAdrLen       'Move the address of the gateway address array into a variable for processing
              mov       ctr,    #4              'Set up a counter of 4 bytes

              call      #ReadMulti              'Read the bytes from the W5500

rGateway_ret ret                                'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to READ the Subnet Address in the W5500
'-----------------------------------------------------------------------------------------------------
rSubnet
              mov       bsb,    #_Common_Reg
              mov       osa,    #_SUBR0         'Move the subnet register address into a variable for processing
              mov       ram,    cmdAdrLen       'Move the address of the subnet address array into a variable for processing
              mov       ctr,    #4              'Set up a counter of 4 bytes

              call      #ReadMulti              'Read the bytes from the W5500

rSubnet_ret ret                                 'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine to READ the IP address in the W5500
'-----------------------------------------------------------------------------------------------------
rIP
              mov       bsb,    #_Common_Reg
              mov       osa,    #_SIPR0         'Move the IP register address into a variable for processing
              mov       ram,    cmdAdrLen       'Move the address of the IP address array into a variable for processing
              mov       ctr,    #4              'Set up a counter of 4 bytes

              call      #ReadMulti              'Read the bytes from the W5500

rIP_ret ret                                     'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine for enabling/disabling a ping response by the W5500, true = blocked, false = not blocked
'-----------------------------------------------------------------------------------------------------
pingBlk
              mov       bsb,    #_Common_Reg
              mov       osa,    #_MR            'Move the mode register address into a variable for processing
              call      #ReadByte               'Read the bytes from the W5500

              rdlong    t0,     cmdAdrLen       'Read the bool from SPIN command and place in a variable for testing
              cmp       t0,     #0         wz   'Is the value zero or non-zero?
        if_z  andn      data,   #_PBMode        'Disable ping blocking - W5500 will respond to a ping
        if_nz or        data,   #_PBMode        'Enable ping blocking - W5500 will not respond to a ping

              call      #WriteByte              'Write the bytes from the W5500

pingBlk_ret ret                                 'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine for resetting the W5500 via hardware
'-----------------------------------------------------------------------------------------------------
rstHW
              andn      outa,   RESETmask       'Toggle the reset line low - resets the W5500

              mov       t0,     _rstTime        'Time to hold IC in reset
              add       t0,     cnt             'Add in the current system counter
              waitcnt   t0,     _UnrstTime      'Wait

              or        outa,   RESETmask       'Finally - make the reset line high for the W5500 to come out of reset
              waitcnt   t0,     _UnrstTime      'Time to wait to come out of reset

rstHW_ret ret                                   'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine for resetting the W5500 via software
'-----------------------------------------------------------------------------------------------------
rstSW
              mov       bsb,    #_Common_Reg
              mov       osa,    #_MR            'Move the mode register address into a variable for processing
              mov       ctr,    #1              'Set up a counter of 1 bytes
              call      #ReadByte               'Read the bytes from the W5500
              
              or        data,   #_RSTMODE       'Software reset
              mov       ctr,    #1              'Set up a counter of 1 bytes
              call      #WriteByte              'Write the bytes from the W5500

              mov       t0,     _UnrstTime      'Time to wait to come out of reset
              add       t0,     cnt             'Add in the current system counter
              waitcnt   t0,     #0              'Wait

rstSW_ret ret                                   'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine for opening a socket         
'-----------------------------------------------------------------------------------------------------
sOPEN
              mov       bsb,    paramA          'Move the socket number into t0
              shl       bsb,    #2              'Multiple by 4
              add       bsb,    _Register_0_d                                          

              'set the MODE  
              mov       osa,    _Sn_MR_d        'Move the offset address into a variable for processing
              mov       data,   paramB          'Move over the socket type
              call      #WriteByte              'Write the bytes from the W5500

              'set the SOURCE PORT
              mov       osa,    _Sn_PORT1_d     'Move the offset address into a variable for processing                                                                                                                                                                                                        
              mov       data,   paramC          'Move over the source socket value
              call      #WriteByte              'Write the bytes from the W5500

              sub       osa,    #1              'Increment the offset address
              mov       data,   paramC          'Move over the source socket value
              shr       data,   #8              'shift the data over one byte
              call      #WriteByte              'Read the bytes from the W5500

              'set the DESTINATION PORT
              mov       osa,    _Sn_DPORT1_d    'Move the offset address into a variable for processing                                                                                                                                                                                                       
              mov       data,   paramD          'Move over the destination socket value
              call      #WriteByte              'Write the bytes from the W5500
              
              sub       osa,    #1              'Increment the offset address
              mov       data,   paramD          'Move over the destination socket value
              shr       data,   #8              'shift the data over one byte
              call      #WriteByte              'Read the bytes from the W5500

              'set the DESTINATION IP
              mov       osa,    _Sn_DIPR0_d     'Move the offset address into a variable for processing                                                                                                                                                                                                       
              mov       ram,    paramE          'Move the address of the IP address array into a variable for processing
              mov       ctr,    #4              'Set up a counter of 4 bytes
              call      #WriteString            'Write the bytes from the W5500

              'set the PORT OPEN
              mov       osa,    _Sn_CR_d        'Move the offset address into a variable for processing                                                                                                                                                                                                        
              mov       data,   #_OPEN          'Move over the command
              call      #WriteByte              'Write the bytes from the W5500

sOPEN_ret ret                                   'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine for disconnecting a socket
'-----------------------------------------------------------------------------------------------------
sDISCON
              mov       bsb,     paramA         'Move the socket number into t0
              shl       bsb,     #2             'Multiple by 4
              add       bsb,     _Register_0_d  'Add bit select block offset                      
              
              'set the port to disconnect
              mov       osa,    _Sn_CR_d        'Move the register address into a variable for processing                                                                                                                                                                                               
              mov       data,   #_DISCON        'Move over the command
              call      #WriteByte              'Write the bytes from the W5500

sDISCON_ret ret                                 'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine for closing a socket
'-----------------------------------------------------------------------------------------------------
sCLOSE
              mov       bsb,     paramA         'Move the socket number into t0
              shl       bsb,     #2             'Multiple by 4
              add       bsb,     _Register_0_d  'Add bit select block offset                      
              
              'set the port close
              mov       osa,    _Sn_CR_d        'Move the register address into a variable for processing                                                                                                                                                                                               
              mov       data,   #_CLOSE         'Move over the command
              call      #WriteByte              'Write the bytes from the W5500

sCLOSE_ret ret                                  'Command execution complete

'-----------------------------------------------------------------------------------------------------
'Command sub-routine holding place
'-----------------------------------------------------------------------------------------------------
LastCMD

LastCMD_ret ret                                 'Command execution complete

'=====================================================================================================
'-----------------------------------------------------------------------------------------------------
'Sub-routine to map write to SPI
' NOTE: Data and Reg setup must be done before calling this routine
'-----------------------------------------------------------------------------------------------------
WriteByte
              mov       opm,    #0              'OpMode set to VDM (variable data mode)
              mov       ctr,    #1              'Single byte of data
              call      #wSPI                   'Clock the data out
              call      #wSPI_Data              'Write the data byte
              or        outa,   SCSmask         'De-assert CS 
WriteByte_ret ret                               'Return to the calling code

'-----------------------------------------------------------------------------------------------------
'Sub-routine to map read to SPI 
' NOTE: Reg setup must be done before calling this routine   
'-----------------------------------------------------------------------------------------------------
ReadByte
              mov       opm,    #0              'OpMode set to VDM (variable data mode)
              mov       ctr,    #1              'Single byte of data 
              call      #rSPI                   'send the read command
              call      #rSPI_Data              'Read the data byte 
              and       data,   _bytemask       'Ensure there is only a byte
              or        outa,   SCSmask         'De-assert CS 
ReadByte_ret ret
                     
'-----------------------------------------------------------------------------------------------------
'Sub-routine to map WRITE to SPI and to loop through bytes
' NOTE: RAM, Reg, and CTR setup must be done before calling this routine
'-----------------------------------------------------------------------------------------------------
WriteString
              mov       opm,    #0              'OpMode set to VDM (variable data mode)
              call      #wSPI                   'send the first write command
              
:bytes        
              rdbyte    data,   ram             'Read the byte/octet from hubram           
              call      #wSPI_Data              'write one byte to W5500
              
              add       osa,    #1              'Increment the offset address by one byte
              add       ram,    #1              'Increment the hubram address by one byte
              djnz      ctr,    #:bytes         'Check if there is another byte, if so, process it              
              or        outa,   SCSmask         'De-assert SCS 
WriteString_ret ret                             'Return to the calling code

'-----------------------------------------------------------------------------------------------------
'Sub-routine to map READ to SPI and to loop through bytes
' NOTE: Reg, and CTR setup must be done before calling this routine
'-----------------------------------------------------------------------------------------------------
              
ReadMulti     mov       opm,    #0              'OpMode set to VDM (variable data mode)
              call      #rSPI                   'send the first read command to the W5200              
:bytes         
              call      #rSPI_Data              'read one data byte from the W5500   1.15us
              and       data,   _bytemask       'Ensure there is only a byte   +20 clocks in this loop = 1.4us/byte
              wrbyte    data,   ram             'Write the byte to hubram
              add       osa,    #1              'Increment the address offset by one byte
              add       ram,    #1              'Increment the hubram address by one byte
              djnz      ctr,    #:bytes         'Check if there is another if so, process it              
              or        outa,   SCSmask         'De-assert SCS        

ReadMulti_ret ret                               'Return to the calling code

'-----------------------------------------------------------------------------------------------------
'Sub-routine to write data to W5500 via SPI
'-----------------------------------------------------------------------------------------------------
wSPI
'High speed serial driver utilizing the counter modules. Counter A is the clock while Counter B is used as a special register
'to get the data on the output line in one clock cycle. This code is meant to run at 80MHz processor clock speed and the code
'clocks data at 20MHz. Populate reg and data before calling this routine.
                  
              andn      outa,   SCLKmask        'turn the clock off, ensure it is low before placing data on the line              
              
              'Preamble                         'Populate long with Address, Control Phase, First data byte
              mov       phsb,   osa             'Add address (16 bits) to the register
              shl       phsb,   #5              'Make room (5 bits) for Block Select Bits (BSB)
              or        phsb,   bsb             'Add Block Select Bits
              shl       phsb,   #1              'Make room (1 bit) for Read/Write bit 
              or        phsb,   #1              'Add in a write operation in phsb write = 1              
              shl       phsb,   #2              'Make room (2 bits) for the Op Mode
              or        phsb,   opm             'Add Op Mode - 24 bits added, DONE!
              shl       phsb,   #8              'Move data to top of long (32-24 = 8)

              andn      outa,   SCSmask         'Begin the data transmission by enabling SPI mode - making line go low 

              mov       frqa,   frq20           'Setup the writing frequency for 20mhz 
              mov       phsa,   phs20           'Setup the writing phase of data/clock
              
              mov       ctra,   ctramode        'Turn on Counter A to start clocking                                                                                                                                                                                                                                            
              rol       phsb,   #1              'NOTE: First bit is clocked just as soon as the clock turns on
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1  
              mov       ctra,   #0              '24 bits sent - Turn off the clocking                                          
wSPI_ret      ret                               'wSPI return

wSPI_Data
              mov       phsb,   #0
              mov       phsb,   data            'Add in the data, to be clocked out
              shl       phsb,   #24             'Move data to top of long (32-8 = 24)
              mov       frqa,   frq20           'Setup the writing frequency (20mhz writes)
              mov       phsa,   phs20           'Setup the writing phase of data/clock              
              mov       ctra,   ctramode        'Turn on Counter A to start clocking
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              mov       ctra,   #0              '8 bits sent - Turn off the clocking
wSPI_Data_ret ret                               'Return to the calling loop

'-----------------------------------------------------------------------------------------------------
'Sub-routine to read data from W5500 via SPI (Note that it must write in order to read)
'-----------------------------------------------------------------------------------------------------
rSPI
'High speed serial driver utilizing the counter modules. Counter A is the clock while Counter B is used as a special register
'to get the data on the output line in one clock cycle. This code is meant to run on 80MHz. processor and the code clocks data
'at 10MHz. 
               
              andn      outa,   SCLKmask        'turn the clock off, ensure it is low before placing data on the line  

              'Preamble                         'Populate long with Address, Control Phase, First data byte   
              mov       phsb,   osa             'Add address (16 bits) to the register                     
              shl       phsb,   #5              'Make room (5 bits) for Block Select Bits (BSB)
              or        phsb,   bsb             'Add Block Select Bits                         
              shl       phsb,   #1              'Make room (1 bit) for Read/Write bit          
              or        phsb,   #0              'Add in a write operation in phsb read = 0              
              shl       phsb,   #2              'Make room (2 bits) for the Op Mode            
              or        phsb,   opm             'Add Op Mode - 24 bits added, DONE!            
              shl       phsb,   #8              'Move data to top of long (32-24 = 8)

              andn      outa,   SCSmask         'Begin the data transmission by enabling SPI mode - making line go low  

              mov       frqa,   frq20           'Setup the writing frequency  for 20mhz 08/15/2012
              mov       phsa,   phs20           'Setup the writing phase of data/clock for 20mhz 08/15/2012
              
              mov       ctra,   ctramode        'Turn on Counter A to start clocking                                                                                                                                                         
              rol       phsb,   #1              'NOTE: First bit is clocked just as soon as the clock turns on
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1
              rol       phsb,   #1 
              mov       ctra,   #0              '24 bits sent - Turn off the clocking
rSPI_ret      ret

rSPI_Data
              mov       frqa, frq10             'Reset to 10MHz read frequency read speed. We can't speed up because we
              mov       phsa, phs10             'need 2-instructions per bit to read. 20MHz max/2 instructions per = 10MHz
              nop
              
              mov       ctra, ctramode          'start clocking
              test      MISOmask, ina wc        'Gather data, to be clocked in       
              rcl       data, #1                'Data bit 0
              test      MISOmask, ina wc        
              rcl       data, #1                'Data bit 1 
              test      MISOmask, ina wc        
              rcl       data, #1                'Data bit 2 
              test      MISOmask, ina wc        
              rcl       data, #1                'Data bit 3  
              test      MISOmask, ina wc        
              rcl       data, #1                'Data bit 4 
              test      MISOmask, ina wc        
              rcl       data, #1                'Data bit 5 
              test      MISOmask, ina wc        
              rcl       data, #1                'Data bit 6 
              test      MISOmask, ina wc        
              mov       ctra, #0                'Turn off the clocking immediately, otherwise you might get odd behavior
              rcl       data, #1                'Data bit 7 
rSPI_Data_ret ret                               'Return to the calling loop

'==========================================================================================================
'Defined data
_zero         long      0                       'Zero
_bytemask     long      $FF                     'Byte mask
_rstTime      long      44_000                  'Time to hold in reset  (550us) 
_UnrstTime    long      16_000_000              'Time to wait after coming out of reset  (200ms)

'Pin/mask definitions are initianlized in SPIN and program/memory modified here before the COG is started
SCSmask       long      0-0                     'W5500 SPI slave select - active low, output
SCLKmask      long      0-0                     'W5500 SPI clock - output
MOSImask      long      0-0                     'W5500 Master out slave in - output
MISOmask      long      0-0                     'W5500 Master in slave out - input
RESETmask     long      0-0                     'W5500 Reset - active low, output

'NOTE: Data that is initialized in SPIN and program/memory modified here before COG is started
ctramode      long      0-0                     'Counter A for the COG is used a serial clock line = SCLK
                                                'Counter A has phsa and frqa loaded appropriately to create a clock cycle
                                                'on the configured APIN

ctrbmode      long      0-0                     'Counter B for the COG is used as the data output = MOSI
                                                'Counter B isn't really used as a counter per se, but as a special register
                                                'that can quickly output data onto an I/O pin in one instruction using the
                                                'behavior of the phsb register where phsb[31] = APIN of the counter

frq20         long      $4000_0000              'Counter A & B's frqa register setting for reading data from W5500. 08/15/2012
                                                'This value is the system clock divided by 4 i.e. CLKFREQ/4 (80MHz clk = 20MHz)
phs20         long      $5000_0000              'Counter A & B's phsa register setting for reading data from W5500.   08/15/2012
                                                'This sets the relationship of the MOSI line to the clock line.  Note have not tried
                                                'other values to determine if there is a "sweet sdpot" for phase... 08/15/2012
frq10         long      $2000_0000              'need to keep 10mhz vaues also, because read is maxed at 10mhz
phs10         long      $6000_0000              '08/15/2012

'Data defined in constant section, but needed in the ASM for program operation
_Sn_MR_d       long      _Sn_MR
_Sn_PORT1_d    long      _Sn_PORT1
_Sn_DPORT1_d   long      _Sn_DPORT1
_Sn_DIPR0_d    long      _Sn_DIPR0
_Sn_CR_d       long      _Sn_CR
_Register_0_d  long     _Register_0

'==========================================================================================================
'Uninitialized data - temporary variables
t0            res 1     'temp0
t1            res 1     'temp1

'Parameters read from commands passed into the ASM routine
cmdAdrLen     res 1     'Combo of address, ocommand and data length into ASM
paramA        res 1     'Parameter A
paramB        res 1     'Parameter B
paramC        res 1     'Parameter C
paramD        res 1     'Parameter D
paramE        res 1     'Parameter E

bsb           res 1     'Block Select Bits
osa           res 1     'Offset Address
opm           res 1     'Operation Mode
data          res 1     'Data read to/from            
ram           res 1     'Pointer address of Hubram for reading/writing data from 
ctr           res 1     'Counter of bytes for looping

              fit 496   'Ensure the ASM program and defined/res variables fit in a single COG.

DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}