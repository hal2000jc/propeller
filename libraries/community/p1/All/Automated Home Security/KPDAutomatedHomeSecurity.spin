{{

 KPDAutomateHomeSecurity
 By: KPD237                                 
 Much indebted to Beau Schwabe              
 Whose webserver I ripped appart for this                                               
 See end of file for terms of use.          

 
}}
CON
    _clkfreq = 80_000_000
    _clkmode = xtal1 + pll16x
    
    socket = 0
    listenPort = 3456'───┬── Your port of choice goes here ; typically between 0 and 65535
'                        │      Note: If you use port 80, then you don't need to specify
{                        ├──┐         the ':xxxx' at the end of the HTTP address, however 
   http://24.253.241.231:xxxx         some IP's block port 80.  In your router you will  
          └────────────┤              need to configure it so that the port is forwarded.
                       │
                       This number can be found at some place like...
                       
   http://whatismyipaddress.com

   Note: The Above method gets you on the entire web, if you just want local network access to
         the Spinneret, then you don't need to use port forwarding, and you can use the static
         IP address instead.  You still need to specify the port (':xxxx') if it's something
         other than port 80.

   http://192.168.0.50:xxxx

   or (if using port 80)... 
 
   http://192.168.0.50        
                          
}    
OBJ
    DHCPClient    : "DHCP_GBSbuild_01_28_2011.spin"
    RTC           : "s-35390A_GBSbuild_01_23_2011"
    PST           : "Parallax Serial Terminal"
    SENSORS       : "kd_SensorArray"

