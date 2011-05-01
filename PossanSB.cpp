// Possan's ShiftBrite class
// 
// possansb.cpp

#include "WProgram.h"
#include "PossanSB.h"

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
  _SB_CommandPacket = (_SB_CommandPacket << 10) | (r & 1023);
  _SB_CommandPacket = (_SB_CommandPacket << 10) | (g & 1023);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket >> 24);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket >> 16);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket >> 8);
  shiftOut(_datapin, _clockpin, MSBFIRST, _SB_CommandPacket);
  delay(0);
}

void PossanSB::current( unsigned long r,unsigned long g,unsigned long b){
  _command( B01, r,g,b );
}

void PossanSB::push( unsigned long r,unsigned long g,unsigned long b){
  _command( B00, r,g,b );
}
