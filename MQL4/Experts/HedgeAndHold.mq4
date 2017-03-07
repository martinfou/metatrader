//+------------------------------------------------------------------+
//|                                                 HedgeAndHold.mq4 |
//|                                                   Copyright 2017 |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017"
#property version   "1.00"
#property description "Hedge and Hold"
#property strict

//************************************ Hedge and hold *******************************
//Hedge every hour
//Declaring external variables for user input
extern double Lot=0.01;
extern double TakeProfit=0.0005;
extern double MaxSpread=0.00005;
extern int Slippage=1;

//Declaring account variables
double BalanceCheck;
double Spread;
double StartingEquity;
double LastEquity;

//Declaring variables for the class functions
double UsePoint;
int UseSlippage;
bool CloseTicket;
double CalcPoint;
int CalcSlippage;
int CountOrdersBuy;
int CountOrdersSell;
datetime CurrentTimeStamp;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   UsePoint=PipPoint(Symbol());
   UseSlippage=GetSlippage(Symbol(),Slippage);
   BalanceCheck=AccountBalance();
   StartingEquity=AccountEquity();
   LastEquity=0;
   CountOrdersBuy=0;
   CountOrdersSell=0;
   CurrentTimeStamp=Time[0];
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   RefreshRates();
   Spread=Ask-Bid;
   CountOrdersBuy=0;
   CountOrdersSell=0;
   if(isAllowedToTrade())
     {
      if(CurrentTimeStamp!=Time[0])
        {
         CurrentTimeStamp=Time[0];
         buy();
         sell();
         for(int i=0; i<OrdersTotal();i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
              {
               if(OrderSymbol()==Symbol())
                 {
                  if(OrderType()==OP_BUY)
                    {
                     CountOrdersBuy=CountOrdersBuy+1;
                    }
                  if(OrderType()==OP_SELL)
                    {
                     CountOrdersSell=CountOrdersSell+1;
                    }
                 }
              }
           }
         if(CountOrdersBuy>CountOrdersSell)
           {
            sell();
           }
         if(CountOrdersBuy<CountOrdersSell)
           {
            buy();
           }
        }
     }

// Closing the day if in profit otherwise let the opened trades run until the day is in profit
   closeOrdersEndOfDay();
   startOfDay();
  }//End Void Tick
//+------------------------------------------------------------------+
//Pip Point function. It is used to calculate the correct decimal digits for any currency pair.
double PipPoint(string Currency)
  {
   double CalcDigits=MarketInfo(Currency,MODE_DIGITS);
   if(CalcDigits==2 || CalcDigits==3) CalcPoint=0.01;
   else if(CalcDigits==4 || CalcDigits==5) CalcPoint=0.0001;
   return(CalcPoint);
  }
//+------------------------------------------------------------------+
//Slippage function. It is used to calculate the correct Slippage in the appropriate Pips value for the any currency pair.
int GetSlippage(string Currency,int SlippagePips)
  {
   double CalcDigits=MarketInfo(Currency,MODE_DIGITS);
   if(CalcDigits==2 || CalcDigits==4) CalcSlippage=SlippagePips;
   else if(CalcDigits==3 || CalcDigits==5) CalcSlippage=SlippagePips*10;
   return(CalcSlippage);
  }
//+------------------------------------------------------------------+

void buy()
  {
   int ticket=OrderSend(Symbol(),OP_BUY,Lot,Ask,Slippage,0,Ask+TakeProfit,"Buy",911,0,Green);
   if(ticket<=0)
     {
      Print("Error trying to BUY #",GetLastError());
     }
  }
//+------------------------------------------------------------------+
void sell()
  {
   int ticket=OrderSend(Symbol(),OP_SELL,Lot,Bid,Slippage,0,Bid-TakeProfit,"Sell",911,0,Red);
   if(ticket<=0)
     {
      Print("Error trying to BUY #",GetLastError());
     }
  }
//+------------------------------------------------------------------+
void closeOrdersEndOfDay()
  {
   if(Hour()==23 && Minute()==50 && Seconds()<01)
     {
      //Close all open trades
      while(OrdersTotal()>0)
        {
         for(int k=0; k<OrdersTotal(); k++)
           {
            if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==true)
              {
               if(OrderSymbol()==Symbol())
                 {
                  if(OrderType()==OP_BUY)
                    {
                     RefreshRates();
                     CloseTicket=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrNONE);
                    }
                  if(OrderType()==OP_SELL)
                    {
                     RefreshRates();
                     CloseTicket=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrNONE);
                    }
                 }
              }
           }
        }
      if(OrdersTotal()==0)
        {
         SendNotification("All trades are closed... : "+Hour()+":"+Minute()+":"+Seconds());
        }
      else
        {
         SendNotification("ERROR*** CLOSING ALL TRADES... : "+Hour()+":"+Minute()+":"+Seconds());
        }
     }
  }
//+------------------------------------------------------------------+
void startOfDay()
  {
   if(Hour()==00 && Minute()==05 && Seconds()==01)
     {
      SendNotification("New day start... : "+Hour()+":"+Minute()+":"+Seconds());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isAllowedToTrade()
  {
   if(Spread>MaxSpread)
     {
      return false;
     }
   else{
      return true;
   }  

  }
//+------------------------------------------------------------------+
