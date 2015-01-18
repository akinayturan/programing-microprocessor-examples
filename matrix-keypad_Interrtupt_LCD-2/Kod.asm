
; CC8E Version 1.3D, Copyright (c) B Knudsen Data
; C compiler for the PIC18 microcontrollers
; ************  24. Jan 2011  11:11  *************

	processor  PIC18F452
	radix  DEC

	__config 0x300001, 0xF1
	__config 0x300002, 0xF8
	__config 0x300003, 0xFE

TBLPTR      EQU   0xFF6
TABLAT      EQU   0xFF5
PRODL       EQU   0xFF3
Carry       EQU   0
Zero_       EQU   2
TRISE       EQU   0xF96
TRISD       EQU   0xF95
TRISC       EQU   0xF94
TRISB       EQU   0xF93
PORTD       EQU   0xF83
PORTC       EQU   0xF82
PORTB       EQU   0xF81
INT0IF      EQU   1
INT0IE      EQU   4
GIE         EQU   7
INTEDG0     EQU   6
e           EQU   0
rs          EQU   1
rw          EQU   2
disp        EQU   0xF83
t           EQU   0x0C
x           EQU   0x0E
index       EQU   0x01
b           EQU   0x02
kom         EQU   0x0B
c           EQU   0x0B
msj         EQU   0x06
adr         EQU   0x07
i           EQU   0x08
j           EQU   0x09
k           EQU   0x0A
ci          EQU   0x0B

	GOTO main

  ; FILE Kod.c
			;#pragma config[1] = 0xF1 // Osilatör: XT
			;#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
			;#pragma config[3] = 0xFE // Watchdog Timer kapalý
			;#pragma origin 0x8    //Aþaðýdaki kesme fonksiyonunun hangi program satýrýndan baþlayacaðý ayarlandý
	ORG 0x0008
			;       					//(0x8 adresi yüksek öncelikli kesme baþlangýç adresidir)
			;
			;#pragma interruptSaveCheck n
			;#pragma sharedAllocation
			;
			;void ayarlar();
			;void bekle(unsigned long t);	// t milisaniye gecikme saðlayan fonksiyon tanýmý
			;void oku_yaz();
			;void LcdInit();
			;void LcdYaz(char);
			;void LcdKomut(unsigned kom);
			;void MesajYaz(const char *msj,unsigned adr);
			;
			;bit e @ PORTE.0, rs @ PORTE.1, rw @ PORTE.2;
			;unsigned disp @ PORTD;
			;
			;
			;interrupt int_server(void)  // KESME SUNUCU FONKSÝYONU
			;{   
int_server
			;	if(INT0IF)				//Gelen kesme, INT0 kesmesi mi?
	BTFSS 0xFF2,INT0IF,0
	BRA   m001
			;	{
			;		oku_yaz();
	RCALL oku_yaz
			;		INT0IF = 0;
	BCF   0xFF2,INT0IF,0
			;	}
			;}
