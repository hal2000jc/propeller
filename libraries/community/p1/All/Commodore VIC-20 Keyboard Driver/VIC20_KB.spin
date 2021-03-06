''-----------------------------------------------------------------------------
'' Commodore VIC-20 Keyboard Driver
''
'' Copyright (c) 2018 Mike Christle
'' See end of file for terms of use.
''
'' History:
'' 1.0.0 - Original release - 10/23/2018.
''-----------------------------------------------------------------------------
'' This module will scan a Commodore VIC-20 keyboard and returns ASCII codes.
'' Like the VIC-20 it has two modes, graphics and text.
'' Press the Shift and Commodore keys together to switch modes.
'' The tables in the DAT section give the ASCII values.
''-----------------------------------------------------------------------------
'' Circuit: CN1 is the VIC-20 keyboard connector.
''
''                   +3.3V               
''        All 10KΩ         
''       ┌─┳─┳─┳─┳─┳─┳─┫     
'' Prop            CN1    Prop      CN1                CN1
''  P0 ─┻─┼─┼─┼─┼─┼─┼─┼─ 20      P8  ── 12         +V  ─ 4
''  P1 ───┻─┼─┼─┼─┼─┼─┼─ 19      P9  ── 11    RESTORE  ─ 3
''  P2 ─────┻─┼─┼─┼─┼─┼─ 18      P10 ── 10        KEY   ─ 2
''  P3 ───────┻─┼─┼─┼─┼─ 17      P11 ── 9         GND  ─ 1
''  P4 ─────────┻─┼─┼─┼─ 16      P12 ── 8
''  P5 ───────────┻─┼─┼─ 15      P13 ── 7
''  P6 ─────────────┻─┼─ 14      P14 ── 6
''  P7 ───────────────┻─ 13      P15 ── 5
''
'' The VIC-20 schematics show pin 4 connected to +5V. However, the cable to
'' the keyboard does not have a wire for pin 4. So +V can be ignored.
'' The RESTORE signal is not used in this module. Pressing RESTORE will
'' short pin 3 to GND. KEY is a pin allignment key and can not be used.
''-----------------------------------------------------------------------------
CON

  SHFT_KEY = $100
  COMD_KEY = $200
  CNTL_KEY = $400
  BASE_KEY = $800

VAR

  word  keyvalue
  byte  cog, gr_mode

PUB Start
'-----------------------------------------------------------------------------
'' Starts the module.
'-----------------------------------------------------------------------------
  Stop
  gr_mode := TRUE
  key_ptr := @keyvalue
  wait_cnt := clkfreq >> 4
  cog := cognew(@scan_keys, 0) + 1

PUB Stop
'-----------------------------------------------------------------------------
'' Stops the module.
'-----------------------------------------------------------------------------
  if cog
    cogstop(cog -  1)

PUB Key | val, mod
'-----------------------------------------------------------------------------
'' Returns the ASCII code for a key press, or 0 if no key is pressed.
'-----------------------------------------------------------------------------
  val := keyvalue
  keyvalue := 0
  mod := val & $F00
  val := val & $0FF

  'If Commodore and Shift Keys pressed together toggle graphics mode
  if mod == $300
    not gr_mode
    return 0

  'If no valid key pressed return 0
  if (mod & BASE_KEY) == 0
    return 0

  'If key pressed with Commodore Key
  if mod & COMD_KEY
    val := COMD_VALUE[val]

  'If key pressed with Control Key
  elseif mod & CNTL_KEY
    val := CNTL_VALUE[val]
   
  'If key pressed with Shift Key
  elseif mod & SHFT_KEY

    'If graphics mode
    if gr_mode
      val := SHFT_GR_VALUE[val]

    'Else text mode
    else
      val := SHFT_TX_VALUE[val]

  'Else key pressed with not extra keys
  else

    'If graphics mode
    if gr_mode
      val := BASE_GR_VALUE[val]

    'Else text mode
    else
      val := BASE_TX_VALUE[val]
     
  return val

DAT
'-----------------------------------------------------------------------------
' STP = Run/Stop             CRT = Cursor Right     DEL = Delete
' SPC = Space                CLT = Cursor Left      INS = Insert
' RET = Return               CND = Cursor Down      HOM = Home
'                            CUP = Cursor Up        CLR = Clear
' LSH = Left Shift
' RSH = Right Shift          LA  = Left Arrow
' CTL = Control              UA  = Up Arrow
' CMB = Commodore Button     BP  = British Pound
'-----------------------------------------------------------------------------
                  '    
