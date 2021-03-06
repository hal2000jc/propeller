' 6432 3mm Bi-color display Graphics driver... 0.1

' This is the small 64x32 Bi-color LED matrix from Sure Electronics.
' The Graphics routines were written with Brad's Spin tool on Ubuntu... ;-)

' Basic Graphics routines.

VAR

   long displayBitmap_ptr   ' Bitmap pointer

' The bitmap (64x32) is arranged with 8 bytes per row aligned on long.
' The upper 32 rows controls the Red LED's
' The lower 32 rows controls the Green LED's
' To get yellow, set both green and red at the same time... ;-)

   byte bigdigitoffset

   byte scrollmap[9*8]          ' Used to scroll bytes.
   byte scrollpos               ' Position in scroll
   byte scollbitpos             ' The bit position

   byte bitShift                ' Used for plot routine, need to be bytes
   byte shiftedBit              ' Used for plot routine, need to be bytes

PUB start(disp_ptr)

    ' Save variable.
    displayBitmap_ptr := disp_ptr

' Plot something
PUB plot(x, y, color) | baseAddress

    bitShift := x // 8
    shiftedBit := 128 >> bitShift
    baseAddress := displayBitmap_ptr + y*8 + x/8
    if (color & 1) ' Red ?
        byte[baseAddress] := byte[baseAddress] | shiftedBit
    if (color & 2) ' Green ?
        baseAddress := baseAddress + 256
        byte[baseAddress] := byte[baseAddress] | shiftedBit

' Or clear something
PUB unplot(x, y, color) | baseAddress

    bitShift := x // 8
    shiftedBit := 128 >> bitShift
    shiftedBit := shiftedBit ^ 255
    baseAddress := displayBitmap_ptr + y*8 + x/8

    if (color & 1) ' Red ?
        byte[baseAddress] := byte[baseAddress] & shiftedBit
    if (color & 2) ' Green ?
        baseAddress := baseAddress + 256
        byte[baseAddress] := byte[baseAddress] & shiftedBit

' Bresenham Line algorithm...
PUB line(x0, y0, x1, y1, color) | steep, deltax, deltay, error, ystep, x, y, temp_swap
     steep := ||(y1 - y0) - ||(x1 - x0)
     if (steep > 0)
         temp_swap := x0
         x0 := y0
         y0 := temp_swap
         temp_swap := x1
         x1 := y1
         y1 := temp_swap

     if (x0 > x1)
         temp_swap := x0
         x0 := x1
         x1 := temp_swap
         temp_swap := y0
         y0 := y1
         y1 := temp_swap

     deltax := x1 - x0
     deltay := ||(y1 - y0)
     error := deltax / 2
     y := y0
     if (y0 < y1)
       ystep := 1
     else
       ystep := -1
     repeat x from x0 to x1
         if (steep > 0)
           plot(y,x,color)
         else
           plot(x,y,color)

         error := error - deltay
         if (error < 0)
             y := y + ystep
             error := error + deltax

' Init the scroll stuff
PUB initScroll

    scrollpos := 0
    scollbitpos := 0
    setScrollBitmap

' Update scroll in memory.
PUB updateScroll | i, j

  scollbitpos := scollbitpos + 1
   if (scollbitpos == 8)
     scrollpos := scrollpos + 1
     scollbitpos := 0
     if (byte[@scrollText + 8 + scrollpos] == 0)
       scrollpos := 0
     setScrollBitmap
   else
     repeat i from 0 to 8
       repeat j from 0 to 7
         byte[@scrollmap + i + j*9] := byte[@scrollmap + i + j*9] << 1
         if (i < 8)
           if ((byte[@scrollmap + i + j*9 + 1] & 128) == 128)
             byte[@scrollmap + i + j*9] := byte[@scrollmap + i + j*9] + 1

' Print chars to bitmap.
PUB setScrollBitmap | i, j, char, baseAddress, charAddress

    repeat i from 0 to 8
        char := byte[@scrollText + i + scrollpos]

        if (char > 63) ' Translate to font position.
          char:= char - 64

        charAddress := @C64font + char*8
        baseAddress := @scrollmap + i

        repeat j from 0 to 7
          byte[baseAddress + j*9] := byte [charAddress + j]

