//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Time
  {
public:
   datetime          OpenDaily(datetime date);
   datetime          CloseDaily(datetime date);
   datetime          Yesterday(datetime date, const int days_ago=1);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time::OpenDaily(datetime date)
  {
   MqlDateTime time_mql, time_i;
   TimeToStruct(date, time_mql);
   time_mql.hour = 00;
   time_mql.min = 00;
   time_mql.sec = 00;

   int date_i = time_mql.day;

   int shift_i = iBarShift(Symbol(), PERIOD_CURRENT, StructToTime(time_mql));
   datetime time_shift = iTime(Symbol(), PERIOD_CURRENT, shift_i);
   TimeToStruct(time_shift, time_i);

   if(time_i.day != date_i)
     {
      shift_i--;
      time_shift = iTime(Symbol(), PERIOD_CURRENT, shift_i);
     }

   return time_shift;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time::CloseDaily(datetime date)
  {
   MqlDateTime time_mql, time_i;
   TimeToStruct(date, time_mql);
   time_mql.hour = 23;
   time_mql.min = 59;
   time_mql.sec = 00;

   int date_i = time_mql.day;

   int shift_i = iBarShift(Symbol(), PERIOD_CURRENT, StructToTime(time_mql));
   datetime time_shift = iTime(Symbol(), PERIOD_CURRENT, shift_i);

   return time_shift;
  }
//+------------------------------------------------------------------+
datetime Time::Yesterday(datetime date, const int days_ago=1)
  {
   int oneDay = 60*60*24,
       forDay = 0;
   datetime time_i = date ;

   MqlDateTime time_ii;
   do
     {
      TimeToStruct(time_i, time_ii);
      time_i = time_i - oneDay;
      if(!(time_ii.day_of_week == 0 || time_ii.day_of_week == 1))
        {
         forDay++;
        }
     }
   while(forDay<days_ago);

   return time_i;
  }
//+------------------------------------------------------------------+