'-----------------------------------------------------------------------------
' No Control Key Lookup Table, Graphics Mode
'-----------------------------------------------------------------------------
BASE_GR_VALUE
              '  1    3    5    7    9    +    BP  DEL
        byte     49,  51,  53,  55,  57,  43,  92,  20
              '  LA   W    R    Y    I    P    *   RET
        byte     95,  87,  82,  89,  73,  80,  42,  13
              ' CTL   A    D    G    J    L    ;   CRT
        byte      0,  65,  68,  71,  74,  76,  59,  29
              ' STP  LSH   X    V    N    ,    /   CDN
        byte    203,   0,  88,  86,  78,  44,  47,  17
              ' SPC   Z    C    B    M    .   RSH   F1
        byte     32,  90,  67,  66,  77,  46,   0, 133
              ' CBM   S    F    H    K    :    =    F3
        byte      0,  83,  70,  72,  75,  58,  61, 134
              '  Q    E    T    U    O    @    UA   F5
        byte     81,  69,  84,  85,  79,  64,  94, 135
              '  2    4    6    8    0    -   HOM   F7
        byte     50,  52,  54,  56,  48,  45,  19, 136

'-----------------------------------------------------------------------------
' Shift Key Lookup Table, Graphics Mode
'-----------------------------------------------------------------------------
SHFT_GR_VALUE
              '  !    #    %    '    )    +    BP  INS
        byte     33,  35,  37,  39,  41, 219, 169, 148
              '  LA   W    R    Y    I    P    *   RET
        byte     95, 215, 210, 217, 201, 208, 192, 141
              ' CTL   A    D    G    J    L    ]   CLT
        byte      0, 193, 196, 199, 202, 204,  93, 157
              ' STP  LSH   X    V    N    <    ?   CUP
        byte    203,   0, 216, 214, 206,  60,  63, 145
              ' SPC   Z    C    B    M    >   RSH   F2
        byte    160, 218, 195, 194, 205,  62,   0, 137
              ' CBM   S    F    H    K    [    =    F4
        byte      0, 211, 198, 200, 203,  91,  61, 138
              '  Q    E    T    U    O    @    PI   F6
        byte    209, 197, 212, 213, 207, 186, 222, 139
              '  "    $    &    (    0    -   CLR   F8
        byte     34,  36,  38,  40,  48, 221, 147, 140

'-----------------------------------------------------------------------------
' No Control Key Lookup Table, Text Mode
'-----------------------------------------------------------------------------
BASE_TX_VALUE
              '  1    3    5    7    9    +    BP  DEL
        byte     49,  51,  53,  55,  57,  43,  92, 127
              '  LA   w    r    y    i    p    *   RET
        byte      0, 119, 114, 121, 105, 112,  42,  13
              ' CTL   a    d    g    j    l    ;   CRT
        byte      0,  97, 100, 103, 106, 108,  59,   0
              ' STP  LSH   x    v    n    ,    /   CDN
        byte    203,   0, 120, 118, 110,  44,  47,   0
              ' SPC   z    c    b    m    .   RSH   F1
        byte      0, 122,  99,  98, 109,  46,   0, 133
              ' CBM   s    f    h    k    :    =    F3
        byte      0, 115, 102, 104, 107,  58,  61, 134
              '  q    e    t    u    o    @    UA   F5
        byte    113, 101, 116, 117, 111,  64,  94, 135
              '  2    4    6    8    0    -   HOM   F7
        byte     50,  52,  54,  56,  48,  45,   0, 136

'-----------------------------------------------------------------------------
' Shift Key Lookup Table, Text Mode
'-----------------------------------------------------------------------------
SHFT_TX_VALUE
              '  !    #    %    '    )    +    BP  DEL
        byte     33,  35,  37,  39,  41,  43,  92, 127
              '  LA   W    R    Y    I    P    *   RET
        byte      0,  87,  82,  89,  73,  80,  42,  13
              ' CTL   A    D    G    J    L    ]   CRT
        byte      0,  65,  68,  71,  74,  76,  93,   0
              ' STP  LSH   X    V    N    <    ?   CDN
        byte    203,   0,  88,  86,  78,  60,  63,   0
              ' SPC   Z    C    B    M    >   RSH   F2
        byte      0,  90,  67,  66,  77,  62,   0, 137
              ' CBM   S    F    H    K    [    =    F4
        byte      0,  83,  70,  72,  75,  91,  61, 138
              '  Q    E    T    U    O    @    PI   F6
        byte     81,  69,  84,  85,  79,  64, 222, 139
              '  "    $    &    (    0    -   CLR   F8
        byte     34,  36,  38,  40,  48,  45,   0, 140

'-----------------------------------------------------------------------------
' Commodore Key Lookup Table
'-----------------------------------------------------------------------------
COMD_VALUE
              '  1    3    5    7    9    +    BP  DEL
        byte    129, 150, 152, 154,  41, 166, 168, 148
              '  LA   W    R    Y    I    P    *   RET
        byte     95, 179, 178, 183, 162, 175, 223, 141
              ' CTL   A    D    G    J    L    ;   CRT
        byte      0, 176, 172, 165, 181, 182,  93, 157
              ' STP  LSH   X    V    N    ,    /   CDN
        byte    203,   0, 189, 190, 170,  60,  63, 145
              ' SPC   Z    C    B    M    .   RSH   F1
        byte      0, 173, 188, 191, 167,  62,   0, 137
              ' CBM   S    F    H    K    :    =    F3
        byte      0, 174, 187, 180, 161,  91,  61, 138
              '  Q    E    T    U    O    @    UA   F5
        byte    171, 177, 163, 184, 185, 164, 222, 139
              '  2    4    6    8    0    -   HOM   F7
        byte    149, 151, 153, 155,  48, 220, 147, 140

