//+------------------------------------------------------------------+
//|                                             ArchitectMainEA.mq5 |
//|                                  Copyright 2026, Trading Architect |
//|           Integrated Multi-Agent Trading & Bridge Framework      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://github.com/your-username"
#property version   "1.00"
#property strict

//--- Import Architectural Pillars
#include <Include/BridgeInterface.mqh>
#include <Include/ObserverAgent.mqh>
#include <Include/RiskManager.mqh>

//--- Input Parameters
input string   InpApiUrl      = "https://api.yourfintech.com"; // API Endpoint
input string   InpAuthToken   = "AUTH_TOKEN_HERE";             // Security Token
input double   InpMaxDD       = 5.0;                           // Max Drawdown %
input double   InpDailyLoss   = 2.0;                           // Daily Loss Limit %
input double   InpRiskPerTrade= 1.0;                           // Risk per Trade %

//--- Global Pointers to Architecture Classes
CBridgeInterface *bridge;
CAIAgent         *observer;
CRiskManager     *risk;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // 1. Initialize Bridge (Communication)
   bridge = new CBridgeInterface(InpApiUrl, InpAuthToken, 800);
   
   // 2. Initialize Observer (Analysis)
   observer = new CAIAgent(_Symbol, _Period);
   
   // 3. Initialize Risk Manager (Protection)
   risk = new CRiskManager(InpMaxDD, InpDailyLoss);

   Print("Architect Framework: System initialized successfully.");
   bridge.SendHeartbeat();
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Professional Memory Management
   delete bridge;
   delete observer;
   delete risk;
   Print("Architect Framework: Resources released cleanly.");
  }

//+------------------------------------------------------------------+
//| Expert tick function (The Event Loop)                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Step 1: Check Global Safety (Risk)
   if(risk.IsTradingHalted()) return;

   // Step 2: Update Market Analysis (Observer)
   observer.UpdateSignals();
   double signalStrength = observer.GetSignalPulse();

   // Step 3: Logic Execution
   if(MathAbs(signalStrength) > 0.5) // Threshold for entry
     {
      double lots = risk.CalculateLotSize(InpRiskPerTrade, 200); // 200 point SL
      string type = (signalStrength > 0) ? "BUY" : "SELL";
      
      // Step 4: External Synchronization (Bridge)
      // This sends the signal to Node.js/PostgreSQL BEFORE local execution for 
      // minimal latency in copy-trading environments.
      if(bridge.PushSignal(type, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), lots))
        {
         Print("Signal propagated successfully. Executing locally...");
         // Local execution logic would go here
        }
     }
     
   // Step 4: Update Web Dashboard periodically
   static datetime lastUpdate = 0;
   if(TimeCurrent() - lastUpdate > 60) // Every 60 seconds
     {
      bridge.UpdateDashboard(AccountInfoDouble(ACCOUNT_EQUITY), 
                             AccountInfoDouble(ACCOUNT_BALANCE), 
                             AccountInfoDouble(ACCOUNT_MARGIN));
      lastUpdate = TimeCurrent();
     }
  }
