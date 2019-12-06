''stupid test program - don't look at this ;P

CON

_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000
 NUM_LINES = gfx#NUM_LINES
_stack   = 128 + 76 + ((256+NUM_LINES)*8) ''Stack+TV parameter shiz+8 scanline bufferz

 SCANLINE_BUFFER = $7800
 
 SPR_BUCKETS = SCANLINE_BUFFER - (NUM_LINES*8)
 request_scanline       = SPR_BUCKETS-2      'address of scanline buffer for TV driver
 tilemap_adr            = SPR_BUCKETS-4      'address of tile map (UNUSED)
 tile_adr               = SPR_BUCKETS-6 'address of tiles (must be 64-byte-aligned) (UNUSED)
 border_color           = SPR_BUCKETS-8 'address(!) of border color   
 oam_adr             =    SPR_BUCKETS-10      'address of where sprite attribs are stored
 oam_in_use             =    SPR_BUCKETS-12   'OAM adress feedback
 debug_shizzle             =    SPR_BUCKETS-16  'used for debugging, sometimes
 text_colors             =    SPR_BUCKETS-18    'adress of text colors
 first_subscreen        =    SPR_BUCKETS-20     'pointer to first subscreen
 buffer_attribs         = SPR_BUCKETS-28 'array of 8 bytes
 aatable                = SPR_BUCKETS-60 'array of 32 bytes
 aatable8               = SPR_BUCKETS-76 'array of 16 bytes
 ''placeholder            = SPR_BUCKETS-78 'delet dis

 num_sprites    = gfx#num_sprites

VAR

OBJ

gfx : "JET_v01.spin"     
pst : "parallax serial terminal"
kb  : "Keyboard"



VAR

long screen[32*16]
long gfx_screen[32*16]
byte cur_oam
byte colnow
byte sec_countdown
byte startchar
byte aaedit

