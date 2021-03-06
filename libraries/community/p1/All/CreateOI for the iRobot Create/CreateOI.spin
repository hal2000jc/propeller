{{
─────────────────────────────────────────────────
File: CreateOI.spin
Version: 1.2
Copyright (c) 20014 Joe Lucia
See end of file for terms of use.

Author: Joe Lucia                                      
─────────────────────────────────────────────────

************************************
* iRobot Create Serial Interface  v1.2 2014 for ServerBot
* by Joe Lucia - 2joester@gmail.com
* http://irobotcreate.googlepages.com
*
* This object requires two (2) cogs, one for the serial port
* and one for the CreateCog to process the serial port data.
*
* call SetCompassPtr(ptr) to point to the Compass Reading Variable to help with better localization calculations

The following pins are available on the Creates 25pin cargo bay connector:
_rxpin  (Receive Data from Create, add a 1k inline resistor since create serial lines are at 5v)
_txpin  (Transmit Data to Create)
_pwrtogglepin (output to toggle the create Power)
_pwrsenpin    (input to sense when power is ON, add a 1k inline resistor)
_chrgsenpin   (input to sense when the create is docked or plugged in to charge, add a 1k inline resistor)
                      
Get Started:
create.Start(_rxpin, _txpin, _pwrtogglepin, _pwrsenpin, _chrgsenpin)
create.SafeMode
create.Drive(300, create#RADStraight)
waitcnt(clkfreq*3+cnt) ' delay five seconds 
create.DriveStop

}}

CON
  '' * Create 25-pin Cargo Bay Connector Pins for referen
  ' 1 - RXD
  ' 2 - TXD 
  ' 3 - Power Control Toggle
  ' 4 - Analog Input
  ' 5 - Digital input 1
  ' 6 - Digital input 3
  ' 7 - Digital output 1
  ' 8 - Switched 5V (100ma)
  ' 9 - Vpwr (unregulated, 500ma)
  ' 10,11,12 - Switched Vpwr (1500ma)
  ' 13 - Robot charging
  ' 14,16,21,25 - GND
  ' 15 - BRC (digital input, baud-rate-change to 19200)
  ' 17 - Digital input 0
  ' 18 - Digital input 2
  ' 19 - Digital output 0
  ' 20 - Digital output 2
  ' 22 - Low side driver 0 (500ma)
  ' 23 - Low side driver 1 (500ma, IR LED)
  ' 24 - Low side driver 2 (1500ma)

  DebugRXPin                    = 31
  DebugTXPin                    = 30                        

  SCLPin     = 24                
  SDAPin     = 25                

  '' * oi.h - Definitions for the Open Interface 
  ' Command values
  CmdSoftReset    =7
  CmdStart        =128
  CmdBaud         =129
  CmdControl      =130
  CmdSafe         =131
  CmdFull         =132
  CmdSpot         =134
  CmdClean        =135
  CmdDemo         =136
  CmdDrive        =137
  CmdMotors       =138
  CmdLeds         =139
  CmdSong         =140
  CmdPlay         =141
  CmdSensors      =142
  CmdDock         =143
  CmdPWMMotors    =144
  CmdDriveWheels  =145
  CmdOutputs      =147
  CmdSensorStream =148
  CmdSensorList   =149
  CmdStreamControl=150
  CmdIRChar       =151
   
  ' Sensor byte indices - offsets in packets 0, 5 and 6
  SenBumpDrop     =0            
  SenWall         =1
  SenCliffL       =2
  SenCliffFL      =3
  SenCliffFR      =4
  SenCliffR       =5
  SenVWall        =6
  SenOverC        =7
  SenIRChar       =10
  SenButton       =11
  SenDist1        =12
  SenDist0        =13
  SenAng1         =14
  SenAng0         =15
  SenChargeState  =16
  SenVolt1        =17
  SenVolt0        =18
  SenCurr1        =19
  SenCurr0        =20
  SenTemp         =21
  SenCharge1      =22
  SenCharge0      =23
  SenCap1         =24
  SenCap0         =25
  SenWallSig1     =26
  SenWallSig0     =27
  SenCliffLSig1   =28
  SenCliffLSig0   =29
  SenCliffFLSig1  =30
  SenCliffFLSig0  =31
  SenCliffFRSig1  =32
  SenCliffFRSig0  =33
  SenCliffRSig1   =34
  SenCliffRSig0   =35
  SenInputs       =36
  SenAInput1      =37
  SenAInput0      =38
  SenChAvailable  =39
  SenOIMode       =40
  SenOISong       =41
  SenOISongPlay   =42
  SenStreamPckts  =43
  SenVel1         =44
  SenVel0         =45
  SenRad1         =46
  SenRad0         =47
  SenVelR1        =48
  SenVelR0        =49
  SenVelL1        =50
  SenVelL0        =51
  ' there may be more packets, not sure

  ' Sensor packet sizes
  Sen0Size        =26
  Sen1Size        =10
  Sen2Size        =6
  Sen3Size        =10
  Sen4Size        =14
  Sen5Size        =12
  Sen6Size        =52
   
  ' Sensor bit masks
  WheelDropFront  =$10
  WheelDropLeft   =$08
  WheelDropRight  =$04
  BumpLeft        =$02
  BumpRight       =$01
  BumpBoth        =$03
  BumpEither      =$03
  WheelDropAll    =$1C
  
  ButtonAdvance   =$04
  ButtonPlay      =$01
  
  LeftWheelOverC  =$10
  RightWheelOverC =$08
  LD2OverC        =$04
  LD0OverC        =$02
  LD1OverC        =$01
   
  ' LED Bit Masks
  LEDAdvance      =$08
  LEDPlay         =$02
  LEDsBoth        =$0A
   
  ' Baud codes
  Baud300         =0
  Baud600         =1
  Baud1200        =2
  Baud2400        =3
  Baud4800        =4
  Baud9600        =5
  Baud14400       =6
  Baud19200       =7
  Baud28800       =8
  Baud38400       =9
  Baud57600       =10
  Baud115200      =11
   
  ' Drive radius special cases
  RadStraight     =32768
  RadCCW          =1
  RadCW           =-1
   
  ' Baud UBRRx values
  Ubrr300         =3839
  Ubrr600         =1919
  Ubrr1200        =959
  Ubrr2400        =479
  Ubrr4800        =239
  Ubrr9600        =119
  Ubrr14400       =79
  Ubrr19200       =59
  Ubrr28800       =39
  Ubrr38400       =29
  Ubrr57600       =19
  Ubrr115200      =9
     
  ' Charge states.  Goes into WAIT_CHG before TRKL_CHG
  #0, NO_CHG, RECON_CHG, FULL_CHG, TRKL_CHG, WAIT_CHG, CHG_FAULT
   
  '' Create OI Modes
  #0, MODE_UNKNOWN, MODE_PASSIVE, MODE_SAFE, MODE_FULL, MODE_OFF

  '' Drive Modes.  Used by BumperCheck to determine direction to turn
  #0, DM_Normal, DM_Left, DM_Right

  ' IR Commands from Remotes
  IRSendAll     = 128
  IRLeft        = 129
  IRForward     = 130
  IRRight       = 131
  IRSpot        = 132
  IRMax         = 133
  IRClean       = 136
  IRPause       = 137
  IRPower       = 138
  IRDock        = 143

  ' Home Base IR Codes (240..254)
  HBDetect      = 240  ' %1111_0000 (Reserved)
  HBForceField  = 242  ' %1111_0010
  HBGreen       = 244  ' %1111_0100
  HBGreenForce  = 246  ' %1111_0110
  HBRed         = 248  ' %1111_1000
  HBRedForce    = 250  ' %1111_1010
  HBRedGreen    = 252  ' %1111_1100
  HBRedGreenForce= 254 ' %1111_1110

  ' IR value returned when nothing is seen
  IRNothing     = 255

  
  ' Chargers
  WALL_CHARGER    =1
  DOCK_CHARGER    =2
  
  DEFAULTPOLLINTERVAL           = 100                   ' interval at which to poll sesor data from the Create
  TURNSPEED                     = 75                    ' optimal turning speed
  TURNERROR                     = 4                     ' +/- degrees error for heading adjustments

  '' COMPASS MODULE
  HEADINGCORRECTINTERVAL        = 100                   ' how often we should adjust the robot toward correct heading

  SPEEDCHECKINTERVAL            = 80                    ' interval at which to check/adjust current speed
  SPEEDADJUSTINCREMENT          = 10                    ' increment to adjust speed until TargetSpeed is reached
  
  DRIVINGTURNRADIUS             = 950                   ' default turn radius to adjust toward heading while driving
  DISTANCECHECKINTERVAL         = 50                    ' interval at which to check if we've reached target-distance 

  OBJECTMIN                     = 16                    ' used for Sonar Distance checks

  #0, CC_IDLE, CC_DRIVE, CC_DRIVEDISTANCE, CC_TURNLEFT, CC_TURNRIGHT, CC_TURNTODEG, CC_TURNDEG, CC_SETOIMODE, CC_PLAYSONG, CC_DOCK, CC_UNDOCK, CC_SENDIRCHAR, CC_SPEEDADJUST, CC_SPEEDSET

  ' DivertReasons for _DivertReason variable - get set whenever we change directions for any reason (ideally) for debugging
  #0, DR_None, DR_Sonar0, DR_Sonar1, DR_Sonar2, DR_Sonar3, DR_Sonar4, DR_BumpBoth, DR_BumpLeft, DR_BumpRight

  ' Function that set the last _DivertReason
  #0, DF_None, DF_Speed, DF_Heading, DF_Bumpers, DF_Sonars, DF_Distance  

OBJ
  SerialCreate  :  "FullDuplexSerial"
  clock         :  "Clock"
  d             :  "DynamicMathLib_short"
  
VAR
  '' cog Variables
  long  CreateStack[300]        ' stack for CreateCog()
  byte  cog                     ' CreateCog() id
  long  isPaused                ' when set, Speed, Distance, and Heading will not be processed
  long  isCheckSpeed
  long  isCheckHeading
  long  txLocked                ' set when cog is sending data to Create
  
  '' Create to Propeller Pins
  byte  rxPin                   ' Propeller RXpin for Create's TXpin                   
  byte  txPin                   ' Propeller TXpin for Create's RXpin
  byte  RobotPwrTogglePin       ' Create Pin 3  (Power control toggle low-to-high) OUTPUT
  byte  RobotPowerSensePin      ' Create Pin 8  (Switched 5V 100ma) INPUT 10k resistor
  byte  RobotChargePin          ' Create Pin 13 (Robot charging) INPUT 10k resistor

  '' Sensor Buffer
  long  isSensorData            ' set to TRUE after requesting a sensor packet
  byte  sensors[Sen6Size]       ' array of sensor packet bytes
  byte  sensorsPtr              ' pointer to current sensor packet byte in sensors[] array
  long  _SensorPacketReq        ' increments every time we Request a packet from the Create
  long  _SensorPacketID         ' increments each time we Get a packet from the Create
  long  LastPacketClk           ' last time we received a sensor packet
  long  _Enabled                ' if not SET the we won't request a packet from the Create (is FALSE when Create Power is OFF)
  long  ReadInterval            ' interval (ms) to request a Packet from the Create
  long  gotSensorData

  '' Sensor Data
  byte  _Bumpers                ' left,middle,right bumpers
  byte  _VirtualWall            ' virtual wall detected
  byte  _IRChar                 ' IR Char received
  byte  _OverCurrent            ' over-current sensor 0..31
  byte  _OverCurrentCounter     ' helps ignore short-term over-current, increments each time we get a packet with OverCurrent set
  byte  _Buttons                ' create Button status
  byte  _ChargeState            ' current charging state
  byte  _ChargerAvailable       ' charger is available
  byte  _OIMode                 ' current OI mode reported by the Create                                                                      
  byte  _CliffL, _CliffFL, _CliffFR, _CliffR           ' cliff sensors (0 or 1)
  long  _CliffLv, _CliffFLv, _CliffFRv, _CliffRv       ' cliff sensor values
  long  _BatteryVoltage         ' current voltage of battery mV
  long  _BatteryUsage           ' current ma usage
  long  _BatteryRemaining       ' current mah remaining
  long  _BatteryCapacity        ' total mah battery starts with
  long  _BatteryTemperature     ' temperature of battery
  long  _WallPresent            ' true if wall is available
  long  _Wall                   ' right wall sensor value approx 0..500
  long  _Velocity               ' current speed as reported via sensor packet
  long  _LeftWheelVelocity
  long  _RightWheelVelocity
  long  _Radius                 ' current turning radius as reported via sensor packet
  byte  _isSongPlaying
  byte  _DigitalInputs
  long  _AnalogInput

  '' Calculated sensor data
  long  _mmTravelled            ' generic running total of millimeters travelled, can be reset without affecting distance/angle measurements
  long  _isUndocking            ' TRUE if we are attempting to Undock, get set to false as soon as we determine we are no longer docked
  long  _isDocking              ' TRUE when we are attempting to Dock
  long  _Bearing                ' current robot heading based on Angle sensor data
  long  _Distance               ' accumulated Distance Traveled
  long  _DistanceR              ' accumulated Distance, not reset with _Distance
  long  _Angle                  ' accumulated Angle
  long  _XCoord, _YCoord        ' current x,y coordinates

  '' Target Distance, Angle, and Heading settings
  long  _TargetSpeed
  long  _TargetAngle            ' direction of target
  long  _TargetDistance         ' distance of target in mm, decremented on each sensor reading
  long  _TargetHeading          ' desired robot Heading
  long  _TargetBearing          ' direction to go to get to Target X,Y Coordinates
  long  _TargetXYBearing        ' calculated on each sensordata update
  long  _TargetXYDistance       ' calculated on each sensordata update
  long  _TargetRange            ' distance to Target X,Y Coordinates
  long  _GoToTargetXY            ' we are actively working toward TargetXCoord, TargetYCoord
  long  _TargetXCoord
  long  _TargetYCoord           ' coordinates of where we want to be
  long  _TargetXYSpeed          ' speed we should use when going to X,Y
  long  _TopSpeed               ' target speed when using sonars to avoid objects

  long  newX,newY,newSpd,gotNewXY 

  byte  isTemporaryTarget
  byte  isTemporaryTargetCanceled
  long  _TargetHeading_temp
  long  _TargetDistance_temp
  long  _TargetXCoord_temp
  long  _TargetYCoord_temp
  long  _TargetXCoord_orig
  long  _TargetYCoord_orig
  long  lastDivertHeading
  byte  lastDivertTurnDir '(0=left,1=right)
  byte  _DivertReason      ' reason for last direction change
  byte  _DivertFunction        ' the PUB/PRI function that generated the Divert
  
  '' Status variables
  long  PwrFlag                 ' tracks last-kinow power state to detect the changes
  long  AutoDock
  long  AutoUndock              ' Undock when done charging
  long  _lastSpeed              ' last REQUESTED speed, set in Drive() and DriveDirect() routines
  long  _lastTurnDirection      ' indicates we are currently turning left -1, not 0, or right 1
  long  _lastTurnDegrees        ' number of degrees to turn toward target
  long  _lastTurnSpeed          ' speed at which we are turning, If we are turning
  long  _lastMovement           ' We need to move every so often to put a load on the battery for an accurate reading
  long  LastTurnClk             ' last CNT that we made a turn adjustment
  long  LastSpeedUpdateClk      ' last time we adjusted the speed toward our Target speed
  long  LastDistanceCheckClk    ' last time we check to see if we have reached our requested Distance
  long  TurnStartTime, StraightStartTime, TurnCount
  byte  _DriveMode
  long  _isTemporaryDriveMode  
  long  isAdjusting             ' indicates we are adjusting direction based on bumper or stuck

  '' Compass Variables
  long  CompassOffset           ' degrees to adjust compass results
  long  ptr_Compass             ' pointer to the current compass heading

  long  NextSongNum             ' the Song Queue
  byte  usrMode         

{{ Create Routines ****************************************************************** }}
PUB Start(_rxpin, _txpin, _pwrtogglepin, _pwrsenpin, _chrgsenpin) : ok  
  stop
  
  {Create pins}
  rxpin:=_rxpin
  txpin:=_txpin

  RobotPwrTogglePin := _pwrtogglepin
  RobotPowerSensePin := _pwrsenpin
  RobotChargePin := _chrgsenpin

  ok := (cog := cognew(CreateCog, @CreateStack)+1)

PUB Stop
  if cog
    SerialCreate.stop
    cogstop(cog~ - 1)

PRI CurrentMS
  return clock.TimeInMilliseconds

PRI TimeDiff(tim)
  return clock.TimeInMilliseconds - tim
    
PRI CreateCog | x
  {{ This cog will process the sensor data from the Create and RFID serial ports
      as well as poll the sonar and compass i2c sensors }}
      
  ReadInterval := DEFAULTPOLLINTERVAL                ' interval at which to poll the Create for sensor data

  dira[RobotPwrTogglePin]~~     'output
  outa[RobotPwrTogglePin]~

  d.start
  clock.start

  '' Initialize Create Serial Interface
  SerialCreate.Start(rxpin, txpin, 0, 57600)

  LastPacketClk := CurrentMS
  LastSpeedUpdateClk := CurrentMS
  LastTurnClk := CurrentMS
  _TargetHeading:=-1
  _TargetHeading_temp := -1

  NextSongNum := -1
  
  AutoUndock:=false
  AutoDock:=false
  ClearTarget  
{
  if not IsPowerOn
    PowerOn                                               ' power-up
}
  if isDocked
    PwrFlag:=true
  else
    PwrFlag:=not IsPowerOn                                ' handle transition initially
  _Enabled:=true

  isCheckSpeed:=true
  isCheckHeading:=true

  repeat
    doIdleLoop

PRI doIdleLoop
                                       '' Get and Process sensor data
    GetSensorData

    CheckPower

    if not _isSongPlaying
      if NextSongNum => 0
        doPlaySong(NextSongNum)
        NextSongNum:=-1

    if not isPaused
      if gotNewXY
        doGoToXY(newX,newY,newSpd)
        gotNewXY~

      'CheckBumpers

      'CheckSonars

      CheckDistance

      if isCheckSpeed
        CheckSpeed

      if isCheckHeading
        CheckHeading


PRI tx(c)
  SerialCreate.tx(c)
      
CON '' Request, Buffer, and Extract Sensor data from Create
PRI ClearSensorData
  _BatteryVoltage~
  _BatteryUsage~
  _BatteryRemaining~
  _BatteryCapacity~
  _BatteryRemaining~
  _Bumpers~
  _WallPresent~
  _Wall~
  _VirtualWall~
  _IRChar~   
  _Distance~
  _TargetDistance~
  _mmTravelled~
  _Angle~
  _Bearing~
  _OverCurrent~
  '_OverCurrentCounter~
  _Buttons~
  _ChargeState~
  _ChargerAvailable~
  _BatteryTemperature~
  _CliffL~
  _CliffFL~
  _CliffFR~
  _CliffR~
  _CliffLv~
  _CliffFLv~
  _CliffFRv~
  _CliffRv~
  _OIMode~
  _Velocity~
  _LeftWheelVelocity~
  _RightWheelVelocity~
  _Radius~
  _DigitalInputs~
  _AnalogInput~
  gotSensorData~

PRI GetSensorData | rxchar                              '' Get sensor data from Create serial interface
  repeat while (rxChar:=SerialCreate.rxcheck)=>0
    if isSensorData
      ' we are receiving sensor data
      sensors[sensorsPtr++]:=rxChar
      if sensorsPtr=>Sen6Size
        ' we have a complete sensor packet now
        '' TODO: store packet in temporary array, validate packet before moving in to sensors array
        isSensorData~
        gotSensorData~~
        ProcessSensorData
        _SensorPacketID++

  if _Enabled          ' request a sensor packet
    if TimeDiff(LastPacketClk) > ReadInterval 
        RequestSensorPacket(6)
    
PRI RequestSensorPacket(_packetid)                      '' Send a request for a packet to the Create
  '' TODO: store packet in temporary array, validate packet before moving in to sensors array
  bytefill(@sensors, 255, Sen6Size)
  sensorsPtr:=0                                         ' reset buffer position
  SerialCreate.rxflush
  isSensorData~~
  SerialCreate.tx(CmdSensors)
  SerialCreate.tx(_packetid)
  _SensorPacketReq++
  LastPacketClk:=CurrentMS
    

PRI ProcessSensorData | dx, ax, v                          '' Process a complete sensor packet
  ' this is called every time we receive a complete sensor packet

  ' Validate Sensor Data before populating variables
  v := sensors[SenCap1]<<8 | sensors[SenCap0]
  if (v<2700) or (v>2800)
    return -1   

  ' populate local variables with current data
  _BatteryVoltage:=sensors[SenVolt1]<<8 | sensors[SenVolt0]
  _BatteryUsage:=sensors[SenCurr1]<<8 | sensors[SenCurr0]
  _BatteryUsage:=~~_BatteryUsage
  _BatteryRemaining:=sensors[SenCharge1]<<8 | sensors[SenCharge0]
  _BatteryCapacity:=sensors[SenCap1]<<8 | sensors[SenCap0]
  _BatteryRemaining:=~~_BatteryRemaining

  _Bumpers:=sensors[SenBumpDrop]
  _WallPresent:=sensors[SenWall]
  _Wall:=sensors[SenWallSig1]<<8 | sensors[SenWallSig0]
  _VirtualWall:=sensors[SenVWall]

  _IRChar:=sensors[SenIRChar]   

  dx:=sensors[SenDist1]<<8 | sensors[SenDist0]
  dx:=~~dx
  _Distance+=dx
  _DistanceR+=dx

  if _TargetDistance<>0
    _TargetDistance-=dx
    if _TargetDistance < 0
      _TargetDistance := 0

  if _TargetDistance_temp<>0
    _TargetDistance_temp-=dx
    if _TargetDistance_temp < 0
      _TargetDistance_temp := 0

  _mmTravelled+=dx
                   
  ax:=sensors[SenAng1]<<8 | sensors[SenAng0]
  ax:=~~ax
  _Angle-=ax

  _Bearing-=ax
  if _Bearing>359
    _Bearing-=360
  elseif _Bearing<0
    _Bearing+=360

  CalcNewPosition(dx, Bearing, @_XCoord, @_YCoord)
  if _GotoTargetXY
    CalcTargetXYDistance 
    CalcTargetXYBearing

  _OverCurrent:=sensors[SenOverC]
  if (_BatteryUsage < -1100) 'or (_OverCurrent)
    _OverCurrentCounter++
  else
    _OverCurrentCounter~
  _Buttons:=sensors[SenButton]
  _ChargeState:=sensors[SenChargeState]
  _ChargerAvailable:=sensors[SenChAvailable]
  _BatteryTemperature:=sensors[SenTemp]

  _CliffL:=sensors[SenCliffL]
  _CliffFL:=sensors[SenCliffFL]
  _CliffFR:=sensors[SenCliffFR]
  _CliffR:=sensors[SenCliffR]

  _CliffLv := sensors[SenCliffLSig1]<<8 | sensors[SenCliffLSig0]
  _CliffFLv := sensors[SenCliffFLSig1]<<8 | sensors[SenCliffFLSig0]
  _CliffFRv := sensors[SenCliffFRSig1]<<8 | sensors[SenCliffFRSig0]
  _CliffRv := sensors[SenCliffRSig1]<<8 | sensors[SenCliffRSig0]

  _OIMode:=sensors[SenOIMode]

  v := sensors[SenVel1]<<8 | sensors[SenVel0]
  _Velocity := ~~v
  v := sensors[SenVelL1]<<8 | sensors[SenVelL0]
  _LeftWheelVelocity := ~~v
  v := sensors[SenVelR1]<<8 | sensors[SenVelR0]
  _RightWheelVelocity := ~~v
  v := sensors[SenRad1]<<8 | sensors[SenRad0]
  _Radius := ~~v

  _isSongPlaying := sensors[SenOISongPlay]

  _DigitalInputs := sensors[SenInputs]
  _AnalogInput := sensors[SenAInput1]<<8 | sensors[SenAInput0]


  'if _Velocity <> 0
  '  _lastMovement := clock.SecondsR

PRI DEG2PROP(Deg)               'Convert Deg to 13-bit Propeller angle for lookup
    Result := (Deg * 1024)/45
 
PRI Cos(angl)                  'Cos angle is 13-bit ; Returns a 16-bit signed value
    Result := sin(angl + $800)
 
PRI Sin(angl)                  'Sin angle is 13-bit ; Returns a 16-bit signed value
    Result := angl << 1 & $FFE
    if angl & $800
       Result := word[$F000 - Result]
    else
       Result := word[$E000 + Result]
    if angl & $1000
       -Result
       
PUB CalcNewPosition(dist, angl, xptr, yptr) | x, y, h               '' Calculate new position using dist and angl
  ' update current x,y coordinats with new values based on distance and angle from current xptr and yptr
  ' radians = angl/57.296= angl/(180/pi)
  ' newx = dist * sin(radians)
  ' newy = dist * cos(radians)
  if dist <> 0
    LONG[xptr] += ( sin( deg2prop(angl)) * dist / 65536)
    LONG[yptr] += ( cos( deg2prop(angl)) * dist / 65536)

CON '' Check **Power** Status and for new Command, Power changes, Distance, Speed, and Heading conditions
PRI CheckPower                                          '' Check power-related data 
  if not (isDocked or isDocking or isUndocking)                       '' We are not NOT docked or actively docking
    if PwrFlag   ' Power was on
      if not IsPowerOn ' now it's off
        waitcnt(clkfreq/1000*500+cnt) ' wait a bit, check again   
        if not IsPowerOn
          _Enabled:=false
          PwrFlag:=false
          ClearSensorData
          return
    else ' Power was off
      if IsPowerOn  ' now it's ON
        PwrFlag:=true
        _Enabled:=true
        ClearSensorData
        LastPacketClk := currentMS

  '' No power, nothing else matters
  if not isPowerOn  
    return

  '' We are now docked after actively docking
  if isDocking and isDocked
    _isDocking:=false
    ClearNavData
    ClearTarget
    DelayMs(5000)
    doPassiveMode
    _ChargeState := FULL_CHG
    return


  '' UnDock when we are charged
{
  if gotSensorData and isDocked and (not isUndocking) and (not isCharging)
    '' we are docked and charging is complete
    if AutoUndock 
      UnDock
    else
      ' change mode to stop charging
      if _OIMode <> MODE_FULL
        doFullMode
        _ChargeState := NO_CHG
    return
}


  '' Check Battery Level
  if gotSensorData and ChargerAvailable and not isCharging
    if (BatteryVoltage < 14200) ' we have a low battery
      doSoftReset
      _ChargeState := FULL_CHG
      return

  if (usrMode<>0) and (usrMode<>_OIMode)
    if not isPowerOn
      PowerOn
    case (usrMode)
      1: doPassiveMode
      2: doPassiveMode
        doSafeMode
      3: doPassiveMode
        doFullMode

CON '' Check **Distance** and Slow to a Stop when TargetDistance is reached
PRI CheckDistance                                      '' stop if we've reached our target distance
  if TimeDiff(LastDistanceCheckClk) < DISTANCECHECKINTERVAL
    return

  LastDistanceCheckClk:=CurrentMs

  if isDocked or isDocking or isUndocking or isCharging
    return
    
  if (_TargetHeading_temp=>0) and (_TargetDistance_temp==0)
    _TargetHeading := _TargetHeading_temp
    _TargetHeading_Temp := -1

  if _GotoTargetXY
    ' _TargetDistance:=TargetXYDistance*25.4 ' convert distance to mm
    if targetxydistance < 4 or (isTemporaryTarget and TargetxyDistance < 10)
      if isTemporaryTarget
        ' Check toward target to see if the path is clear yet or extend distance
      else      
        ClearTarget ' we are DONE
        doSetTargetSpeed(0)
    elseif (targetxydistance<16) and (_TargetSpeed>50) ' slow as we get near target
      if not isTemporaryTarget
        'doSetTargetSpeed(50)
        
    return

  if _TargetDistance==0
    return
    
'  if (_TargetSpeed > 0 and (TargetDistance < 3)) or (_TargetSpeed < 0 and TargetDistance > -3)
  '' are we there yet?
  if (_TargetSpeed > 0) and (TargetDistance < 6)
    ClearTarget
    doSetTargetSpeed(0)
    if isUndocking
      _isUndocking:=false
      ClearNavData
      ClearTarget
  elseif (_TargetDistance<>0) and (TargetDistance < 6) and (_TargetSpeed > 50)  
    '' we are close, so slow down
    if (not _gototargetxy) or (_gototargetxy and not isTemporaryTarget)
      'doSetTargetSpeed(50)

      
CON '' Adjust **Speed** to match TargetSpeed
PRI CheckSpeed  
  if TimeDiff(LastSpeedUpdateClk) < SPEEDCHECKINTERVAL
    return
    
  LastSpeedUpdateClk:=CurrentMs

  if isDocked or isDocking or isCharging or isUndocking
    return
       
  if (_lastSpeed==0) and (_TargetSpeed>0)  
    doSetSpeed(5) ' start moving from a stop
  elseif (_lastSpeed==0) and (_TargetSpeed<0) 
    doSetSpeed(-5)
  elseif _TargetSpeed == _lastSpeed
    ' nothing to do
    return

  ' adjust speed toward target
  if _TargetSpeed > _lastSpeed
    doAdjustSpeed(SPEEDADJUSTINCREMENT) 
    if (_lastSpeed > _TargetSpeed) 
      doSetSpeed(_TargetSpeed)
  elseif _TargetSpeed < _lastSpeed
    doAdjustSpeed(-SPEEDADJUSTINCREMENT)
    if (_lastSpeed < _TargetSpeed) 
      doSetSpeed(_TargetSpeed)
    
CON '' Check **Heading** and Automatically Adjust to maintain Target Heading
PRI CheckHeading | turndir,turndeg,turnrad,turnspd                                 '' make adjustments if Bearing doesn't match Target Bearing
  if TimeDiff(LastTurnClk) < HEADINGCORRECTINTERVAL
    return

  LastTurnClk:=CurrentMs

  if isDocked or isDocking or isUndocking or isCharging
    return

  if _GotoTargetXY
    if (_TargetHeading_temp<0)
      _TargetHeading := TargetXYBearing
  elseif (_TargetHeading < 0)  
   _LastTurnDirection := 0
   _LastTurnDegrees := 0
    return    

  turndir := calcTurnDirection(_TargetHeading, TURNERROR) ' Direction -1,0,1 to target
  turndeg := CalcTurnDegrees(_TargetHeading, Bearing) ' direction in degrees to target
  turnrad := DRIVINGTURNRADIUS ' angle at which to turn
  turnspd := TURNSPEED ' speed at which to turn
  
  if _gototargetxy or (_DriveMode > DM_Normal)
    if (turndir <> 0) ' turn right or left
      ' adjust turn speed based on amount needed to turn

      if (||turndeg>110) 
        ' turn in place
        turnrad:=1
        settargetspeed(turnspd)
'      elseif (||turndeg>30) 'and (turndir <> _lastturndirection)
'        turnrad := 90 ' turn faster
'        settargetspeed(turnspd)
      elseif (||turndeg>10) 'and (turndir <> _lastturndirection)
        'if (currentspeed>200)
        if (currentspeed>200) 'and (targetdistance>12)
          turnrad := (currentspeed/2) #> 100' slower turn
        else
          turnrad := 100 ' faster 
      
    else
      settargetspeed(_targetxyspeed)
  else
    if (turndir<>0) and (||turndeg>140) and _lastspeed>0 
      settargetspeed(turnspd)
      turnrad := 1
    elseif (turndir<>0) and (||turndeg>50)
      turnrad := 200
    elseif (turndir<>0) and (||turndeg>30)
      turnrad := 300

  ' if turndeg > 25 then we should turn-in-place, then resume speed
  if turndir == 0 ' go straight
    if _lastspeed <> 0
      doDrive(_lastspeed, RadStraight)
    elseif (turndir <> _lastturndirection)
      doDriveStop
  else
    if turndir == RadCW ' turn right
      if _lastSpeed==0
        if ||turndeg < 10
          doDrive(turnspd/2, turndir) ' turn a little slower when close
        else
          doDrive(turnspd, turndir)
      else      
        if _lastSpeed>0 
          doDrive(_lastspeed, -turnrad)
        else
          doDrive(_lastspeed, turnrad)
    elseif turndir == RadCCW ' turn left
      if _lastSpeed==0
        if ||turndeg < 10
          doDrive(turnspd/2, turndir)
        else
          doDrive(turnspd, turndir)
      else
        if _lastSpeed>0
          doDrive(_lastspeed, turnrad)                            ' turn in appropriate direction based of fwd or rev travel
        else
          doDrive(_lastspeed, -turnrad)
         
  _LastTurnDirection := turndir
  _LastTurnDegrees := turndeg

CON '' Check **Bumpers**
PRI CheckBumpers | x, h, td, b, tim, stuk
  '' Check Bumpers
  if Not GoToTargetXY
    return

  if LastSpeed == 0
    return

  stuk := isStuck
    
  b := Bumpers
  
  if (b & BumpEither) or stuk
    isAdjusting~~    
    if stuk
      ResetOverCurrent
    x := _TargetSpeed
    Drive(-125, RadStraight)
    waitcnt(clkfreq/1000*1000+cnt)
    tim:=1500
    case (_DriveMode)
      DM_Normal:
        if ((b & BumpBoth) == BumpBoth) or stuk
          if TurnDegrees>0
            td := RadCW
          elseif TurnDegrees<0
            td := RadCCW
        elseif (b & BumpRight) == BumpRight
          td := RadCCW
        elseif (b & BumpLeft) == BumpLeft
          td := RadCW
      DM_Left:
        td := RadCW
        tim := 2000
        if (b & BumpLeft) == BumpRight
      DM_Right:
        td := RadCCW
        tim := 2000
        if (b & BumpLeft) == BumpLeft
      
    Drive(TURNSPEED, td)
    waitcnt(clkfreq/1000*tim+cnt)

    if _DriveMode == DM_Normal
      if (not GotoTargetXY)
        if x > 0
          SetSpeed(10)
          SetTargetSpeed(x)
        else
          DriveStop
      else
        if td==RadCW
          h := CalcHeadingFromOffset(35)
        else
          h := CalcHeadingFromOffset(-35)
         
        DivertToTarget(h, 10)
        'ResumeTarget
    else
      doSetHeading(Bearing)

    isAdjusting~~    
    _Bumpers~

   
CON '' Methods to control the Create Power 
PRI TogglePowerPin
  dira[RobotPwrTogglePin]~~     'output

  outa[RobotPwrTogglePin]~  
  outa[RobotPwrTogglePin]~~
  outa[RobotPwrTogglePin]~  

PUB PowerToggle                '' Toggle Robot Power
  if IsPowerOn
    PowerOff
  else
    PowerOn

PRI doSoftReset
  ClearNavData
  ClearTarget
  tx(CmdSoftReset)
  DelayMs(3900)
  doPassiveMode
  ClearSensorData

PUB IsPowerOn     '' TRUE if robot power is ON
  dira[RobotPowerSensePin]~   'input
  return ina[RobotPowerSensePin]
    
PUB IsCharging                 '' TRUE if Charging
  if ((_ChargeState==RECON_CHG) or (_ChargeState==FULL_CHG))
    return true
  else
    return false
    
PUB PowerOn                     '' Toggle Robot Power ON
  if not IsPowerOn
    PwrFlag:=false
    TogglePowerPin
    _OIMode := MODE_UNKNOWN
  repeat until ispoweron
  waitcnt(clkfreq/1000*3000+cnt)
  ClearSensorData
  doPassiveMode
  'SetBaud

PUB PowerOff                    '' Toggle Robot Power OFF
  if IsPowerOn
    PwrFlag:=true
    TogglePowerPin
    '_OIMode := MODE_UNKNOWN
    DelayMs(500)
    ClearSensorData
   
PUB SoftReset                   '' Perform Soft Reset on Robot
  doSoftReset
  
CON '' Methods to control the Create Mode 
PRI SetBaud  
  SerialCreate.Start(rxpin, txpin, 0, 57600)
  DelayMs(500)
  tx(CmdStart)
  DelayMs(200)
  tx(CmdBaud)
  tx(Baud19200)
  DelayMs(200)
  SerialCreate.Start(rxpin, txpin, 0, 19200)
  doPassiveMode
       
PRI doFullMode
  tx(CmdFull)
  doSetLEDs(0, 1, 0, 255)                                 ' Play LED and Power LED ON (Green)
  _OIMode:=MODE_FULL

PUB FullMode                      '' Set Full Mode
  usrMode := MODE_FULL

PRI doSafeMode
  tx(CmdSafe)
  doSetLEDs(0, 1, 0, 0)                                   ' Play LED ON
  _OIMode:=MODE_SAFE

PUB SafeMode                       '' Set Safe Mode
  usrMode := MODE_SAFE

PRI doPassiveMode
  tx(CmdStart)
  doSetLEDs(1, 1, 127, 255)                                   ' Play LED ON
  _OIMode:=MODE_PASSIVE
  DefineSongs

PUB PassiveMode                  '' Set Passive Mode
  usrMode := MODE_PASSIVE

CON '' Navigation commands 
PUB ClearCoordinates               '' Set Current X,Y to 0,0
  _XCoord:=0
  _YCoord:=0

PUB ClearNavData          '' Clear Distance and Angle data
  _Bearing:=0
  _Angle:=0
  _Distance:=0
  '_GoToTargetXY:=false

PUB ClearAngle
  _Angle:=0
  
PUB ClearTarget   '' clear target values for x,y and distance and angle and heading
  _GoToTargetXY := false
  isTemporaryTarget := 0
  _TargetDistance := 0
  _TargetHeading := -1
  '_TargetRange := 0
  '_TargetSpeed := 0

PUB SetXY(x,y)      '' Set CURRENT X,Y Coordiates
  _XCoord := x * 254 / 10 ' convert to millimeters
  _YCoord := y * 254 / 10

CON '' Speed
var
  long  InARut
  
PRI doDrive(velocity, radius)
  if isDocked or isdocking
    if not _isUndocking
      return
      
  if radius==RadStraight
    if StraightStartTime==0
      StraightStartTime:=Cnt
  else
    if (cnt-StraightStartTime)>(clkfreq/1000*3000)
      TurnCount~
      InARut~
    else
      TurnCount++
      InARut:=(TurnCount>5)

  tx(CmdDrive)
  tx(~~velocity >> 8)                         
  tx(velocity)
  tx(~~radius >> 8)                           
  tx(radius)
  
PUB Drive(velocity, radius)          '' Set Velocity and Direction
  doDrive(velocity, radius)
  
PRI doDriveDirect(RightVelocity, LeftVelocity)
  if isDocked or isDocking
    if not _isUndocking
      return

  tx(CmdDriveWheels)
  tx(~~RightVelocity >> 8)
  tx(RightVelocity)
  tx(~~LeftVelocity >> 8)
  tx(LeftVelocity)

PUB DriveDirect(Rv, Lv)               '' Set Left and Right Wheel Speed Directly
  doDriveDirect(Rv, Lv)
  
PUB LastSpeed                         '' Last Speed we told the robot to go
  return _lastSpeed

PUB CurrentSpeed                    '' Current Speed as reported by Create Sensor Data
  return _Velocity

PUB RightWheelVelocity               '' Current Speed of Right Wheel
  return _rightwheelvelocity

PUB LeftWheelVelocity                '' Current Speed of Left Wheel
  return _leftwheelvelocity
  
'' Speed  
PRI doAdjustSpeed(mmpersec)
  '' add/subtract mmpersec from current Speed
  _lastSpeed+=mmpersec
  if _lastSpeed < -500
    _lastSpeed := -500
  if _lastSpeed > 500
    _lastSpeed := 500
  doDrive(_lastSpeed, RadStraight)

PUB AdjustSpeed(mmpersec)         '' Increase/Decrease Current Speed
  doAdjustSpeed(mmpersec)
  
PRI doSetSpeed(mmpersec)
  '' set speed to mmpersec
  if _lastSpeed==mmpersec
    if mmpersec<>0
      return

  _lastSpeed:=mmpersec
  doDrive(_lastSpeed, RadStraight)

PUB SetSpeed(mmpersec)           '' Set Current Speed
  doSetSpeed(mmpersec)

PRI doAdjustTargetSpeed(mmpersec)
  if (isDocked and not _isUndocking) or isDocking
    return
  
  _TargetSpeed+=mmpersec
  if _TargetSpeed < -500
    _TargetSpeed:=-500
  if _TargetSpeed > 500
    _TargetSpeed:=500

PUB AdjustTargetSpeed(mmpersec)     '' Increase/Decrease Target Speed
  doAdjustTargetSpeed(mmpersec)
  
PRI doSetTargetSpeed(mmpersec)
  _TargetSpeed := mmpersec
  if (_lastSpeed==0) 
    doSetSpeed(50)

PUB SetTargetSpeed(mmpersec)     '' set target speed to ramp up/down to
  doSetTargetSpeed(mmpersec)

PRI doDriveSTOP
  if not isPaused
    _isDocking:=false
    _isUndocking:=false
    _TargetSpeed:=0
    _TargetDistance:=0
    _lastSpeed:=0
    _DriveMode:=0  
    SetDriveMode(DM_Normal, 250)
    
  Drive(0, RadStraight)

PUB DriveStop         '' FULL STOP - Clears all targets
  doDriveStop

PUB DrivePause                 '' temporarily stop trying to drive and adjust heading
  'doDrive(0, RadStraight)
  isPaused:=true
  isCheckSpeed:=false
  isCheckHeading:=false

PUB DriveResume                '' resume after DrivePause
  isPaused:=false
  isCheckSpeed:=true
  isCheckHeading:=true

PUB SetCheckSpeed(tf)         '' Enable/Disable automatic Speed Ramping to Targetspeed
  isCheckSpeed:=tf

PUB SetCheckHeading(tf)       '' Enable/Disable automatic heading adjust twoard X,Y Target
  isCheckHeading:=tf

PUB SetDriveMode(dm, topspd)    '' Set the Drive Mode and Top Speed
  _Drivemode := dm
  _TopSpeed := topspd
  
CON '' Heading  
PUB CalcTurnDegrees(dheading, dbearing)     '' Calculate how many degrees to turn from bearing to heading
  ' bearing is the direction you are Facing
  ' heading is the direction you want to go
  ' result is the difference (+/- 0..180) of degrees
  
  if(dheading>dbearing)
    dheading-=360
  result:=dbearing-dheading
  if result > 180
    result := -(360-result)
  return -result

PUB CalcTurnDirection(dheading, dPlusMinus) : turndir | diff1  '' calculate direction to turn from current Bearing to dheading
  ' 1=left RadCCW, 0=straight, -1=right RadCW
  if dHeading==-1
    return 0
  
  diff1:=CalcTurnDegrees(dheading, bearing)
   
  if(||diff1<dPlusMinus)
    turndir:=0
  elseif(diff1<0)
    turndir:=RadCCW
  else               
    turndir:=RadCW   
   
  return turndir

PRI FixTargetHeading
  if _TargetHeading>359
    _TargetHeading-=360
  elseif _TargetHeading<0
    _TargetHeading+=360
  
PRI doAdjustHeading(deg_offset)
  if isDocked or isDocking or _isUndocking
    return
  
  if _TargetHeading<0
    _TargetHeading:=Bearing   
  
  _TargetHeading+=deg_offset
  FixTargetHeading

PUB CalcHeadingFromOffset(deg_offset)      '' Calculate new heading from a +/- Offset
  result := Bearing + deg_offset
  if result > 359
    result -= 360
  elseif result < 0
    result += 360

PUB AdjustHeading(deg_offset)         '' Adjust the heading +/- degrees from current heading
  doAdjustHeading(deg_offset)

PRI doSetHeading(deg)
  if isDocked or isDocking or isUndocking
    return
  _TargetHeading:=deg
  FixTargetHeading
  LastTurnClk:=0
  'CheckHeading

PUB SetHeading(deg)                     '' Set the heading you want to robot to turn to
  doSetHeading(deg)
  
PRI doGoToXY(x,y,spd) ' in Inches
  if _lastspeed==0
    ClearTarget
  _TargetXCoord_orig := x
  _TargetYCoord_orig := y
  _TargetXCoord := x
  _TargetYCoord := y
  _TargetXYSpeed := spd
  CalcTargetXYDistance
  CalcTargetXYBearing
  SetHeading(TargetXYBearing)
  
  if (||TurnDegrees < TURNERROR) and (_TargetSpeed==0)
    SetTargetSpeed(_TargetXYSpeed)

  SetDriveMode(DM_Normal, 250) 
  _GoToTargetXY := true

PRI DivertTargetXY(tempx, tempy)
  isTemporaryTarget := 1
  _TargetXCoord := tempx
  _TargetYCoord := tempy
  CalcTargetXYDistance
  CalcTargetXYBearing
  doSetHeading(TargetXYBearing)
  doSetSpeed(50)
  doSetTargetSpeed(_TargetXYSpeed)

  _GoToTargetXY := true

PUB DivertToTarget(xhdg, xdist) | x,y     '' Temporarily divert to another target
  lastDivertHeading := xhdg
  x := XCoord
  y := YCoord
  CalcNewPosition(xdist, xhdg, @x, @y)    
  DivertTargetXY(x, y)
   
PRI ResumeTarget
  if isTemporaryTarget==0
    return
    
  isTemporaryTarget := 0
  isTemporaryTargetCanceled := 0
  _TargetXCoord := _TargetXCoord_orig
  _TargetYCoord := _TargetYCoord_orig
  CalcTargetXYDistance
  CalcTargetXYBearing
  doSetHeading(TargetXYBearing)
  doSetSpeed(50)
  doSetTargetSpeed(_TargetXYSpeed)

  _GoToTargetXY := true

PUB GoToXY(x,y,spd)             '' Tell robot to go to X,Y Cordinate
  '' DO NOT call this from the CreatOI Cog, it will hang, it is expecting the Cog to process the request before returning.
  if not _GoToTargetXY
    doGoToXY(x,y,spd)
  else  
    newX:=x
    newY:=y
    newSpd:=spd
    gotNewXY~~
    repeat until not gotNewXY
  
PRI CalcTargetXYBearing | a                                      '' direction to the Target X,Y Coordinates
  _TargetXYBearing := d.CoordsToDegs(xcoord, ycoord, _targetxcoord, _targetycoord)/10
  if _TargetXYBearing<0
    _TargetXYBearing+=360

PUB TargetXYBearing                 '' returns Current heading to target
  return _TargetXYBearing

PUB CalcXYBearing (curX, curY, tarX, tarY) | a      '' Calculate direction to a target
  ' calculate direction from a point to a target
  result := d.CoordsToDegs(curX, curY, tarX, tarY)/10
  if result<0
    result+=360

PUB Turn(deg) '' Not Available - turn a particular number of degrees based on Create's internal turn sensor

CON '' Distance
PRI doDriveDistancemm(dist, spd)                          '' Drive Distance in millimeters
  _TargetDistance := dist
  if _TargetHeading<0
    _TargetHeading:=Bearing

  SetTargetSpeed(spd)

'' FIX not starting when drivedistance is called
  if (_lastSpeed ==0)
    if dist > 0
      doSetSpeed(5) ' start out slowwwwww
    else
      doSetSpeed(-5)

PRI doDriveDistance(dist, spd)                            '' Drive Distance in Inches
  doDriveDistancemm(dist*254/10, spd)                          ' convert to millimeters

PUB DriveDistance(dist, spd)     '' Dirve a specific Distance (inches)
  doDriveDistance(dist, spd)

PUB CalcDistance(fromx, fromy, tox, toy) | x,y      '' Calculate Distance between two points
  ' calculate distance directly to target
  ' (solve for the hypotenuse of the triangle) hypotenuse=sqrt(x^2 + y^2)
  if (fromx>tox)
   x:=fromx-tox
  else
   x:=tox-fromx
  if (fromy>toy)
   y:=fromy-toy
  else
   y:=toy-fromy 
  result := ^^(x*x+y*y) 
   
    
PRI CalcTargetXYDistance | x,y,h                                    '' distance to Target x,y Coordinates
 ' calculate distance directly to target
 ' (solve for the hypotenuse of the triangle) hypotenuse=sqrt(x^2 + y^2)
 _TargetXYDistance := CalcXYDistance(XCoord, YCoord, _TargetXCoord, _TargetYCoord)
{
 if (XCoord>_TargetXCoord)
  x:=XCoord-_TargetXCoord
 else
  x:=_TargetXCoord-XCoord
 if (YCoord>_TargetYCoord)
  y:=YCoord-_TargetYCoord
 else
  y:=_TargetYCoord-YCoord 
 h:=^^(x*x+y*y)
 _TargetXYDistance:=h
}
PUB TargetXYDistance              '' Distance in Inches to Target
  return _TargetXYDistance

PUB CalcXYDistance (curX, curY, tarX, tarY) | x,y,h      '' distance to Target x,y Coordinates
 ' calculate distance directly to target
 ' (solve for the hypotenuse of the triangle) hypotenuse=sqrt(x^2 + y^2)
 if (curX>tarX)
  x:=curX-tarX
 else
  x:=tarX-curX
 if (curY>tarY)
  y:=curY-tarY
 else
  y:=tarY-curY
 h:=^^(x*x+y*y)
 result:=h

CON '' Docking
PRI doDock        
  DriveStop  
  _isDocking:=true
  _isUndocking:=false
  doRunDemo(1)
  _OIMode:=0

PUB Dock          '' start Create DOCK Demo
  doDock

PRI doUnDock              
  if (not isDocked) or (_isUndocking) or (isDocking)
    return
  _isUndocking:=true
  doFullMode
  waitcnt(clkfreq/1000*1000+cnt)
  doDrive(-300, RadStraight)
  waitcnt(clkfreq/1000*1500+cnt)
  doDrive(0, RadStraight)
  _isUndocking:=false

PUB UnDock        '' Start UNDOCK routine  
  doUnDock
  
CON '' Make sensor data available to other objects 
PUB psensors(id)               '' returns a raw sensor data byte
  return sensors[id]

PUB SensorBearing              '' Bearing calculated from Sensor Data
  return _Bearing

PRI Compass                        '' returns Compass Heading value from ptr_Compass
  return WORD[ptr_Compass]/10

PRI HAdj(hdg, adj)              ' adjust a heading by hdg degrees and return result
  result := hdg + adj
   
  if result>359
    result-=360
  elseif result<0
    result+=360
  
PUB Bearing           '' Current Heading from Compass (if availble) or Calculated from Sensor Data
  if ptr_compass<>0
    return Hadj(Compass, CompassOffset)
  else
    return Hadj(_Bearing, CompassOffset)

PUB Distancemm                          '' Total distance travelled since last Nav Reset
  return _Distance

PUB Distance | x                        '' Distance travelled in Inches
  x := (_Distance*10/254)
  return x

PUB DistanceR                   
  return (_DistanceR*10/254)

PUB Angle                              '' Angle reported from last sensor data packet                 
  return _Angle

PUB XCoordmm                                            '' Current X coordinates in millimeters
  return _XCoord

PUB XCoord | x                                              '' Current X coordinate in Inches
  x := _XCoord*10/254
  return x

PUB XCoordft                                            '' Current X coordinates in FEET
  return XCoord/12                               

PUB YCoordmm                                            '' Current Y coordinate in Millimeters
  return _YCoord

PUB YCoord | x                                            '' Current Y coordinate in Inches
  x := _YCoord*10/254 
  return x                              
  
PUB YCoordft                                            '' Current Y coordinates in FEET                                                
  return YCoord/12                               

PUB BatteryVoltage                 '' Current battery voltage in mv
  return _BatteryVoltage

PUB BatteryUsage                    '' Current battery usage in ma
  return _BatteryUsage

PUB BatteryRemaining                 '' Battery Capacity Remaining in ma as reported by robot
  return _BatteryRemaining

PUB BatteryPct                       '' returns percentage of battery remaining
  if _BatteryRemaining <> 0
    return (_BatteryRemaining * 100)/(_BatteryCapacity)
  else
    return 999

PUB BatteryCapacity                '' Battery Capacity in ma as reported by robot
  return _BatteryCapacity

PUB BatteryTemperatureC                                 '' Battery Temperature in Degrees C
  return _BatteryTemperature

PUB BatteryTemperature                                  '' Battery Temperature in Degrees F
  return _BatteryTemperature * 9 / 5 + 32
  
PUB Bumpers                        '' bitmask of Bumpers and Wheel Drops
  return _Bumpers

PUB WallPresent                   '' Wall Sensor TRUE/FALSE Value
  return _WallPresent

PUB Wall                          '' Wall Sensor Analog Value
  return _Wall

PUB VirtualWall                   '' Indicates if a Virtual Wall was detected
  return _VirtualWall

PUB IRChar                      '' indicates currently received IR byte froma remote or docking station
  return _IRChar

PUB OverCurrentCounter          '' consecutive packets with OverCurrrent flag set
  return _OverCurrentCounter

PUB Buttons                     '' returns robot Play and Advance Button status
  return _Buttons

PUB ChargeState                 '' return current Charge State
  return _ChargeState

PUB OIMode                      '' returns current OI Mode
  return _OIMode

PUB ChargerAvailable            '' TRUE if robot detects a Charger connected
  return _ChargerAvailable

PUB isDocked                       '' TRUE if robot detects DOCK
  dira[RobotChargePin]~                                 'input

  return ina[RobotChargePin]


PUB SensorPacketID                    '' indicates current sensor packet ID (counter)
  return _SensorPacketID
  ' _SensorPacketID := 0

PUB SensorPacketReq                   '' indicates how many sensor data requests we made since last called
  result := _SensorPacketReq
  _SensorPacketReq := 0

PUB CliffSensors                                        '' return bitmask of cliff sensors
  return (_CliffL<<3 | _CliffFL<<2 | _CliffFR<<1 | _CliffR)

PUB CliffL      '' return Left Cliff TRUE/FALSE Value
  return _CliffL
PUB CliffFL     '' return Front Left Cliff TRUE/FALSE Value
  return _CliffFL
PUB CliffFR     '' return Front Right Cliff TRUE/FALSE Value
  return _CliffFR
PUB CliffR      '' return Right Cliff TRUE/FALSE Value
  return _CliffR

PUB GetCliffSensors(sptr)     '' return actual values of cliff sensors in an Array
  ' pass in a pointer to 4 consecutive Words for results
  WORD[sptr] := _CliffLv
  WORD[sptr][1] := _CliffFLv
  WORD[sptr][2] := _CliffFRv
  WORD[sptr][3] := _CliffRv

PUB CliffLv               '' return Left Cliff Analog Value
  return _CliffLv
PUB CliffFLv              '' return Front Left Cliff Analog Value
  return _CliffFLv
PUB CliffFRv              '' return Front Right Cliff Analog Value
  return _CliffFRv
PUB CliffRv               '' return Right Cliff Analog Value
  return _CliffRv
  
PUB IsStuck                                    '' TRUE if OverCurrent for more then 15 Packets
  result := _OverCurrentCounter>15
'  if result
'  _OverCurrentCounter~

PUB ResetOverCurrent                           '' Reset OverCurrent Counter (used to eliminate spikes)
  _OverCurrentCounter~

PUB OverCurrent                                '' TRUE if OverCurrent Condition exists
  return _OverCurrent

PUB isDocking                                  '' TRUE if we are currently Docking
  return _isDocking

PUB isUndocking                                '' TRUE if we are currently Un-Docking
  return _isUndocking

PUB DigitalInputs                              '' Returns Digital Inputs (bits) from Create Sensor Data
  return _DigitalInputs

PUB AnalogInput                                '' Returns Analog Input from Create Sensor Data
  return _AnalogInput 

CON '' Target X,Y 

PUB TargetHeading                 '' Direction in degrees to Target
  return _TargetHeading

PUB TurnDirection                 '' Direction we need to turn toward target left=-1,0,right=1
  return _LastTurnDirection

PUB TurnDegrees                   '' degrees to Target from current heading +/-
  return _LastTurnDegrees

PUB TargetDistance              '' Distance to X,Y Target in Inches
  return (_TargetDistance*10/254)

PUB TargetSpeed                  '' the Target Speed are are ramping up/down to
  return _TargetSpeed

PUB TargetXCoord              '' X Coordinate we are tracking to 
  if _gototargetxy
    return _TargetXCoord_orig
  else
    return 0

PUB TargetYCoord               '' Y Coordinate we are tracking to
  if _gototargetxy
    return _TargetYCoord_orig
  else
    return 0

PUB GotoTargetXY  ' TRUE if we are actively tracking to TargetXCoord,TargetYCoord
  return _gotoTargetXY

PUB isTempTarget                   '' indicates if we are GoingTo a Temporary Target
  return isTemporaryTarget

PUB TemporaryTargetXCoord          '' returns Temporty Target Y Coordinate
  if isTemporaryTarget
    return _TargetXCoord_temp
  else
    return 0

PUB TemporaryTargetYCoord          '' returns Temporty Target Y Coordinate
  if isTemporaryTarget
    return _TargetYCoord_temp
  else
    return 0
    
PUB CancelTempTarget                '' cancels temporary target and resumes toward Target
  isTemporaryTargetCanceled~~
  
PUB SetDivertReason(DF, DR)         '' Used for debugging while avoiding objects 
  _DivertReason := DR
  _DivertFunction := DF
  PlaySong(1) ' blip

PUB DivertReason                    '' reason for last Divert
  return _DivertReason

PUB DivertFunction                 '' in what way/method are we Diverting
  return _DivertFunction

CON '' Sensor Pointers
PUB SetCompassPtr(ptr)             '' Sets ptr_Compass so the robot has a compass value to reference instead of just the internal angle sensor
  ptr_Compass:=ptr

CON '' More Create Commands
PUB mmTravelled                         '' Millimeters Travelled since last call to Reset_mmTravelled
  return _mmTravelled

PUB Reset_mmTravelled                   '' Reset mmTravelled counter
  _mmTravelled:=0

PRI doPlaySong(num)
  if _isSongPlaying
    return
  _isSongPlaying:=1
  tx(cmdPlay)
  tx(num)

PUB PlaySong(num)                     '' Play a Song
  NextSongNum:=num

PUB isSongPlaying                      '' TRUE if a Song is Playing
  return isSongPlaying

PRI doSetPWM(lsd0pwm, lsd1pwm, lsd2pwm)
{
This command lets you control the three low side drivers
with variable power. With each data byte, you specify the
PWM duty cycle for the low side driver (max 128). For
example, if you want to control a driver with 25% of battery
voltage, choose a duty cycle of 128 * 25% = 32.
}
  tx(cmdPWMMotors) 
  tx(lsd2pwm) 
  tx(lsd1pwm) 
  tx(lsd0pwm)

PUB SetPWM(pwm0,pwm1,pwm2)        '' Set PWM Outputs for LSD's
  doSetPWM(pwm0,pwm1,pwm2)

PRI doSetLSD(lsd)
{
This command lets you control the three low side drivers. The
state of each driver is specified by one bit in the data byte.
Low side drivers 0 and 1 can provide up to 0.5A of current.
Low side driver 2 can provide up to 1.5 A of current. If too
much current is requested, the current is limited and the
overcurrent flag is set (sensor packet 14).
}
  tx(cmdMotors)
  tx(lsd)

PUB SetLSD(lsd)             '' Set Lowside Drivers
  doSetLSD(lsd)

PRI doSetLEDs(advanceled, playled, powercolor, powerintensity) | b
  b := (advanceled << 3) | (playled << 1)
  tx(CmdLeds)
  tx(b)
  tx(powercolor)
  tx(powerintensity)

PUB RunDemo(dnum)       '' run a built-in demo
  doRunDemo(dnum)

PRI doRunDemo(dnum)     
  tx(CmdDemo)
  tx(dnum)
  
PRI doSendIRChar(ch)
  tx(CmdIRChar)
  tx(ch)

PUB SendIRChar(ch)       '' Send an IR Byte out LSD1
  doSendIRChar(ch)

PUB SetCompassOffset(ofs)     '' Set Compass Offset (adjust for a "logical" north)
  CompassOffset := ofs

CON '' Delay Routines
PRI DelayMs(ms) | m
  waitcnt(clkfreq/1000*ms+cnt)

CON '' Define Songs
PRI DefineSongs | x
  tx(cmdSong)
  repeat x from 0 to 9
    tx(SONG0[x])
    
  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG1[x])

  tx(cmdSong)
  repeat x from 0 to 5
    tx(SONG4[x])

  tx(cmdSong)
  repeat x from 0 to 5
    tx(SONG6[x])
    
  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG8[x])

  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG9[x])

  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG10[x])

  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG11[x])

  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG12[x])

  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG13[x])

  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG14[x])

  tx(cmdSong)
  repeat x from 0 to 3
    tx(SONG15[x])


DAT
atanTbl   long   -0.0117212, 0.05265332, -0.011643287
          long   0.19354346, -0.33262348, 0.99997723

'' some pre-defined songs          
SONG0                   byte    0, 4, 96, 4, 84, 4, 72, 4, 60, 4   ' 6 bytes
SONG1                   byte    1, 1, 96, 8
'SONG2                   byte    2, 2, 96, 8, 96, 8
'SONG3                   byte    3, 1, 60, 4, 72, 4, 84, 4, 96, 4   ' 6 bytes
SONG4                   byte    4, 2, 90, 16, 78, 16
'SONG5                   byte    5, 1, 71, 4
SONG6                   byte    6, 2, 100, 4, 100, 4

SONG15                   byte   15, 1, 36, 6
SONG14                   byte   14, 1, 48, 6
SONG13                   byte   13, 1, 60, 6
SONG12                   byte   12, 1, 72, 6
SONG11                   byte   11, 1, 84, 6
SONG10                   byte   10, 1, 96, 6
SONG9                   byte   9, 1, 108, 6
SONG8                   byte   8, 1, 120, 6

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