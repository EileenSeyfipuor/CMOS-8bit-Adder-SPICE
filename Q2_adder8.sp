*******************************************************************
* Microelectronic / Digital Circuits I - Simulation 1
* Question 2 - Eight bit ripple carry adder
*
* The one bit full adder of question 1 is reused as a subcircuit.
*
* The file runs two simulations in sequence:
*   block 1 : part (a) functional check with three input vectors
*   block 2 : part (b) critical path timing and power
*******************************************************************

.include 'mosistsmc180.lib'

.option scale=90n

.param SUPPLY = 1.8
.param N = 4
.param P = 8

.global vdd gnd

*------------------------------------------------------------------
* Inverter
*------------------------------------------------------------------
.subckt inv a y Ni=4 Pi=8
M1 y a gnd gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'
M2 y a vdd vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
.ends

*------------------------------------------------------------------
* Two input XOR      y = a xor b
*------------------------------------------------------------------
.subckt xor2 a b y Ni=8 Pi=16
Xinva a an inv Ni=4 Pi=8
Xinvb b bn inv Ni=4 Pi=8

MN1 y  a  n1  gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'
MN2 n1 b  gnd gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'
MN3 y  an n2  gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'
MN4 n2 bn gnd gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'

MP1 p1 a  vdd vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
MP2 p1 b  vdd vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
MP3 y  an p1  vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
MP4 y  bn p1  vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
.ends

*------------------------------------------------------------------
* AOI22              y = not( a.b + c.d )
*------------------------------------------------------------------
.subckt aoi22 a b c d y Ni=8 Pi=16
MN1 y  a n1  gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'
MN2 n1 b gnd gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'
MN3 y  c n2  gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'
MN4 n2 d gnd gnd NMOS W='Ni' L=2 AS='Ni*5' PS='2*Ni+10' AD='Ni*5' PD='2*Ni+10'

MP1 p1 a vdd vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
MP2 p1 b vdd vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
MP3 y  c p1  vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
MP4 y  d p1  vdd PMOS W='Pi' L=2 AS='Pi*5' PS='2*Pi+10' AD='Pi*5' PD='2*Pi+10'
.ends

*------------------------------------------------------------------
* One bit full adder
*------------------------------------------------------------------
.subckt fa a b cin sum cout
Xx1 a   b   ab           xor2  Ni='2*N' Pi='2*P'
Xx2 ab  cin sum          xor2  Ni='2*N' Pi='2*P'
Xa1 cin ab  a  b  coutn  aoi22 Ni='2*N' Pi='2*P'
Xi1 coutn cout           inv   Ni='N'   Pi='P'
.ends

*------------------------------------------------------------------
* Eight bit ripple carry adder
*------------------------------------------------------------------
.subckt add8 a0 a1 a2 a3 a4 a5 a6 a7
+            b0 b1 b2 b3 b4 b5 b6 b7
+            cin
+            s0 s1 s2 s3 s4 s5 s6 s7
+            cout
Xfa0 a0 b0 cin s0 c1   fa
Xfa1 a1 b1 c1  s1 c2   fa
Xfa2 a2 b2 c2  s2 c3   fa
Xfa3 a3 b3 c3  s3 c4   fa
Xfa4 a4 b4 c4  s4 c5   fa
Xfa5 a5 b5 c5  s5 c6   fa
Xfa6 a6 b6 c6  s6 c7   fa
Xfa7 a7 b7 c7  s7 cout fa
.ends

*******************************************************************
* Circuit under test
*******************************************************************
VDD vdd gnd 'SUPPLY'

Xadd A0 A1 A2 A3 A4 A5 A6 A7
+    B0 B1 B2 B3 B4 B5 B6 B7
+    Cin
+    S0 S1 S2 S3 S4 S5 S6 S7
+    Carry_out
+    add8

CL0 S0 gnd 10fF
CL1 S1 gnd 10fF
CL2 S2 gnd 10fF
CL3 S3 gnd 10fF
CL4 S4 gnd 10fF
CL5 S5 gnd 10fF
CL6 S6 gnd 10fF
CL7 S7 gnd 10fF
CLC Carry_out gnd 10fF

