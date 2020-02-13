//+------------------------------------------------------------------+
//|                                                     SignalAC.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator 'Accelerator Oscillator'              |
//| Type=SignalAdvanced                                              |
//| Name=Accelerator Oscillator                                      |
//| ShortName=AC                                                     |
//| Class=CSignalAC                                                  |
//| Page=signal_ac                                                   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalAC.                                                 |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Accelerator Oscillator' indicator.                 |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalAC : public CExpertSignal
  {
protected:
   CiAC              m_ac;             // object-indicator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "first analyzed bar has required color"
   int               m_pattern_1;      // model 1 "there is a condition for entering the market"
   int               m_pattern_2;      // model 2 "condition for entering the market has just appeared"

public:
                     CSignalAC(void);
                    ~CSignalAC(void);
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)        { m_pattern_0=value;         }
   void              Pattern_1(int value)        { m_pattern_1=value;         }
   void              Pattern_2(int value)        { m_pattern_2=value;         }
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the indicator
   bool              InitAC(CIndicators *indicators);
   //--- methods of getting data
   double            AC(int ind)                 { return(m_ac.Main(ind));    }
   double            DiffAC(int ind)             { return(AC(ind)-AC(ind+1)); }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalAC::CSignalAC(void) : m_pattern_0(30), // 90 потом 30
                             m_pattern_1(50), // 50 / ставил 70 с Awesome
                             m_pattern_2(90) //30 потом 90 / ставил 50 с Awesome
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalAC::~CSignalAC(void)
  {
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalAC::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize AC indicator
   if(!InitAC(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize AC indicators.                                        |
//+------------------------------------------------------------------+
bool CSignalAC::InitAC(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_ac)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_ac.Create(m_symbol.Name(),m_period))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
  
  
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalAC::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   /*Print("AC(idx+3) long ", AC(idx+3));   
   Print("AC(idx+2) long ", AC(idx+2));   
   Print("AC(idx+1) long ", AC(idx+1));   
   Print("AC(idx) long ", AC(idx));*/
   
  if(MathAbs(AC(idx))>0){
     
//--- if the first analyzed bar is "red", don't "vote" for buying
   if((AC(idx)-AC(idx+1))<0.0){ //текущий - предыдущий
      return(result);
    }else{  
   //--- first analyzed bar is "green" (the indicator has no objections to buying)
         //Print("Индикатор Accelerator long: Первый анализируемый бар зеленый, не против покупки, сила ", m_pattern_0);
         result=m_pattern_0;
       };    
              
      //--- there is a condition for buying
      if((AC(idx)-AC(idx+1))>0.0 && (AC(idx+1)-AC(idx+2))>0.0 && AC(idx+1)>0 && AC(idx)>0){
         //Print("Индикатор Accelerator long: Значение индикатора выше 0 и оно растет на анализируемом баре и предыдущем ", m_pattern_1);
         result=m_pattern_1;
   //--- if the previously analyzed bar is "red", the condition for buying has just been fulfilled
      }; 
          
   //--- second analyzed bar is "green" (the condition for buying may be fulfilled)
   //--- if the second analyzed bar is less than zero, we need to analyzed the third bar
      if( (AC(idx)-AC(idx+1))>0.0 && (AC(idx+1)-AC(idx+2))>0.0 && (AC(idx+2)-AC(idx+3))>0.0 && AC(idx)<0){
        // Print("Индикатор Accelerator long: Значение индикатора ниже 0 и оно растет на анализируемом баре и двух предыдущих ", m_pattern_2);
         result=m_pattern_2;
      }; 
   
     if(result==m_pattern_0){
       Print("Индикатор Accelerator long: Первый анализируемый бар зеленый, не против покупки, сила ", m_pattern_0);
     };
     if(result==m_pattern_1){
       Print("Индикатор Accelerator long: Значение индикатора выше 0 и оно растет на анализируемом баре и предыдущем (2 зеленых)", m_pattern_1);
     };
     if(result==m_pattern_2){
       Print("Индикатор Accelerator long: Значение индикатора ниже 0 и оно растет на анализируемом баре и двух предыдущих (3 зеленых)", m_pattern_2);
     };
      
  };  
 
      
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalAC::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   
  /* Print("AC(idx+3) long ", AC(idx+3));   
   Print("AC(idx+2) long ", AC(idx+2));   
   Print("AC(idx+1) long ", AC(idx+1));   
   Print("AC(idx) long ", AC(idx));*/
   
   if(MathAbs(AC(idx))>0){
    
      //--- if the first analyzed bar is "green", don't "vote" for selling
      if((AC(idx)-AC(idx+1))>0.0){ //текущий - предыдущий
         return(result);
       }else{  
      //--- first analyzed bar is "red" (the indicator has no objections to selling)
         //Print("Индикатор Accelerator short: Первый анализируемый бар красный, не против продажи, сила ", -m_pattern_0);
         result=m_pattern_0;
       };    
              
      //--- second analyzed bar is "red" (the condition for selling may be fulfilled)
      if((AC(idx)-AC(idx+1))<0.0 && (AC(idx+1)-AC(idx+2))<0.0 && AC(idx+1)>0 && AC(idx)<0){
         //Print("Индикатор Accelerator short: Значение индикатора ниже 0 и оно падает на анализируемом баре и предыдущем, сила ", -m_pattern_1);
         result=m_pattern_1;
      }; 
         
   //--- second analyzed bar is "green" (the condition for buying may be fulfilled)
   //--- if the second analyzed bar is less than zero, we need to analyzed the third bar
      if( (AC(idx)-AC(idx+1))<0.0 && (AC(idx+1)-AC(idx+2))<0.0 && (AC(idx+2)-AC(idx+3))<0.0 && AC(idx)>0){
        // Print("Индикатор Accelerator short: Значение индикатора выше 0 и оно падает на анализируемом баре и двух предыдущих, сила ", -m_pattern_2);
         result=m_pattern_2;
      };
      
      if(result==m_pattern_0){
         Print("Индикатор Accelerator short: Первый анализируемый бар красный, не против продажи, сила ", -m_pattern_0);
      };
      if(result==m_pattern_1){
         Print("Индикатор Accelerator short: Значение индикатора ниже 0 и оно падает на анализируемом баре и предыдущем (2 красных), сила ", -m_pattern_1);
      };
      if(result==m_pattern_2){
         Print("Индикатор Accelerator short: Значение индикатора выше 0 и оно падает на анализируемом баре и двух предыдущих (3 красных), сила ", -m_pattern_2);
     };
      
         
   }else{ 
    Print("Индикатор Accelerator: Нет сигнала, Abs(значение) < 0.4");
  };  
  
//--- return the result
   return(result);
  }
 
