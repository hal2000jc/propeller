''=============================================================================
'' @file     sensirion_integer_demo.spin
'' @target   Propeller with Sensirion SHT1x or SHT7x   (not SHT2x)
'' @author   Thomas Tracy Allen, EME Systems
'' Copyright (c) 2013 EME Systems LLC
'' See end of file for terms of use.
'' version 1.3
'' uses integer math to return values directly in degC*100 and %RH*10
'' and print to terminal screen
'' no floating point required
'' This is the most basic demo.
''=============================================================================


CON
  _clkmode = xtal1 + pll8x                '
  _xinfreq = 5_000_000

' pins for data and clock.
' Note sht1x and sht7x protocol is like i2c, but not exactly
' Assumes power = 3.3V
  DPIN = 3'13    ' needs pullup resistor
  CPIN = 5'14    ' best use pulldown resistor for reliable startup, ~100k okay.


OBJ
  pst : "parallax serial terminal"
  sht : "sensirion_integer"

PUB Demo
 sht.Init(DPIN, CPIN)
 pst.Start(9600)
 waitcnt(clkfreq/10+cnt)

 repeat
   pst.str(string(13,10,"degC: "))
   if (result := sht.ReadTemperature) == negx
     pst.str(string("NA"))                              ' read temperature and handle possible error (negx)
   else
     result /= 10                                       ' reduce from hundreths to tenths of a degree
     pst.dec(result/10)                                 ' temperature is in units of tenths of a degC
     pst.char(".")
     pst.dec(||result//10)
   pst.str(string("     %RH: "))
   if (result := sht.ReadHumidity) == negx              ' read RH and handle error by printing NA (not available)
     pst.str(string("NA"))
   else
     pst.dec(result/10)                                 ' %RH is in unit of tenths
     pst.char(".")
     pst.dec(||result//10)
   waitcnt(clkfreq+cnt)

' Always read temperature shortly before humidity!   RH temperature compensation depends on valid temperature reading.
' The routines return NEGX if the sensor times out, or if the readings are grossly out of range.
' Due to sensor tolerances, it is still possible to get readings <0 or >100 %RH.


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
