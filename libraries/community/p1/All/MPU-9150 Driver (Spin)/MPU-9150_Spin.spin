CON
{
  *******************************************
  * MPU-9150_Spin_Full                      *
  * by: Zack Lantz                          *
  *******************************************    
           
  7,189 Longs Free Basic,  5,605 Free Full,  8,185 Max  ("Pub Start" Only)

  5,605 / 8,185 = 0.68478924862553451435552840562004 = 65% of Total EEPROM Free = 35% Usage    <This File>
  7,189 / 8,185 = 0.87941356139279169211973121563836 = 88% of Total EEPROM Free = 12% Usage    <This File>
           
  Notes:   This driver's size is from FloatMath, FloatString, and FME.  I do not know
           PASM, nor am I a master at bit shifting.  I am sure there is a smaller and faster
           method for this.  If I ever find one I will update this immediately.

           Returns:  Raw Values, Zero-Offset Raw, and G-Force / Degrees per Second / uT
           
           This is a work in progress.  If you would like to contribute, please email me your suggestions
           at (zLantz at gmail dot com).  Advanced features currently not supported
           will be added in future releases to include:

           BMP-085 / BMP-180 Aux Driver via the MPU's i2c.
           MPU Master / Bypass Support.       <Currently only Bypass i2c is supported>
           Digital Motion Processor Support
           FIFO Control (Read / Write)
           Self Test Mode

           Lower-Level Math (Removal of FloatMath, FloatString, and FME)
           
           PASM Version
}
  
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq               ' system freq as a constant
  MS_001   = CLK_FREQ / 1_000                                   ' ticks in 1ms
  US_001   = CLK_FREQ / 1_000_000                               ' ticks in 1us

  
' // AK8975 Register Map
{
  Name    Address   READ/WRITE    Description     Bit width    Explanation
  WIA      00H        READ        Device ID          8
  INFO     01H        READ        Information        8
  ST1      02H        READ        Status 1           8         Data status
  HXL      03H        READ        Measurement data   8         X-axis data         
  HXH      04H        READ        Measurement data   8         X-axis data
  HYL      05H        READ        Measurement data   8         Y-axis data
  HYH      06H        READ        Measurement data   8         Y-axis data
  HZL      07H        READ        Measurement data   8         Z-axis data
  HZH      08H        READ        Measurement data   8         Z-axis data
  ST2      09H        READ        Status 2           8         Data status
  CNTL     0AH      READ/WRITE    Control            8
  RSV      0BH      READ/WRITE    Reserved           8         DO NOT ACCESS
  ASTC     0CH      READ/WRITE    Self-test          8
  TS1      0DH      READ/WRITE    Test 1             8         DO NOT ACCESS
  TS2      0EH      READ/WRITE    Test 2             8         DO NOT ACCESS
  I2CDIS   0FH      READ/WRITE    I2C disable        8
  ASAX     10H        READ        X-axis sensitivity adjustment value   8    Fuse ROM
  ASAY     11H        READ        Y-axis sensitivity adjustment value   8    Fuse ROM
  ASAZ     12H        READ        Z-axis sensitivity adjustment value   8    Fuse ROM 
}


' // MPU-6050 Register Map
Con         
   
  Self_Test_X     = $0D  ' 13
  Self_Test_Y     = $0E  ' 14
  Self_Test_Z     = $0F  ' 15
  Self_Test_A     = $10  ' 15
   
  SMPLRT_Div      = $19  ' 25
  Config          = $1A  ' 26
  Gyro_Config     = $1B  ' 27
  Accel_Config    = $1C  ' 28
   
  Mot_Thr         = $1F  ' 31
   
  FIFO_En         = $23  ' 35
   
  I2C_Mst_Ctrl    = $24  ' 36
  I2C_Slv0_Addr   = $25  ' 37
  I2C_Slv0_Reg    = $26  ' 38
  I2C_Slv0_Ctrl   = $27  ' 39
   
  I2C_Slv1_Addr   = $28  ' 40
  I2C_Slv1_Reg    = $29  ' 41
  I2C_Slv1_Ctrl   = $2A  ' 42
   
  I2C_Slv2_Addr   = $2B  ' 43
  I2C_Slv2_Reg    = $2C  ' 44
  I2C_Slv2_Ctrl   = $2D  ' 45
   
  I2C_Slv3_Addr   = $2E  ' 46
  I2C_Slv3_Reg    = $2F  ' 47
  I2C_Slv3_Ctrl   = $30  ' 48
   
  I2C_Slv4_Addr   = $31  ' 49
  I2C_Slv4_Reg    = $32  ' 50
  I2C_Slv4_Do     = $33  ' 51
  I2C_Slv4_Ctrl   = $34  ' 52
  I2C_Slv4_Di     = $35  ' 53
   
  I2C_Mst_Status  = $36  ' 54
   
  INT_Pin_Cfg     = $37  ' 55
  INT_Enable      = $38  ' 56
  INT_Status      = $3A  ' 58
   
  Accel_XOut_H    = $3B  ' 59
  Accel_XOut_L    = $3C  ' 60
  Accel_YOut_H    = $3D  ' 61
  Accel_YOut_L    = $3E  ' 62
  Accel_ZOut_H    = $3F  ' 63
  Accel_ZOut_L    = $40  ' 64
   
  Temp_Out_H      = $41  ' 65
  Temp_Out_L      = $42  ' 66
   
  Gyro_XOut_H    = $43  ' 67
  Gyro_XOut_L    = $44  ' 68
  Gyro_YOut_H    = $45  ' 69
  Gyro_YOut_L    = $46  ' 70
  Gyro_ZOut_H    = $47  ' 71
  Gyro_ZOut_L    = $48  ' 72
   
  Ext_Sens_Data_00  = $49 ' 73
  Ext_Sens_Data_01  = $4A ' 74
  Ext_Sens_Data_02  = $4B ' 75
  Ext_Sens_Data_03  = $4C ' 76
  Ext_Sens_Data_04  = $4D ' 77
  Ext_Sens_Data_05  = $4E ' 78
  Ext_Sens_Data_06  = $4F ' 79
  Ext_Sens_Data_07  = $50 ' 80
  Ext_Sens_Data_08  = $51 ' 81
  Ext_Sens_Data_09  = $52 ' 82
  Ext_Sens_Data_10  = $53 ' 83
  Ext_Sens_Data_11  = $54 ' 84
  Ext_Sens_Data_12  = $55 ' 85
  Ext_Sens_Data_13  = $56 ' 86
  Ext_Sens_Data_14  = $57 ' 87
  Ext_Sens_Data_15  = $58 ' 88
  Ext_Sens_Data_16  = $59 ' 89
  Ext_Sens_Data_17  = $5A ' 90
  Ext_Sens_Data_18  = $5B ' 91
  Ext_Sens_Data_19  = $5C ' 92
  Ext_Sens_Data_20  = $5D ' 93
  Ext_Sens_Data_21  = $5E ' 94
  Ext_Sens_Data_22  = $5F ' 95
  Ext_Sens_Data_23  = $60 ' 96
   
  I2C_Slv0_Do       = $63 ' 99
  I2C_Slv1_Do       = $64 ' 100
  I2C_Slv2_Do       = $65 ' 101
  I2C_Slv3_Do       = $66 ' 102
   
  I2C_Mst_Delay_Ctrl  = $67 ' 103
  Signal_Path_Reset   = $68 ' 104
  Mot_Detect_Ctrl     = $69 ' 105
   
  User_Ctrl         = $6A ' 106
   
  PWR_MGMT_1        = $6B ' 107
  PWR_MGMT_2        = $6C ' 108
   
  FIFO_CountH       = $72 ' 114
  FIFO_CountL       = $73 ' 115
  FIFO_R_W          = $74 ' 116
   
  WHO_AM_I          = $75 ' 117
   
   
  ' // *** Reset Value is 0x00 for all registers other than:
  ' //     Register 107: 0x40  (PWR_MGMT_1)
  ' //     Register 117: 0x68  (WHO_AM_I)
   
   

