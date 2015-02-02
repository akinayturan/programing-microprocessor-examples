
; CC8E Version 1.4, Copyright (c) B Knudsen Data
; C compiler for the PIC18 microcontrollers
; ************  15. Dec 2014  10:36  *************

	processor  PIC18F452
	radix  DEC

	__config 0x300001, 0xF1
	__config 0x300002, 0xF8
	__config 0x300003, 0xFE

Zero_       EQU   2
SPBRG       EQU   0xFAF
RCREG       EQU   0xFAE
TXREG       EQU   0xFAD
TRISE       EQU   0xF96
TRISD       EQU   0xF95
TRISC       EQU   0xF94
TRISB       EQU   0xF93
TRISA       EQU   0xF92
PORTD       EQU   0xF83
PORTC       EQU   0xF82
PORTB       EQU   0xF81
GIE         EQU   7
BRGH        EQU   2
SYNC        EQU   4
TXEN        EQU   5
TX9         EQU   6
CREN        EQU   4
RX9         EQU   6
SPEN        EQU   7
TXIF        EQU   4
RCIF        EQU   5
TXIE        EQU   4
RCIE        EQU   5
sayi        EQU   0x00
x           EQU   0x01
deger       EQU   0x02
t           EQU   0x02
x_2         EQU   0x04

	GOTO main

  ; FILE l2.c
			;#pragma config[1] = 0xF1 // Osilatör: XT
			;#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
			;#pragma config[3] = 0xFE // WatchdogTimer kapalý
			;
			;void ayarlar();
			;void seriTXayar();
			;void seriRXayar();
			;void serigonder(unsigned deger);
			;void bekle(unsigned long t);	// t milisaniye gecikme saðlayan fonksiyon tanýmý
			;unsigned char serial(void);
			;
			;void main()
			;{	
main
			;	unsigned sayi='0',x='0';
	MOVLW 48
	MOVWF sayi,0
	MOVLW 48
	MOVWF x,0
			;	ayarlar();
	RCALL ayarlar
			;
			;//-----------------------------------------------	
			;anadongu:
			;	x=serial();
m001	RCALL serial
	MOVWF x,0
			;	serigonder(x);
	MOVF  x,W,0
	RCALL serigonder
			;	bekle(100);
	MOVLW 100
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;goto anadongu;
	BRA   m001
			;//-----------------------------------------------	
			;}
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;void ayarlar()	// Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
			;{	
ayarlar
			;	GIE=0;			// Bütün kesmeleri kapat
	BCF   0xFF2,GIE,0
			;	TRISA=0xFF;
	SETF  TRISA,0
			;	TRISB=0;
	CLRF  TRISB,0
			;	TRISC=0;	
	CLRF  TRISC,0
			;	TRISD=0;
	CLRF  TRISD,0
			;	TRISE.0=1;
	BSF   TRISE,0,0
			;	TRISE.1=1;
	BSF   TRISE,1,0
			;	TRISE.2=1;
	BSF   TRISE,2,0
			;	
			;	PORTC=0;		
	CLRF  PORTC,0
			;	PORTD=0;
	CLRF  PORTD,0
			;	PORTB=0;
	CLRF  PORTB,0
			;	
			;	seriTXayar();
	RCALL seriTXayar
			;	seriRXayar();
	BRA   seriRXayar
			;
			;	
			;}
			;//////////////////////////////////////////////////////////////////////////////////
			;
			;
			;void serigonder(unsigned deger)	// Seri porttan veri gönderir
			;{	
serigonder
	MOVWF deger,0
			;	while(!TXIF);
m002	BTFSS 0xF9E,TXIF,0
	BRA   m002
			;	nop(); nop(); nop(); nop();
	NOP  
	NOP  
	NOP  
	NOP  
			;	TXREG=deger;
	MOVFF deger,TXREG
			;	
			;}
	RETURN
			;
			;
			;//////////////////////////////////////////////////////////////////////////////////
			;
			;
			;void seriTXayar()	// Seri Portu veri göndermeye hazýr hale getirir
			;{
seriTXayar
			;	TRISC.6=0;
	BCF   TRISC,6,0
			;	TRISC.7=1;
	BSF   TRISC,7,0
			;	SPBRG=25;	// Baud Rate=9.6k
	MOVLW 25
	MOVWF SPBRG,0
			;	BRGH=1;		// Yüksek Hýz
	BSF   0xFAC,BRGH,0
			;	SYNC=0;		// Asenkron mod
	BCF   0xFAC,SYNC,0
			;	SPEN=1;		// Seri port etkin
	BSF   0xFAB,SPEN,0
			;	TXIE=0;
	BCF   0xF9D,TXIE,0
			;	TX9=0;		// 8 bit Veri Gönderme
	BCF   0xFAC,TX9,0
			;	TXEN=1;	// Gönderme etkin	
	BSF   0xFAC,TXEN,0
			;}
	RETURN
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;void bekle(unsigned long t)	//t milisaniye gecikme saðlar
			;{
bekle
			;	unsigned x;
			;	
			;	for(;t>0;t--)
m003	MOVF  t,W,0
	IORWF t+1,W,0
	BTFSC 0xFD8,Zero_,0
	BRA   m006
			;		for(x=80;x>0;x--)
	MOVLW 80
	MOVWF x_2,0
m004	MOVF  x_2,1,0
	BTFSC 0xFD8,Zero_,0
	BRA   m005
			;			nop();
	NOP  
	DECF  x_2,1,0
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
			;unsigned char serial(void)
			;{
serial
			;	while(!RCIF);
m007	BTFSS 0xF9E,RCIF,0
	BRA   m007
			;nop(); nop(); nop(); nop();
	NOP  
	NOP  
	NOP  
	NOP  
			;	return RCREG;
	MOVF  RCREG,W,0
	RETURN
			;}
			;void seriRXayar()	// Seri Portu veri almaya hazýr hale getirir
			;{
seriRXayar
			;	TRISC.6=0;
	BCF   TRISC,6,0
			;	TRISC.7=1;
	BSF   TRISC,7,0
			;	SPBRG=25;	// Baud Rate=9.6k
	MOVLW 25
	MOVWF SPBRG,0
			;	BRGH=1;		// Yüksek Hýz
	BSF   0xFAC,BRGH,0
			;	SYNC=0;		// Asenkron mod
	BCF   0xFAC,SYNC,0
			;	SPEN=1;		// Seri port etkin
	BSF   0xFAB,SPEN,0
			;	RCIE=0;
	BCF   0xF9D,RCIE,0
			;	RX9=0;		// 8 bit Veri Alma
	BCF   0xFAB,RX9,0
			;	CREN=1;	// Alma etkin	
	BSF   0xFAB,CREN,0
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x000020   13 word(s)  0 % : ayarlar
; 0x00004E   11 word(s)  0 % : seriTXayar
; 0x000096   11 word(s)  0 % : seriRXayar
; 0x00003A   10 word(s)  0 % : serigonder
; 0x000064   17 word(s)  0 % : bekle
; 0x000086    8 word(s)  0 % : serial
; 0x000004   14 word(s)  0 % : main

; RAM usage: 5 bytes (5 local), 1531 bytes free
; Maximum call level: 2
; Total of 86 code words (0 %)