'-----------------------------------------------------------------------------
' Control Key Lookup Table
'-----------------------------------------------------------------------------
CNTL_VALUE
              '  1    3    5    7    9    +    BP  DEL
        byte    144,  28, 156,  31,  18,  43,  28,   0
              '  LA   W    R    Y    I    P    *   RET
        byte      6,  23,  18,  25,   9,  16,   0,   0
              ' CTL   A    D    G    J    L    ;   CRT
        byte      0,   1,   4,   7,  10,  12,  29,   0
              ' STP  LSH   X    V    N    ,    /   CDN
        byte    203,   0,  24,  22,  14,   0,   0,   0
              ' SPC   Z    C    B    M    .   RSH   F1
        byte      0,  26,   3,   2,  13,   0,   0,   0
              ' CBM   S    F    H    K    :    =    F3
        byte      0,  19,   6,   8,  11,  27,  31,   0
              '  Q    E    T    U    O    @    UA   F5
        byte     17,   5,  20,  21,  15,   0,  30,   0
              '  2    4    6    8    0    -   HOM   F7
        byte      5, 159,  30, 158, 146,  45,   0,   0

'-----------------------------------------------------------------------------
' Assembly language keyboard driver
'-----------------------------------------------------------------------------
                        org     0
' Initialize
scan_keys               mov     outa, #0
                        mov     last_key, #0
                        mov     wait_cntr, cnt
                        add     wait_cntr, wait_cnt

' Wait for next scan period
scan_keys9              waitcnt wait_cntr, wait_cnt

' Start key scan
                        mov     col_val, col_init_val
                        mov     key_val, #0
                        mov     key_cnt, #0
                        mov     col_cnt, #8

' Key scan loop
scan_keys1              mov     dira, col_val
                        shl     col_val, #1

' Wait for signals to settle
                        mov     temp, settle_delay
scan_keys7              djnz    temp, #scan_keys7

' Read columns
                        mov     row_val, ina
                        and     row_val, #255

' Start key value decode
                        mov     row_cnt, #8

' Shift scan value and test of a key is pressed
scan_keys4              shr     row_val, #1  wc
              if_c      jmp     #scan_keys5

' Decode key count
                        cmp     key_cnt, #$26  wz  'Right Shift
              if_z      or      key_val, shift_val
              if_z      jmp     #scan_keys5

                        cmp     key_cnt, #$19  wz  'Left Shift
              if_z      or      key_val, shift_val
              if_z      jmp     #scan_keys5

                        cmp     key_cnt, #$28  wz  'Commodore Key
              if_z      or      key_val, comd_val
              if_z      jmp     #scan_keys5

                        cmp     key_cnt, #$10  wz  'Control Key
              if_z      or      key_val, contl_val
              if_z      jmp     #scan_keys5

                        or      key_val, base_val
                        or      key_val, key_cnt

' Advance to next key
scan_keys5              add     key_cnt, #1
                        djnz    row_cnt, #scan_keys4
                        djnz    col_cnt, #scan_keys1

' If a key was pressed, write to global memory
scan_keys3              cmp     key_val, last_key  wz
              if_z      jmp     #scan_keys9

                        mov     last_key, key_val  wz
              if_nz     wrword  key_val, key_ptr
                        jmp     #scan_keys9
                                                                
wait_cnt                long    80_000_000
key_ptr                 long    0
col_init_val            long    $00_00_01_00
settle_delay            long    10_000

shift_val               long    SHFT_KEY
comd_val                long    COMD_KEY
contl_val               long    CNTL_KEY
base_val                long    BASE_KEY

wait_cntr               res     1
row_val                 res     1
row_cnt                 res     1
col_val                 res     1
col_cnt                 res     1
key_val                 res     1
key_cnt                 res     1
temp                    res     1
last_key                res     1

                        fit
{{
┌────────────────────────────────────────────────────────────────────────────┐
│                       TERMS OF USE: MIT License                            │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining       │
│a copy of this software and associated documentation files (the "Software"),│
│to deal in the Software without restriction, including without limitation   │
│the rights to use, copy, modify, merge, publish, distribute, sublicense,    │
│and/or sell copies of the Software, and to permit persons to whom the       │
│Software is furnished to do so, subject to the following conditions:        │                                                           │
│                                                                            │                                                  │
│The above copyright notice and this permission notice shall be included in  │
│all copies or substantial portions of the Software.                         │
│                                                                            │                                                  │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  │
│IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL     │
│THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     │
│FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         │
│DEALINGS IN THE SOFTWARE.                                                   │
└────────────────────────────────────────────────────────────────────────────┘
}}