PUB main | tileset_aligned, y, k, x, oam_length,s,t
  bytemove(aatable,@aatabvals,32)
  bytemove(aatable8,@aatab8vals,16)
 'gfx.Set_Border_Color($f8) 'set border color (unused?)
 pst.start(115_200)
 kb.start(8,9)

 bytefill(SCANLINE_BUFFER,$02,256*8)
 
 tileset_aligned := (@tileset + %1111_00)&(!%1111_11)
 if tileset_aligned & %1111_00
   reboot
 bytemove(tileset_aligned,@tileset+64,(@tileset_end-@tileset)-64)
 
 tiletest(true)
 sec_countdown := 60
 'longfill(@screen,%0000___000000_______0000_0__0_________0000___000001_______0000_0___0,32*12)

 'word[tilemap_adr] := @screen
 'word[tile_adr] := tileset_aligned
 word[oam_adr] := @oam1
 word[text_colors] := @text_colos
 word[first_subscreen] := @gfx_sub
 word[@gfx_sub+2] := @text_sub
 word[@gfx_sub+10] := tileset_aligned
 word[@text_sub+10] := tileset_aligned
 word[@gfx_sub+12] := @gfx_screen
 word[@text_sub+12] := @screen

 longfill(@gfx_screen,((1) << 6) + (0 <<20),32*16)
 repeat y from 0 to 15
   repeat x from 0 to 31
     gfx_screen[x+(y<<5)] := ((1+(x&1)) << 6) + (0 <<20) + 2 + ((x&8)>>3) + ((x&4)<<14)
        
 ''set up graphics driver
 gfx.start(%001_0101,%00,4) 'start graphics driver

 oam1_enable  |= %0000_0001_1111_1111_1111_1111_1111_1111
 oam1_mirror  |= %0000_0000_0000_0000_0000_0000_0000_0000
 oam1_flip    |= %0000_0000_0000_0000_0000_0000_0001_0001
 oam1_yexpand |= %0000_0000_0000_0000_0000_0000_1111_0001
 oam1_xexpand |= %0000_0000_0000_0000_0000_0000_1111_1111
 oam1_solid   |= %0000_0001_0000_0000_0000_0000_0000_1001
 
 oam2_enable  |= %0000_0001_1111_1111_1111_1111_1111_1111
 oam2_mirror  |= %0000_0000_0000_0000_0000_0000_0000_0001
 oam2_flip    |= %0000_0000_0000_0000_0000_0000_0001_0001
 oam2_yexpand |= %0000_0000_0000_0000_0000_0000_1111_0001
 oam2_xexpand |= %0000_0000_0000_0000_0000_0000_1111_1111
 oam2_solid   |= %0000_0001_0000_0000_0000_0000_0000_1001

 repeat x from 0 to 7
  oam1_xpos.word[x] := ((x)*33)-1
  oam2_xpos.word[x] := ((x)*33)-1
 repeat x from 8 to 23
  oam1_xpos.word[x] := (x-8)*16
  oam2_xpos.word[x] := (x-8)*16
  oam1_ypos.word[x] := 40
  oam2_ypos.word[x] := 40
 repeat x from 24 to 31
  oam1_xpos.word[x] := 248
  oam2_xpos.word[x] := 248
  oam1_ypos.word[x] := 209
  oam2_ypos.word[x] := 209

 oam1_palette.byte[24] := 20
 oam2_palette.byte[24] := 20
                       
 x := 1
 y := 100
 s := 96
 t := -3
 oam_length := @oam1-@oam1_end
 repeat
   {pst.str(string("aatable:",$0d))
   repeat k from 0 to 30 step 2
     pst.hex(byte[aatable+k],2)
     pst.char(" ")
     pst.hex(byte[aatable+k+1],2)
     pst.NewLine}
   'pst.hex(long[debug_shizzle],8)
   'pst.NewLine
   
   if cur_oam
     cur_oam := 0
     word[oam_adr] := @oam1
   else
     cur_oam := 1
     word[oam_adr] := @oam2

   repeat while word[oam_adr] <> word[oam_in_use]
    gfx.Wait_Vsync
   repeat 500 'fix screen tearing (a better method would involve double buffering subscreens)
   
   y += x':= -8
   if y => 256
     x := -1
   elseif y =< -32
     x := 1
   if cur_oam 
     oam1_ypos.word[0] := y                                                                             
     oam1_xpos.word[24] := y
   else                    
     oam2_ypos.word[0] :=  y
     oam2_xpos.word[24] := y

   {if (--sec_countdown) =< 0
     sec_countdown := 90
     colnow++}
   s += t
   if s<0
     s := 0
     t := 1
   elseif s>224
     s := 224
     t := -1
  word[@gfx_sub+4] := sin(s*64)/$3FF
  word[@gfx_sub+6] := 0'sin((s*(-64))+$800)/$3FF
  word[@gfx_sub+8] := lookupz(s&1:9,8)
  word[@text_sub+8] := s&1
  'word[@gfx_sub+6] := -256
  word[@text_sub+0] := s+100
  word[@text_sub+4] := (-s)-100
  word[@text_sub+6] := 0's/2
  
  k := kb.key
  case k
    $C0: 'left
      startchar--
    $C1: 'right
      startchar++
    $C2: 'up
      colnow--
    $C3: 'down
      colnow++
    $C4: 'home
      aaedit := (aaedit -1)&31
    $C5: 'end
      aaedit := (aaedit +1)&31
    $C6: 'page up
      byte[aatable+aaedit] := (byte[aatable+aaedit] -4)&(31<<2)                       
    $C7: 'page down
      byte[aatable+aaedit] := (byte[aatable+aaedit] +4)&(31<<2)
  if k
    tiletest (false) 
  
 

PUB tiletest(init) |  y, x,b0,b1,c,n
if init
  n~
  longfill(@screen,((1) << 6) + (0 <<20),32*16)
else
  n:=10
   
