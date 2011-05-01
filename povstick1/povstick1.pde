// 
// POV stick
//
// Hold B1 to play back once
// Tap B2 to change timing
//

#include <PossanSB.h>
#include <Bounce.h>
#include <avr/pgmspace.h>
#define BINTYPE prog_uchar
#define BINSUFFIX PROGMEM

#include "pixels1.h"
#include "pixels2.h"
// #include "pixels3.h"

#define B1_PIN 8
#define B2_PIN 9

PossanSB sb(13,12,11,10);
Bounce b1 = Bounce(B1_PIN,25);
Bounce b2 = Bounce(B2_PIN,25);

enum STATES {
  STATE_IDLE,
  STATE_DEMOING,
  STATE_PLAY,
  STATE_PLAY_LOOP_LIGHT,
  STATE_PLAY_LOOP_DARK,
  STATE_PLAY_ENDING,
  STATE_PLAY_ENDED,
};

#define ROWS 10
#define COLUMNS 100
#define MODES 4

int image = 0;
int column = 0;
int counter = 0;
STATES state = STATE_IDLE;
int shutter_mode = 0;
int shutter_lighttime = 0;
int shutter_darktime = 0;


int gammatable[] = {
  0,
  0,
  0,
  0,
  0,
  1,
  1,
  1,  
  2,
  2,
  3,
  7,
  40,
  156,
  512,
  1023
};

int gamma(int bri) { 
  return gammatable[bri>>4];
}

void fillrow() {
    unsigned char *data = NULL;
    if( (image % 2) == 0 ) data = (unsigned char *) &pixels1;
    if( (image % 2) == 1 ) data = (unsigned char *) &pixels2;
 //   if( (image % 3) == 2 ) data = (unsigned char *) &pixels3;
    sb.begin();
    for( long y=ROWS-1; y>=0; y-- ) {
      long bo = (y * COLUMNS) + column;
      bo *= 3;
      unsigned char rr = pgm_read_byte_near( data + bo + 0 );
      unsigned char gg = pgm_read_byte_near( data + bo + 1 );
      unsigned char bb = pgm_read_byte_near( data + bo + 2 );
      sb.push( gamma(rr), gamma(gg), gamma(bb) );
    }
    sb.end();
}

void demorow() {
    sb.begin();
    for( int y=0; y<ROWS; y++ ){
      int k = y*255/10;
      sb.push(
        gamma((y==shutter_mode)?255:k),
        gamma(k),
        gamma(k) );
    }
    sb.end();
    
}

void cleardemorow() {
    sb.begin();
    for( int y=0; y<ROWS; y++ )
      sb.push(
        gamma((y==shutter_mode)?255:0),
        gamma(0),
        gamma(0) );
    sb.end();
}

void clearrow()
{
    sb.begin();
    for( int y=0; y<ROWS; y++ )
      sb.push( gamma(0),
        gamma(0), 
        gamma(0) );
    sb.end();
}




void setupshutter() {
  switch(shutter_mode % MODES) {
    case 0:
      debug("Setup shutter 0: 20 of 50");
      shutter_lighttime = 20;
      shutter_darktime = 50 - shutter_lighttime;
      break;
    case 1:
      debug("Setup shutter 1: 20 of 100");
      shutter_lighttime = 20;
      shutter_darktime = 100 - shutter_lighttime;
      break;
    case 2:
      debug("Setup shutter 2: 20 of 200");
      shutter_lighttime = 20;
      shutter_darktime = 200 - shutter_lighttime;
      break;
    case 3:
      debug("Setup shutter 3: 20 of 400");
      shutter_lighttime = 20;
      shutter_darktime = 400 - shutter_lighttime;
      break;
  }  
}

void demoshutter(){
  // flash three times
  sb.enable();
  sb.current(127,127,127);  
  for( int f=0; f<3; f++ ) {
    debug("Demo flash.");
    demorow();
    delay(shutter_lighttime);
    cleardemorow();
    delay(shutter_darktime);
  }
  sb.current(0,0,0);
  sb.disable();
  debug("Demo done.");
}

void debug(char *str) {
//  Serial.println(str);
}

void setup() {
  pinMode(B1_PIN,INPUT);
  pinMode(B2_PIN,INPUT);
//  Serial.begin(9600);
  sb.enable();
  sb.begin();
  sb.current(127,127,127);
  sb.end();
  pinMode(3,INPUT);
  srand(analogRead(0));
  shutter_mode = 0;
  setupshutter();
  demoshutter();
}


void loop() {
  b1.update();
  b2.update();
  if( b2.read() && b2.risingEdge() ) {
    debug("B2 Tap");
    if( state == STATE_IDLE ) {
      state = STATE_DEMOING;
      shutter_mode ++;
      if( shutter_mode >= MODES ) 
        shutter_mode = 0;
      setupshutter();
      demoshutter();
      state = STATE_IDLE;
    } else {
      debug( "Unable to demo, not idle." );
    }
  }
  
  if( b1.read() ) {
    // start animating (once)
    if( state == STATE_IDLE ) {
      debug("Start play");
      state = STATE_PLAY;
    }
  } else {
    // stop animating
    if( state == STATE_PLAY_LOOP_LIGHT || state == STATE_PLAY_LOOP_DARK) {
      debug("Playing, stop.");
      state = STATE_PLAY_ENDING; 
    } else if( state == STATE_PLAY_ENDED ) {
      debug("Ended, stop.");
      state = STATE_IDLE;
    }
  }
  
  if( state == STATE_PLAY ) {
    debug("Play.");
    sb.enable();
    sb.begin();
    sb.current(100,127,100);// 127,127,127);  
    sb.end();
    column = 0;
    fillrow();
    state = STATE_PLAY_LOOP_LIGHT;
    counter=shutter_lighttime/10;
  }
  
  if( state == STATE_PLAY_LOOP_LIGHT ) {
    if( counter == 0 ) {
      clearrow();
      counter=shutter_darktime/10;
      state = STATE_PLAY_LOOP_DARK;
    } else {
      counter --;
      delay(10);
    }
  }
  if( state == STATE_PLAY_LOOP_DARK ) {
    if( counter == 0 ) {
      if( column < COLUMNS ) {
        column ++;
        fillrow();
        counter=shutter_lighttime/10;
        state = STATE_PLAY_LOOP_LIGHT;
      } else {
        state = STATE_PLAY_ENDING;
      }
    } else {
      counter --;
      delay(10);
    }
  }
  
  if( state == STATE_PLAY_ENDING ) {
    debug("Ending.");
    image ++;
    sb.begin();
    sb.current(0,0,0);
    sb.end();
    sb.disable();
    state = STATE_PLAY_ENDED;
  }
   
}

