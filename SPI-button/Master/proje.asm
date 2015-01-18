
; CC8E Version 1.3D, Copyright (c) B Knudsen Data
; C compiler for the PIC18 microcontrollers
; ************  23. Jan 2011  19:59  *************

	processor  PIC18F452
	radix  DEC

	__config 0x300001, 0xF1
	__config 0x300002, 0xF8
	__config 0x300003, 0xFE

Zero_       EQU   2
SSPBUF      EQU   0xFC9
SSPADD      EQU   0xFC8
SSPCON1     EQU   0xFC6
TRISD       EQU   0xF95
TRISC       EQU   0xF94
PORTD       EQU   0xF83
PORTC       EQU   0xF82
GIE         EQU   7
SSPEN       EQU   5
SEN         EQU   0
PEN         EQU   2
SSPIF       EQU   3
TUS         EQU   0x03
data        EQU   0x04
t           EQU   0x00
x           EQU   0x02

	GOTO main

  ; FILE proje.c
			;
			;#pragma config[1] = 0xF1 // Osilatör: XT
			;#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
			;#pragma config[3] = 0xFE // Watchdog Timer kapalý
			;
			;char	keypad_oku();
			;void	i2cgonder();
			;char	TUS;
			;char	data;
			;void	ayarlar();
			;void 	bekle(unsigned long t);	// t milisaniye gecikme saðlayan fonksiyon tanýmý
			;
			;//-----------------------------------------------	
			;unsigned data;
			;void main()
			;{
main
			;	ayarlar();
	RCALL ayarlar
			;
			;anadongu:
			;	bekle(1);	// Acquisition Time(Sample & Hold kapasitörünün þarj olmasý için gerekli zaman)
	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;  	while(1)
			; {
			;	PORTD=keypad_oku();
m001	RCALL keypad_oku
	MOVWF PORTD,0
			;	data=TUS;
	MOVFF TUS,data
			;	i2cgonder();
	RCALL i2cgonder
			; }   
	BRA   m001
			;	goto anadongu;
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
			;	TRISC.3=1; 		//I2C SCL Ayarý
	BSF   TRISC,3,0
			;	TRISC.4=1; 		//I2C SDA Ayarý
	BSF   TRISC,4,0
			;	SSPCON1.3=1; 	//I2C Master Modu seç
	BSF   SSPCON1,3,0
			;	SSPCON1.2=0;
	BCF   SSPCON1,2,0
			;	SSPCON1.1=0;
	BCF   SSPCON1,1,0
			;	SSPCON1.0=0;
	BCF   SSPCON1,0,0
			;	SSPADD=0x0A; 	//100kHZ Hýz Modu seç
	MOVLW 10
	MOVWF SSPADD,0
			;	SSPEN=1; 		//MSSP'yi Etkinleþtir
	BSF   0xFC6,SSPEN,0
			;	TRISD=0xF0;		// 
	MOVLW 240
	MOVWF TRISD,0
			;		
			;	PORTD=0;		// D portu çýkýþlarý sýfýrlandý
	CLRF  PORTD,0
			;	PORTC=0;		// C portu çýkýþlarý sýfýrlandý
	CLRF  PORTC,0
			;
			;
			;}
	RETURN
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;void i2cgonder()
			;{
i2cgonder
			;	SEN=1; 			//I2C Start Biti Yolla
	BSF   0xFC5,SEN,0
			;	while(SEN); 	//Baþlatma iþlemi geçerli olana kadar bekle
m002	BTFSC 0xFC5,SEN,0
	BRA   m002
			;	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
	BCF   0xF9E,SSPIF,0
			;	SSPBUF=0x02; 	//Seçilecek I2C Cihazýnýn Adresini Gönder ve Yazma Bitini Aktifleþtir
	MOVLW 2
	MOVWF SSPBUF,0
			;	while(!SSPIF); 	//Adres Gönderilene Kadar Bekle
m003	BTFSS 0xF9E,SSPIF,0
	BRA   m003
			;	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
	BCF   0xF9E,SSPIF,0
			;	SSPBUF=data; 	//Seçilen Cihaza Veriyi Gönder
	MOVFF data,SSPBUF
			;	while(!SSPIF); 	//Veri Gönderilene Kadar Bekle
m004	BTFSS 0xF9E,SSPIF,0
	BRA   m004
			;	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
	BCF   0xF9E,SSPIF,0
			;	PEN=1; 			//I2C Stop Biti Yolla
	BSF   0xFC5,PEN,0
			;	while(PEN); 	//Bitirme iþlemi geçerli olana kadar bekle
m005	BTFSC 0xFC5,PEN,0
	BRA   m005
			;	SSPIF=0; 		//SSPIF Bayraðýný Sýfýrla
	BCF   0xF9E,SSPIF,0
			;}
	RETURN
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;char keypad_oku()	// tarama keypad'ýn okunduðu kýsým
			;{	
keypad_oku
			;	PORTD.0=1;
	BSF   PORTD,0,0
			;	if(PORTD.4==1)
	BTFSS PORTD,4,0
	BRA   m006
			;	{bekle(50);TUS=0X01;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 1
	MOVWF TUS,0
			;	if(PORTD.5==1)
m006	BTFSS PORTD,5,0
	BRA   m007
			;	{bekle(50);TUS=0X02;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 2
	MOVWF TUS,0
			;	if(PORTD.6==1)
m007	BTFSS PORTD,6,0
	BRA   m008
			;	{bekle(50);TUS=0X03;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 3
	MOVWF TUS,0
			;	if(PORTD.7==1)
m008	BTFSS PORTD,7,0
	BRA   m009
			;	{bekle(50);TUS=0X0A;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 10
	MOVWF TUS,0
			;  	PORTD.0=0;
m009	BCF   PORTD,0,0
			;	bekle(1);  	
	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;
			;	PORTD.1=1;
	BSF   PORTD,1,0
			;	if(PORTD.4==1)
	BTFSS PORTD,4,0
	BRA   m010
			;	{bekle(50);TUS=0X04;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 4
	MOVWF TUS,0
			;	if(PORTD.5==1)
m010	BTFSS PORTD,5,0
	BRA   m011
			;	{bekle(50);TUS=0X05;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 5
	MOVWF TUS,0
			;	if(PORTD.6==1)
m011	BTFSS PORTD,6,0
	BRA   m012
			;	{bekle(50);TUS=0X06;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 6
	MOVWF TUS,0
			;	if(PORTD.7==1)
m012	BTFSS PORTD,7,0
	BRA   m013
			;	{bekle(50);TUS=0X0B;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 11
	MOVWF TUS,0
			;	PORTD.1=0;
m013	BCF   PORTD,1,0
			;	bekle(1);  
	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;
			;	PORTD.2=1;
	BSF   PORTD,2,0
			;	if(PORTD.4==1)
	BTFSS PORTD,4,0
	BRA   m014
			;	{bekle(50);TUS=0X07;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 7
	MOVWF TUS,0
			;	if(PORTD.5==1)
m014	BTFSS PORTD,5,0
	BRA   m015
			;	{bekle(50);TUS=0X08;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 8
	MOVWF TUS,0
			;	if(PORTD.6==1)
m015	BTFSS PORTD,6,0
	BRA   m016
			;	{bekle(50);TUS=0X09;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 9
	MOVWF TUS,0
			;	if(PORTD.7==1)
m016	BTFSS PORTD,7,0
	BRA   m017
			;	{bekle(50);TUS=0X0C;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 12
	MOVWF TUS,0
			;	PORTD.2=0;
m017	BCF   PORTD,2,0
			;	bekle(1);  
	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;
			;	PORTD.3=1;
	BSF   PORTD,3,0
			;	if(PORTD.4==1)
	BTFSS PORTD,4,0
	BRA   m018
			;	{bekle(50);TUS=0X0E;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 14
	MOVWF TUS,0
			;	if(PORTD.5==1)
m018	BTFSS PORTD,5,0
	BRA   m019
			;	{bekle(50);TUS=0X00;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	CLRF  TUS,0
			;	if(PORTD.6==1)
m019	BTFSS PORTD,6,0
	BRA   m020
			;	{bekle(50);TUS=0X0F;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 15
	MOVWF TUS,0
			;	if(PORTD.7==1)
m020	BTFSS PORTD,7,0
	BRA   m021
			;	{bekle(50);TUS=0X0D;}
	MOVLW 50
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
	MOVLW 13
	MOVWF TUS,0
			;	PORTD.3=0;
m021	BCF   PORTD,3,0
			;	bekle(1);  
	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			;	
			;	return TUS;	
	MOVF  TUS,W,0
	RETURN
			;	
			;}
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;void bekle(unsigned long t)	//t milisaniye gecikme saðlar
			;{
bekle
			;	unsigned x;
			;	
			;	for(;t>0;t--)
m022	MOVF  t,W,0
	IORWF t+1,W,0
	BTFSC 0xFD8,Zero_,0
	BRA   m025
			;		for(x=140;x>0;x--)
	MOVLW 140
	MOVWF x,0
m023	MOVF  x,1,0
	BTFSC 0xFD8,Zero_,0
	BRA   m024
			;			nop();
	NOP  
	DECF  x,1,0
	BRA   m023
m024	DECF  t,1,0
	MOVLW 0
	SUBWFB t+1,1,0
	BRA   m022
			;}
m025	RETURN

	END


; *** KEY INFO ***

; 0x00005E  153 word(s)  0 % : keypad_oku
; 0x000038   19 word(s)  0 % : i2cgonder
; 0x00001A   15 word(s)  0 % : ayarlar
; 0x000190   17 word(s)  0 % : bekle
; 0x000004   11 word(s)  0 % : main

; RAM usage: 5 bytes (3 local), 1531 bytes free
; Maximum call level: 2
; Total of 217 code words (1 %)