m001	RETFIE
			;
			;
			;void main()
			;{
main
			;	ayarlar(); // Ýlgili Port ve INT tanýmlamalarýnýn yapýlmdýðý fonksiyon
	RCALL ayarlar
			;	LcdInit(); // LCD' nin kullanýmý için gerekli ayarlamalar.
	RCALL LcdInit
			;	
			;	MesajYaz("Islem Basliyor",0x80); //0x80 Cursorýn baslangýc konumunu belirliyor
	CLRF  msj,0
	MOVLW 128
	RCALL MesajYaz
			;	bekle(500);
	MOVLW 244
	MOVWF t,0
	MOVLW 1
	MOVWF t+1,0
	RCALL bekle
			;//-----------------------------------------------	
			;anadongu:
			;	
			;	
			; 	bekle(1);	// Acquisition Time(Sample & Hold kapasitörünün þarj olmasý için gerekli zaman)
m002	MOVLW 1
	MOVWF t,0
	CLRF  t+1,0
	RCALL bekle
			; 	MesajYaz("Basilan Tus : ",0x80);
	MOVLW 15
	MOVWF msj,0
	MOVLW 128
	RCALL MesajYaz
			;	goto anadongu;
	BRA   m002
			;//-----------------------------------------------	
			;}
			;
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;
			;void ayarlar()	// Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
			;{	
ayarlar
			;
			;	INT0IE = 1;		// INT0 kesmesi açýk
	BSF   0xFF2,INT0IE,0
			;	INTEDG0 = 0;	// INT0 kesmesi düþen kenarda aktif olacak
	BCF   0xFF1,INTEDG0,0
			;	GIE = 1;		// Bütün kesmeler kullanýlabilir
	BSF   0xFF2,GIE,0
			;	TRISC = 0x00;	// PORTC çýkýþ yapýldý( LED )
	CLRF  TRISC,0
			;	TRISB = 0xFF;	// PORTB giriþ yapýldý ( Matrix Klavye )
	SETF  TRISB,0
			;	TRISD = 0X00;	// PORTD çýkýþ yapýldý ( LCD )
	CLRF  TRISD,0
			;	TRISE = 0X00;	// PORTE çýkýþ yapýldý ( LCD )
	CLRF  TRISE,0
			;	
			;	PORTC = 0;		// PORTC çýkýþlarý sýfýrlandý
	CLRF  PORTC,0
			;	PORTD = 0;	
	CLRF  PORTD,0
			;	
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
			;void oku_yaz()
			;{
oku_yaz
			;	unsigned x;
			;	int index;
			;	int b[4];
			;	static const v[8] = {0x01,0x02,0x03,0x00,0x04,0x05,0x06,0x00}; //Girilen deðer 6'dan küçükse kullanýlan bu diziyi kullan
			;	static const n[8] = {0x07,0x08,0x09,0x00,0x0F,0x00,0x0F,0x00}; //Girilen deðer 6'dan büyükse kullanýlan bu diziyi kullan
			;	
			;	//Matrix klavyeden girilen deðeri bulmak için, b dizisini kullan
			;	b[0] = PORTB.4;
	CLRF  b,0
	BTFSC PORTB,4,0
	INCF  b,1,0
			;	b[1] = PORTB.5;
	CLRF  b+1,0
	BTFSC PORTB,5,0
	INCF  b+1,1,0
			;	b[2] = PORTB.6;
	CLRF  b+2,0
	BTFSC PORTB,6,0
	INCF  b+2,1,0
			;	b[3] = PORTB.7;
	CLRF  b+3,0
	BTFSC PORTB,7,0
	INCF  b+3,1,0
			;
			;	//Girilen sayýnýn decimal karþýlýðý
			;	index = b[0] + (b[1]*2);
	BCF   0xFD8,Carry,0
	RLCF  b+1,W,0
	ADDWF b,W,0
	MOVWF index,0
			;	index += (b[2]*4); 
	MOVLW 4
	MULWF b+2,0
	MOVF  PRODL,W,0
	ADDWF index,1,0
			;	index += (b[3]*8);
	MOVLW 8
	MULWF b+3,0
	MOVF  PRODL,W,0
	ADDWF index,1,0
			;	
			;	if( index>6 ) //Girilen sayýnýn 6 dan büyük olmasý
	BTFSC index,7,0
	BRA   m014
	MOVLW 6
	CPFSGT index,0
	BRA   m014
			;	{
			;		
			;		PORTC = n[index-8];
	MOVLW 30
	ADDWF index,W,0
	RCALL _const1
	MOVWF PORTC,0
			;		if ( index == 12 || index == 14 ) //Basýlan tuþun "*" veya "#" olmasý
	MOVF  index,W,0
	XORLW 12
	BTFSC 0xFD8,Zero_,0
	BRA   m007
	MOVLW 14
	CPFSEQ index,0
	BRA   m009
			;		{
			;			if ( index == 12 )
m007	MOVLW 12
	CPFSEQ index,0
	BRA   m008
			;				MesajYaz("*",0x8E);
	MOVLW 46
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;			else
	BRA   m021
			;				MesajYaz("#",0x8E);
m008	MOVLW 48
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;		}
			;		else //Basýlan tuþun 7,8,9,0 olmasý durumu
	BRA   m021
			;		{
			;			switch (index)
m009	MOVF  index,W,0
	XORLW 8
	BTFSC 0xFD8,Zero_,0
	BRA   m010
	XORLW 1
	BTFSC 0xFD8,Zero_,0
	BRA   m011
	XORLW 3
	BTFSC 0xFD8,Zero_,0
	BRA   m012
	XORLW 7
	BTFSC 0xFD8,Zero_,0
	BRA   m013
	BRA   m021
			;			{
			;				case 8:
			;					MesajYaz("7",0x8E);
m010	MOVLW 50
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;				case 9:
			;					MesajYaz("8",0x8E);
m011	MOVLW 52
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;				case 10:
			;					MesajYaz("9",0x8E);
m012	MOVLW 54
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;				case 13:
			;					MesajYaz("0",0x8E);
m013	MOVLW 56
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;			}
			;		}
			;	}
			;	else //Girilen sayýnýn 6 veya 6'dan küçük olmasý
			;	{
			;		PORTC = v[index];
m014	MOVLW 30
	ADDWF index,W,0
	RCALL _const1
	MOVWF PORTC,0
			;		switch(index) //Basýlan tuþun 1,2,3,4,5,6 olmasý durumu
	MOVF  index,W,0
	BTFSC 0xFD8,Zero_,0
	BRA   m015
	XORLW 1
	BTFSC 0xFD8,Zero_,0
	BRA   m016
	XORLW 3
	BTFSC 0xFD8,Zero_,0
	BRA   m017
	XORLW 6
	BTFSC 0xFD8,Zero_,0
	BRA   m018
	XORLW 1
	BTFSC 0xFD8,Zero_,0
	BRA   m019
	XORLW 3
	BTFSC 0xFD8,Zero_,0
	BRA   m020
	BRA   m021
			;		{
			;			case 0:
			;					MesajYaz("1",0x8E);
m015	MOVLW 58
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;			case 1:
			;					MesajYaz("2",0x8E);
m016	MOVLW 60
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;			case 2:
			;					MesajYaz("3",0x8E);
m017	MOVLW 62
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;			case 4:
			;					MesajYaz("4",0x8E);
m018	MOVLW 64
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;			case 5:
			;					MesajYaz("5",0x8E);
m019	MOVLW 66
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
	BRA   m021
			;			case 6:
			;					MesajYaz("6",0x8E);
m020	MOVLW 68
	MOVWF msj,0
	MOVLW 142
	RCALL MesajYaz
			;					break;
			;		}
			;	}	
			;}
m021	RETURN
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;void LcdKomut(unsigned kom) // Gelen mesajýn iþlem komutuna göre, ilgili komutu gerçekleþtiren fonksiyon 
			;{							// MesajYaz("....",0x80); satýrýndaki 0x80' i iþleme koyan fonksiyon
LcdKomut
	MOVWF kom,0
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
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;void LcdYaz(char c) // Gelen karakteri ekrana basan fonksiyon
			;{
LcdYaz
	MOVWF c,0
			;	bekle(50);
	MOVLW 50
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
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;void LcdInit() // LCD ekranýn kullaným özelliklerini belirleyen fonksiyon
			;{
LcdInit
			;	rw=0;			// LCD' ye yazdýrma
	BCF   0xF84,rw,0
			;	e=1;			// LCD aktif edildi
	BSF   0xF84,e,0
			;	rs=1;			// Yazmaç seçimi
	BSF   0xF84,rs,0
			;	LcdKomut(0x38);	
	MOVLW 56
	RCALL LcdKomut
			;	LcdKomut(0x01);	//Clear display
	MOVLW 1
	RCALL LcdKomut
			;	LcdKomut(0x0C); //Dont display cursor,Blink off
	MOVLW 12
	RCALL LcdKomut
			;	LcdKomut(0x06); //Increment ddram adres, do not shift disp.
	MOVLW 6
	BRA   LcdKomut
			;}
			;//////////////////////////////////////////////////////////////////////////////////////////////////
			;void MesajYaz(const char *msj,unsigned adr)
			;{
MesajYaz
	MOVWF adr,0
			;	unsigned i,j,k;
			;	i=0;
	CLRF  i,0
			;	while(msj[i]!=0) //Gelen mesajýn boyutunun bulunmasý
m022	MOVF  i,W,0
	ADDWF msj,W,0
	RCALL _const1
	XORLW 0
	BTFSC 0xFD8,Zero_,0
	BRA   m023
			;		i++;
	INCF  i,1,0
	BRA   m022
			;	
			;	LcdKomut(adr);
m023	MOVF  adr,W,0
	RCALL LcdKomut
			;	for(j=0;j<i;j++) //LcdYaz fonksiyonu içine, mesajýn karakterleri tek tek yollanýyor.
	CLRF  j,0
m024	MOVF  i,W,0
	CPFSLT j,0
	BRA   m027
			;	{
			;		LcdYaz(msj[j]);
	MOVF  j,W,0
	ADDWF msj,W,0
	RCALL _const1
	RCALL LcdYaz
			;		for(k=0;k<30;k++) //30 cycle boyunca bekleme yarat
	CLRF  k,0
m025	MOVLW 30
	CPFSLT k,0
	BRA   m026
			;			nop();
	NOP  
	INCF  k,1,0
	BRA   m025
			;	}
m026	INCF  j,1,0
	BRA   m024
m027	RETURN
_const1
	MOVWF ci,0
	MOVF  ci,W,0
	ADDLW 32
	MOVWF TBLPTR,0
	MOVLW 2
	CLRF  TBLPTR+1,0
	ADDWFC TBLPTR+1,1,0
	CLRF  TBLPTR+2,0
	TBLRD *
	MOVF  TABLAT,W,0
	RETURN
	DW    0x7349
	DW    0x656C
	DW    0x206D
	DW    0x6142
	DW    0x6C73
	DW    0x7969
	DW    0x726F
	DW    0x4200
	DW    0x7361
	DW    0x6C69
	DW    0x6E61
	DW    0x5420
	DW    0x7375
	DW    0x3A20
	DW    0x20
	DW    0x201
	DW    0x3
	DW    0x504
	DW    0x6
	DW    0x807
	DW    0x9
	DW    0xF
	DW    0xF
	DW    0x2A
	DW    0x23
	DW    0x37
	DW    0x38
	DW    0x39
	DW    0x30
	DW    0x31
	DW    0x32
	DW    0x33
	DW    0x34
	DW    0x35
	DW    0x36

	END


; *** KEY INFO ***

; 0x000038   10 word(s)  0 % : ayarlar
; 0x00004C   17 word(s)  0 % : bekle
; 0x00006E  140 word(s)  0 % : oku_yaz
; 0x0001B8   11 word(s)  0 % : LcdInit
; 0x00019C   14 word(s)  0 % : LcdYaz
; 0x000186   11 word(s)  0 % : LcdKomut
; 0x0001CE   30 word(s)  0 % : MesajYaz
; 0x000008    5 word(s)  0 % : int_server
; 0x000012   19 word(s)  0 % : main
; 0x00020A   46 word(s)  0 % : _const1

; RAM usage: 15 bytes (15 local), 1521 bytes free
; Maximum call level: 3 (+5 for interrupt)
; Total of 305 code words (1 %)
