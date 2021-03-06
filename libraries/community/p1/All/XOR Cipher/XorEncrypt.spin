{{
*****************************************
* XOR Cipher *
* Author: Michael S. King                  *
* Copyright (c) 2007 DTG          *
* See end of file for terms of use.     *
*****************************************
}}

' Encrypt(String("Thisisthekey"),String("This is the message"),@buf)
' Decrypt(String("Thisisthekey"),@buf,@msg)


var
   byte buf[64]
   
PUB Encrypt(Key,Msg,Emsg):value |Z,X ,I,h
z:=0

bytefill(@buf,0,64)
  
  repeat I from 0 to strsize(msg)- 1
  
   if z== strsize(key)
    z:=0
   
   buf[i]:=(byte[msg+i] ^ byte[key+z])+1
      z++ 
  bytemove(Emsg,@buf,strsize(@buf)+1)


PUB Decrypt(Key,Msg,Dmsg):value |Z,X ,I,h ,t
z:=0

bytefill(@buf,0,64)

 repeat I from 0 to strsize(msg)- 1
  
   if z== strsize(key)
    z:=0
   
  buf[i]:=(byte[msg+i]-1) ^ byte[key+z]
  z++



bytemove(Dmsg,@buf,strsize(@buf)+1)
  
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