' // This _Spin_ Con's
Con


  ' // MPU-6050 Accelerometer Divisor
  AFS0 = 16384.0    '  +/- 2  G
  AFS1 = 8192.0     '  +/- 4  G
  AFS2 = 4096.0     '  +/- 8  G
  AFS3 = 2048.0     '  +/- 16 G

  mAFS0 = 0
  mAFS1 = 1
  mAFS2 = 2
  mAFS3 = 3

  ' // MPU-6050 Gyro Divisor
  FS0  = 16.0       '  +/- 250  °/S
  FS1  = 131.0      '  +/- 500  °/S
  FS2  = 32.8       '  +/- 1000 °/S
  FS3  = 16.4       '  +/- 2000 °/S

  mFS0 = 0
  mFS1 = 1
  mFS2 = 2
  mFS3 = 3

  ' // Digital Low Pass Filter Settings
  DLP0 = 0          ' Bandwidth = 260 Hz
  DLP1 = 1          ' Bandwidth = 184 Hz
  DLP2 = 2          ' Bandwidth = 94  Hz
  DLP3 = 3          ' Bandwidth = 44  Hz
  DLP4 = 4          ' Bandwidth = 21  Hz
  DLP5 = 5          ' Bandwidth = 10  Hz
  DLP6 = 6          ' Bandwidth = 5   Hz
  DLP7 = 7          ' Reserved

  ' // MPU-9150 Magnetometer Divisor   (uT / LSB)
  mMIN = 0.285
  mTYP = 0.3
  mMAX = 0.315

  ' // Current Settings:
  cAccelFS = AFS2
  cGyroFS  = FS0 'FS2
  cMagFS   = mMIN                

  mAFS    = mAFS2
  mFS     = mFS0 'mFS2
  mDLP    = DLP3

  ' // Comp Filter to 16-Bit Value
  Multiplier = 4.096

  ' // Pitch & Roll Calculations
  Alpha = 0.3       ' Low Pass Filter Sensitivity  
  

  I2C_SDA = 10
  I2C_SCL = 11
  
  AddressW = %1101_0000         ' MPU-6050/9150 Write Address
  AddressR = %1101_0001         ' MPU-6050/9150 Read Address
                  
  MagAddrW  = %00011000         ' AK8975 Write Address $0C, $0D, $0E
  MagAddrR  = %00011001         ' AK8975 Read Address  $0C, $0D, $0E  
    
   
Obj
  ser : "FullDuplexSerial"

  ' // Driver Space Comes from Here:  
  f   : "FloatMath"
  fS  : "FloatString"                  
  fm  : "FME"                         

  
VAR
  ' // Cog Storage
  long Cog, Stack[32]

  ' // I2C Storage
  long i2csda, i2cscl, Ready

  ' // Zero Calibration, Measurement Data, and Status Storage
  long x0, y0, z0, a0, b0, c0, d0, e0, f0, t, drift 
  long cID, Temp, aX, aY, aZ, gX, gY, gZ, mX, mY, mZ
  long E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12  
  long FIFOcnt, FIFOrw, mID, mInfo, mStatus, PT_En, MM_En, FIFO_Enable, Verify_Registers

  ' // Calculated Angles
  long aPitch, aRoll, aHdg, Gyro[3], Accel[3], Mag[3]
  
  ' // Low-Pass Filter
  long fXa, fYa, fZa, fXg, fYg, fZg, fXm, fYm, fZm
  
  ' // MPU-6050 User Set Init Settings
  long GyroFS, AccelFS, PowerMgmt, SampleRate, DLP              

  ' // Verified Register Storage
  long vPWR, vSMP, vDLPF, vGyro, vAccel, vMM, vPT

  ' // Tilt Compensated Mag
  long CMx, CMy
  
  
Pub TestMPU | MPUcog, pXYZ    

  ser.start(31, 30, 0, 115200)

  MM_En := 0                    ' // Master Mode Enable  0 = Off, 1 = On
  'FIFO_Enable := 0              ' // Use FIFO Enabled / Disabled     (Currently Disabled)
  Verify_Registers := 0         ' // Display Config Registers 

  pXYZ := 0                     ' // Plot X, Y, Z in CSV
  
  ser.str(string("Starting..."))

  i2csda := I2C_SDA
  i2cscl := I2C_SCL

  MPUcog := StartX( I2C_SCL, I2C_SDA, 1 )
        
  repeat
    {
    ser.tx(13)
    ser.str(string("Chip ID: 0x"))
    ser.hex(cID, 2)
    ser.str(string("   "))       
    }
    if pXYZ == 0
    ' // Temperature
      ser.dec(Temp)                                                                                          
      ser.str(string(", "))
      ser.dec(GetTempC)                                                                                          
      ser.str(string(", "))
      ser.dec(GetTempF)        
      ser.str(string("   "))
       
      ' // Pitch & Roll Angles
      ser.str(fs.floattostring(GetPitch))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(GetRoll))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(GetHeading))
      ser.str(string("   "))
       
      ' // Update Accel[#], Gyro[#], and Mag[#]
      UpdateForceVals             
       
      ' // G-Force, Degrees per Second, and Mag uT
      ser.str(fs.floattostring(Accel[0]))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(Accel[1]))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(Accel[2]))
      ser.str(string("   "))
          
      ser.str(fs.floattostring(Gyro[0]))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(Gyro[1]))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(Gyro[2]))
      ser.str(string("   "))
       
      ser.str(fs.floattostring(Mag[0]))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(Mag[1]))                                                                                          
      ser.str(string(", "))
      ser.str(fs.floattostring(Mag[2]))
      ser.str(string("   "))
       
      ' // Verify Registers Wrote Correctly  
      if Verify_Registers == 1
        ser.tx(13)
        ser.str(string("MPU Config: "))
        ser.bin(vPWR, 8)            ' %00000001
        ser.str(string(", "))
        ser.bin(vSMP, 8)            ' %00000001
        ser.str(string(", "))
        ser.bin(vDLPF, 8)           ' %00000011
        ser.str(string(", "))    
        ser.bin(vGyro, 8)           ' %00011000
        ser.str(string(", "))              
        ser.bin(vAccel, 8)          ' %00011000
        ser.str(string(", "))     
        ser.bin(vMM, 8)             ' %00000000
        ser.str(string(", "))
        ser.bin(vPT ,8)             ' %00000000
        ser.tx(13)       
       
      ser.tx(13)

    elseif pXYZ == 1

      UpdateForceVals

      ' // *** Mag needs to have High End Noise Filtered Off
      
      ser.str(fs.floattostring(Mag[0]))                                                                                          
      ser.str(string(",   "))
      ser.str(fs.floattostring(Mag[1]))                                                                                          
      ser.str(string(",   "))
      ser.str(fs.floattostring(Mag[2]))
      ser.str(string(",   "))
      ser.str(fs.floattostring(GetHeading))
      ser.str(string(",   "))
      ser.str(fs.floattostring(CMx))                                                                                          
      ser.str(string(",   "))
      ser.str(fs.floattostring(CMy))                                                                                          
      ser.str(string(",   "))
      ser.str(fs.floattostring(aPitch))                                                                                          
      ser.str(string(",   "))
      ser.str(fs.floattostring(aRoll))                                                                                          

      ser.tx(13)
            
