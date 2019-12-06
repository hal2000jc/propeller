''****************************************''*  Debug_Lcd v1.2.1                    *''*  Authors: Jon Williams, Jeff Martin  *''*  Copyright (c) 2006 Parallax, Inc.   *''*  See end of file for terms of use.   *''****************************************'''' Debugging wrapper for Serial_Lcd object'''' v1.2 - March 26, 2008 - Updated by Jeff Martin to conform to Propeller object initialization standards.'' v1.1 - April 29, 2006 - Updated by Jon Williams for consistency.''CON  LCD_BKSPC     = $08                                   ' move cursor left  LCD_RT        = $09                                   ' move cursor right  LCD_LF        = $0A                                   ' move cursor down 1 line  LCD_CLS       = $0C                                   ' clear LCD (follow with 5 ms delay)  LCD_CR        = $0D                                   ' move pos 0 of next line  LCD_BL_ON     = $11                                   ' backlight on  LCD_BL_OFF    = $12                                   ' backlight off  LCD_OFF       = $15                                   ' LCD off  LCD_ON1       = $16                                   ' LCD on; cursor off, blink off  LCD_ON2       = $17                                   ' LCD on; cursor off, blink on  LCD_ON3       = $18                                   ' LCD on; cursor on, blink off  LCD_ON4       = $19                                   ' LCD on; cursor on, blink on  LCD_LINE0     = $80                                   ' move to line 1, column 0  LCD_LINE1     = $94                                   ' move to line 2, column 0  LCD_LINE2     = $A8                                   ' move to line 3, column 0  LCD_LINE3     = $BC                                   ' move to line 4, column 0OBJ  lcd : "serial_lcd"                                    ' driver for Parallax Serial LCD  num : "simple_numbers"                                ' number to string conversionPUB init(pin, baud, lines) : okay'' Initializes serial LCD object'' -- returns true if all parameters okay  okay := lcd.init(pin, baud, lines) PUB finalize'' Finalizes lcd object -- frees the pin (floats)  lcd.finalize  PUB putc(txbyte)'' Send a byte to the terminal  lcd.putc(txbyte)    PUB str(strAddr)'' Print a zero-terminated string  lcd.str(strAddr)PUB dec(value)'' Print a signed decimal number  lcd.str(num.dec(value))  PUB decf(value, width) '' Prints signed decimal value in space-padded, fixed-width field  lcd.str(num.decf(value, width))     PUB decx(value, digits) '' Prints zero-padded, signed-decimal string'' -- if value is negative, field width is digits+1  lcd.str(num.decx(value, digits)) PUB hex(value, digits)'' Print a hexadecimal number  lcd.str(num.hex(value, digits))PUB ihex(value, digits)'' Print an indicated hexadecimal number  lcd.str(num.ihex(value, digits))   PUB bin(value, digits)'' Print a binary number  lcd.str(num.bin(value, digits))PUB ibin(value, digits)'' Print an indicated (%) binary number  lcd.str(num.ibin(value, digits))         PUB cls'' Clears LCD and moves cursor to home (0, 0) position  lcd.cls PUB home'' Moves cursor to 0, 0  lcd.home  PUB gotoxy(col, line)'' Moves cursor to col/line  lcd.gotoxy(col, line)  PUB clrln(line)'' Clears line  lcd.clrln(line)PUB cursor(type)'' Selects cursor type''   0 : cursor off, blink off  ''   1 : cursor off, blink on   ''   2 : cursor on, blink off  ''   3 : cursor on, blink on  lcd.cursor(type)       PUB display(status)'' Controls display visibility; use display(false) to hide contents without clearing  if status    lcd.displayOn  else    lcd.displayOffPUB custom(char, chrDataAddr)'' Installs custom character map'' -- chrDataAddr is address of 8-byte character definition array  lcd.custom(char, chrDataAddr)      PUB backLight(status)'' Enable (true) or disable (false) LCD backlight'' -- affects only backlit models  lcd.backLight(status){{┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐│                                                   TERMS OF USE: MIT License                                                  │                                                            ├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ │files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ││modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software││is furnished to do so, subject to the following conditions:                                                                   ││                                                                                                                              ││The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.││                                                                                                                              ││THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ││WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ││COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ││ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘}}  