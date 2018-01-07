 ;;
 ;;  outputgrb
 ;;      outputgrb( bufp, count);
 ;;      where:
 ;;        bufp - 16 bit pointer to 8 bit GRB sequences
 ;;        count - number of 8 bit GRB sequences (3 per LED)
 ;
 ;;  This routine bit bangs the WS2812B LED. The protocol is kind of ugly. It's timing 
 ;;  based and there is no hardware in standard microcontrollers that can drive it so software 
 ;;  is the only solution. Each bit is clocked at approx 1.25 uS with the length of the 
 ;;  on section determining if it's a one or a zero. Each LED requires about a 30 microsecond 
 ;;  command with interrupts disabled. Sure wish they just used good old SPI but that would 
 ;;  have required an extra pin.
 ;;
 ;;  A 10 LED string will require 300 microsecond of interrupt off. A 100 LED string
 ;;  will take 3 mS.  A 1000 LED string will take, well you get the idea. The good 
 ;;  news is the LEDS will continue for ever once sent a specific set of commands.
 ;;
 ;;  This code was originally written by Mike Silva and posted on his blog at www.embeddedrelated.com
 ;;  with a very nice explanation of how it works.
 ;;
 ;;  Todo:
 ;;     - make output pin a parameter
 ;;     - mul count by 3 to make it 1 per LED, not 3.
 ;;     - investigate SPI version
 ;;     - rewrite for 16 and 20 MHz clocks
 ;;
 
 ; let us start off with a grotesque hack to make I/O PORT addresses be right under Atmel Studio 7
 #define __SFR_OFFSET 0x0
 #include <avr/io.h>
 .global outputgrb

 ; This is the output pin.
#define OUTBIT 4

outputgrb:
         movw   r26, r24      ;r26:27 = X = p_buf
         movw   r24, r22      ;r24:25 = count
         in     r22, SREG     ;save SREG (global int state)
         cli                  ;no interrupts from here on, we're cycle-counting
         in     r20, PORTB
         ori    r20, (1<<OUTBIT)         ;our '1' output
         in     r21, PORTB
         andi   r21, ~(1<<OUTBIT)        ;our '0' output
         ldi    r19, 7        ;7 bit counter (8th bit is different)
         ld     r18,X+        ;get first data byte
loop1:
         out    PORTB, r20    ; 1   +0 start of a bit pulse
         lsl    r18           ; 1   +1 next bit into C, MSB first
         brcs   L1            ; 1/2 +2 branch if 1
         out    PORTB, r21    ; 1   +3 end hi for '0' bit (3 clocks hi)
         nop                  ; 1   +4
         bst    r18, 7        ; 1   +5 save last bit of data for fast branching
         subi   r19, 1        ; 1   +6 how many more bits for this byte?
         breq   bit8          ; 1/2 +7 last bit, do differently
         rjmp   loop1         ; 2   +8, 10 total for 0 bit
L1:
         nop                  ; 1   +4
         bst    r18, 7        ; 1   +5 save last bit of data for fast branching
         subi   r19, 1        ; 1   +6 how many more bits for this byte
         out    PORTB, r21    ; 1   +7 end hi for '1' bit (7 clocks hi)
         brne   loop1         ; 2/1 +8, 10 total for 1 bit (fall thru if last bit)
bit8:
         ldi    r19, 7        ; 1   +9 bit count for next byte
         out    PORTB, r20    ; 1   +0 start of a bit pulse
         brts   L2            ; 1/2 +1 branch if last bit is a 1
         nop                  ; 1   +2
         out    PORTB, r21    ; 1   +3 end hi for '0' bit (3 clocks hi)
         ld     r18, X+       ; 2   +4 fetch next byte
         sbiw   r24, 1        ; 2   +6 dec byte counter
         brne   loop1         ; 2   +8 loop back or return
		 nop
         out    SREG, r22     ; restore global int flag
         ret
L2:
         ld     r18, X+       ; 2   +3 fetch next byte
         sbiw   r24, 1        ; 2   +5 dec byte counter
         out     PORTB, r21   ; 1   +7 end hi for '1' bit (7 clocks hi)
         brne   loop1         ; 2   +8 loop back or return
         out    SREG, r22 
		 ret
