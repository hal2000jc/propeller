'Assembly parallel interface driver for uOLED-96-Prop
'Copyright (C) 2008 Raymond Allen.  See end of file for terms of use.


'Basically, a modified version of SPI Engine to shift in-out parallel data
{
                                ********************************************
                                                 SPI Engine             V1.1    
                                ********************************************
                                      coded by Beau Schwabe (Parallax)
                                ********************************************
Revision History:
         V1.0   - original program
         
         V1.1   - fixed problem with SHIFTOUT MSBFIRST option
                - fixed argument allocation in the SPI Engines main loop
}
CON
  #1,Write_cmd,Write_Word,Write_Byte,Write_Start,Write_Stop,Read_Word,Write_Bytes,Write_Words,Write_Bmp24

  '*------------------------------------------------------------------------*
'*  OLED Interface (PINS)                                                        *
'*------------------------------------------------------------------------*
  CS_OLED         =  8               ' OLED Chip Select Signal
  RESETPIN_OLED   =  9               ' OLED Reset Signal
  D_C             =  10              ' Data/Command
  WR_OLED         =  11              ' OLED Write Signal
  RD_OLED         =  12              ' OLED Read Signal
  CS_VHI          =  13              ' OLED VCC Enable
  
VAR
    long     cog, command, Flag

PUB start : okay
'' Start PPI Engine - starts a cog
'' returns false if no cog available
    stop
    Flag := 1
    okay := cog := cognew(@init, @command) + 1
PUB stop
'' Stop PPI Engine - frees a cog
    Flag := 0
    if cog
       cogstop(cog~ - 1)
    command~    
PUB setcommand(cmd, argptr)
    command := cmd << 16 + argptr                       'write command and pointer
    repeat while command                                'wait for command to be cleared, signifying receipt
'################################################################################################################
DAT           org
'  
' SPI Engine - main loop
'
init          mov       dira,diraoled
              or        outa, RD_mask1 
              or        outa, DC_mask1
              or        outa, WR_mask1
              or        outa, CS_mask1  
              
              
loop          rdlong  t1,par          wz                'wait for command
        if_z  jmp     #loop
              movd    :arg,#arg0                        'get 5 arguments ; arg0 to arg4
              mov     t2,t1                             '    │
              mov     t3,#5                             '───┘ 
:arg          rdlong  arg0,t2
              add     :arg,d0
              add     t2,#4
              djnz    t3,#:arg
              mov     address,t1                        'preserve address location for passing
                                                        'variables back to Spin language.
                                                        
              wrlong  zero,par                          'zero command to signify command received
              ror     t1,#16+2                          'lookup command address
              add     t1,#jumps
              movs    :table,t1
              rol     t1,#2
              shl     t1,#3
:table        mov     t2,0
              shr     t2,t1
              and     t2,#$FF
              jmp     t2                                'jump to command
jumps         byte    0                                 '0
              byte    WRITECMD_                         '1
              byte    WriteWord_                        '2
              byte    WriteByte_                          '3
              byte    WriteStart_               '4
              byte    WriteStop_                '5
              byte    ReadWord_                 '6
              byte    WriteBytes_               '7
              byte    WriteWords_               '8
              byte    WriteBmp24_                '9
NotUsed_      jmp     #loop
'################################################################################################################
WRITECMD_                                               'write command byte

  'OUTA[D_C] := 0
  'OUTA[CS_OLED] := 0
  'OUTA[WR_OLED] := 0
  'OUTA[7..0] := cmd.byte[0]                      ' pins 7:0 
  'OUTA[WR_OLED] := 1
  'OUTA[CS_OLED] := 1
  'OUTA[D_C] := 1


              
              and       outa, DC_mask0
              and       outa, CS_mask0
              and       outa, WR_mask0

              and       arg0, bytemask1
              and       outa, bytemask0
              or        outa, arg0
              
              or        outa, WR_mask1
              or        outa, CS_mask1
              or        outa, DC_mask1
              jmp       #loop

'################################################################################################################
WriteStart_                                               'set up from writing GRAM
  'OUTA[D_C] := 1
  'OUTA[CS_OLED] := 0
              or        outa, DC_mask1
              and       outa, CS_mask0
              jmp       #loop  


'################################################################################################################
WriteStop_                                               'stop from writing GRAM
'OUTA[CS_OLED] := 1          
             or        outa, CS_mask1
             jmp       #loop   

'################################################################################################################
WriteWord_                                               'write data word

  'OUTA[WR_OLED] := 0
  'OUTA[7..0] := wordData.byte[1]                 ' MSB
  'OUTA[WR_OLED] := 1
  'OUTA[WR_OLED] := 0
  'OUTA[7..0] := wordData.byte[0]                 ' LSB
  'OUTA[WR_OLED] := 1


              
              and       outa, WR_mask0
              
              mov       t1, arg0
              shr       t1,#8
              and       t1, bytemask1
              and       outa, bytemask0
              or        outa, t1              

              or        outa, WR_mask1

WriteByte_                 'just jump in the middle of WriteWord!

              and       outa, WR_mask0

              and       arg0, bytemask1
              and       outa, bytemask0
              or        outa, arg0
              
              or        outa, WR_mask1
              

              jmp       #loop              