' // Currently Disabled
{
    ' // External Sensor Output - Master Mode i2c
    if MM_En == 1
      ' // *** Master Mode External Sensor:
      ' // Set Slave 0 Address
      ' // Set Slave 0 Register
      ' // Set Slave 0 Control  Bytes Read = 2
      ' // Slave0_Do = Data To Slave
      ' // Slave0_Di = Data From Slave
          
      ' // External Sensor Data     *** Currently Set to Read 2 Bytes at a time (24/2=12)
      ' //                          *** May need to update Read Function to match desired Bytes Read 
      ser.dec(E1)  
      ser.str(string(", "))
      ser.dec(E2)  
      ser.str(string(", "))
      ser.dec(E3)                                                                                         
      ser.str(string(", "))
      ser.dec(E4)  
      ser.str(string(", "))
      ser.dec(E5)
      ser.str(string(", "))
      ser.dec(E6)  
      ser.str(string(", "))
      ser.dec(E7)
      ser.str(string(", "))
      ser.dec(E8)  
      ser.str(string(", "))
      ser.dec(E9)
      ser.str(string(", "))
      ser.dec(E10)  
      ser.str(string(", "))
      ser.dec(E11)
      ser.str(string(", "))
      ser.dec(E12)                                                            
      ser.str(string("   "))    
}
' // Currently Disabled
{
    ' // FIFO Enabled
    if FIFO_Enabled == 1
      ser.str(string("FIFO: "))
      ser.dec(FIFOcnt)          ' // R/W FIFOcount  
      ser.str(string(", "))
      ser.dec(FIFOrw)           ' // Read From  FIFO  *** Needs to Repeat FIFOcount bytes                                                                                                     
}
      



    ' // TODO: Addin BMP-180 on External Sensor or Via Pass-Through Mode

           

' // Basic Start with User Accel AFS & Gyro FS & DLP   
PUB Start( SCL, SDA, aFS, gFS, fDLP, doCal ) : Status 

  if aFS == 0
    AccelFS := %00000000  ' ±  2 g
  elseif aFS == 1          
    AccelFS := %00001000  ' ±  4 g
  elseif aFS == 2
    AccelFS := %00010000  ' ±  8 g
  elseif aFS == 3
    AccelFS := %00011000  ' ± 16 g

  if gFS == 0
    GyroFS := %00000000   ' ±  250 ° /s
  elseif gFS == 1
    GyroFS := %00001000   ' ±  500 ° /s
  elseif gFS == 2
    GyroFS := %00010000   ' ± 1000 ° /s
  elseif gFS == 3
    GyroFS := %00011000   ' ± 2000 ° /s

                      '| DLPF_CFG |   Accelerometer    |          Gyroscope          |       
  if fDLP == 0        '             Bw (Hz)  Delay (ms)  Bw (Hz)  Delay (ms)  FS (Khz)
    DLP := %00000000  '      0        260        0         256       0.98        8
  elseif fDLP == 1
    DLP := %00000001  '      1        184       2.0        188       1.9         1
  elseif fDLP == 2
    DLP := %00000010  '      2         94       3.0         98       2.8         1
  elseif fDLP == 3
    DLP := %00000011  '      3         44       4.9         42       4.8         1
  elseif fDLP == 4
    DLP := %00000100  '      4         21       8.5         20       8.3         1
  elseif fDLP == 5
    DLP := %00000101  '      5         10      13.8         10      13.4         1
  elseif fDLP == 6    
    DLP := %00000110  '      6          5      19.0          5      18.6         1
  elseif fDLP == 7
    DLP := %00000111  '      7           RESERVED             RESERVED           8

  PowerMgmt  := %00000001  ' X gyro as clock source
  SampleRate := %00000001  ' 500 Hz
    
  i2csda := SDA
  i2cscl := SCL

  Ready := 0
  Status := Cog := cognew(MPU9150_Loop, @stack) + 1

  if doCal == 1
    CalibrateAccel
    CalibrateGyro
    CalibrateMag

' // Start w/ Full User Init Settings
PUB StartA( SCL, SDA, aFS, gFS, fDLP, PM, doCal ) : Status 

  if aFS == 0
    AccelFS := %00000000
  elseif aFS == 1
    AccelFS := %00001000
  elseif aFS == 2
    AccelFS := %00010000
  elseif aFS == 3
    AccelFS := %00011000

  if gFS == 0
    GyroFS := %00000000
  elseif gFS == 1
    GyroFS := %00001000
  elseif gFS == 2
    GyroFS := %00010000
  elseif gFS == 3
    GyroFS := %00011000

                      '| DLPF_CFG |   Accelerometer    |          Gyroscope          |       
  if fDLP == 0        '             Bw (Hz)  Delay (ms)  Bw (Hz)  Delay (ms)  FS (Khz)
    DLP := %00000000  '      0        260        0         256       0.98        8
  elseif fDLP == 1
    DLP := %00000001  '      1        184       2.0        188       1.9         1
  elseif fDLP == 2
    DLP := %00000010  '      2         94       3.0         98       2.8         1
  elseif fDLP == 3
    DLP := %00000011  '      3         44       4.9         42       4.8         1
  elseif fDLP == 4
    DLP := %00000100  '      4         21       8.5         20       8.3         1
  elseif fDLP == 5
    DLP := %00000101  '      5         10      13.8         10      13.4         1
  elseif fDLP == 6    
    DLP := %00000110  '      6          5      19.0          5      18.6         1
  elseif fDLP == 7
    DLP := %00000111  '      7           RESERVED             RESERVED           8
                      
  if PM == 0
    PowerMgmt := %00000000  ' Internal 8MHz oscillator
  elseif PM == 1
    PowerMgmt := %00000001  ' PLL with X axis gyroscope reference
  elseif PM == 2
    PowerMgmt := %00000010  ' PLL with Y axis gyroscope reference
  elseif PM == 3
    PowerMgmt := %00000011  ' PLL with Z axis gyroscope reference
  elseif PM == 4
    PowerMgmt := %00000100  ' PLL with external 32.768kHz reference
  elseif PM == 5
    PowerMgmt := %00000101  ' PLL with external 19.2MHz referenc
  elseif PM == 6
    PowerMgmt := %00000110  ' Reserved
  elseif PM == 7
    PowerMgmt := %00000111  ' Stops the clock and keeps the timing generator in reset
          
  ' *** Sample Rate = Gyroscope Output Rate / (1 + SMPLRT_DIV)  
  ' // 0 threw 255
  SampleRate := %00000001   ' 500 Hz Sample Rate,   %00000000 = 1000 Hz Sample rate

  i2csda := SDA
  i2cscl := SCL

  Ready := 0
  Status := Cog := cognew(MPU9150_Loop, @stack) + 1

  if doCal == 1
    CalibrateAccel
    CalibrateGyro
    CalibrateMag

' // Start Basic, No User Init
PUB StartX( SCL, SDA, doCal ) : Status 

  AccelFS := %00010000  ' AFS2
  GyroFS  := %00011000  ' FS3

  DLP        := %00000011  ' 40 Hz
  PowerMgmt  := %00000001  ' X gyro as clock source
  SampleRate := %00000001  ' 500 Hz

  i2csda := SDA
  i2cscl := SCL
  
  Status := Cog := cognew(MPU9150_Loop, @stack) + 1

  if doCal == 1
    CalibrateAccel
    CalibrateGyro
    CalibrateMag

  
