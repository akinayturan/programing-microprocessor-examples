
; CC8E Version 1.4, Copyright (c) B Knudsen Data
; C compiler for the PIC18 microcontrollers
; ************  15. Dec 2014  10:45  *************

	processor  PIC18F452
	radix  DEC

TBLPTR      EQU   0xFF6
TABLAT      EQU   0xFF5
Zero_       EQU   2
TRISE       EQU   0xF96
TRISD       EQU   0xF95
e           EQU   0
rs          EQU   1
rw          EQU   2
disp        EQU   0xF83
t           EQU   0x06
n           EQU   0x08
kom         EQU   0x05
c           EQU   0x05
msj         EQU   0x00
adr         EQU   0x01
i           EQU   0x02
j           EQU   0x03
k           EQU   0x04
ci          EQU   0x05

	GOTO main

  ; FILE l.c
			;void init();
			;void bekle(unsigned long t);
			;void LcdInit();
			;void LcdYaz(char );
			;void LcdKomut(unsigned kom);
			;void MesajYaz(const char *msj,unsigned adr);
			;
			;bit e @ PORTE.0, rs @ PORTE.1, rw @ PORTE.2;
			;unsigned disp @ PORTD;
			;
			;void main(){
main
			;	init();
	RCALL init
			;	LcdInit();
	RCALL LcdInit
			;anadongu:
			;	MesajYaz("ONiR AKiN",0x80);
m001	CLRF  msj,0
	MOVLW 128
	RCALL MesajYaz
			;	bekle(1500);
	MOVLW 220
	MOVWF t,0
	MOVLW 5
	MOVWF t+1,0
	RCALL bekle
			;	MesajYaz("LCD uygulama    ",0x80);
	MOVLW 10
	MOVWF msj,0
	MOVLW 128
	RCALL MesajYaz
			;	bekle(1500);
	MOVLW 220
	MOVWF t,0
	MOVLW 5
	MOVWF t+1,0
	RCALL bekle
			;	
			;goto anadongu;
	BRA   m001
			;}
			;	
			;
			;void init()
			;{
init
			;	TRISD=0X00;
	CLRF  TRISD,0
			;	TRISE=0X00;
	CLRF  TRISE,0
			;}
	RETURN
			;
			;
			;void bekle(unsigned long t)	//t milisaniye gecikme saðlar
			;{
bekle
			;	unsigned n;
			;	for(;t>0;t--)
m002	MOVF  t,W,0
	IORWF t+1,W,0
	BTFSC 0xFD8,Zero_,0
	BRA   m005
			;		for(n=140;n>0;n--)
	MOVLW 140
	MOVWF n,0
m003	MOVF  n,1,0
	BTFSC 0xFD8,Zero_,0
	BRA   m004
			;			nop();
	NOP  
	DECF  n,1,0
	BRA   m003
m004	DECF  t,1,0
	MOVLW 0
	SUBWFB t+1,1,0
	BRA   m002
			;}
m005	RETURN
			;
			;void LcdKomut(unsigned kom)
			;{
LcdKomut
	MOVWF kom,0
			;	
			;	bekle(20);
	MOVLW 20
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;	disp=kom;
	MOVFF kom,disp
			;	rs=0;
	BCF   0xF84,rs,0
			;	e=0;
	BCF   0xF84,e,0
			;	e=1;
	BSF   0xF84,e,0
			;}
	RETURN
			;
			;void LcdYaz(char c)
			;{
LcdYaz
	MOVWF c,0
			;	bekle(100);
	MOVLW 100
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;	disp=c;
	MOVFF c,disp
			;	rs=1;
	BSF   0xF84,rs,0
			;	e=0;
	BCF   0xF84,e,0
			;	e=1;
	BSF   0xF84,e,0
			;	bekle(1);	
	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	BRA   bekle
			;}
			;
			;
			;void LcdInit()
			;{
LcdInit
			;	rw=0;
	BCF   0xF84,rw,0
			;	e=1;
	BSF   0xF84,e,0
			;	rs=1;
	BSF   0xF84,rs,0
			;	LcdKomut(0x38);	
	MOVLW 56
	RCALL LcdKomut
			;	LcdKomut(0x01);	//Cleardisplay
	MOVLW 1
	RCALL LcdKomut
			;	LcdKomut(0x0D); //Display,Cursor,Blink on
	MOVLW 13
	RCALL LcdKomut
			;	LcdKomut(0x06); //Incrementddram adres, do not shiftdisp.
	MOVLW 6
	BRA   LcdKomut
			;}
			;
			;void MesajYaz(const char *msj,unsigned adr)
			;{
MesajYaz
	MOVWF adr,0
			;	unsigned i,j,k;
			;	i=0;
	CLRF  i,0
			;	while(msj[i]!=0)	i++;
m006	MOVF  i,W,0
	ADDWF msj,W,0
	RCALL _const1
	XORLW 0
	BTFSC 0xFD8,Zero_,0
	BRA   m007
	INCF  i,1,0
	BRA   m006
			;	
			;	LcdKomut(adr);
m007	MOVF  adr,W,0
	RCALL LcdKomut
			;	for(j=0;j<i;j++){
	CLRF  j,0
m008	MOVF  i,W,0
	CPFSLT j,0
	BRA   m011
			;		LcdYaz(msj[j]);
	MOVF  j,W,0
	ADDWF msj,W,0
	RCALL _const1
	RCALL LcdYaz
			;		for(k=0;k<30;k++)nop();
	CLRF  k,0
m009	MOVLW 30
	CPFSLT k,0
	BRA   m010
	NOP  
	INCF  k,1,0
	BRA   m009
			;	}
m010	INCF  j,1,0
	BRA   m008
			;}
m011	RETURN
_const1
	MOVWF ci,0
	MOVF  ci,W,0
	ADDLW 238
	MOVWF TBLPTR,0
	MOVLW 0
	CLRF  TBLPTR+1,0
	ADDWFC TBLPTR+1,1,0
	CLRF  TBLPTR+2,0
	TBLRD *
	MOVF  TABLAT,W,0
	RETURN
	DW    0x4E4F
	DW    0x5269
	DW    0x4120
	DW    0x694B
	DW    0x4E
	DW    0x434C
	DW    0x2044
	DW    0x7975
	DW    0x7567
	DW    0x616C
	DW    0x616D
	DW    0x2020
	DW    0x2020
	DW    0x0

	END


; *** KEY INFO ***

; 0x00002C    3 word(s)  0 % : init
; 0x000032   17 word(s)  0 % : bekle
; 0x000086   11 word(s)  0 % : LcdInit
; 0x00006A   14 word(s)  0 % : LcdYaz
; 0x000054   11 word(s)  0 % : LcdKomut
; 0x00009C   30 word(s)  0 % : MesajYaz
; 0x000004   20 word(s)  0 % : main
; 0x0000D8   25 word(s)  0 % : _const1

; RAM usage: 9 bytes (9 local), 1527 bytes free
; Maximum call level: 3
; Total of 133 code words (0 %)
