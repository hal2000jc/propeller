' Test X Band Motion Detector.bs2
' Test to see the number of cycles the X Band Motion Detector
' sends in respons to motion.

CON
   
  _clkmode = xtal1 + pll16x                  ' Crystal and PLL settings.
  _xinfreq = 5_000_000                       ' 5 MHz crystal x 16 = 80 MHz.

Baud115k       =     115200                  ' Baud rate
XbandEnPin     =     9                       ' Enable pin
XbandOutPin    =     8                       ' Output pin
HalfSecond     =     500                     ' ms in 1/2 s delay
MoveThreshld   =     2                       ' Motion threhold

OBJ

  pst   : "Parallax Serial Terminal"         ' Serial communication object
  xband : "X Band Motion Detector"           ' X Band Motion Detector object

PUB go | cycles                                  

  pst.Start(Baud115k)                        ' Parallax Serial Terminal  cog
  xband.Enable(XbandEnPin)                   ' Set optional enable pin
  xband.Out(XbandOutPin)                     ' Set output pin

  repeat 360                                 ' Main loop
  
    cycles := xband.GetCycles(HalfSecond)    ' Check X Band Motion Detector
    
      pst.Str(String(pst#HM, "cycles = "))   ' Display cycles
      pst.Dec(cycles)
      pst.Str(String(pst#CE, pst#NL))
      
    if xband.GetCycles(500) > MoveThreshld   ' Decide if motion & display
      pst.Str(String("Motion detected!"))    
    else
      pst.Str(String("Not detected.", pst#CE))
  
  pst.Str(String("Test done, motion detector disabled."))