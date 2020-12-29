//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CTrade ctrade;
CPositionInfo iposisi;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Buy(const double volume, bool pip=false, double stoploss=0.0, double takeprofit=0.0, const string symbol=NULL, const string comment="")
  {
   ctrade.Buy(volume, symbol, NULL, (pip)?NULL:stoploss, (pip)?NULL:takeprofit, comment);

   if(pip)
     {
      takeprofit = ctrade.ResultPrice()+takeprofit*Point();
      stoploss = ctrade.ResultPrice()-stoploss*Point();
      ctrade.PositionModify(ctrade.ResultOrder(),stoploss,takeprofit);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sell(const double volume, bool pip=false, double stoploss=0.0, double takeprofit=0.0, const string symbol=NULL, const string comment="")
  {
   ctrade.Sell(volume, symbol, NULL, (pip)?NULL:stoploss, (pip)?NULL:takeprofit, comment);

   if(pip)
     {
      takeprofit = ctrade.ResultPrice()-takeprofit*Point();
      stoploss = ctrade.ResultPrice()+stoploss*Point();
      ctrade.PositionModify(ctrade.ResultOrder(),stoploss,takeprofit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Close(const ulong ticket)
  {
   ctrade.PositionClose(ticket);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   ctrade.PositionClose(Symbol());
  }
//+------------------------------------------------------------------+
int CountOP()
  {
   return iposisi.Select(Symbol());
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PriceRange(double price)
  {
   MqlTick mqt;
   SymbolInfoTick(Symbol(), mqt);

   double price_now = mqt.bid;

   return (price_now<(price+(20*Point())) && price_now>(price-(20*Point())))?true:false;
  }