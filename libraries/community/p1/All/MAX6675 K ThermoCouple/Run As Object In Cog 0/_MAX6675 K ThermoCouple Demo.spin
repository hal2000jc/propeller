{ File   _MAX6675 K ThermoCouple Demo.spin
   Michael J. Lord   650-219-6467

this demo was written for the Parallax Professional Demo board using the TV display



}

CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000


      TvPin       =   24     'Pin for TV    Control Prop
        

 
      LedPin       =   22
      LedPin2      =   21

{
      SCK      =  13
      CS       =  14
      So       =  15
}
      SCK      =  20
      CS       =  19
      So       =  18



      TempScale  = 1     '1 is Farienheight   0 is Centegrade
      
  
Var

       Long TempIn



OBJ

      Tv        :  "Mirror_TV_Text"
      Max6675       :  "Max6675_K_thermoCouple"

      
'====================================================================================
PUB _Start    |  TimeCnt_10Hz,  DisplayTime  , ElapsedCnt , index  , AddrVar
'====================================================================================


       Initialize 
   
       dira[LedPin] := 1
       Outa[LedPin] := 1
                                
                 
      ' ByteFill( @BytesIn , "R" , 17 )          
   
         DisplayTime := 878
    
       
        TimeCnt_10Hz  := Cnt
        ElapsedCnt  := 0 
        repeat

               !Outa[LedPin] 
               Max6675.ReadTemp(So, CS, SCK , TempScale , @TempIn  )
               
               Tv.out($0D)
               Tv.out($0D)
                       
                      
              if  TempScale == 0
                      Tv.Str(String("Measured Temperture in Celsius = ")) 
                      Tv.Dec( TempIn )
              Else     
                      Tv.Str(String("Measured Temperture in Fahrenheit = ")) 
                      Tv.Dec( TempIn )




               
              waitcnt(clkfreq / 1 + cnt)    'dont scan too fast or the conversion will not run
             Tv.out($00)





             
'====================================================================================
Pub  Initialize
'====================================================================================
      
 
   'Start cogs
        TV.start(TvPin)
        Tv.Str(String("Tv Started")  )
        Tv.out($0D)
        Tv.Str(String("MAX6675 ThermoCouple Demo")) 
 

        
 


  