PUB Stop
''Stops the Cog and the PID controller
  cogstop(cog)
         

'**********************
'   Accessors
'**********************

' // Floating Point G-force, Degrees/sec, uT
PUB GetfAccelX          ' Accel X G-Force
  return Accel[0]

PUB GetfAccelY          ' Accel Y G-Force
  return Accel[1]

PUB GetfAccelZ          ' Accel Z G-Force
  return Accel[2]
            
PUB GetfGyroX           ' Gyro X Degrees / Second
  return Gyro[0]

PUB GetfGyroY           ' Gyro Y Degrees / Second
  return Gyro[1]

PUB GetfGyroZ           ' Gyro Z Degrees / Second
  return Gyro[2]

PUB GetfMagX            ' Mag X uT
  return Mag[0]

PUB GetfMagY            ' Mag Y uT
  return Mag[1]

PUB GetfMagZ            ' Mag Z uT
  return Mag[2]

  
' // Rounded Floating Point G-force, Degrees/sec, uT
PUB GetAccelX          ' Accel X
  return f.fRound(Accel[0])

PUB GetAccelY          ' Accel Y
  return f.fRound(Accel[1])

PUB GetAccelZ          ' Accel Z
  return f.fRound(Accel[2])
            
PUB GetGyroX           ' Gyro X
  return f.fRound(Gyro[0])

PUB GetGyroY           ' Gyro Y
  return f.fRound(Gyro[1])

PUB GetGyroZ           ' Gyro Z
  return f.fRound(Gyro[2])

PUB GetMagX            ' Mag X 
  return f.fRound(Mag[0])

PUB GetMagY            ' Mag Y 
  return f.fRound(Mag[1])

PUB GetMagZ            ' Mag Z 
  return f.fRound(Mag[2])


' // Raw  -  Zero Offset
PUB GetAccelXZero          ' Raw Accel X - Zero Offset
  return aX - x0
 
PUB GetAccelYZero          ' Raw Accel Y - Zero Offset
  return aY - y0

PUB GetAccelZZero          ' Raw Accel Z - Zero Offset
  return aZ - z0
            
PUB GetGyroXZero           ' Raw Gyro X - Zero Offset
  return gX - a0

PUB GetGyroYZero           ' Raw Gyro Y - Zero Offset
  return gY - b0

PUB GetGyroZZero           ' Raw Gyro Z - Zero Offset
  return gZ - c0

PUB GetMagXZero            ' Raw Mag X - Zero Offset
  return mX - d0

PUB GetMagYZero            ' Raw Mag Y - Zero Offset
  return mY - e0

PUB GetMagZZero            ' Raw Mag Z - Zero Offset
  return mZ - f0
  
' // Low-Pass Filtered Values
Pub GetLPaX              ' Accel X Low-Pass Filtered
  return fXa

Pub GetLPaY              ' Accel Y Low-Pass Filtered
  return fYa

Pub GetLPaZ              ' Accel Z Low-Pass Filtered
  return fZa

Pub GetLPgX              ' Gyro X Low-Pass Filtered
  return fXg

Pub GetLPgY              ' Gyro Y Low-Pass Filtered
  return fYg

Pub GetLPgZ              ' Gyro Z Low-Pass Filtered
  return fZg

Pub GetLPmX              ' Mag X Low-Pass Filtered
  return fXm

Pub GetLPmY              ' Mag Y Low-Pass Filtered
  return fYm

Pub GetLPmZ              ' Mag Z Low-Pass Filtered
  return fZm

  
' // Raw Values
Pub GetaX              ' Accel X Raw
  return aX

Pub GetaY              ' Accel Y Raw
  return aY

Pub GetaZ              ' Accel Z Raw
  return aZ

Pub GetgX              ' Gyro X Raw
  return gX

Pub GetgY              ' Gyro Y Raw
  return gY

Pub GetgZ              ' Gyro Z Raw
  return gZ

Pub GetmX              ' Mag X Raw
  return mX

Pub GetmY              ' Mag Y Raw
  return mY

Pub GetmZ              ' Mag Z Raw
  return mZ

PUB GetTemp            ' Raw Temperature
  return Temp

Pub GetTempF           ' Temp Deg F
  ' // Celsius to Fahrenheit = (°C × 9/5) + 32 = °F
  return (GetTempC * (9 / 5)) + 32

Pub GetTempC | tTmp           ' Temp Deg C
  ' // Temperature in degrees C = (TEMP_OUT Register Value as a signed quantity)/340 + 35
  tTmp := 65535 / 125         ' Temperatrue Range is from -40 to +85
  return Temp / tTmp - 35     ' (TempRaw / (65535 / (85 + 40))) - Temp Offset


' // Get Accel, Gyro, Mag Offset Values
Pub GetAccelOffsetX  ' Accelerometer Zero Offset X
  return x0
  
Pub GetAccelOffsetY  ' Accelerometer Zero Offset Y
  return y0
  
Pub GetAccelOffsetZ  ' Accelerometer Zero Offset Z
  return z0
  
Pub GetGyroOffsetX   ' Gyroscope Zero Offset X
  return a0
  
Pub GetGyroOffsetY   ' Gyroscope Zero Offset Y
  return b0
  
Pub GetGyroOffsetZ   ' Gyroscope Zero Offset Z
  return c0

Pub GetMagOffsetX   ' Magnetometer Zero Offset X
  return d0
  
Pub GetMagOffsetY   ' Magnetometer Zero Offset Y
  return e0
  
Pub GetMagOffsetZ   ' Magnetometer Zero Offset Z
  return f0

  
' // Calabrate Sensors  
Pub CalAccel         ' Calibrate Accelerometer
  CalibrateAccel

Pub CalGyro          ' Calibrate Gyroscope
  CalibrateGyro

Pub CalMag           ' Calibrate Magnetometer
  CalibrateMag

Pri toRadians(ab)
 return f.fMul(ab, 0.01745329252)

Pri toDegrees(ab)
  return f.fMul(ab, 57.2957795)

Pri Deg2Rad(mDeg)
  return f.fDiv(f.fMul(mDeg, PI), 180.0)

' // Radians to Degrees
Pri Rad2Deg(mRad)
  return f.fDiv(f.fMul(mRad, 180.0), PI)


Pub GetHeading : MAG_Heading '| CMx, CMy
{                                                                           
                                                       Minimum     Typical   Maximum
  Full-Scale Range                                                 ±1200 uT
  ADC Word Length Output in two's complement format                13 bits 
  Sensitivity Scale Factor                             0.285       0.3       0.315 uT / LSB
}

{
    Direction (y>0) = 90 - [arcTAN(x/y)]*180/π
    Direction (y<0) = 270 - [arcTAN(x/y)]*180/π
    Direction (y=0, x<0) = 180.0
    Direction (y=0, x>0) = 0.0
}

  ' Pitch =   Atan2(fXa, Sqrt(fYa * fYa + fZa * fZa) * 180 / PI
  ' Roll  =   Atan2(-fYa, fZa) * 180 / PI

  '  lpPitch := f.fDiv((f.fMul(fm.Atan2(fXa, f.fSqr(f.fAdd(f.fMul(fYa, fYa), f.fMul(fZa, fZa)))), 180.0)), PI)
  '  lpRoll  := f.fDiv(f.fMul(fm.Atan2(f.fNeg(fYa), fZa), 180.0), PI)

  ' CMx =   Mag[0] * cos(Pitch) + Mag[1] * (sin(Roll) * sin(Pitch)) + Mag[2] * ((cos(Roll) * sin(Pitch))
  ' CMy =   Mag[1] * cos(Roll) - Mag[2] * sin(Roll)
  
  CMx := f.fAdd(f.fAdd(f.fMul(Mag[0], fm.cos(GetPitch)), f.fMul(Mag[1], f.fMul(fm.sin(GetRoll), fm.sin(GetPitch)))), f.fMul(Mag[2], f.fMul(fm.cos(GetRoll), fm.sin(GetPitch))))  
  CMy := f.fSub(f.fMul(Mag[1], fm.cos(GetRoll)), f.fMul(Mag[2], fm.sin(GetRoll)))

  ' MAG_Heading = Rad2Deg(Atan(CMy, CMx) * 2)

  'MAG_Heading := Rad2Deg(f.fMul(fm.Atan(f.fDiv(CMy, CMx)), 2.0))               ' // All over the place, Semi-correct IF Flat
  MAG_Heading := Rad2Deg(f.fMul(fm.Atan(f.fDiv(f.fNeg(Mag[1]), Mag[0])), 2.0))  ' // Correct IF Flat

  return MAG_Heading   