' Copy scroll to bitmap
PUB showScroll | i, j

    repeat i from 0 to 7
      repeat j from 0 to 7
        byte[displayBitmap_ptr + j + i*8 + 192] := byte[@scrollmap + j + i*9]         ' Red
        byte[displayBitmap_ptr + j + i*8 + 192 + 256] := byte[@scrollmap + j + i*9]   ' Green

' Clear bitmap.
PUB clear_Display | i

  repeat i from 0 to 127
    long[displayBitmap_ptr][i] := 0

' Print a single char.
PUB print_char(row, col, char, color) | i, baseAddress, charAddress

  ' Calculate character offset
  charAddress := @C64font + char*8
  ' Calculate bitmap offset
  baseAddress := displayBitmap_ptr + col + row*8

  if (color & 1) ' Red color ?
    repeat i from 0 to 7
      byte[baseAddress + i*8 ] := byte [charAddress + i]

  if (color & 2) ' Green color ?
    baseAddress := baseAddress + 256
    repeat i from 0 to 7
      byte[baseAddress + i*8 ] := byte [charAddress + i]

' Print a whole string.
PUB print_string(row,col,daString, color) | i, daChar

    ' String loop
    repeat i from 0 to strSize(daString) - 1
      daChar:= byte[daString][i]
      if byte[daString][i] == 13
        row := row + 8
        next
      if byte[daString][i] == 10
        col:=0
        next
      if byte[daString][i] == 0
        abort

      if (daChar > 63) ' Translate to font position.
        daChar:= daChar - 64

      ' Print char and move on...
      print_char(row, col, daChar, color)
      col++

DAT

' Change this text to your own scroll text...
' Pad with 8 spaces at beginning and end.
' All text should be uppercase.
scrollText byte "        LETS SCROLL SOMETHING...        ", 0

