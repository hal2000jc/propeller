{{
  TCN75 (temperature sensor) and HP03 (temperature and pressure sensor) driver tests
        Tim Moore Aug 08
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000                                  'NOTE SPEED

OBJ 
                                                        '1 Cog here 
  uarts         : "pcFullDuplexSerial4FC"               '1 COG for 4 serial ports

  config        : "config"                              'no COG required

  i2cObject     : "basic_i2c_driver"                    '0 COG
  tem           : "tcn75Object"                         '0 COG
  hum           : "hp03Object"                          '0 COG
  i2cScan       : "i2cScan"                             '0 COG
  
VAR
  long i2cSCL, i2cSCL1
  
Pub Start | Temp, Pressure
  config.Init(@pininfo,@i2cinfo)

  waitcnt(clkfreq*3 + cnt)                              'delay for debugging
  
  i2cSCL := config.GetPin(CONFIG#I2C_SCL1)
  ' setup i2cObject
  i2cObject.Initialize(i2cSCL)

  i2cSCL1 := config.GetPin(CONFIG#I2C_SCL2)
  ' setup i2cObject
  i2cObject.Initialize(i2cSCL1)

  uarts.Init
  uarts.AddPort(0,config.GetPin(CONFIG#DEBUG_RX),config.GetPin(CONFIG#DEBUG_TX),{
}   UARTS#PINNOTUSED,UARTS#PINNOTUSED,UARTS#DEFAULTTHRESHOLD, {
}   UARTS#NOMODE,UARTS#BAUD115200)                      'Add debug port
  uarts.Start                                           'Start the ports
  
  uarts.str(0,string("TCN75/HP03 Test",13))

  'i2cScan will not detect A2D unless initialized and out of reset so do this before scanning i2c buses
  hum.Init(i2cSCL1,config.GetI2C(CONFIG#HP03_EEPROM),config.GetPin(CONFIG#HP03_MCLK),config.GetPin(CONFIG#HP03_XCLR))

  waitcnt(clkfreq/4 + cnt)

  'Scan main i2c bus
  i2cScan.i2cScan(i2cSCL)

  'Scan secondary i2c bus
  i2cScan.i2cScan(i2cSCL1)

  'start sensor going
  tem.Init(i2cSCL,config.GetI2C(CONFIG#TCN75_0))

  repeat
    'Temperature from TCN75
    tem.GetTemperature(i2cSCL,config.GetI2C(CONFIG#TCN75_0),@Temp)
    uarts.str(0,string("TCN75 Temp: "))
    uarts.dec(0,Temp/2)
    uarts.tx(0,".")
    if Temp&1
      uarts.tx(0,"5")
    else
      uarts.tx(0,"0")
    uarts.tx(0,13)

    'Temperature from HP03
    'repeat until result obtained
    repeat until hum.GetTemperature(i2cSCL1,config.GetI2C(CONFIG#HP03_AD),@Temp) == TRUE
    uarts.str(0,string("HP03 Temp: "))
    uarts.dec(0,Temp/10)
    uarts.tx(0,".")
    uarts.dec(0,Temp//10)
    uarts.tx(0,13)

    'Pressure from HP03
    'repeat until result obtained
    repeat until hum.GetPressure(i2cSCL1,config.GetI2C(CONFIG#HP03_AD),@Pressure) == TRUE
    uarts.str(0,string("HP03 Pressure: "))
    uarts.dec(0,Pressure/100)
    uarts.tx(0,".")
    uarts.decx(0,Pressure//100,2)
    uarts.tx(0,13)
    
    waitcnt(clkfreq+cnt)                                'loop 1 per sec
               
DAT
'pin configuration table for this project
pininfo       word CONFIG#I2C_SCL2              'pin 0
              word CONFIG#I2C_SDA2              'pin 1
              word CONFIG#HP03_XCLR             'pin 2
              word CONFIG#HP03_MCLK             'pin 3
              word CONFIG#NOT_USED              'pin 4
              word CONFIG#NOT_USED              'pin 5
              word CONFIG#NOT_USED              'pin 6
              word CONFIG#NOT_USED              'pin 7
              word CONFIG#NOT_USED              'pin 8
              word CONFIG#NOT_USED              'pin 9
              word CONFIG#NOT_USED              'pin 10
              word CONFIG#NOT_USED              'pin 11
              word CONFIG#NOT_USED              'pin 12
              word CONFIG#NOT_USED              'pin 13
              word CONFIG#NOT_USED              'pin 14
              word CONFIG#NOT_USED              'pin 15
              word CONFIG#NOT_USED              'pin 16
              word CONFIG#NOT_USED              'pin 17
              word CONFIG#NOT_USED              'pin 18
              word CONFIG#NOT_USED              'pin 19
              word CONFIG#NOT_USED              'pin 20
              word CONFIG#NOT_USED              'pin 21
              word CONFIG#NOT_USED              'pin 22
              word CONFIG#NOT_USED              'pin 23
              word CONFIG#NOT_USED              'pin 24
              word CONFIG#NOT_USED              'pin 25
              word CONFIG#NOT_USED              'pin 26
              word CONFIG#NOT_USED              'pin 27
              word CONFIG#I2C_SCL1              'pin 28 - I2C - eeprom, sensors, rtc, fpu
              word CONFIG#I2C_SDA1              'pin 29
              word CONFIG#DEBUG_TX              'pin 30
              word CONFIG#DEBUG_RX              'pin 31

i2cinfo       byte CONFIG#TCN75_0               'TCN7 temp sensor
              byte %1001_0000
              byte CONFIG#HP03_AD               'on i2cSCL2
              byte %1110_1110
              byte CONFIG#HP03_EEPROM           'on i2cSCL2
              byte %1010_0000
              byte CONFIG#NOT_USED
              byte CONFIG#NOT_USED
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