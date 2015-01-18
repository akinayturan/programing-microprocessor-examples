
; CC8E Version 1.4, Copyright (c) B Knudsen Data
; C compiler for the PIC18 microcontrollers
; ************  17. Nov 2014   9:32  *************

	processor  PIC18F452
	radix  DEC

	__config 0x300001, 0xF1

INTCON      EQU   0xFF2
Carry       EQU   0
Zero_       EQU   2
ADRESH      EQU   0xFC4
ADCON0      EQU   0xFC2
ADCON1      EQU   0xFC1
TRISE       EQU   0xF96
TRISD       EQU   0xF95
TRISC       EQU   0xF94
TRISB       EQU   0xF93
TRISA       EQU   0xF92
PORTD       EQU   0xF83
PORTC       EQU   0xF82
INT0IF      EQU   1
GIE         EQU   7
GO          EQU   2
t           EQU   0x00
x           EQU   0x02

	GOTO main

  ; FILE yy.c
			;#pragma config[1] = 0xF1 // Osilatör: XT
			;void ayarlar();
			;void bekle(unsigned long t);	// t milisaniye gecikme saðlayan fonksiyon tanýmý
			;void kesme();	
			;
			;
			;void kesme() //kesme gelince yapilacak komutlar, kesmede calisacak fonksiyon main fonksiyonunun ustundeyazilir...	
			;{
kesme
			;	INTCON=0x90; // kesmeler acilir RBO/INT0 girisiinterruptenable edilir. 
	MOVLW 144
	MOVWF INTCON,0
			;	GO=1;	// adc cevrimi baslar
	BSF   0xFC2,GO,0
			;	while(GO);	//cevirme bitene kadar calisir, cevirme bitince go=0 olur
m001	BTFSC 0xFC2,GO,0
	BRA   m001
			;	INT0IF=0;  // yeni kesmeler gelmesi icin butona bagli olan INT0 portundaki interruptflagikapatilir.
	BCF   0xFF2,INT0IF,0
			;	GIE=1;	//kesmeler acilir, yeni kesme gelmesine musade edilir
	BSF   0xFF2,GIE,0
			;}	
	RETURN
			;
			;
			;void main()
			;{
main
			;	
			;	ayarlar();
	RCALL ayarlar
			;
			;//-----------------------------------------------	
			;anadongu:
			;
			;	bekle(1);	// Acquisition Time(Sample&Holdkapasitörünün þarj olmasý için gerekli zaman)
m002	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;	INTCON=0x90; 
	MOVLW 144
	MOVWF INTCON,0
			;	
			;    PORTC.0=1;
	BSF   PORTC,0,0
			;bekle(ADRESH);
	MOVFF ADRESH,t
	CLRF  t+1,0
	RCALL bekle
			;    PORTC.0=0;
	BCF   PORTC,0,0
			;bekle(0xFF-ADRESH);
	COMF  ADRESH,W,0
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;
			;
			;
			;goto anadongu;
	BRA   m002
			;//-----------------------------------------------	
			;}
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;void bekle(unsigned long t)	//t milisaniye gecikme saðlar
			;{
bekle
			;	unsigned x;
			;	t=t/2;
	BCF   0xFD8,Carry,0
	RRCF  t+1,1,0
	RRCF  t,1,0
			;	for(;t>0;t--)
m003	MOVF  t,W,0
	IORWF t+1,W,0
	BTFSC 0xFD8,Zero_,0
	BRA   m006
			;		for(x=140;x>0;x--)
	MOVLW 140
	MOVWF x,0
m004	MOVF  x,1,0
	BTFSC 0xFD8,Zero_,0
	BRA   m005
			;			nop();
	NOP  
	DECF  x,1,0
	BRA   m004
m005	DECF  t,1,0
	MOVLW 0
	SUBWFB t+1,1,0
	BRA   m003
			;}
m006	RETURN
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;void ayarlar()	// Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
			;{	
ayarlar
			;	GIE=1;			// Bütün kesmeleri ac
	BSF   0xFF2,GIE,0
			;	TRISA=0xFF;
	SETF  TRISA,0
			;	TRISB=0xFF;
	SETF  TRISB,0
			;	TRISC=0x00;	
	CLRF  TRISC,0
			;	TRISD=0x00;		
	CLRF  TRISD,0
			;	TRISE=0xFF;
	SETF  TRISE,0
			;	
			;	PORTC=0x00;		
	CLRF  PORTC,0
			;	PORTD=0x00;
	CLRF  PORTD,0
			;	
			;	ADCON0=0b.0100.0001;// Anlog kanal 0 aktif, A/D conversion is not in progress
	MOVLW 65
	MOVWF ADCON0,0
			;	ADCON1=0b.0000.0000;
	CLRF  ADCON1,0
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x000060   12 word(s)  0 % : ayarlar
; 0x000038   20 word(s)  0 % : bekle
; 0x000004    8 word(s)  0 % : kesme
; 0x000014   18 word(s)  0 % : main

; RAM usage: 3 bytes (3 local), 1533 bytes free
; Maximum call level: 1
; Total of 60 code words (0 %)
