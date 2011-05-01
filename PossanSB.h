
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
