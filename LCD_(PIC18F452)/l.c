void init();
void bekle(unsigned long t);
void LcdInit();
void LcdYaz(char );
void LcdKomut(unsigned kom);
void MesajYaz(const char *msj,unsigned adr);

bit e @ PORTE.0, rs @ PORTE.1, rw @ PORTE.2;
unsigned disp @ PORTD;

void main(){
	init();
	LcdInit();
anadongu:
	MesajYaz("ONiR AKiN",0x80);
	bekle(1500);
	MesajYaz("LCD uygulama    ",0x80);
	bekle(1500);
	
goto anadongu;
}
	

void init()
{
	TRISD=0X00;
	TRISE=0X00;
}


void bekle(unsigned long t)	//t milisaniye gecikme saðlar
{
	unsigned n;
	for(;t>0;t--)
		for(n=140;n>0;n--)
			nop();
}

void LcdKomut(unsigned kom)
{
	
	bekle(20);
	disp=kom;
	rs=0;
	e=0;
	e=1;
}

void LcdYaz(char c)
{
	bekle(100);
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
	LcdKomut(0x01);	//Cleardisplay
	LcdKomut(0x0D); //Display,Cursor,Blink on
	LcdKomut(0x06); //Incrementddram adres, do not shiftdisp.
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

