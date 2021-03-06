'' max1270 ADC
'' -- dan miller
'' -- 16 july 2006
''




CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000
  
  ClkAdc        = 5             ' A/D clock
  CsAdc         = 4             ' Chip Select for ADC
  AoutAdc       = 3             ' A/D Data out
  AinAdc        = 0             ' A/D Data in
  
  

{{

Table 1. Control-Byte Format
BIT 7(MSB)   BIT 6 BIT  5 BIT 4 BIT 3 BIT 2 BIT 1  BIT 0(LSB)
START        SEL2  SEL1   SEL0  RNG   BIP   PD1    PD0

BIT        NAME           DESCRIPTION
7 (MSB)    START          First logic 1 after CS goes low defines the beginning of the control byte.
6          SEL2           These 3 bits select the desired “on” channel (Table 2).
5          SEL1
4          SEL0
3          RNG            Selects the full-scale input voltage range (Table 3).
2          BIP            Selects the unipolar or bipolar conversion mode (Table 3).
1          PD1            Select clock and power-down modes
0 (LSB)    PD0 

 Channel Selection
SEL2 SEL1 SEL0 CHANNEL
0    0    0    CH0
0    0    1    CH1
0    1    0    CH2
0    1    1    CH3
1    0    0    CH4
1    0    1    CH5
1    1    0    CH6
1    1    1    CH7

 Power-Down and Clock Selection
PD1   PD0   MODE
0     0     Normal operation (always on), internal clock mode.
0     1     Normal operation (always on), external clock mode.
1     0     Standby power-down mode (STBYPD), clock mode unaffected.
1     1     Full power-down mode (FULLPD), clock mode unaffected.


RANGE AND POLARITY SELECTION FOR THE MAX1270
INPUT RANGE     RNG     BIP     Negative FULL SCALE     ZERO SCALE (V)  FULL SCALE
0 to +5V        0       0       —                       0               VREF x 1.2207
0 to +10V       1       0       —                       0               VREF x 2.4414
±5V             0       1       -VREF x 1.2207          0               VREF x 1.2207
±10V            1       1       -VREF x 2.4414          0               VREF x 2.4414



for example 0-10 vdc, no power down, internal reference is %10001000

How to Start a Conversion
The MAX1270 uses either an external serial
clock or the internal clock to complete an acquisition
and perform a conversion. In both clock modes, the
external clock shifts data in and out. See Table 4 for
details on programming clock modes.
The falling edge of CS does not start a conversion on
the MAX1270; a control byte is required for
each conversion. Acquisition starts after the sixth bit is
programmed in the input control byte. Conversion
starts when the acquisition time, six clock cycles,
expires.
Keep CS low during successive conversions. If a startbit
is received after CS transitions from high to low, but
before the output bit 6 (D6) becomes available, the current
conversion will terminate and a new conversion will
begin.

}}

OBJ
  bs2   : "bs2_functions"
  
  delay : "timing"
 
  
var   long stack1[20]
  
pub start(control,average,ADC_addr)

  cognew(get_count(control,average,ADC_addr),@stack1)
  
              
pub get_count(control_bit, average_sample, ADC_count_address) | temp, adresult_temp

   repeat
      adResult_temp := 0 
      repeat average_sample                             '' how many samples to average
        
        delay.pause1ms(10)                              ' wait 10 msecond    
        outa[CsAdc] := 0                                '' signal chip select
      
        bs2.SHIFTOUT(AoutAdc, ClkAdc,control_bit, BS2#MSBFIRST,8 ) '' put the control bit out
        outa[CsAdc] := 1                                             
        outa[CsAdc] := 0 
        temp := bs2.SHIFTIN(AinAdc, ClkAdc, BS2#MSBPRE,12)         '' data in
        adResult_temp := adResult_temp + temp
        outa[CsAdc] := 1
    
      long[ADC_count_address] := adResult_temp / average_sample                       ' average samples
      
    





        