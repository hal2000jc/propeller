{{                       Sure Echo Demo (B Board)
               This board receives a packet and retransmits it

                Sure Electronics GP-GC010v1 433Mhz Transceiver test program
                          Circuit board is labeled CY2196R
                       Author: Ray Tracy  (ray0665 on the forums)
                             Copyright (c) 2010 Ray Tracy
                        * See end of file for terms of use. *

                   ┌─────────────────────────────────────────────────┐
                   │              433Mhz Transceiver                 └─┐
                   │     Sure Electronics GP-GC010v1 / CY2196R       ┌─┘ Antenna
                   │                                                 │
                   │  1   2   3   4   5   6   7   8                  │
            +3.3V  │ VDD GND DRx DTx Ena Rts Cts Frq                 │
                  └──┬───┬───┬───┬───┬───┬───┬───┬──────────────────┘
               │      │   │   │   │   │   │   │   │          1K
               └──────┘   │   │   │   │   │   └───┴───────────── VDD
                          │   │   │   │   │
                          │   │   │   │   └───────────────── Ready to Send
                             │   │   
                              │   │
                              │   └───────────────────────── to Prop (RxPin)
                              │
                              └───────────────────────────── From Prop (TxPin)

     Note: #1 Tx from the Prop goes to DRx on the module
              Rx from the Prop goes to DTx on the module.
           #2 VDD = +3.3v

  Both a sender and a receiver are included here. To use this package you will need two propeller
  boards and two CY2196R transceiver boards. Then Build the above circuit (one per board) and
  change the pin assignments to match your configuration. In my case I used a Parallax Demo board
  and a SpinStudio board, but any two propeller boards will work just fine.
  I was able to receive indoors about 60 feet through six walls which was the two furthest points
  I could find indoors.  I have not tested outdoor performance.

  Revision History
  01/31/2011  V2.00 Initial release
  02/01/2011  V2.01 Added getch to provide timeout on receive
  02/12/2011  V2.1  Convertion to use FourPortSerial

}}
CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  Clock         = 80_000_000          '_CLKFREQ
  ms20          = Clock / 50

' ======<< Ascii control Characters >>=====
   soh = %00000001   '01, $01, %00000001
   stx = %00000010   '02, $02, %00000010
   etx = %00000011   '03, $03, %00000011
   eot = %00000100   '04, $04, %00000100
   ack = %00000110   '06, $06, %00000110
   nak = %00010101   '21, $15, %00010101
   syn = %00010110   '22, $16, %00010110

' =====<< Board A Pin Assignments >>=====  SpinStudio Board
  ATxPin   = 8
  ARxPin   = 9
  ARtsPin  = 10

' =====<< Board B Pin Assignments >>=====  Parallax Demo Board
  BTxPin   = 7
  BRxPin   = 6
  BRtsPin  = 5

'=====<< Misc constants >>=====
  MaxPacketSize  = 64    'including <soh><stx><count> and <cksum>
  MaxData        = 60
  TimeOutMs      = 10_000
  PstBaud        = 115200
  SureBaud       = 19200
  #0,Sure,Term

OBJ
  Ser:  "FourPortSerial"        '4 serial ports 1 cog
  Led:  "MyLed1"                'Leds are just for activity indication

VAR
  long KeepAlive
  byte cog, Packet[MaxPacketSize]

PUB Start |  i, Count     '##### THIS IS CONFIGURED FOR THE DEMO BOARD #####
'' Receive a Packet of data and retransmit that packet light leds to indicate progress
   i := 0
   Led.Start
   ser.Init
   ser.AddPort(Term, 31, 30,-1,-1,0, 0,PstBaud)              'Port,Rx,Tx,Cts,Rts,Threshold,Mode,Baud
   ser.AddPort(Sure, BRxPin, BTxPin,-1,-1,0, 0,SureBaud)
   ser.Start
   Repeat
      KeepAlive := TimeOutMs                ' reset KeepAlive
      Led.ShowByte(%00000001)               ' Flash some lights to show activity
      if Count:=\ReceivePacket              ' get a packet
' ### Remove the next line after testing ######
         Packet[0] := i++//26+$41
         Led.ShowByte(%00011000)            ' Flash lights to show activity
         SendPacket(BRtsPin, Count)         ' Retransmit the Packet
      else
         Led.ShowByte(%11000000)            'Arrive here if abort or error
         Waitcnt(ms20+cnt)                  'Allow time to see led flash


{{ ------------------------------------------------------------------------------
    Sender -- Sends a block of bytes
     Each block begins with <soh> and <stx> a <count> followed by the data (1 to 60)
     bytes and the <checksum>. There are no restrictions on the contents of the data.
     The checksum is the mod 256 sum of the data not including soh,stx,count or cksum
     <soh><stx> :: Start of Packet
     <count>    :: Number of data bytes (60 Maximum)
     <cksum>    :: Sum(data bytes) mod 256
     Packet     :: <soh><stx><count> data <cksum>
 --------------------------------------------------------------------------------}}
Pri SendPacket(Rts, Count) | cksum, i, Char   ' This code runs in the just launched cog
   i := 0
   waitpeq(|<Rts, |<Rts, 0)      ' Wait for rts
   Ser.Tx(Sure,soh)              ' Send soh
   Ser.Tx(Sure,stx)              ' Send stx, these two characters mark the start of the packet
   Ser.Tx(Sure,Count)            ' Send the data count
   cksum := 0                    ' Clear the checksum
   repeat Count                  ' Send count bytes (60 max)
      cksum += Packet[i]         ' Compute CheckSum
      Ser.Tx(Sure,Packet[i++])   ' Send 1 byte to transceiver
   Ser.Tx(Sure,cksum//256)       ' Send the checksum mod 256


{{ ------------------------------------------------------------------------------------------
 Receiver   Receives a Packet of data formatted as described for the Sender above.
       As implemented here the receiver receives a variable number of bytes.
       It first waits for the <soh><stx> pair. The data count is the first byte received
       after the <soh><stx> pair.  It then receives count bytes and computes a running
       checksum of the received data.  After all data is received it compares the
       checksum against the one sent by the sender and returns the data count (True, Good
       Packet) or zero (False, Bad Packet)
----------------------------------------------------------------------------------------------}}
Pri ReceivePacket | i, Count, cksum, Char
   i := cksum := 0
   cksum := 0
   repeat until ((getch==soh) and (getch==stx))
   Count := getch                 ' Get Count
   repeat Count
      Packet[I] := getch          ' Fetch a byte from the transceiver
      cksum += Packet[i++]        ' Calculate running CheckSum
   Char := getch                  ' Receive the checksum
   cksum //= 256                  ' Finish the checksum calculation
   ifnot (cksum == Char)
      return 0
   return Count

{{ -------------------------------------------------------------------------
Getch:  Get character with timeout. This waits 1ms for a character to be received on
   the serial interface. If no character is returned it decrements a timeout counter
   and starts the wait again. If the timeout counter reaches zero it aborts all
   operations and returns to the top level where the entire cycle restarts.
--------------------------------------------------------------------------- }}
Pri getch | Ch                   '
   repeat
      if (--KeepAlive==0)            ' Decrement Timeout Counter
         abort                       ' Oh Oh, We are hung up, so bail out
      Ch := Ser.RxTime(Sure,1)       ' Wait 1ms for a new byte
   while (Ch == -1)                  ' If byte not received repeat the loop
   return Ch                         ' Return the byte just received

{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}