//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//#include <framework4ex\draw.mqh>
#include <framework4ex\time.mqh>
Time time;
#include <indicators\trend.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MA_HighLow
  {
protected:
   double            ma_high, ma_low;
   CiMA              ma_i;
public:
   void              Create(datetime date);
   double            getHigh() { return ma_high; }
   double            getLow() { return ma_low; }
   double            getPriceHigh();
   double            getPriceLow();
   double getPriceMA();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MA_HighLow::Create(datetime date)
  {
   datetime time_x = time.OpenDaily(time.Yesterday(date)),
            time_y = time.CloseDaily(time.Yesterday(date));

   int shift_x = iBarShift(Symbol(),PERIOD_CURRENT,time_x);
   int shift_y = iBarShift(Symbol(),PERIOD_CURRENT,time_y);

   int shiftCount = shift_x-shift_y;

   int shift_h = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,shiftCount,shift_y);
   double high_h = iHigh(Symbol(),PERIOD_CURRENT,shift_h);


   int shift_l = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,shiftCount,shift_y);
   double low_l = iLow(Symbol(),PERIOD_CURRENT,shift_l-1);

   ma_i = new CiMA;
   ma_i.Create(Symbol(),PERIOD_CURRENT,33,0,MODE_EMA,PRICE_CLOSE);
   ma_i.Refresh(-1);

   ma_high = NormalizeDouble(high_h-ma_i.Main(shift_h), Digits());
   ma_low = NormalizeDouble(ma_i.Main(shift_l)-low_l, Digits());
  }
//+------------------------------------------------------------------+
double MA_HighLow::getPriceMA()
  {
   ma_i.Refresh(-1);
   return NormalizeDouble(ma_i.Main(0), Digits());
  }
  
double MA_HighLow::getPriceHigh()
  {
   ma_i.Refresh(-1);
   return NormalizeDouble(ma_i.Main(0)+ma_high, Digits());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MA_HighLow::getPriceLow()
  {
   ma_i.Refresh(-1);
   return NormalizeDouble(ma_i.Main(0)-ma_low, Digits());
  }
//+------------------------------------------------------------------+
class MA_Custom
  {
protected:
   CiMA              ma_i;
   double            price_h, price_l, price_ma;
public:
   void              Create(datetime date, double level);

   double            getPriceHigh() { return price_h; }
   double            getPriceLow() { return price_l; }
   double            getPriceMA() { return price_ma; }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MA_Custom::Create(datetime date, double level)
  {
   ma_i = new CiMA;
   ma_i.Create(Symbol(), PERIOD_CURRENT, 33, 0, MODE_EMA,PRICE_CLOSE);
   ma_i.Refresh(-1);

   price_h = NormalizeDouble(ma_i.Main(0)+level*Point(), Digits());
   price_l = NormalizeDouble(ma_i.Main(0)-level*Point(), Digits());
   price_ma = NormalizeDouble(ma_i.Main(0), Digits());
  }

//+------------------------------------------------------------------+
