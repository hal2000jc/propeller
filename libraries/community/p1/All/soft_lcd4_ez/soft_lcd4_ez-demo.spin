{{ soft_lcd4ez-demo.spin
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ soft_lcd4_ez-demo                   │ BR             │ (C)2010             │  19July2010   │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│                                                                                            │
│ Demonstrates use of the ldc software emulation in tandem with a real LCD.                  │
│ Set lcd_base_pin constant to coincide with your hardware setup.                            │
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘

}}

CON
  _clkmode = xtal1 + pll16x 
  _xinfreq = 5_000_000
'hardware constants
  lcd_base_pin = 16

 
OBJ
   lcd  : "jm_lcd4_ez"                'the real 4-bit LCD driver
   slcd : "soft_lcd4_ez"              'wrapper to make PST look like jm_lcd4_ez
  
VAR
  byte cmd, out
  byte data[12]

  
PUB main|i,_month,_day,_year,_dow,_hour,_min,_sec,tmp

   waitcnt(clkfreq * 5 + cnt)                     ' wait 5 secs
   lcd.init(lcd_base_pin, 8, 2)                   ' initialize LCD, bl on P8
   slcd.init(lcd_base_pin, 8, 2)                  ' initialize soft LCD emulation

    repeat
      lcd.cmd(lcd#cls)
      lcd.str(string("soft lcd"))
      lcd.moveto(1,2)
      lcd.str(string("demo"))
      slcd.cmd(slcd#cls)
      slcd.str(string("soft lcd"))
      slcd.moveto(1,2)
      slcd.str(string("demo"))
      waitcnt(clkfreq*3+cnt)

      'lcd memory wrapping
      lcd.cmd(lcd#cls)
      lcd.str(string("lcd mem"))
      lcd.moveto(1,2)
      lcd.str(string("wrapping"))
      slcd.cmd(slcd#cls)
      slcd.str(string("lcd mem"))
      slcd.moveto(1,2)
      slcd.str(string("wrapping"))
      waitcnt(clkfreq*3+cnt)
      '                        1         2         3         4         5         6         7         8
      '               12345678901234567890123456789012345678901234567890123456789012345678901234567890
      lcd.str(string("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
      slcd.str(string("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
      waitcnt(clkfreq*3+cnt)

      'command cursor left
      lcd.cmd(lcd#cls)
      slcd.cmd(slcd#cls)
      lcd.str(string("cursor"))
      slcd.str(string("cursor"))
      lcd.moveto(1,2)
      slcd.moveto(1,2)
      lcd.str(string("left    "))
      slcd.str(string("left    "))
      lcd.cmd(lcd#CRSR_LF)
      slcd.cmd(slcd#CRSR_LF)
      lcd.out("1")
      slcd.out("1")
      waitcnt(clkfreq+cnt)
      lcd.cmd(lcd#CRSR_LF)
      slcd.cmd(slcd#CRSR_LF)
      lcd.out("2")
      slcd.out("2")
      waitcnt(clkfreq+cnt)
      lcd.cmd(lcd#CRSR_LF)
      slcd.cmd(slcd#CRSR_LF)
      lcd.out("3")
      slcd.out("3")
      waitcnt(clkfreq+cnt)
      lcd.cmd(lcd#CRSR_LF)
      slcd.cmd(slcd#CRSR_LF)
      lcd.out("4")
      slcd.out("4")
      waitcnt(clkfreq+cnt)

      'command cursor right
      lcd.cmd(lcd#cls)
      slcd.cmd(slcd#cls)
      lcd.str(string("cursor"))
      slcd.str(string("cursor"))
      lcd.moveto(1,2)
      slcd.moveto(1,2)
      lcd.str(string("right"))
      slcd.str(string("right"))
      lcd.moveto(1,2)
      slcd.moveto(1,2)
      waitcnt(clkfreq+cnt)
      repeat tmp from 1 to 4
        lcd.dec(tmp)
        slcd.dec(tmp)
        lcd.cmd(lcd#CRSR_RT)
        slcd.cmd(slcd#CRSR_RT)
        waitcnt(clkfreq+cnt)
      
      'lcd on/off
      lcd.cmd(lcd#cls)
      slcd.cmd(slcd#cls)
      lcd.str(string("lcd"))
      slcd.str(string("lcd"))
      lcd.moveto(1,2)
      slcd.moveto(1,2)
      lcd.str(string("on/off"))
      slcd.str(string("on/off"))
      waitcnt(clkfreq*2+cnt)
      repeat 4
        lcd.display(0)                      'one small enancement of softlcd... define constants: #0,off,on
        slcd.display(slcd#off)
        waitcnt(clkfreq/2+cnt)
        lcd.display(1)
        slcd.display(slcd#on)
        waitcnt(clkfreq/2+cnt)

      'shift display left/right
      lcd.cmd(lcd#cls)
      slcd.cmd(slcd#cls)
      lcd.str(string("left/right"))
      slcd.str(string("left/right"))
      waitcnt(clkfreq*2+cnt)
      repeat 2
        lcd.cmd(lcd#DISP_LF)
        slcd.cmd(lcd#DISP_LF)
        waitcnt(clkfreq/2+cnt)
        lcd.cmd(lcd#DISP_LF)
        slcd.cmd(lcd#DISP_LF)
        waitcnt(clkfreq/2+cnt)
        lcd.cmd(lcd#DISP_RT)
        slcd.cmd(lcd#DISP_RT)
        waitcnt(clkfreq/2+cnt)
        lcd.cmd(lcd#DISP_RT)
        slcd.cmd(lcd#DISP_RT)
        waitcnt(clkfreq/2+cnt)
      
      'print hex bin
      lcd.cmd(lcd#cls)
      slcd.cmd(slcd#cls)
      lcd.str(string("hex"))
      slcd.str(string("hex"))
      lcd.hex(17,2)
      slcd.hex(17,2)
      lcd.moveto(1,2)
      slcd.moveto(1,2)
      lcd.str(string("bin"))
      slcd.str(string("bin"))
      lcd.bin(17,5)
      slcd.bin(17,5)      
      waitcnt(clkfreq*2+cnt)
      
      'scroll demo
      lcd.cmd(lcd#cls)
      slcd.cmd(slcd#cls)
      lcd.str(string("scroll"))
      slcd.str(string("scroll"))
      lcd.moveto(1,2)
      slcd.moveto(1,2)
      lcd.scrollstr(1, 2, 8, 350, string("        Scroll line onto screen"))
      slcd.scrollstr(1, 2, 8, 350, string("        Scroll line onto screen"))
      waitcnt(clkfreq+cnt)

      'rt scroll demo
      lcd.cmd(lcd#cls)
      slcd.cmd(slcd#cls)
      lcd.str(string("scroll2"))
      slcd.str(string("scroll2"))
      lcd.moveto(1,2)
      slcd.moveto(1,2)
      lcd.rscrollstr(1, 2, 8, 350, string("Scroll line onto screen       "))
      slcd.rscrollstr(1, 2, 8, 350, string("Scroll line onto screen       "))
      waitcnt(clkfreq+cnt)

'      lcd.str(string("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZaabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz"))

DAT

{{

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                                       │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and    │
│associated documentation files (the "Software"), to deal in the Software without restriction,        │
│including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,│
│and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,│
│subject to the following conditions:                                                                 │
│                                                                                                     │                        │
│The above copyright notice and this permission notice shall be included in all copies or substantial │
│portions of the Software.                                                                            │
│                                                                                                     │                        │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT│
│LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  │
│IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION│
│WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}  