' Yes, it's ripped from a C=64 ROM I had laying around...
C64font
        BYTE  %00111100  '0
        BYTE  %01100110
        BYTE  %01101110
        BYTE  %01101110
        BYTE  %01100000
        BYTE  %01100010
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00011000  '1
        BYTE  %00111100
        BYTE  %01100110
        BYTE  %01111110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %01111100  '2
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01111100
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01111100
        BYTE  %00000000
        BYTE  %00111100  '3
        BYTE  %01100110
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %01111000  '4
        BYTE  %01101100
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01101100
        BYTE  %01111000
        BYTE  %00000000
        BYTE  %01111110  '5
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01111000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %01111110  '6
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01111000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %00000000
        BYTE  %00111100  '7
        BYTE  %01100110
        BYTE  %01100000
        BYTE  %01101110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %01100110  '8
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01111110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %00111100  '9
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00011110  '10
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %01101100
        BYTE  %00111000
        BYTE  %00000000
        BYTE  %01100110  '11
        BYTE  %01101100
        BYTE  %01111000
        BYTE  %01110000
        BYTE  %01111000
        BYTE  %01101100
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %01100000  '12
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %01100011  '13
        BYTE  %01110111
        BYTE  %01111111
        BYTE  %01101011
        BYTE  %01100011
        BYTE  %01100011
        BYTE  %01100011
        BYTE  %00000000
        BYTE  %01100110  '14
        BYTE  %01110110
        BYTE  %01111110
        BYTE  %01111110
        BYTE  %01101110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %00111100  '15
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %01111100  '16
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01111100
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %01100000
        BYTE  %00000000
        BYTE  %00111100  '17
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00001110
        BYTE  %00000000
        BYTE  %01111100  '18
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01111100
        BYTE  %01111000
        BYTE  %01101100
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %00111100  '19
        BYTE  %01100110
        BYTE  %01100000
        BYTE  %00111100
        BYTE  %00000110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %01111110  '20
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %01100110  '21
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %01100110  '22
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %01100011  '23
        BYTE  %01100011
        BYTE  %01100011
        BYTE  %01101011
        BYTE  %01111111
        BYTE  %01110111
        BYTE  %01100011
        BYTE  %00000000
        BYTE  %01100110  '24
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00011000
        BYTE  %00111100
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %01100110  '25
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %01111110  '26
        BYTE  %00000110
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %01100000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %00111100  '27
        BYTE  %00110000
        BYTE  %00110000
        BYTE  %00110000
        BYTE  %00110000
        BYTE  %00110000
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00001100  '28
        BYTE  %00010010
        BYTE  %00110000
        BYTE  %01111100
        BYTE  %00110000
        BYTE  %01100010
        BYTE  %11111100
        BYTE  %00000000
        BYTE  %00111100  '29
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00000000  '30
        BYTE  %00011000
        BYTE  %00111100
        BYTE  %01111110
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00000000  '31
        BYTE  %00010000
        BYTE  %00110000
        BYTE  %01111111
        BYTE  %01111111
        BYTE  %00110000
        BYTE  %00010000
        BYTE  %00000000
        BYTE  %00000000  '32
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00011000  '33
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %01100110  '34
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %01100110  '35
        BYTE  %01100110
        BYTE  %11111111
        BYTE  %01100110
        BYTE  %11111111
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %00011000  '36
        BYTE  %00111110
        BYTE  %01100000
        BYTE  %00111100
        BYTE  %00000110
        BYTE  %01111100
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %01100010  '37
        BYTE  %01100110
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %01100110
        BYTE  %01000110
        BYTE  %00000000
        BYTE  %00111100  '38
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00111000
        BYTE  %01100111
        BYTE  %01100110
        BYTE  %00111111
        BYTE  %00000000
        BYTE  %00000110  '39
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00001100  '40
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %00110000
        BYTE  %00110000
        BYTE  %00011000
        BYTE  %00001100
        BYTE  %00000000
        BYTE  %00110000  '41
        BYTE  %00011000
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %00000000
        BYTE  %00000000  '42
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %11111111
        BYTE  %00111100
        BYTE  %01100110
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000  '43
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %01111110
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000  '44
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %00000000  '45
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000  '46
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00000000  '47
        BYTE  %00000011
        BYTE  %00000110
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %01100000
        BYTE  %00000000
        BYTE  %00111100  '48
        BYTE  %01100110
        BYTE  %01101110
        BYTE  %01110110
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00011000  '49
        BYTE  %00011000
        BYTE  %00111000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %00111100  '50
        BYTE  %01100110
        BYTE  %00000110
        BYTE  %00001100
        BYTE  %00110000
        BYTE  %01100000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %00111100  '51
        BYTE  %01100110
        BYTE  %00000110
        BYTE  %00011100
        BYTE  %00000110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00000110  '52
        BYTE  %00001110
        BYTE  %00011110
        BYTE  %01100110
        BYTE  %01111111
        BYTE  %00000110
        BYTE  %00000110
        BYTE  %00000000
        BYTE  %01111110  '53
        BYTE  %01100000
        BYTE  %01111100
        BYTE  %00000110
        BYTE  %00000110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00111100  '54
        BYTE  %01100110
        BYTE  %01100000
        BYTE  %01111100
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %01111110  '55
        BYTE  %01100110
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00111100  '56
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00111100  '57
        BYTE  %01100110
        BYTE  %01100110
        BYTE  %00111110
        BYTE  %00000110
        BYTE  %01100110
        BYTE  %00111100
        BYTE  %00000000
        BYTE  %00000000  '58
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000  '59
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %00001110  '60
        BYTE  %00011000
        BYTE  %00110000
        BYTE  %01100000
        BYTE  %00110000
        BYTE  %00011000
        BYTE  %00001110
        BYTE  %00000000
        BYTE  %00000000  '61
        BYTE  %00000000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %01111110
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %00000000
        BYTE  %01110000  '62
        BYTE  %00011000
        BYTE  %00001100
        BYTE  %00000110
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %01110000
        BYTE  %00000000
        BYTE  %00111100  '63
        BYTE  %01100110
        BYTE  %00000110
        BYTE  %00001100
        BYTE  %00011000
        BYTE  %00000000
        BYTE  %00011000
        BYTE  %00000000

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
