
Con
{{
                      ┌──────┐
                  QB  ┫1•  16┣  Vcc                 
                  QC  ┫2   15┣  QA                                
                  QD  ┫3   14┣────────────────────────────────────────────────────────────────────┳────  ← A (Data in from Propeller)│      
                  QE  ┫4   13┣──gnd───────────────────•  Output Enable (Ground each one)          │  
                  QF  ┫5   12┣───────────────┐     ←  Latch Clock                                 │
                  QG  ┫6   11┣─────────────┐ │     ←  Shift Clock                                 │
                  QH  ┫7   10┣──────────────────┐  ←  RESET                                       │
                 gnd  ┫7    9┣───────┐ QH' │ │  │                                                 │
                      └──────┘       │     │ │  │      Notes:                                     │
                                     │     │ │  │                                                 │
                      ┌──────┐       │     │ │  │                                                 │
                  QB  ┫1•  16┣  Vcc  │     │ │  │                                                 │
                  QC  ┫2   15┣  QA   │     │ │  │                                                 │
                  QD  ┫3   14┣───────┘ A   │ │  │                                                 │
                  QE  ┫4   13┣───gnd───────│─│──│───•  Output Enable (Ground each output enable)  │             
                  QF  ┫5   12┣──┳──────────│─┻──│───•  Latch/Strobe(To StrobePin from Propeller)  │               
                  QG  ┫6   11┣──│─┳────────┻────│───•  Clock (to ClockPin from Propeller)         │
                  QH  ┫7   10┣──│─│─────────────┻───•  RESET (to Vcc or to Propeller's Reset pin) │
                 gnd  ┫7    9┣──│─│──┐ Qh'                                                        │
                      └──────┘  │ │  │                                                            │
                                │ │  │                                                            │
                    ┌───────────┘ │  │                                                            │
                    │             │  │                                                            │
                  ┌─┼─────────────┘  │                                                            │
                  │ │ ┌──────┐       │                                                            │
 Strobe    SH/LD  │ └-┫1•  16┣  Vcc  │                                                            │
 Clock     CLK    └-──┫2   15┣  gnd  │                                                            │
                  e   ┫3   14┣ d     │     input D                                                │
                  f   ┫4   13┣ c     │ ────input C                                                │
                  g   ┫5   12┣ b     │ ────input B                                                │
                  h   ┫6   11┣ a     │ ────input a                                                │
                -QH   ┫7   10┣───────┘                                                            │
                 gnd  ┫7    9┣───────┐ Qh'                                                        │
                      └──────┘       │                                                            │
                                to next 74HC165 Ser (pin 10)                                      │
                                or connect to DATA using 10k resistor.                            │
                                     │                                                            │
                                     └────────────────/\/\/\──────────────────────────────────────┘
                                                        10k
}}
                    

obj
 'debug : "simpledebug" 
var
  
 long data_in
 long out_data
 long SR_CLOCK 
 long SR_STROBE
 long SR_DATA 
 long num_inputs
 long num_outputs 

PUB init(_clock,_strobe,_data,_num_inputs,_num_outputs)
{{ Launches the shift-out asm routine. }}

  SR_CLOCK    := _clock
  SR_STROBE   := _strobe
  SR_DATA     := _data

  num_inputs  := _num_inputs
  num_outputs := _num_outputs
     '##  set pins to output
  dira[SR_STROBE]~~
  dira[SR_CLOCK]~~
  


PUB High(bit_pos)
{{  Sets specified bit high.
}}

  out_data |= (1 << bit_pos)

PUB Low(bit_pos)
{{  Sets specified bit low.
}}

  out_data &= !(1 << bit_pos)

PUB SetBit(bit_pos, state)
{{  Sets specified bit to specified state.
}}

  if state
    High(bit_pos)
  else
    Low(bit_pos)
pub in_out(data_out) | i,j

 
  
 ' pull clock  low and single strobe to clear all
  outa[SR_CLOCK] := 0
  '##strobe low to latch inputs on 165
  outa[SR_STROBE] := 0
  outa[SR_STROBE] := 1'  /* Must go high here to allow HC7597 to clock */

  data_in~    '## reset data_in  ... ??? need to check why this needed
  
      '##loop through all inputs and stick into data_in 
        repeat i from 0 to NUM_INPUTS-1
         
           dira[SR_DATA]~

           
           data_in :=(data_in << 1) + ina[SR_DATA]  
           'data_in <<= ina[SR_DATA]
          '##clock clock
          outa[SR_CLOCK] := 1
          outa[SR_CLOCK] := 0  
                    
      ' ## loop through all outputs and hit strobe to latch outputs and reread the inputs
        repeat i from 0 to num_outputs-1  
        '
            dira[SR_DATA]~~
            
            j :=  (data_out >> i ) & 1
         
          outa[SR_DATA] :=j   
          
           '##clock cycle 1
          outa[SR_CLOCK] := 1
          outa[SR_CLOCK] := 0
          
          
       '##strobe low to latch outputs on 595
        outa[SR_STROBE] := 0

        '
        outa[SR_STROBE] := 1'  /*
       ' waitcnt(clkfreq/10+cnt)  '## stabilize output

       
         
  
       
        

         
  return data_in           

   