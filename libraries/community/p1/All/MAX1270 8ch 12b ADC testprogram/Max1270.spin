'' max1270 ADC
'' -- HJ Kiela
'' -- 16 july 2009
'' Multi channel version with averaging Based on BS2 SPI functions.
'' An ASM based version should follow some time later




CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000
  
  ClkAdc        = 10             ' A/D clock
  CsAdc         = 11             ' Chip Select for ADC
  AoutAdc       = 8             ' A/D Data out to 1270
  AinAdc        = 9             ' A/D Data in from 1270
  
{'' MAX1270 Setup
      CS    = 11                 '' Set 1270 CSn Pin
      CLK   = 10                 '' Set 1270 Clock Pin
      Din   = 8                  '' Set 1270 Data in Pin
      Dout  = 9                  '' Set 1270 Data out Pin  
}
{{
--------------------------------------------------------------------------------------------------------
     The MAX1270 is uses fast ADC via the SPI's asm assembly SHIFTIN and SHIFTOUT functions.
--------------------------------------------------------------------------------------------------------

Schematic MAX1270:
                    Vdd
                     
                ┌────┴────┐
     CSn --─--─┤6   1  13├──Ch0
                │         │
     CLK ──────┤5       x├──Chx
                │         │
     Di ───────┤7      20├──Ch7
                │         │
     Do ───────┤10  24   ├
                └────┬────┘
                     
                    Vss


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

How to Start a Conversion: The MAX1270 uses either an external serial
clock or the internal clock to complete an acquisition and perform a conversion. In both clock modes, the
external clock shifts data in and out. See Table 4 for details on programming clock modes.
The falling edge of CS does not start a conversion on the MAX1270; a control byte is required for
each conversion. Acquisition starts after the sixth bit is programmed in the input control byte. Conversion
starts when the acquisition time, six clock cycles, expires.
Keep CS low during successive conversions. If a startbit is received after CS transitions from high to low, but
before the output bit 6 (D6) becomes available, the current conversion will terminate and a new conversion will
begin.

}}

con'' MAX1270 Setup
      CS    = 11                 '' Set 1270 CSn Pin
      CLK   = 10                 '' Set 1270 Clock Pin
      Din   = 8                  '' Set 1270 Data in Pin
      Dout  = 9                  '' Set 1270 Data out Pin

OBJ
  bs2   : "bs2_functions a"
  Delay : "timing"
 
  
var   long stack1[20]
      long CogNr
  
pub start(average,ADC_addr, nCh)  'Run continuous ADC in cog if you want

  CogNr:=cognew(get1270bs(average,ADC_addr, nCh),@stack1)
Return CogNr  
  
Pub Stop
  CogStop(CogNr)
                 
pub get1270bs(average_sample, ADC_count_address, nCh) | control_bit, temp, adresult_temp, ch, lCr ' do one ADC
   temp:=0
   repeat
     repeat ch from 0 to nCh-1
        control_bit:=ch*16 + $80
        
        Low(CsAdc) 
        bs2.SHIFTOUT(AoutAdc, ClkAdc,control_bit, BS2#MSBFIRST,8 ) '' put the control bit out
        High(CsAdc) 
        Low(CsAdc)

        temp := bs2.SHIFTIN(AinAdc, ClkAdc, BS2#MSBPRE,12)         '' data in
        High(CsAdc) 
    
        long[ADC_count_address + ch*4] := (long[ADC_count_address + ch*4]*(average_sample-1) + temp) / average_sample        ' average samples


PUB HIGH(Pin)   'Set pin high
    dira[Pin]~~
    outa[Pin]~~
         
PUB LOW(Pin)    'Set pin low
    dira[Pin]~~
    outa[Pin]~

PUB MakeCR(CH, PowerCl, RangeSel)| lCR  'Create Command register from Channel, PD, Range
  lCR:=CH*16 + PowerCl + RangeSel*4
  lCr:=lCr + $80  'Set starbit
Return lCR





        