{
--Calculate the "tilt compensated" x and y magnetic component (standard formulation):

    CMx = mag_x*cos(pitch) + mag_y*sin(roll)sin(pitch) + mag_z*cos(roll)sin(pitch) CMy = mag_y*cos(roll) - mag_z*sin(roll) 

--Calculate the magnetic heading with this compensated components:

    MAG_Heading = Atan(CMy/CMx) 
}


{
  def wrap(angle):
    if angle > pi:
      angle -= (2*pi)
    if angle < -pi:
      angle += (2*pi)
    if angle < 0:
      angle += 2*pi
    return angle
     
  def magnetometer_readings_to_tilt_compensated_heading(bx, by, bz, phi, theta):
    """ Takes in raw magnetometer values, pitch and roll and turns it into a tilt-compensated heading value ranging from -pi to pi (everything in this function should be in radians). """
    variation = 4.528986*(pi/180) # magnetic variation for Corpus Christi, should match your bx/by/bz and where they were measured from (a lookup table is beyond the scope of this gist)
    Xh = bx * cos(theta) + by * sin(phi) * sin(theta) + bz * cos(phi) * sin(theta)
    Yh = by * cos(phi) - bz * sin(phi)
    return wrap((atan2(-Yh, Xh) + variation))
}

{
    http://www.pololu.com/file/download/LSM303DLH-compass-app-note.pdf?file_id=0J434
    
    Xh = Xm * cos(Pitch) + Zm * sin(Pitch)
    Yh = (Ym * sin(Roll) * sin(Pitch)) + (Ym * cos(Roll)) - (Zm * sin(Roll) * cos(Pitch))
    
    Where Xm, Ym, Zm are magnetic sensor measurements

    Equation 12:
        
    M_x2 =  M_x1 * cos(p) + M_z1 * sin(p)
    M_y2 =  M_x1 * sin(y) * sin(p) + M_y1 * cos(y) - M_z1 * sin(y) * cos(p)
    M_z2 = -M_x1 * cos(y) * sin(p) + M_y1 * sin(y) - M_z1 * cos(y) * cos(p)

    Sqrt(M_x2^2 + M_y2^2 + M_z2^2) = Should also be equal to 1.  If not, it means that the
    external magnetic interference field is detected or a pitch/roll error is present.

    *** Fast motion causes pitch/roll calculation error which directly introduces an error into the heading

    Then do  Atan(M_y2 / M_x2) to get tilt corrected heading ???
}

{
    ' // Tilt Compensation using Accelerometer:
    
    Xn = Xm * cos(Pitch) + Zm * sin(Pitch)
    Yn = Xm * sin(Roll) * sin(Pitch) + Ym * cos(Roll) - Zm * sin(Roll) * cos(Pitch)
}


