'' Timer Countdown Demo
'' -- Jon Williams, Parallax (This version modified by Jagrifen)
'' -- 06 APR 2006 (Modified 23 Nov 2010)


CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000
  

OBJ

  lcd   : "serial_lcd"
  timer : "timer_Plus_countdown"

  
PUB main | Minutes, seconds

  if lcd.init(1, 19_200, 4)                            ' 4x20 Parallax LCD on A0, set to 19.2k
    lcd.cursor(0)                                       ' no cursor
    lcd.cls
    lcd.backlight(1)                                    ' backlight on
    lcd.str(string("TIMER"))

   if timer.start_down                                      ' start timer cog
      timer.set(0,1,5)
      timer.run        
      repeat
        lcd.gotoxy(0, 1)                                ' move to col 0 on line 1
        lcd.str(timer.showTimer)
   else
      lcd.cls
      lcd.str(string("No cog for Timer."))
      
{
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
}