VAR
    long  IP, SubnetMask, GatewayIP, DNS_Server ,destIP
    byte  MAC_Address[6], data[DHCPClient#BUFFER_SIZE]

VAR
    byte  ButtonSelected, formState, numsensor, index
    byte  sendEmail[80]
    byte  smtpServer[80]
    byte  phoneEmail[80]
    byte  Stringbuffer[100]
    byte  sensorState[6]
    byte  sensorStore[6]    
  
PUB main|i1,i2
    RTC.start                     'Initialize On board RTC
  ' RTC.SetDateTime(month, day, year, dayOfWeek, hour, minutes, seconds) '<- Just do this once to set time

    PST.start(115200)             'Initialize Parallax Serial Terminal

  ' Network Settings
    DHCPClient.IPs(@IP,192,168,0,50)                      ' IP ; a static address of the router
    DHCPClient.IPs(@SubnetMask,255,255,255,0)             ' SubnetMask ; see: www.subnet-calculator.com
    DHCPClient.IPs(@GatewayIP,192,168,0,1)                ' GatewayIP ; your local router's address
    DHCPClient.IPs(@DNS_Server,192,168,0,1)               ' DNS_Server ; usually same as Gateway
    DHCPClient.IPs(@destIP,0,0,0,0)                       ' Dest IP can be all zero's
    DHCPClient.MAC(@MAC_Address,$00,$08,$DC,$16,$F0,$13)  ' MAC address located on spinneret

  ' Initialize Wiznet 5100 chip 
    DHCPClient.Wiznet5100(socket, @MAC_Address, @GatewayIP, @SubnetMask, @IP, @destIP, listenPort)


    ButtonSelected :=1
    formState = 1
  'Start the sensor checking method which is an infinite loop, parameters are passed by value so they can be written\read to later
    cognew(SENSORS.threePinSensorArray, @numSensor, @sensorState)
    
  ' Infinite loop of the server ; listen on the TCP socket     
    repeat
      If formState ==1  'before starting sensor and status tests, request email server/address/number of sensors input
        if DHCPClient.HTMLReady(@data)==0                   'Is connection ready to send HTML?

         PST.Char(0)
         PST.str(@data)
         ParseDATA
         ButtonLOGIC
        
      '  Update dynamic HTML here
         bytemove(@dtime,RTC.FmtDateTime,strsize(RTC.FmtDateTime))

      '  Display HTML here
         DHCPClient.StringSend(socket, @htmlheader) 
         DHCPClient.StringSend(socket, @timestamp)         
         'Insert Form here to GET all email address/server information and the number of sensors attached.
         DHCPClient.StringSend(socket, @htmlfooter)
         set formState = 2

      else
         if DHCPClient.HTMLReady(@data)==0                   'Is connection ready to send HTML?

           PST.Char(0)
           PST.str(@data)
           ParseDATA
           ButtonLOGIC
        
        '  Update dynamic HTML here
          bytemove(@dtime,RTC.FmtDateTime,strsize(RTC.FmtDateTime))

        '  Display HTML here
           DHCPClient.StringSend(socket, @htmlheader) 
           DHCPClient.StringSend(socket, )         
           DHCPClient.StringSend(socket, )
           DHCPClient.StringSend(socket, @htmlfooter)
         index = 0
         repeat TO 5
           if sensorState[index] <>  sensorStore[index]
             SendEmail(25)
             sensorStore[index] = sensorState[index]
          index++
          'also display webpage here with information on sensor states
          'make button to allow user to change settings, change formState back to 1
        ' we don't support persistent connections, so disconnect here when done sending HTML     
      DHCPClient.NoPersistanceAllowed(socket)
         

PUB ButtonLOGIC
          byte[@dB1]:="4"             '<- Make font size for all buttons 4 (small)
          byte[@dB2]:="4"
          byte[@dB3]:="4"
          byte[@dB4]:="4"
          Case ButtonSelected
               1  : byte[@dB1]:="8"   '<- Make font size for selected button 8 (big)
               2  : byte[@dB2]:="8"
               3  : byte[@dB3]:="8"
               4  : byte[@dB4]:="8"

PUB ParseData
    if InStr(0,@data, string("GET /button_action?Left=")) <> -1  'Left
       ButtonSelected := ButtonSelected - 1 #> 1

    if InStr(0,@data, string("GET /button_action?Right=")) <> -1 'Right
       ButtonSelected := ButtonSelected + 1 <# 4
    
PUB {
      String Search: Compares two strings, if one string is located within the other
      string, the value returned is the starting position within the LONGEST string
      that the SHORTER string can be found.  If there is no match, the result is a
      -1. You may also specify a starting position within the longest string to begin
      a search.
       
    } InStr(Start,String1Address,String2Address)|size1,size2,i
      
      size1 := strsize(String1Address)
      size2 := strsize(String2Address)
      if size1<>0 and size2<>0            '<- Zero length string not allowed
         if size1 > size2
            repeat i from Start to size1-size2
              bytemove(@Stringbuffer,String1Address+i,size2)
              byte[@Stringbuffer][size2] := 0
              if strcomp(@Stringbuffer,String2Address)
                 return i 
         else
            repeat i from Start to size2-size1
              bytemove(@Stringbuffer,String2Address+i,size1)
              byte[@Stringbuffer][size1] := 0
              if strcomp(@Stringbuffer,String1Address)
                 return i               
      result := -1
PUB SendEmail(id) | st, size, wait
'taken from Mike, modified, not completely working
  wait := 200
  DHCPClient.SocketClose(id)
  pause(wait)
  DHCPClient.SocketOpen(id,)
  
  PST.str(string(13, "Connecting to mail server",13))
  'Socket.Connect(id)
  pause(wait)

  'repeat while !Socket.Connected(id)

  PST.str(string("Connected... Talking with mail server",13))
  StringSend(id, string("HELO "smtpServer, 13, 10))
  pause(wait)
  StringSend(id, string("MAIL FROM: <"+sendEmail+">", 13, 10))
  pause(wait)
  StringSend(id, string("RCPT TO: <"+phoneEmail+">", 13, 10))
  pause(wait)
  StringSend(id, string("RCPT TO: <"+sendEmail+">", 13, 10))
  pause(wait)
  StringSend(id, string("DATA", 13, 10))
  pause(wait)
  StringSend(id, string("SUBJECT: Intrusion Detected!", 13, 10))
  pause(wait)
  StringSend(id, string("!Warning! from the Spinneret!", 13, 10))
  pause(wait)
  StringSend(id, string("On "+RTC.GetDay+" of"+RTC.GetMonth+" AT "+RTC.GetHour+":"+RTC.GetMinute+":"+RTC.GetSecond, 13, 10))
  pause(wait)
  StringSend(id, string("Intrusion was detected at Sensor"+index, 13, 10))
  pause(wait)
  StringSend(id, string(".", 13, 10))
  pause(wait)
  StringSend(id, string("QUIT", 13, 10))
  pause(wait)
  pst.str(string("Done",13, 10))
  
  'repeat until size := Socket.rxTCP(id, @rxdata)
  'Socket.rxTCP(id, @rxdata)
  pst.str(@rxdata)

  'Reset the socket
  'Socket.Disconnect(id)
  'InitializeSocket(id)

PRI StringSend(_socket, _dataPtr)

  if byte[_dataPtr] <> 0
    ETHERNET.txTCP(_socket, _dataPtr, strsize(_dataPtr))
  return 'end of StringSend

DAT

'-----------------------------------------------
'Pseudo HTML code below ... some quirks, but relatively basic and straight forward.
'One thing in particular to notice is the modular approach you can take.   
'
'Note: Browsers also recognize single quotes in place of double quotes (makes code less messy) 

'--------------------------------------------------------------------------
htmlheader
        byte  "HTTP/1.1 200 OK", 13, 10
        byte  "You have connected to a Spinneret Web Server",13
        byte  "Connection: close",13
        byte  "Content-Type: text/html", 13, 10,13,10
        byte  "<HTML>"
        byte  "<HEAD>"

        byte  "<TITLE>KPD - Automated Home Security</TITLE>"
        byte  "</HEAD>"
        byte  "<BODY>",0

'--------------------------------------------------------------------------
timestamp
        byte  "<FONT FACE=ARIAL SIZE=8>"
dtime   byte  "--- --- --, --:--:-- --</FONT>",0
'--------------------------------------------------------------------------
htmlfooter
        byte  "</BODY>"
        byte  "</HTML>",0
'--------------------------------------------------------------------------
ButtonExample
        byte  "<FORM ACTION='button_action'method='get'>"
        byte  "<BR><FONT FACE=ARIAL SIZE=6>Dynamic HTML Button Example:</FONT>"
        byte  "<button type='submit' NAME='Left' style='background-color:YELLOW'><<</button>"
        
        'Notice the offset from 'SIZE=', the goal is to align the size value with the
        'corresponding label on the far left.  This allows for easy dynamic adjustments.
        byte             "<FONT FACE=ARIAL SIZE="
dB1     byte  "4> 1</FONT><FONT FACE=ARIAL SIZE="        
dB2     byte  "4> 2</FONT><FONT FACE=ARIAL SIZE="        
dB3     byte  "4> 3</FONT><FONT FACE=ARIAL SIZE="        
dB4     byte  "4> 4</FONT>"        
        byte  "<button type='submit' NAME='Right' style='background-color:YELLOW'>>></button>"
        byte  "</FORM>",0

OBJ
{{
┌───────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                                     │                                                            
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and  │
│associated documentation files (the "Software"), to deal in the Software without restriction,      │
│including without limitation the rights to use, copy, modify, merge, publish, distribute,          │
│sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is      │
│furnished to do so, subject to the following conditions:                                           │
│                                                                                                   │
│The above copyright notice and this permission notice shall be included in all copies or           │
│ substantial portions of the Software.                                                             │
│                                                                                                   │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT  │
│NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND             │
│NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,       │
│DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,                   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE        │
│SOFTWARE.                                                                                          │     
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
}} 