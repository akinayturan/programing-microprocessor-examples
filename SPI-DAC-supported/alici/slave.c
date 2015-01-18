#pragma config[1] = 0xF1 // Osilatör: XT
#pragma config[2] = 0xFE & 0xF9 // PWRT açýk, BOR kapalý
#pragma config[3] = 0xFE // Watchdog Timer kapalý

void ayarlar();
void LcdInit();
void LcdYaz(char);
void LcdKomut(unsigned kom);
void MesajYaz(const char*msj,unsigned adr);
bit e@PORTE.0, rs@PORTE.1, rw@PORTE.2;
unsigned disp@PORTD;
void bekle(unsigned long t);   // t milisaniye gecikme saðlayan fonksiyon tanýmý


void main()
{  
anadongu:
   uns8 gelen;
   ayarlar();

while(!SSPIF);
gelen=SSPBUF;
SSPIF=0;

    PORTB.1=1;
bekle(gelen);
    PORTB.1=0;
bekle(0xFF-gelen);

goto anadongu;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
void ayarlar()   // Bütün baþlangýç ayarlarýnýn tamamlandýðý kýsým
{   
   GIE=0;         // Bütün kesmeleri kapat
   TRISD=0x00;
   TRISA=0xFF;
   TRISE=0x00; 
   TRISC=0x18; 
   TRISB=0x00;
   PORTB=0x00;  
   //SPBRG=25;   // Baud Rate=9.6k
   BRGH=1;      // Yüksek Hýz
  SYNC=1;      // senkron mod
  SMP=0;
  CKE=0;
  BF=0;
  WCOL=0;
  SSPOV=0;
  SSPEN=0;
  SSPEN=1;
  CKP=1;
  SSPCON1.3=0;
  SSPCON1.2=1;
  SSPCON1.1=0;
  SSPCON1.0=1;
  
	ADCON0=0b.0100.0001;// Anlog kanal 0 aktif, A/D conversion is not in progress
} 
 void LcdKomut(unsigned kom)
{
	//while(IsLcdBusy());
	bekle(20);
	disp=kom;
	rs=0;
	e=0;
	e=1;
}
void LcdYaz(char c)
{
	//while(IsLcdBusy());
	bekle(20);
	disp=c;
	rs=1;
	e=0;
	e=1;
	bekle(1);	
}
void LcdInit()
{
	rw=0;
	e=1;
	rs=1;
	LcdKomut(0x38);
	LcdKomut(0x01);	//Clear display
	LcdKomut(0x0D); //Display,Cursor,Blink on
	LcdKomut(0x06); //Increment ddram adres, do not shift disp.
}
void MesajYaz(const char *msj,unsigned adr)
{
	unsigned i,j,k;
	i=0;
	while(msj[i]!=0)	i++;
	LcdKomut(adr);
	for(j=0;j<i;j++){
		LcdYaz(msj[j]);
		for(k=0;k<30;k++)nop();
	}
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