repeat y from 0 to 15
   repeat x from 0 to 15
      if y>3
         {if y==10
           c := x&$f
         else}
           c:= colnow &$f
         'b0 := test_str.byte[(x<<1)+((y-10)<<6)]
         b0 := ((x+((y-4)*16))*2 + startchar)&$FF
         'b1 := test_str.byte[(x<<1)+((y-10)<<6)+1]
         b1 := ((x+((y-4)*16))*2 + startchar +1)&$FF
         if (colnow&1) AND x&1
           if x&2
             screen[x+(y<<5)] := ((2) << 6) + (0 <<20) + 2 + ((x&8)>>3) + ((x&4)<<14)
           else
             screen[x+(y<<5)] := ((1) << 6) + (0 <<20) + 2 + ((x&8)>>3) + ((x&4)<<14)
         else
           screen.word[(x<<1)+(y<<6)] := $8000+((b0>>1)<<7)+ ((b0&1)) + (c<<2)
           screen.word[(x<<1)+(y<<6)+1] := $8000+((b1>>1)<<7)+ ((b1&1)) + (c<<2)
      else
         if x&1
           b0 := hexchars.byte[byte[aatable+(((x>>1)+((y-0)<<3)))]>>2]
           b1 := " "
         else
           b0 := hexchars.byte[((x>>1)+((y-0)<<3))>>1]
           if x&%10
            b1 := "t"
           else
            b1 := "b"
           
         c := 0 + (3&((x>>1)+((y-0)<<3) == aaedit))
         
         screen.word[(x<<1)+(y<<6)] := $8000+((b0>>1)<<7)+ ((b0&1)) + (c<<2) 
         screen.word[(x<<1)+(y<<6)+1] := $8000+((b1>>1)<<7)+ ((b1&1)) + (c<<2)

      {elseif y>6
       if x==1
         screen[x+(y<<5)] := (3+(y>>1)) << 6
       elseif x==3
         screen[x+(y<<5)] := (3+4+(y>>1)) << 6
         
       elseif x>6
         if x&1
           screen[x+(y<<5)] := 1 << 6
         else
           screen[x+(y<<5)] := (1 << 6) + (1<<16) 
       elseif x&1
         screen[x+(y<<5)] := (2 << 6)+1
       else
         screen[x+(y<<5)] := ((3+16) << 6) + (20 <<22) }

PUB sin(angle) : s | c,z
  c := angle & $800            'angle: 0..8192 = 360°
  z := angle & $1000
  if c
    angle := -angle
  angle |= $E000>>1
  angle <<= 1
  s := word[angle]
  if z
    s := -s                    ' return sin = -$FFFF..+$FFFF

DAT

gfx_sub
word 0  'ystart
word 0  ' next (gets set at runtime due to spin wierdness)
word 0 ' yscroll
word 0  ' xscroll
word 9 ' mode
word 0  ' tile_base (must be 64-byte-aligned) (also gets set at run time)
word 0  ' map_base (also gets set at run time)
word %1111_11111_00 ' map_mask
word 16<<2 ' map_width in bytes (must be power of 2 for wraparound)
word 5+2 ' map_y_shift
word 4 'tile_height (well, technically log2(tile_height))

text_sub
word 96 'ystart
word 0  ' next (none)
word 8  ' yscroll
word 1  ' xscroll
word 0  ' mode
word 0  ' tile_base (must be 64-byte-aligned) (also gets set at run time)
word 0  ' map_base (also gets set at run time)
word %1111_11111_00 ' map_mask
word 16<<2 ' map_width in bytes (must be power of 2 for wraparound)
word 5+2 ' map_y_shift
word 3 'tile_height (well, technically log2(tile_height))

test_str
byte "~~Hello World! Pseudo-4bpp tile-"
byte 0[32]
byte "driver! Antialiased ROM Font!   "
byte 0[32]
byte "Hello World!                    "

hexchars
byte "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

''01213355
''789ACBED
''FGIHKJLM
''NOPQSSTU
aatabvals
byte  0<<2, 1<<2
byte  2<<2, 1<<2
byte  3<<2, 3<<2
byte  5<<2, 5<<2
byte  7<<2, 8<<2
byte  9<<2,10<<2   
byte 12<<2,11<<2
byte 14<<2,13<<2
byte 15<<2,16<<2
byte 18<<2,17<<2
byte 20<<2,19<<2
byte 21<<2,22<<2
byte 23<<2,24<<2
byte 25<<2,26<<2
byte 28<<2,28<<2
byte 29<<2,30<<2
''2467CBEF
''IHJLOQST
aatab8vals      
byte  2<<2, 4<<2
byte  6<<2, 7<<2
byte 12<<2,11<<2
byte 14<<2,15<<2
byte 18<<2,17<<2
byte 19<<2,21<<2
byte 24<<2,26<<2
byte 28<<2,29<<2


'org 0
oam1
oam1_enable    long %0
oam1_flip      long %0
oam1_mirror    long %0
oam1_yexpand    long %0
oam1_xexpand    long %0
oam1_solid     long %0
oam1_ypos      word 3[num_sprites]
oam1_xpos      word 2[num_sprites]
oam1_pattern   byte 2[num_sprites]
oam1_palette   byte 0[num_sprites]
oam1_end

'org 0
oam2
oam2_enable    long %0
oam2_flip      long %0
oam2_mirror    long %0
oam2_yexpand    long %0
oam2_xexpand    long %0
oam2_solid     long %0
oam2_ypos      word 3[num_sprites]
oam2_xpos      word 2[num_sprites]
oam2_pattern   byte 2[num_sprites]
oam2_palette   byte 0[num_sprites]
oam2_end

