
// Possan's ShiftBrite class
// 
// possansb.h

class PossanSB {
private:
  int _datapin;
  int _latchpin;
  int _clockpin;
  int _enablepin;
  void _command( int cmd, unsigned long r,unsigned long g,unsigned long b);
public:
  PossanSB();
  PossanSB(int datapin, int latchpin, int clockpin, int enablepin);
  ~PossanSB();
  void enable();
  void disable();
  void begin();
  void end();
  void push(unsigned long r,unsigned long g,unsigned long b);
  void current(unsigned long r,unsigned long g,unsigned long b);
};

// 
// possansb.cpp

PossanSB::PossanSB() {
  PossanSB(10,11,12,13);
}

PossanSB::PossanSB(int datapin, int latchpin, int enablepin, int clockpin){
  _datapin = datapin;
  _latchpin = latchpin;
  _enablepin = enablepin;
  _clockpin = clockpin;

  pinMode(_datapin, OUTPUT);
  pinMode(_latchpin, OUTPUT);
  pinMode(_enablepin, OUTPUT);
  pinMode(_clockpin, OUTPUT);

}
PossanSB::~PossanSB(){
}
void PossanSB::enable(){
  digitalWrite(_enablepin,LOW);
}
void PossanSB::disable(){
  digitalWrite(_enablepin,HIGH);
}
void PossanSB::begin(){
  digitalWrite(_latchpin,LOW);
}
void PossanSB::end(){
  digitalWrite(_latchpin,HIGH);
}

void PossanSB::_command( int cmd, unsigned long r,unsigned long g,unsigned long b){
  unsigned long _SB_CommandPacket = cmd & B11;
  _SB_CommandPacket = (_SB_CommandPacket << 10) | (b & 1023);
  _SB_CommandPacket = (_SB_CommandPacket << 10) | (g & 1023);
  _SB_CommandPacket = (_SB_CommandPacket << 10) | (r & 1023);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket >> 24);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket >> 16);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket >> 8);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket);
}

void PossanSB::current( unsigned long r,unsigned long g,unsigned long b){
  _command( B01, r,g,b );
 }

void PossanSB::push( unsigned long r,unsigned long g,unsigned long b){
  _command( B00, r,g,b );
}






// 
// test1

int frame = 0;
int color1 = 0;
int color2 = 0;
int color3 = 0;
int last_b1 = 0;
PossanSB sb(10,11,12,13);

void setup() {
  sb.enable();
  sb.current(127,127,127);
  pinMode(3,INPUT);
  srand(analogRead(0));
}

void loop() {
  /*
  sb.disable();
  
  delay(100);
  sb.enable();
  for( int k2=0; k2<103; k2++ ){
  sb.begin();
    for( int k=0; k<10; k++ ) {
      if( k < 5 )
        sb.push(0,0,k2*10);
   else
        sb.push(1023-k2*10,0,0);
  
   //sb.push(1023,0,0);
    }
  sb.end();
  delay(10);
  }

  delay(1000);

  sb.begin();
for( int k=0; k<10; k++ ) {
    sb.push(0,1023,0);
  }
  sb.end();

  delay(1000);

  sb.begin();
for( int k=0; k<=10; k++ ) {
    sb.push(0,0,1023);
  }
  sb.end();

  delay(1000);

  sb.begin();
for( int k=0; k<=10; k++ ) {
    sb.push(1023,1023,1023);
  }
  sb.end();

  delay(1000);
*/

 // sb.disable();
  
//  delay(1000);
//  sb.enable();


  int b1 = digitalRead(3);
  if( b1 != last_b1 ){
    if( b1 ){
      color1 = 1023;
//      color2 = rand()%1024;
///      color3 = rand()%1024;   
    }
    else {
   //   color1 = 0;
   //   color2 = 0;
 //     color3 = 0;
    }
    last_b1 = b1;
  }

  sb.begin();
  for( int k=0; k<10; k++ ){
    int i2 = (k + frame) % 10;
  sb.push(
(i2 == 0)*color1,
(i2 == 1)*color1,
(i2 == 2)*color1
  );
  }
  sb.end();
  
  delay(100);
  
  frame ++;
  for(int tt=0;tt<50;tt++)
    if( color1 > 0 )
      color1 --;
  
}

