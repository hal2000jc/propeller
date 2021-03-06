{{
*****************************************
* Parallax Legacy Infrared Sensor v1.0  *
* 3/13/2011                             *
* Author: Nick Randal                   *
* Copyright (c) 2011 Nick Randal.       *
* See end of file for terms of use.     *
*****************************************
}}
con

  FREQ_IR       = 2_066_953
  CTRMODE       = 26
  SENSOR_A      = $FF00
  SENSOR_B      = $FF

  
var

  long stack[10], pulseDelay, pwmA, countA, pwmB, countB, detectDelay
  byte cog, lock, pinA, pinB, hitA, hitB, samples


{{ Initialize the cog to handle two legacy parallax infrared sensors. }}
pub Init(a, b, c, d)

  pinA := a
  pinB := b
  detectDelay := c #> 431
  samples := (d - 1) <# 7 #>  0                   ' samples must be between 1 and 8, then converted to 0 base
  pulseDelay := (clkfreq / 1000)                  ' 1ms delay between pulse and count
  
  lock := locknew
  cog := cognew(Run, @stack)

  result := (lock & $FF) << 8  |  (cog & $FF)


{{ Stop the cog and release resources }}
pub Stop

  cogstop(cog)
  lockret(lock)
  

{{ External call to check sensor detection values }}
pub Detect

  repeat until not lockset(lock)

  result := (hitA & $FF) << 8  |  hitB & $FF

  lockclr(lock)

  
{{ Run infrared detection loop }}
pri Run | s

  pwmA := %00100 << CTRMODE    | pinA             ' NCO/PWM
  countA := %01010 << CTRMODE    | pinA           ' POS Edge count

  pwmB := %00100 << CTRMODE    | pinB             ' NCO/PWM
  countB := %01010 << CTRMODE    | pinB           ' POS Edge count

  repeat
    repeat until not lockset(lock)                ' obtain the lock

    repeat s from 0 to samples                    ' user specified number of samples to take
      irDetectA(s)                                ' check sensor A
      irDetectB(s)                                ' check sensor B

    lockclr(lock)                                 ' release the lock

    waitcnt(detectDelay + cnt)


{{ Sample infrared sensor A using PWM and Count }}
pri irDetectA(sample)
 
  frqa := FREQ_IR
  phsa := 0                                       ' reset PWM phase
  ctra := pwmA                                    ' NCO/PWM
  dira[pinA]~~                                    ' make the pin an output
   
  waitcnt(pulseDelay + cnt)                            ' wait 1ms

  dira[pinA]~                                     ' make the pin an input
  frqa := 1
  ctra := countA                                  ' POS Edge count
  phsa := 0                                       ' reset counter

  waitcnt(pulseDelay + cnt)
  hitA := (phsa & 1) << sample


{{ Sample infrared sensor B using PWM and Count }}  
pri irDetectB(sample)
 
  frqb := FREQ_IR
  phsb := 0                                       ' reset PWM phase
  ctrb := pwmB                                    ' NCO/PWM
  dira[pinB]~~                                    ' make the pin an output
   
  waitcnt(pulseDelay + cnt)                            ' wait 1ms

  dira[pinB]~                                     ' make the pin an input
  frqb := 1
  ctrb := countB                                  ' POS Edge count
  phsb := 0                                       ' reset counter
 
  waitcnt(pulseDelay + cnt)
  hitB := (phsb & 1) << sample


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