'################################################################################################################
WriteBytes_                                               'write data bytes

              rdbyte    t1,arg0
              
              and       outa, WR_mask0
              and       outa, bytemask0 
              or        outa, t1              
              or        outa, WR_mask1
              add       arg0, #1
              djnz      arg1, #WriteBytes_
              jmp       #loop           

'################################################################################################################
WriteWords_                                               'write data words

              rdword    t1,arg0
              mov       t2,t1

              shr       t1,#8
              and       outa, WR_mask0
              and       outa, bytemask0 
              or        outa, t1              
              or        outa, WR_mask1

              and       outa, WR_mask0
              and       t2,bytemask1
              and       outa, bytemask0 
              or        outa, t2              
              or        outa, WR_mask1
              
              
              add       arg0, #2
              djnz      arg1, #WriteWords_
              jmp       #loop

'################################################################################################################
WriteBmp24_                                               'write 24-bit color pixels
              'get RGB data
              rdbyte    t3,arg0    'blue
              add       arg0,#1
              rdbyte    t2,arg0    'green                 
              add       arg0,#1
              rdbyte    t1,arg0    'red
              add       arg0,#1

              'convert to 16-bit
              'C := ((R >> 3)<<11)|((G >> 2)<<5)|(B >> 3)     ' Convert R,G,B to 16 bit color
              shr       t1,#3
              shl       t1,#11
              shr       t2,#2
              shl       t2,#5
              shr       t3,#3
              or        t1,t2
              or        t1,t3

              'now write word
              mov       t2,t1
              shr       t1,#8
              and       outa, WR_mask0
              and       outa, bytemask0 
              or        outa, t1              
              or        outa, WR_mask1
              and       outa, WR_mask0
              and       t2,bytemask1
              and       outa, bytemask0 
              or        outa, t2              
              or        outa, WR_mask1

              'repeat until done
              djnz      arg1, #WriteBmp24_
              jmp       #loop                  
'################################################################################################################
ReadWord_                                               'read data word      (LSB first)
  'note that a "dummy" read is required prior to getting real data...
  'DIRA := %00000000_00000000_00111111_00000000   ' Set Pins Direction 0 : Input, 1 : Output
  'OUTA[RD_OLED] := 0
  'wordData.byte[1]:=INA[7..0]                  ' MSB
  'OUTA[RD_OLED] := 1
  'OUTA[RD_OLED] := 0
  'wordData.byte[0]:=INA[7..0]                  ' LSB
  'OUTA[RD_OLED] := 1
  'DIRA := %00000000_00000000_00111111_11111111   ' Set Pins Direction 0 : Input, 1 : Output
              and       dira, bytemask0
              and       outa, RD_mask0
              mov       t1,ina
              and       t1,bytemask1              
              or        outa, RD_mask1
              and       outa, RD_mask0
              mov       t2,ina
              and       t2,bytemask1
              rol       t2,#8
              or        t1,t2
              or        outa, RD_mask1
              or        dira, bytemask1
              wrlong    t1, address
              
              jmp       #loop
              
              
               
                

'------------------------------------------------------------------------------------------------------------------------------
Done                                                    '     Shut COG down
              mov     t2,             #0                '          Preset temp variable to Zero
              mov     t1,             par               '          Read the address of the first perimeter
              add     t1,             #4                '          Add offset for the second perimeter ; The 'Flag' variable
              wrlong  t2,             t1                '          Reset the 'Flag' variable to Zero
              CogID   t1                                '          Read CogID
              COGSTOP t1                                '          Stop this Cog!
'------------------------------------------------------------------------------------------------------------------------------
{
########################### Defined data ###########################
}
CS_mask1       long 1<<8               ' OLED Chip Select Signal
CS_mask0      long %11111111_11111111_11111110_11111111
DC_mask1       long 1<<10              ' Data/Command
DC_mask0      long %11111111_11111111_11111011_11111111
WR_mask1       long 1<<11              ' OLED Write Signal
WR_mask0      long %11111111_11111111_11110111_11111111
RD_mask1       long 1<<12              ' OLED Read Signal
RD_mask0      long %11111111_11111111_11101111_11111111
bytemask1      long %00000000_00000000_00000000_11111111
bytemask0      long %11111111_11111111_11111111_00000000  
diraoled      long %00000000_00000000_00111111_11111111   ' long %00000000_00000000_00000000_11111111 ' long %00000000_00000000_00111111_11111111   '
  

zero                    long    0                       'constants
d0                      long    $200

{
########################### Undefined data ###########################
}
                                                        'temp variables
t1                      res     1                       '     Used for DataPin mask     and     COG shutdown 
t2                      res     1                       '     Used for CLockPin mask    and     COG shutdown
t3                      res     1                       '     Used to hold DataValue SHIFTIN/SHIFTOUT
t4                      res     1                       '     Used to hold # of Bits
t5                      res     1                       '     Used for temporary data mask
t6
address                 res     1                       '     Used to hold return address of first Argument passed

arg0                    res     1                       'arguments passed to/from high-level Spin
arg1                    res     1
arg2                    res     1
arg3                    res     1
arg4                    res     1


{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}