{
    Heading = Atan(mY / mX)

    After obtaining the heading, the angle between true north and the compass, called azimuth, can be obtained by using: 
    
              [ 180 Heading      x < 0
              |     Heading  x > 0, y < 0
    Azimuth = | 360 Heading  x > 0. y > 0
              |     90       x = 0, y < 0
              [     270      x = 0, y > 0
}


{
    Pitch = p = arcsin(-A_x1)
    Roll  = y = arcsin(A_y1 / cos(p))

    |A| = Sqrt(A_x1^2 + A_y1^2 + A_z1^2) = 1

    Heading = W = arctan(M_y2 / M_x2)        for M_x2 > 0 and M_y2 >= 0
                = 180 + arctan(M_y2 / M_x2)  for M_x2 < 0
                = 360 + arctan(M_y2 / M_x2)  for M_x2 > 0 and M_y2 <= 0
                =  90                        for M_x2 = 0 and M_y2 < 0
        M_x2 = M_x1 * cos(p) + M_z1 * sin(p)                  M_y2 > 0
        M_y2 = M_x1 * sin(y) * sin(p) + M_y1 * sin(y) + M_z1 * cos(y) * cos(p)
        |M|A = Sqrt(M_x1^2 + M_y1^2 + M_z1^2) = Should also be equal to 1

        Where M_x1, M_y1, M_z1 are the normalized magnatice sensor measurements after applying calibration parameters                                                                        

}


{                                                                           
                                                       Minimum     Typical   Maximum
  Full-Scale Range                                                 ±1200 uT
  ADC Word Length Output in two's complement format                13 bits 
  Sensitivity Scale Factor                             0.285       0.3       0.315 uT / LSB
}

{
    Direction (y>0) = 90 - [arcTAN(x/y)]*180/π
    Direction (y<0) = 270 - [arcTAN(x/y)]*180/π
    Direction (y=0, x<0) = 180.0
    Direction (y=0, x>0) = 0.0
}

{
--Calculate the "tilt compensated" x and y magnetic component (standard formulation):

    CMx = mag_x*cos(pitch) + mag_y*sin(roll)sin(pitch) + mag_z*cos(roll)sin(pitch) CMy = mag_y*cos(roll) - mag_z*sin(roll) 

--Calculate the magnetic heading with this compensated components:

    MAG_Heading = Atan(CMy/CMx) 
}


' // TODO:  Addin Temperature Compensation


Pri DoLowPass

    ' // Accelerometer Low-Pass Filter
    fXa := f.fAdd(f.fMul(Accel[0], Alpha), f.fMul(fXa, f.fSub(1.0, Alpha)))
    fYa := f.fAdd(f.fMul(Accel[1], Alpha), f.fMul(fYa, f.fSub(1.0, Alpha)))
    fZa := f.fAdd(f.fMul(Accel[2], Alpha), f.fMul(fZa, f.fSub(1.0, Alpha)))

    ' // Gyroscope Low-Pass Filter
    fXg := f.fAdd(f.fMul(Gyro[0], Alpha), f.fMul(fXg, f.fSub(1.0, Alpha)))
    fYg := f.fAdd(f.fMul(Gyro[1], Alpha), f.fMul(fYg, f.fSub(1.0, Alpha)))
    fZg := f.fAdd(f.fMul(Gyro[2], Alpha), f.fMul(fZg, f.fSub(1.0, Alpha)))

    ' // Magnetometer Low-Pass Filter    *** Likely Not Needed
    fXm := f.fAdd(f.fMul(Mag[0], Alpha), f.fMul(fXm, f.fSub(1.0, Alpha)))
    fYm := f.fAdd(f.fMul(Mag[1], Alpha), f.fMul(fYm, f.fSub(1.0, Alpha)))
    fZm := f.fAdd(f.fMul(Mag[2], Alpha), f.fMul(fZm, f.fSub(1.0, Alpha)))

    
' // Update G-Force, Degrees per Second, and Mag Angle       
Pub UpdateForceVals | faX, faY, faZ, fgX, fgY, fgZ                   

    ' // Accelerometer
    faX := f.fSub(f.fFloat(aX), 32768.0)  
    faY := f.fSub(f.fFloat(aY), 32768.0)
    faZ := f.fSub(f.fFloat(aZ), 32768.0)  

    ' // Convert Accel Value to G-Force
    ' G-Force = Accel[x] / 8,192  (AFS-1)
    Accel[0] := f.fAdd(f.fDiv(faX, cAccelFS), 8.0)       ' *** Need to be able to Calculate this Offset Value                      
    Accel[1] := f.fAdd(f.fDiv(faY, cAccelFS), 8.0)
    Accel[2] := f.fAdd(f.fDiv(faZ, cAccelFS), 8.0)


    ' // Gyroscope
    fgX := f.fSub(f.fFloat(gX), 32768.0)  
    fgY := f.fSub(f.fFloat(gY), 32768.0)
    fgZ := f.fSub(f.fFloat(gZ), 32768.0)    

    ' // Convert Gyro Value to Degrees per Second
    ' Gyro = Gyro[x] / 16.4       (FS-3)    
    Gyro[0] := f.fAdd(f.fDiv(fgX, cGyroFS), 2048.0)       ' *** Need to be able to Calculate this Offset Value                      
    Gyro[1] := f.fAdd(f.fDiv(fgY, cGyroFS), 2048.0)
    Gyro[2] := f.fAdd(f.fDiv(fgZ, cGyroFS), 2048.0)


    ' // Magnetometer   (uT)   (Full Scale Range = +/- 1200 uT)  (Raw Value / 0.3 uT/LSB) 
    Mag[0] := f.fDiv(f.fFloat(mX), cMagFS)                       
    Mag[1] := f.fDiv(f.fFloat(mY), cMagFS) 
    Mag[2] := f.fDiv(f.fFloat(mZ), cMagFS)


' // Low-Pass Filtered Pitch Angle
Pub GetLPPitch | lpPitch, faX, faY, faZ
    ' // Accelerometer
    faX := f.fSub(f.fFloat(aX), 32768.0)  
    faY := f.fSub(f.fFloat(aY), 32768.0)
    faZ := f.fSub(f.fFloat(aZ), 32768.0)  

    ' // Convert Accel Value to G-Force
    ' G-Force = Accel[x] / 8,192  (AFS-1)
    Accel[0] := f.fAdd(f.fDiv(faX, cAccelFS), 8.0)       ' *** Need to be able to Calculate this Offset Value                      
    Accel[1] := f.fAdd(f.fDiv(faY, cAccelFS), 8.0)
    Accel[2] := f.fAdd(f.fDiv(faZ, cAccelFS), 8.0)

    ' // Accelerometer Low-Pass Filter
    fXa := f.fAdd(f.fMul(Accel[0], Alpha), f.fMul(fXa, f.fSub(1.0, Alpha)))
    fYa := f.fAdd(f.fMul(Accel[1], Alpha), f.fMul(fYa, f.fSub(1.0, Alpha)))
    fZa := f.fAdd(f.fMul(Accel[2], Alpha), f.fMul(fZa, f.fSub(1.0, Alpha)))

    lpPitch := f.fDiv((f.fMul(fm.Atan2(fXa, f.fSqr(f.fAdd(f.fMul(fYa, fYa), f.fMul(fZa, fZa)))), 180.0)), PI)

    return lpPitch

' // Low-Pass Filtered Heading
Pub GetLPHdg
    return 0   

' // Low-Pass Filtered Roll Angle
Pub GetLPRoll | lpRoll, faX, faY, faZ
    ' // Accelerometer
    faX := f.fSub(f.fFloat(aX), 32768.0)  
    faY := f.fSub(f.fFloat(aY), 32768.0)
    faZ := f.fSub(f.fFloat(aZ), 32768.0)  

    ' // Convert Accel Value to G-Force
    ' G-Force = Accel[x] / 8,192  (AFS-1)
    Accel[0] := f.fAdd(f.fDiv(faX, cAccelFS), 8.0)       ' *** Need to be able to Calculate this Offset Value                      
    Accel[1] := f.fAdd(f.fDiv(faY, cAccelFS), 8.0)
    Accel[2] := f.fAdd(f.fDiv(faZ, cAccelFS), 8.0)

    ' // Accelerometer Low-Pass Filter
    fXa := f.fAdd(f.fMul(Accel[0], Alpha), f.fMul(fXa, f.fSub(1.0, Alpha)))
    fYa := f.fAdd(f.fMul(Accel[1], Alpha), f.fMul(fYa, f.fSub(1.0, Alpha)))
    fZa := f.fAdd(f.fMul(Accel[2], Alpha), f.fMul(fZa, f.fSub(1.0, Alpha)))

    lpRoll  := f.fDiv(f.fMul(fm.Atan2(f.fNeg(fYa), fZa), 180.0), PI)    

    return lpRoll
    
' // Non-Filtered Pitch Angle
Pub GetPitch | faX, faY, faZ         
    ' // Accelerometer
    faX := f.fSub(f.fFloat(aX), 32768.0)  
    faY := f.fSub(f.fFloat(aY), 32768.0)
    faZ := f.fSub(f.fFloat(aZ), 32768.0)  

    ' // Convert Accel Value to G-Force
    ' G-Force = Accel[x] / 8,192  (AFS-1)
    Accel[0] := f.fAdd(f.fDiv(faX, cAccelFS), 8.0)       ' *** Need to be able to Calculate this Offset Value                      
    Accel[1] := f.fAdd(f.fDiv(faY, cAccelFS), 8.0)
    Accel[2] := f.fAdd(f.fDiv(faZ, cAccelFS), 8.0)

    'aPitch := f.fDiv((f.fMul(fm.Atan2(fXa, f.fSqr(f.fAdd(f.fMul(fYa, fYa), f.fMul(fZa, fZa)))), 180.0)), PI)
    aPitch := f.fDiv((f.fMul(fm.Atan2(Accel[0], f.fSqr(f.fAdd(f.fMul(Accel[1], Accel[1]), f.fMul(Accel[2], Accel[2])))), 180.0)), PI)
  
    return aPitch

' // Non-Filtered Roll Angle    
Pub GetRoll | faX, faY, faZ           
    ' // Accelerometer
    faX := f.fSub(f.fFloat(aX), 32768.0)  
    faY := f.fSub(f.fFloat(aY), 32768.0)
    faZ := f.fSub(f.fFloat(aZ), 32768.0)  

    ' // Convert Accel Value to G-Force
    ' G-Force = Accel[x] / 8,192  (AFS-1)
    Accel[0] := f.fAdd(f.fDiv(faX, cAccelFS), 8.0)       ' *** Need to be able to Calculate this Offset Value                      
    Accel[1] := f.fAdd(f.fDiv(faY, cAccelFS), 8.0)
    Accel[2] := f.fAdd(f.fDiv(faZ, cAccelFS), 8.0)

    'aRoll  := f.fDiv(f.fMul(fm.Atan2(f.fNeg(fYa), fZa), 180.0), PI)
    aRoll  := f.fDiv(f.fMul(fm.Atan2(f.fNeg(Accel[1]), Accel[2]), 180.0), PI)    
        
    return aRoll



' // TODO:  Addin Self Test Function
{
Pub TestAccelX       ' Test Accelerometer X

Pub TestAccelY       ' Test Accelerometer Y

Pub TestAccelZ       ' Test Accelerometer Z

Pub TestGyroX        ' Test Gyroscope X

Pub TestGyroY        ' Test Gyroscope Y    

Pub TestGyroZ        ' Test Gyroscope Z

Pub TestMagX         ' Test Gyroscope X

Pub TestMagY         ' Test Gyroscope Y    

Pub TestMagZ         ' Test Gyroscope Z
}

' // Main Loop  
Pri MPU9150_Loop

  SetConfig

  'SetDMP
  'SetFIFO

  repeat

    MPUReadValues

    'UpdateForceVals  *** Makes All Values = 0 ***   Why???      
    
    VerifyReg

    drift := (Temp + 15000) / 100      '  (Temp + 15000) / 100 = drift    (MPUComputeDrift)



' // Configure Digital Motion Processor  -  Uses FIFO for Data Access
Pri SetDMP

  ' // TODO:  Addin DMP Control Setup / Load DMP Firmware to MPU Memory

' // Configure FIFO  -  Used for DMP
Pri SetFIFO

  ' // TODO:  Addin FIFO Control Setup
       
Pri VerifyReg
    vPWR   := Read_Register($6B)
    vSMP   := Read_Register($19)
    vDLPF  := Read_Register($1A)
    vGyro  := Read_Register($1B)
    vAccel := Read_Register($1C)
    vMM    := Read_Register($6A)
    vPT    := Read_Register($37)  

    
' // Resets All Registers on MPU    
Pri FactoryReset | i

  ' // *** Reset Value is 0x00 for all registers other than:
  ' //     Register 107: 0x40  (PWR_MGMT_1)
  ' //     Register 117: 0x68  (WHO_AM_I)

  repeat i from $00 to $75
    Write_Register(i, $00)
    
    if i == PWR_MGMT_1
      Write_Register(PWR_MGMT_1, $40)  ' Device Off
    if i == WHO_AM_I
      Write_Register(WHO_AM_I, $68)    ' Device ID = 0x68


' // Calibrations Copied from MPU-6050 PASM  
Pri CalibrateAccel | tc, xc, yc, zc, dr

  x0 := 0         ' Initialize offsets
  y0 := 0
  z0 := 0
  
  'wait 1/2 second for the body to stop moving
  waitcnt( constant(80_000_000 / 2) + cnt )

  'Find the zero points of the 3 axis by reading for ~1 sec and averaging the results
  xc := 0
  yc := 0
  zc := 0

  repeat 256
    xc += aX
    yc += aY
    zc += aZ

    waitcnt( constant(80_000_000/192) + cnt )

  'Perform rounding
  if( xc > 0 )
    xc += 128
  elseif( xc < 0 )
    xc -= 128

  if( yc > 0 )
    yc += 128
  elseif( yc < 0 )
    yc -= 128

  if( zc > 0 )
    zc += 128
  elseif( zc < 0 )
    zc -= 128
    
  x0 := xc / 256
  y0 := yc / 256
  z0 := zc / 256
      
Pri CalibrateGyro | tc, xc, yc, zc, dr

  a0 := 0         ' Initialize offsets
  b0 := 0
  c0 := 0
  
  'wait 1/2 second for the body to stop moving
  waitcnt( constant(80_000_000 / 2) + cnt )

  'Find the zero points of the 3 axis by reading for ~1 sec and averaging the results
  xc := 0
  yc := 0
  zc := 0

  repeat 256
    xc += gX
    yc += gY
    zc += gZ

    waitcnt( constant(80_000_000/192) + cnt )

  'Perform rounding
  if( xc > 0 )
    xc += 128
  elseif( xc < 0 )
    xc -= 128

  if( yc > 0 )
    yc += 128
  elseif( yc < 0 )
    yc -= 128

  if( zc > 0 )
    zc += 128
  elseif( zc < 0 )
    zc -= 128
    
  a0 := xc / 256
  b0 := yc / 256
  c0 := zc / 256

Pri CalibrateMag | tc, xc, yc, zc, dr

  d0 := 0         ' Initialize offsets
  e0 := 0
  f0 := 0
  
  'wait 1/2 second for the body to stop moving
  waitcnt( constant(80_000_000 / 2) + cnt )

  'Find the zero points of the 3 axis by reading for ~1 sec and averaging the results
  xc := 0
  yc := 0
  zc := 0

  repeat 256
    xc += mX
    yc += mY
    zc += mZ

    waitcnt( constant(80_000_000/192) + cnt )

  'Perform rounding
  if( xc > 0 )
    xc += 128
  elseif( xc < 0 )
    xc -= 128

  if( yc > 0 )
    yc += 128
  elseif( yc < 0 )
    yc -= 128

  if( zc > 0 )
    zc += 128
  elseif( zc < 0 )
    zc -= 128
    
  d0 := xc / 256
  e0 := yc / 256
  f0 := zc / 256


' // MPU-6050 / MPU-9150 Config
Pri SetConfig
                   
    i2cstart                         ' #i2cReset

    Write_Register(PWR_MGMT_1,   PowerMgmt)   ' 107 - PWR_MGMT_1    
    Write_Register(SMPLRT_DIV,  SampleRate)   ' 25  - SMPLRT_DIV = 1 => 1khz/(1+1) = 500hz sample rate
    Write_Register(CONFIG,             DLP)   ' 26  - Set DLPF_CONFIG to 4 for 20Hz bandwidth     
    Write_Register(Gyro_Config,     GyroFS)   ' 27  - Gyro_Config   
    Write_Register(Accel_Config,   AccelFS)   ' 28  - Accel_Config

    Write_Register(INT_Pin_Cfg,  %00000010)   ' 55  - INT_Pin_Cfg  i2c Bypass Enabled  *** Required to Read Mag Via Aux Bus    
    
    if MM_En == 0    
      Write_Register(User_Ctrl,   %00000000)   ' 106 - Disable Master Mode    
      Write_Register(INT_Pin_Cfg, %00000010)   ' 55  - INT_Pin_Cfg  i2c Bypass Enabled
    elseif MM_En == 1
      Write_Register(User_Ctrl,   %00010000)   ' 106 - Enable Master Mode    
      Write_Register(INT_Pin_Cfg, %00000000)   ' 55  - INT_Pin_Cfg  i2c Bypass Disabled


            
{
    Write_Register(PWR_MGMT_1,   %00000001)   ' 107 - PWR_MGMT_1    
    Write_Register(SMPLRT_DIV,   %00000001)   ' 25  - SMPLRT_DIV = 1 => 1khz/(1+1) = 500hz sample rate
    Write_Register(CONFIG,       %00000100)   ' 26  - Set DLPF_CONFIG to 4 for 20Hz bandwidth     
    Write_Register(Gyro_Config,  %00011000)   ' 27  - Gyro_Config
    Write_Register(Accel_Config, %00010000)   ' 28  - Accel_Config
    Write_Register(User_Ctrl,    %00000000)   ' 106 - Disable Master Mode    
    Write_Register(INT_Pin_Cfg,  %00110010)   ' 55  - INT_Pin_Cfg  
    Write_Register(INT_Enable,   %00000001)   ' 56  - INT_Enable
}

    
' // MPU-6050 / MPU-9150 Get Values
Pri MPUReadValues | dr, cFactor
    ' // Start at Register $3B  (Accel, Temp, Gyro) 
    i2cStart                   ' start the transaction  
    i2cWrite(AddressW)         ' 0 for write
    i2cWrite(Accel_XOut_H)     ' send the register to start the read at
    i2cStart
    i2cWrite(AddressR)         ' start the read 
    
    aX  := i2cRead(0)   << 8      
    aX  |= i2cRead(0)    
    aY  := i2cRead(0)   << 8      
    aY  |= i2cRead(0)   
    aZ  := i2cRead(0)   << 8
    aZ  |= i2cRead(0)   
    Temp := i2cRead(0)  << 8  
    Temp |= i2cRead(0)    
    gX  := i2cRead(0)   << 8      
    gX  |= i2cRead(0)   
    gY  := i2cRead(0)   << 8      
    gY  |= i2cRead(0)    
    gZ  := i2cRead(0)   << 8       
    gZ  |= i2cRead(1)
    
    ~~aX
    ~~aY
    ~~aZ
    ~~gX
    ~~gY
    ~~gZ

    ' // Change Register to $75  (Chip ID)
    i2cStart            '\         
    i2cWrite(AddressW)  ' > Address Register Select  
    i2cWrite(WHO_AM_I)  '/   
    i2cStop             '\  StartRead
    i2cStart            '/
    i2cWrite(AddressR)  '\  i2cRead       
    cID := i2cRead(1)   '/       

    ' // *** Enable Passthrough Mode if not Enabled (Default = Enabled)
    if MM_En == 0
      Write_Register(User_Ctrl,    %00000000)   ' 106 - Master Mode Disabled
      Write_Register(INT_Pin_Cfg,  %00000010)   ' 55  - Bypass Enabled   

    ' // Change Address to MagAddr    (Magnetometer)

    ' // Magnetometer (AK8975)  - Set CTRL ($0A) = %00000001 = Single Measurement Mode
    i2cStart            
    i2cWrite(MagAddrW)     ' AK8975 Write Address
    i2cWrite($0A)          ' CTRL Register
    i2cWrite(%00000001)    ' Set config $0A to %00000001 to turn on the device.    
    i2cStop    

    i2cStart            
    i2cWrite(MagAddrW)     ' AK8975 Write Address
    i2cWrite($00)          ' Address to start reading from
    i2cStop
    i2cStart
    i2cWrite(MagAddrR)     ' AK8975 Read Address
    mID     := i2cRead(1)

    i2cStart            
    i2cWrite(MagAddrW)     ' AK8975 Write Address
    i2cWrite($01)          ' Address to start reading from
    i2cStop
    i2cStart
    i2cWrite(MagAddrR)     ' AK8975 Read Address    
    mInfo   := i2cRead(1)

    i2cStart            
    i2cWrite(MagAddrW)     ' AK8975 Write Address
    i2cWrite($02)          ' Address to start reading from
    i2cStop
    i2cStart
    i2cWrite(MagAddrR)     ' AK8975 Read Address    
    mStatus := i2cRead(1)

    i2cStart            
    i2cWrite(MagAddrW)     ' AK8975 Write Address
    i2cWrite($03)          ' Address to start reading from
    i2cStop
    i2cStart
    i2cWrite(MagAddrR)     ' AK8975 Read Address

    ' // is this right: ????
    mX := i2cRead(0)       ' Mag_X_L
    mX |= i2cRead(0) << 8  ' Mag_X_H
    mY := i2cRead(0)       ' Mag_Y_L
    mY |= i2cRead(0) << 8  ' Mag_Y_H
    mZ := i2cRead(0)       ' Mag_Z_L
    mZ |= i2cRead(1) << 8  ' Mag_Z_H       

    ~~mX
    ~~mY
    ~~mZ
    
    ' // TODO: Read BMP-180 Via Master Mode or Pass-Through Mode next

    i2cStop

    if MM_En == 1
      Write_Register(INT_Pin_Cfg,  %00000000)   ' 55  - Bypass Disabled
      Write_Register(User_Ctrl,    %00010000)   ' 106 - Master Mode Enabled
                 
                                               

' // Read MPU Register    
Pri Read_Register(rReg) : rVal | key  
    i2cStart                    ' start the transaction  
    i2cWrite(AddressW)
    i2cWrite(rReg)
    i2cStop
    i2cStart
    i2cWrite(AddressR)          ' start the read 
    rVal := i2cRead(1)          ' read first bit field 0 - 7
    i2cStop 

    key := >| rVal              'encode >| bitfield tonumber
    ' // Method to debug with piezo (from example code)
    if rVal == $FFFF
     {use this to insure that if the Address fails or is unplugged
     that the program does not lock since I2C will be showing $FFFF}    
      return 0
      
    return rVal    
 
' // Write MPU Register    
Pri Write_Register(wReg, wVal)
    i2cStart
    i2cWrite(AddressW)
    i2cWrite(wReg)
    i2cWrite(wVal)
    i2cStop  
      
   

' // Minimal I2C Driver:
con

   i2cack    = 0                                        
   i2cnak    = 1                                           
   i2cxmit   = 0                                               
   i2crecv   = 1                                              
   i2cboot   = 28                                               
   i2ceeprom = $a0                                           

'Var
'  long i2csda, i2cscl
      
Pri i2cstart                                        
                     
   outa[i2cscl]~~                                         
   dira[i2cscl]~~
   outa[i2csda]~~                                         
   dira[i2csda]~~
   outa[i2csda]~                                   
   outa[i2cscl] ~                              

Pri i2cstop

   outa[i2cscl] ~~                              
   outa[i2csda] ~~                              
   dira[i2cscl] ~                                   
   dira[i2csda] ~                                                      

Pri i2cwrite(i2cdata) : ackbit

   ackbit := 0 
   i2cdata <<= 24
   repeat 8                                          
      outa[i2csda] := (i2cdata <-= 1) & 1
      outa[i2cscl] ~~                                                
      outa[i2cscl] ~
   dira[i2csda] ~                                              
   outa[i2cscl] ~~
   ackbit := ina[i2csda]                                      
   outa[i2cscl] ~
   outa[i2csda] ~                                      
   dira[i2csda] ~~

Pri i2cread(ackbit): i2cdata

   i2cdata := 0
   dira[i2csda]~                                    
   repeat 8                                             
      outa[i2cscl] ~~                                         
      i2cdata := (i2cdata << 1) | ina[i2csda]
      outa[i2cscl] ~
   outa[i2csda] := ackbit                               
   dira[i2csda] ~~
   outa[i2cscl] ~~                                                   
   outa[i2cscl] ~
   outa[i2csda] ~                                      

Pri i2creadpage(i2caddr, addrreg, dataptr, count) : ackbit
                                                                              
   i2caddr |= addrreg >> 15 & %1110
   i2cstart
   ackbit := i2cwrite(i2caddr | i2cxmit)
   ackbit := (ackbit << 1) | i2cwrite(addrreg >> 8 & $ff)
   ackbit := (ackbit << 1) | i2cwrite(addrreg & $ff)          
   i2cstart
   ackbit := (ackbit << 1) | i2cwrite(i2caddr | i2crecv)
   repeat count - 1
      byte[dataptr++] := i2cread(i2cack)
   byte[dataptr++] := i2cread(i2cnak)
   i2cstop
   return ackbit

Pri i2cwritepage(i2caddr, addrreg, dataptr, count) : ackbit
                                                                           
   i2caddr |= addrreg >> 15 & %1110
   i2cstart
   ackbit := i2cwrite(i2caddr | i2cxmit)
   ackbit := (ackbit << 1) | i2cwrite(addrreg >> 8 & $ff)
   ackbit := (ackbit << 1) | i2cwrite(addrreg & $ff)          
   repeat count
      ackbit := ackbit << 1 | ackbit & $80000000                             
      ackbit |= i2cwrite(byte[dataptr++])
   i2cstop
   return ackbit

  