*******************************************************************
* Block 1 - part (a)
* Three test vectors, one every 20 ns:
*    0 - 20 ns   A = 0F, B = 0F, Cin = 0   ->  Sum = 1E, Cout = 0
*   20 - 40 ns   A = FF, B = 01, Cin = 0   ->  Sum = 00, Cout = 1
*   40 - 60 ns   A = 33, B = 0C, Cin = 1   ->  Sum = 40, Cout = 0
*
* The middle vector is the worst case: the carry generated in bit 0
* must ripple through all eight stages.
*******************************************************************
VA0 A0 gnd 'SUPPLY'
VA1 A1 gnd 'SUPPLY'
VA2 A2 gnd PWL(0 'SUPPLY' 39.9n 'SUPPLY' 40n 0 60n 0)
VA3 A3 gnd PWL(0 'SUPPLY' 39.9n 'SUPPLY' 40n 0 60n 0)
VA4 A4 gnd PWL(0 0 19.9n 0 20n 'SUPPLY' 60n 'SUPPLY')
VA5 A5 gnd PWL(0 0 19.9n 0 20n 'SUPPLY' 60n 'SUPPLY')
VA6 A6 gnd PWL(0 0 19.9n 0 20n 'SUPPLY' 39.9n 'SUPPLY' 40n 0 60n 0)
VA7 A7 gnd PWL(0 0 19.9n 0 20n 'SUPPLY' 39.9n 'SUPPLY' 40n 0 60n 0)

VB0 B0 gnd PWL(0 'SUPPLY' 39.9n 'SUPPLY' 40n 0 60n 0)
VB1 B1 gnd PWL(0 'SUPPLY' 19.9n 'SUPPLY' 20n 0 60n 0)
VB2 B2 gnd PWL(0 'SUPPLY' 19.9n 'SUPPLY' 20n 0 39.9n 0 40n 'SUPPLY' 60n 'SUPPLY')
VB3 B3 gnd PWL(0 'SUPPLY' 19.9n 'SUPPLY' 20n 0 39.9n 0 40n 'SUPPLY' 60n 'SUPPLY')
VB4 B4 gnd 0
VB5 B5 gnd 0
VB6 B6 gnd 0
VB7 B7 gnd 0

VCin Cin gnd PWL(0 0 39.9n 0 40n 'SUPPLY' 60n 'SUPPLY')

.tran 10ps 60ns

.print tran v(S0) v(S1) v(S2) v(S3) v(S4) v(S5) v(S6) v(S7) v(Carry_out)

*******************************************************************
* Block 2 - part (b), critical path
*
* The longest path is the carry chain. Setting every A bit high and
* every B bit low makes A xor B equal to 1 in all eight stages, which
* is the carry propagate condition, so a transition on Cin must pass
* through all eight AOI22 and inverter pairs before Carry_out settles.
*******************************************************************
.alter Critical path timing and power

VA0 A0 gnd 'SUPPLY'
VA1 A1 gnd 'SUPPLY'
VA2 A2 gnd 'SUPPLY'
VA3 A3 gnd 'SUPPLY'
VA4 A4 gnd 'SUPPLY'
VA5 A5 gnd 'SUPPLY'
VA6 A6 gnd 'SUPPLY'
VA7 A7 gnd 'SUPPLY'

VB0 B0 gnd 0
VB1 B1 gnd 0
VB2 B2 gnd 0
VB3 B3 gnd 0
VB4 B4 gnd 0
VB5 B5 gnd 0
VB6 B6 gnd 0
VB7 B7 gnd 0

VCin Cin gnd PULSE (0 'SUPPLY' 2ns 100ps 100ps 10ns 20ns)

.tran 10ps 20ns

.measure tran tplh_path
+ TRIG v(Cin)       VAL='SUPPLY/2' RISE=1
+ TARG v(Carry_out) VAL='SUPPLY/2' RISE=1

.measure tran tphl_path
+ TRIG v(Cin)       VAL='SUPPLY/2' FALL=1
+ TARG v(Carry_out) VAL='SUPPLY/2' FALL=1

.measure tran tp_path PARAM='(tplh_path+tphl_path)/2'

.measure tran tr_path
+ TRIG v(Carry_out) VAL='0.1*SUPPLY' RISE=1
+ TARG v(Carry_out) VAL='0.9*SUPPLY' RISE=1

.measure tran tf_path
+ TRIG v(Carry_out) VAL='0.9*SUPPLY' FALL=1
+ TARG v(Carry_out) VAL='0.1*SUPPLY' FALL=1

.measure tran iavg_path  AVG i(VDD) FROM=0 TO=20ns
.measure tran power_path PARAM='abs(iavg_path)*SUPPLY'

.print tran v(Cin) v(S7) v(Carry_out)

.end
