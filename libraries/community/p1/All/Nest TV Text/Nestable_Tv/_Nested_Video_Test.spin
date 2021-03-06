{ File: _Nested_Video_Test.spin        This is Nested program used to demo the TV nested program
                               by Mike Lord
                             
' this is a re-write of the TV text object as shown below. This re-write 2010-07 by Mike Lord is intended to make the
' program nestable - meaning that it can work from more than just one object
'

 } 
                      

CON

  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x

  LCDPin    = 6                ' this is the default location for the LCD or TV display

  


Obj
       text        :  "Mirror_TV_Text"    



PUB NestedProg

      Text.out($0C)       'this is the set color command -- the next ascii char is the color
      text.out($05)

      text.str(string("After branch to sub program"))
      text.out($0D)
      text.out($0D)
      waitcnt(clkfreq * 1 + cnt)
  


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



                             