text_colos
text_white     long $07_05_04_02
text_lessaa    long $07_04_03_02
text_grey      long $06_04_03_02
text_black     long $02_04_05_07
text_black2    long $02_05_06_07

text_red0      long $CC_CB_CA_02
text_red1      long $CD_CB_CA_02
text_red2      long $CE_CC_CB_02
text_red3      long $48_CC_CB_02

text_teal0     long $4C_4B_4A_02
text_teal1     long $4D_4B_4A_02
text_teal2     long $4E_4C_4B_02
'text_teal3    long $C8_4C_4B_02
text_or        long $07_07_07_02

text_and       long $07_02_02_02
text_xnor      long $02_07_07_02
'text_bold     long $07_07_03_02
'text_top      long $07_07_02_02
text_wtf       long $ED_6B_6A_02



{text_grey    long $06_03_03_02
text_white    long $07_03_03_02

text_white2   long $07_04_04_02
text_white3   long $07_05_05_02
text_noaa   long $07_02_02_02
text_or   long $07_07_07_02
text_t1   long $07_05_04_02
text_t2   long $07_04_05_02
text_rednew   long $CD_CC_CC_02

text_red    long $CD_CB_CB_02
'text_red2    long $48_CC_CC_02
text_purple    long $ED_EB_EB_02
'text_purple2    long $68_EC_EC_02
text_violet   long $0D_0B_0B_02
'text_violet2    long $88_0C_0C_02
text_blue   long $2D_2B_2B_02
'text_blue2    long $A8_2C_2C_02
text_teal   long $4D_4B_4B_02
'text_teal2    long $C8_4C_4C_02
text_green   long $6D_6B_6B_02
'text_green2    long $E8_6C_6C_02
text_yellow   long $8D_8B_8B_02
'text_yellow2    long $08_8B_8B_02}


tileset

long 0[16] ' = alignment buffer

' tiles, both of the "palette" and "pattern" variety

long $07_04_0D_0C
long $07_04_1D_1C
long $07_04_2D_2C
long $07_04_3D_3C
long $07_04_4D_4C
long $07_04_5D_5C
long $07_04_6D_6C
long $07_04_7D_7C
long $07_04_8D_8C
long $07_04_9D_9C
long $07_04_AD_AC
long $07_04_BD_BC
long $07_04_CD_CC
long $07_04_DD_DC
long $07_04_ED_EC
long $07_04_FD_FC

' pattern tiles are 2-bit delta encoded 
long %%0000_0003_0100_0000 
long %%0000_0003_0100_0000 
long %%0000_0031_0310_0000 
long %%0000_0031_0310_0000 
long %%0000_0310_0031_0000 
long %%0000_0310_0031_0000 
long %%0000_3100_0003_1000 
long %%0000_3100_0003_1000 
long %%0003_1000_0000_3100 
long %%0003_1000_0000_3100 
long %%0031_0000_0000_0310 
long %%0031_0000_0000_0310 
long %%0310_0000_0000_0031 
long %%0310_0000_0000_0031 
long %%3100_0000_0000_0003 
long %%3100_0000_0000_0003

long %%2000_0000_0000_0000 
long %%0000_0000_0000_0000 
long %%0000_0000_0000_0000 
long %%0000_0000_0000_0000 
long %%0000_0000_0003_1000 
long %%0000_0000_0003_0100 
long %%0000_0000_0003_0010 
long %%0300_0000_0000_0001 
long %%0300_0000_0000_0001 
long %%0000_0000_0003_0010 
long %%0000_0000_0003_0100 
long %%0000_0000_0003_1000 
long %%0000_0000_0000_0000 
long %%0000_0000_0000_0000 
long %%0000_0000_0000_0000 
long %%2000_0000_0000_0000

long %%31<<28[16]
long %%31<<26[16]
long %%31<<24[16]
long %%31<<22[16]
long %%31<<20[16]
long %%31<<18[16]
long %%31<<16[16]
long %%31<<14[16]
long %%31<<12[16]
long %%31<<10[16]
long %%31<<8[16]
long %%31<<6[16]
long %%31<<4[16]
long %%31<<2[16]
long %%31[16]
long %%3[16]
long %%0[16]

long $07_05_03_02[16]  

org 0 ' long align
tileset_end
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    TERMS OF USE: Parallax Object Exchange License                                            │                                                            
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