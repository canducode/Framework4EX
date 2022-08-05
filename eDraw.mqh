//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void eBox(string nameBox, datetime time_x, double price_x, datetime time_y, double price_y)
  {
   ObjectCreate(0, nameBox, OBJ_RECTANGLE, 0, time_x, price_x, time_y, price_y);
   ObjectSetInteger(0,nameBox,OBJPROP_BACK, true);
   ObjectSetInteger(0,nameBox,OBJPROP_FILL, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void eLine(string nameLine, const datetime time_x, const double price_x=NULL, const datetime time_y=NULL, const double price_y=NULL)
  {
   if(price_x==NULL)
     {
      ObjectCreate(0, nameLine, OBJ_VLINE, 0, time_x, 0);
     }
   else
      if(time_y==NULL && price_y==NULL)
        {
         ObjectCreate(0, nameLine, OBJ_HLINE, 0, time_x, price_x);
        }
      else
        {
         ObjectCreate(0, nameLine, OBJ_TREND, 0, time_x, price_x, time_y, price_y);
        }

   ObjectSetInteger(0, nameLine, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, nameLine, OBJPROP_RAY_RIGHT, true);
  }
//+------------------------------------------------------------------+

void Clear() {
//ObjectDelete(0,"SRHH");
//ObjectDelete(0,"SRLH");
ObjectDelete(0,"HH");
ObjectDelete(0,"LL");
}