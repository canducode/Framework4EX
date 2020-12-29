//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <framework4ex\draw.mqh>
#include <framework4ex\time.mqh>
Time time;
#include <indicators\trend.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OpenPriceDaily
  {
protected:
   datetime          time_i;
   double            longest;
   int               shift_i;
   double            price_h, price_l;

public:
   void              Create(datetime date);

   double            getLongest() { return longest; }
   int               getShift() { return shift_i; }
   datetime          getTime() { return iTime(Symbol(), PERIOD_CURRENT, shift_i); }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPriceDaily::Create(datetime date)
  {
   datetime time_x = time.OpenDaily(time.Yesterday(date)),
            time_y = time.CloseDaily(time.Yesterday(date));

   int shift_x = iBarShift(Symbol(),PERIOD_CURRENT,time_x),
       shift_y = iBarShift(Symbol(),PERIOD_CURRENT,time_y);

   longest = 0.0;
   for(int i = shift_x; i >= shift_y; i--)
     {
      double longCandle = iHigh(Symbol(),PERIOD_CURRENT,i)-iLow(Symbol(),PERIOD_CURRENT,i);
      if(longest < longCandle)
        {
         longest = (longCandle<0)?longCandle*-1:longCandle;
         shift_i = i;
        }
     }

   time_i = iTime(Symbol(),PERIOD_CURRENT, shift_i);
   price_h = iHigh(Symbol(), PERIOD_CURRENT, shift_i);
   price_l = iLow(Symbol(), PERIOD_CURRENT, shift_i);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SilentCandle: public OpenPriceDaily
  {
public:
   double            getPriceHigh() { return price_h; }
   double            getPriceLow() { return price_l; }

   void              Paint()
     {
      Line("SCH", time_i, price_h);
      Line("SCL", time_i, price_l);
     }
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CrosspainMA33
  {
protected:
   datetime          time_x;
   double            price_x;

public:
   void              Create(datetime date);

   double            getPrice() { return price_x; }
   void              Paint() { Line("CPMA",time_x, price_x); }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CrosspainMA33::Create(datetime date)
  {
   time_x = time.OpenDaily(date);

   int shift_x = iBarShift(Symbol(),PERIOD_CURRENT,time_x);
   CiMA i_ma = new CiMA;
   i_ma.Create(Symbol(),PERIOD_CURRENT,33,0,MODE_EMA,PRICE_CLOSE);
   i_ma.Refresh(-1);

   price_x = NormalizeDouble(i_ma.Main(shift_x), Digits());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ShadowShooter
  {
protected:
   datetime          time_x;
   datetime          time_y;
   double            high_x, low_x;
   bool              HT, LT, HS, LS;
   datetime          HT_time, LT_time, HS_time, LS_time;
   double            HT_price, LT_price, HS_price, LS_price;

public:
   void              Create(datetime date);
   void              Paint();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShadowShooter::Create(datetime date)
  {
   time_x = time.OpenDaily(date);
   time_y = time.CloseDaily(date);

   int shift_x = iBarShift(Symbol(),PERIOD_CURRENT,time_x);
   int shift_y = iBarShift(Symbol(),PERIOD_CURRENT,time_y);

   high_x = NormalizeDouble(iHigh(Symbol(), PERIOD_CURRENT, shift_x), Digits());
   low_x = NormalizeDouble(iLow(Symbol(), PERIOD_CURRENT, shift_x), Digits());

   HT = false;
   LT = false;
   HS = false;
   LS = false;
   for(int i=shift_x; i>=shift_y; i--)
     {
      double high_i = NormalizeDouble(iHigh(Symbol(), PERIOD_CURRENT, i), Digits());
      double low_i = NormalizeDouble(iLow(Symbol(), PERIOD_CURRENT, i), Digits());

      datetime time_i = iTime(Symbol(),PERIOD_CURRENT,i);
      int shift_i = iBarShift(Symbol(),PERIOD_CURRENT,time_i);

      if(high_i>high_x && !HT)
        {
         HT_time = time_i;
         HT_price = high_i;
         HT = true;
        }

      if(low_i<low_x && !LT)
        {
         LT_time = time_i;
         LT_price = low_i;
         LT = true;
        }

      if(low_i>high_x && !HS)
        {
         for(int ii=shift_x; ii>=shift_i; ii--)
           {
            double high_ii = NormalizeDouble(iHigh(Symbol(),PERIOD_CURRENT,ii), Digits());
            if(high_ii>high_i)
              {
               break;
              }
            else
               if(ii==shift_i)
                 {
                  HS_time = time_i;
                  HS_price = high_i;
                  HS = true;
                 }
           }
        }

      if(high_i<low_x && !LS)
        {
         for(int ii=shift_x; ii>=shift_i; ii--)
           {
            double low_ii = NormalizeDouble(iLow(Symbol(),PERIOD_CURRENT,ii), Digits());
            if(low_ii<low_i)
              {
               break;
              }
            else
               if(ii==shift_i)
                 {
                  LS_time = time_i;
                  LS_price = low_i;
                  LS = true;
                 }
           }
        }

      if(HT && LT && HS && LS)
         break;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShadowShooter::Paint()
  {
   Box("SS",time_x,high_x,time_y,low_x);
   if(HT)
     {
      Line("High Tembus", time_x, high_x, HT_time, HT_price);
     }

   if(LT)
     {
      Line("Low Tembus", time_x, low_x, LT_time, LT_price);
     }

   if(HS)
     {

      Line("High Sniper", time_x, high_x, HS_time, HS_price);
     }
   if(LS)
     {

      Line("Low Sniper", time_x, low_x, LS_time, LS_price);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
class ShadowRepeater
  {
protected:
   datetime          time_x, time_y;
   datetime          time_h, time_l;
   double            high_h, low_h, high_l, low_l;

public:
   void              Create(datetime date);
   void              Paint();

   double            getPriceHH() { return high_h; }
   double            getPriceHL() { return low_h; }
   double            getPriceLH() { return low_h; }
   double            getPriceLL() { return low_l; }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShadowRepeater::Create(datetime date)
  {
   time_x = time.OpenDaily(time.Yesterday(date));
   time_y = time.CloseDaily(time.Yesterday(date));

   int shift_x = iBarShift(Symbol(),PERIOD_CURRENT,time_x);
   int shift_y = iBarShift(Symbol(),PERIOD_CURRENT,time_y);

   int shiftCount = shift_x-shift_y;

   int highest = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,shiftCount,shift_y);
   time_h = iTime(Symbol(),PERIOD_CURRENT,highest-1);
   high_h = iHigh(Symbol(),PERIOD_CURRENT,highest-1);
   low_h = iLow(Symbol(),PERIOD_CURRENT,highest-1);

   int lowest = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,shiftCount,shift_y);
   time_l = iTime(Symbol(),PERIOD_CURRENT,lowest-1);
   high_l = iHigh(Symbol(),PERIOD_CURRENT,lowest-1);
   low_l = iLow(Symbol(),PERIOD_CURRENT,lowest-1);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShadowRepeater::Paint()
  {
   Line("SRHH", time_h, high_h);
   Line("SRLH", time_h, low_h);
   Box("SR-HBOX", time_h, high_h, time_y, low_h);

   Line("SRHL", time_l, high_l);
   Line("SRLL", time_l, low_l);
   Box("SR-LBOX", time_l, high_l, time_y, low_l);
  }
//+------------------------------------------------------------------+
class SilenHarmony
  {
protected:
   datetime          time_h, time_l;
   double            price_h, price_l;

public:
   void              Create(datetime date);
   double            getPriceHigh() { return price_h; }
   double            getPriceLow() { return price_l; }
   void              Paint()
     {
      Line("HH", time_h, price_h);
      Line("LL", time_l, price_l);
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SilenHarmony::Create(datetime date)
  {
   datetime time_x = time.OpenDaily(time.Yesterday(date)),
            time_y = time.CloseDaily(time.Yesterday(date));

   int shift_x = iBarShift(Symbol(),PERIOD_CURRENT,time_x);
   int shift_y = iBarShift(Symbol(),PERIOD_CURRENT,time_y);
   int shiftCount = shift_x-shift_y;

   CiMA ma33 = new CiMA;
   ma33.Create(Symbol(),PERIOD_CURRENT,33,0,MODE_EMA,PRICE_CLOSE);
   ma33.Refresh(-1);

   int highest = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,shiftCount,shift_y);
   time_h = iTime(Symbol(),PERIOD_CURRENT,highest);
   price_h = NormalizeDouble(ma33.Main(highest), Digits());

   int lowest = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,shiftCount,shift_y);
   time_l = iTime(Symbol(),PERIOD_CURRENT,lowest);
   price_l = NormalizeDouble(ma33.Main(lowest),Digits());

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandlePioneer
  {
protected:
   datetime          time_i;

public:
   void              Create(datetime date);

   void              Paint()
     {
      Line("CP", time_i);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlePioneer::Create(datetime date)
  {
   datetime time_x = time.OpenDaily(date),
            time_y = time.CloseDaily(date);

   int shift_x = iBarShift(Symbol(),PERIOD_CURRENT,time_x);
   int shift_y = iBarShift(Symbol(),PERIOD_CURRENT,time_y);

   SilentCandle sc = new SilentCandle;

   sc.Create(time.Yesterday(time_x));
   double longestSC = sc.getLongest();

   int shift_i = 0;
   double longest = 0.0;
   for(int i = shift_x; i >= shift_y; i--)
     {
      double longCandle = iHigh(Symbol(),PERIOD_CURRENT,i)-iLow(Symbol(),PERIOD_CURRENT,i);
      if(longCandle>longestSC)
        {
         longest = (longCandle<0)?longCandle*-1:longCandle;
         shift_i = i;
         time_i = iTime(Symbol(),PERIOD_CURRENT,shift_i);
         break;
        }
     }
  }
//+------------------------------------------------------------------+