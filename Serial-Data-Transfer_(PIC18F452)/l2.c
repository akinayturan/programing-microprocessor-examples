#pragma config[1] = 0xF1 // Osilatör: XT
#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
#pragma config[3] = 0xFE // WatchdogTimer kapalý

void ayarlar();
void seriTXayar();
void seriRXayar();
void serigonder(unsigned deger);
void bekle(unsigned long t);	// t milisaniye gecikme saðlayan fonksiyon tanýmý
unsigned char serial(void);

void main()
{	
	unsigned sayi='0',x='0';
	ayarlar();

//-----------------------------------------------	
anadongu:
	x=serial();
	serigonder(x);
	bekle(100);
goto anadongu;
//-----------------------------------------------	
}

//////////////////////////////////////////////////////////////////////////////////////////////////

void ayarlar()	// Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
{	
	GIE=0;			// Bütün kesmeleri kapat
	TRISA=0xFF;
	TRISB=0;
	TRISC=0;	
	TRISD=0;
	TRISE.0=1;
	TRISE.1=1;
	TRISE.2=1;
	
	PORTC=0;		
	PORTD=0;
	PORTB=0;
	
	seriTXayar();
	seriRXayar();

	
}
//////////////////////////////////////////////////////////////////////////////////


void serigonder(unsigned deger)	// Seri porttan veri gönderir
{	
	while(!TXIF);
	nop(); nop(); nop(); nop();
	TXREG=deger;
	
}


//////////////////////////////////////////////////////////////////////////////////


void seriTXayar()	// Seri Portu veri göndermeye hazýr hale getirir
{
	TRISC.6=0;
	TRISC.7=1;
	SPBRG=25;	// Baud Rate=9.6k
	BRGH=1;		// Yüksek Hýz
	SYNC=0;		// Asenkron mod
	SPEN=1;		// Seri port etkin
	TXIE=0;
	TX9=0;		// 8 bit Veri Gönderme
	TXEN=1;	// Gönderme etkin	
}

//////////////////////////////////////////////////////////////////////////////////////////////////

void bekle(unsigned long t)	//t milisaniye gecikme saðlar
{
	unsigned x;
	
	for(;t>0;t--)
		for(x=80;x>0;x--)
			nop();
}

//////////////////////////////////////////////////////////////////////////////////////////////////

unsigned char serial(void)
{
	while(!RCIF);
nop(); nop(); nop(); nop();
	return RCREG;
}
void seriRXayar()	// Seri Portu veri almaya hazýr hale getirir
{
	TRISC.6=0;
	TRISC.7=1;
	SPBRG=25;	// Baud Rate=9.6k
	BRGH=1;		// Yüksek Hýz
	SYNC=0;		// Asenkron mod
	SPEN=1;		// Seri port etkin
	RCIE=0;
	RX9=0;		// 8 bit Veri Alma
	CREN=1;	// Alma etkin	
}

