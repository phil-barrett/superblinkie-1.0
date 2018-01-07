/*
 * superblinkie.cpp
 *
 * Created: 1/3/2018 10:23:37 AM
 * Author : philba
 */ 
#define F_CPU 8000000L

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#define NUMLEDS 3

struct grb_t {
	uint8_t G;
	uint8_t R;
	uint8_t B; } grb8[] = {0,0,0, 0,128,0, 128,0,0, 0,0,128, 
		0,0,0, 0,128,0, 128,0,0, 0,0,128,
		0,0,0, 0,128,0, 128,0,0, 0,0,128,
		0,0,0, 0,128,0, 128,0,0, 0,0,128,
		0,0,0, 0,128,0, 128,0,0, 0,0,128 
		};
		
extern "C" void outputgrb( grb_t * grbp, int cnt);

void init_timer0(){
	cli();
	OCR0A = 0x40;	// 64 count, 1 mS interrupt period
//	TCCR0A = 0x02;	// clear timer on comp match mode
	TIFR |= 0x1;	// clear int flag
	TIMSK = (1<<OCIE0B) | (1<<TOIE0);	//TC0 comp match A interrupt enable
	TCCR0B = 0x04;	// prescale 8 mhz clock to 64 Khz (div by 64)
	sei();	
}

unsigned long _ms_timer = 0;
ISR(TIMER0_COMPA_vect) {
//ISR(TIMER0_COMPA_vect) {
	_ms_timer++;
}

void delay_ms(unsigned long mils){
	
	mils += _ms_timer;
	while(mils > _ms_timer);
}

int main(void)
{
	int i;
	
//	init_timer0();
	DDRB = 0x10;
//	outputgrb(grb8, 3*NUMLEDS);
			outputgrb(&grb8[0], 3);

	while(1){
		i=0;
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
		outputgrb(&grb8[i++], 24);
		_delay_ms(250L);_delay_ms(250L);
	}
}

