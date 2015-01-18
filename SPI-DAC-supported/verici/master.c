#pragma config[1] = 0xF1 // Osilatör: XT
#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
#pragma config[3] = 0xFE // Watchdog Timer kapalý

void ayarlar();
void SPIayar();
void bekle(unsigned long t);   // t milisaniye gecikme saðlayan fonksiyon tanýmý
void main()
{   
anadongu:
ayarlar();

	GO=1;	// adc cevrimi baslar
	while(GO);	//cevirme bitene kadar calisir, cevirme bitince go=0 olur

    PORTB.1=1;
bekle(ADRESH);
    PORTB.1=0;
bekle(0xFF-ADRESH);


PORTD.0=0;
   SSPBUF=ADRESH;
   while(!SSPIF);
   SSPIF=0;
   PORTD.0=1;
 bekle(1);


goto anadongu;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
void ayarlar()   // Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
{   
   GIE=0;         // Bütün kesmeleri kapat

 
  // TRISE=0xFF;
   TRISD=0x00; 
   TRISC=0xD0;
   PORTC=0x00;   
   TRISA=0xFF; 
   TRISB=0x00;
   PORTB=0x00;  

   //SPBRG=25;   // Baud Rate=9.6k
   BRGH=1;      // Yüksek Hýz
   SYNC=1;      // senkron mod
   SMP=0;
   CKE=0;
   BF=0;
   //WCOL=0;
   //SSPOV=0;
   SSPEN=0;
   SSPEN=1;
   CKP=1;
SSPCON1.3=0;
SSPCON1.2=0;
SSPCON1.1=0;
SSPCON1.0=1;

	ADCON0=0b.0100.0001;// Anlog kanal 0 aktif, A/D conversion is not in progress
}


//////////////////////////////////////////////////////////////////////////////////////////////////

void bekle(unsigned long t)   //t milisaniye gecikme saðlar
{
   unsigned x;
   
   for(;t>0;t--)
      for(x=140;x>0;x--)
         nop();
}

//////////////////////////////////////////////////////////////////////////////////////////////////
