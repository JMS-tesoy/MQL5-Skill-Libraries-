//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                                  Copyright 2026, Trading Architect |
//|          Institutional-Grade Risk Control & Exposure Management   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Class to manage capital preservation and position sizing         |
//+------------------------------------------------------------------+
class CRiskManager
  {
private:
   double            m_max_drawdown;    // Emergency equity kill-switch %
   double            m_max_daily_loss;  // Daily halt limit %
   double            m_initial_balance;

public:
                     CRiskManager(double max_dd_pct, double max_daily_pct);
                    ~CRiskManager();

   // Core Methods
   double            CalculateLotSize(double risk_per_trade, int sl_points);
   bool              IsTradingHalted(); 
   bool              ValidateExposure(string symbol, double new_lots, double max_symbol_risk);
  };

//--- Constructor
CRiskManager::CRiskManager(double max_dd_pct, double max_daily_pct)
  {
   m_max_drawdown = max_dd_pct;
   m_max_daily_loss = max_daily_pct;
   m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
  }

CRiskManager::~CRiskManager() {}

//+------------------------------------------------------------------+
//| Calculates lot size based on fixed % risk and SL distance        |
//+------------------------------------------------------------------+
double CRiskManager::CalculateLotSize(double risk_per_trade, int sl_points)
  {
   if(sl_points <= 0) return 0.0;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   // Calculate dollar amount at risk
   double risk_amount = equity * (risk_per_trade / 100.0);
   
   // Formula: Lots = Risk_Amount / (SL_Points * Tick_Value)
   double raw_lots = risk_amount / (sl_points * tick_value);
   
   // Normalize to broker specifications
   double final_lots = MathFloor(raw_lots / lot_step) * lot_step;
   
   return MathMin(max_lot, MathMax(min_lot, final_lots));
  }

//+------------------------------------------------------------------+
//| Emergency Kill-Switch: Checks if drawdown exceeds safety limits  |
//+------------------------------------------------------------------+
bool CRiskManager::IsTradingHalted()
  {
   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // 1. Check Lifetime Drawdown
   double dd_pct = (1.0 - (current_equity / m_initial_balance)) * 100.0;
   if(dd_pct >= m_max_drawdown)
     {
      PrintFormat("CRITICAL: Max Drawdown Reached (%.2f%%). System Halted.", dd_pct);
      return true;
     }

   // 2. Check Daily Loss Limit (Balance vs Equity)
   double daily_loss = (1.0 - (current_equity / current_balance)) * 100.0;
   if(daily_loss >= m_max_daily_loss)
     {
      PrintFormat("WARNING: Daily Loss Limit Reached (%.2f%%). Suspending Activity.", daily_loss);
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Validates total exposure for a specific symbol                   |
//+------------------------------------------------------------------+
bool CRiskManager::ValidateExposure(string symbol, double new_lots, double max_symbol_lots)
  {
   double current_lots = 0;
   
   // Loop through open positions to check current volume
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == symbol)
            current_lots += PositionGetDouble(POSITION_VOLUME);
        }
     }
     
   return ((current_lots + new_lots) <= max_symbol_lots);
  }
