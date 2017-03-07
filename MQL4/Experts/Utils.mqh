//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                          Copyright 2017, Compica |
//|                                          https://www.compica.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Compica"
#property link      "https://www.compica.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|   Utility Class for EA plumbing                                  |
//+------------------------------------------------------------------+
class Utils
  {
private:
   bool              isTradingAllowed;
   double            startOfDayAccountBalance;
public:
                     Utils();
                    ~Utils();

   void isTimeToTrade()
     {
      startOfDay();
      endOfDay();
     }

   //+------------------------------------------------------------------+
   //|   Detetect Start Of Day and Save Account Balance                 |
   //+------------------------------------------------------------------+
   void startOfDay()
     {
      if(Hour()==0  && Minute()==10 && isTradingAllowed == false)
        {
         this.isTradingAllowed=true;
         setStartOfDayAccountBalance();
         Print("=== START OF DAY === Account Balance ==>  ",this.startOfDayAccountBalance);
        }
     }
   //+------------------------------------------------------------------+     
   //|   Method to detect the end of days and close all positions.      |
   //+------------------------------------------------------------------+
   void endOfDay()
     {
      if(Hour()==23 && Minute()==45 && isTradingAllowed == true)
        {
         closeAllOrders();
         this.isTradingAllowed=false;
         double profitOrLoss=startOfDayAccountBalance-AccountBalance();
         Print("===  END OF DAY   === Profit / Loss  ==> "+(string)profitOrLoss);
        }
     }

   //+------------------------------------------------------------------+
   //| Sets the Account Balance at the start of the day.                |
   //+------------------------------------------------------------------+
   void setStartOfDayAccountBalance()
     {
      this.startOfDayAccountBalance=AccountBalance();
      Print("=== START OF DAY === Account Balance ==>  ",this.startOfDayAccountBalance);
     }
     
     bool isAllowedToTrade(){
     return this.isTradingAllowed;
     }

   //+------------------------------------------------------------------+
   //| Detect if a new bar is created.                                  |
   //+------------------------------------------------------------------+
   bool isNewBar()
     {
      static datetime lastbar;
      datetime curbar=Time[0];
      if(lastbar!=curbar)
        {
         lastbar=curbar;
         Print("=== NEW BAR ===");
         return (true);
        }
      else
        {
         return(false);
        }
     }

   void closeAllOrders()
     {
      if(OrdersTotal()>0)
        {
         for(int c=0; c<OrdersTotal(); c++)
           {
            if(OrderSelect(c,SELECT_BY_POS)==true)
              {

               if(OrderType()==OP_BUY)
                 {
                  if(OrderClose(OrderTicket(),OrderLots(),Bid,3,Green)!=true){
                     Print("Error trying to close Order #",GetLastError());
                  }
                 }
               else if(OrderType()==OP_SELL)
                 {
                  if(OrderClose(OrderTicket(),OrderLots(),Ask,3,Red)!=true){
                   Print("Error trying to close Order #",GetLastError());
                  }
                 }
              }
           }
        }
     }

  };
//+------------------------------------------------------------------+
//| Constructor setting attributes on class creations                |
//+------------------------------------------------------------------+
Utils::Utils()
  {
   isTradingAllowed=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Utils::~Utils()
  {
  }
//+------------------------------------------------------------------+
