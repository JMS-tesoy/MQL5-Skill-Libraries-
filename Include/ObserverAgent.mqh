//+------------------------------------------------------------------+
//|                                                ObserverAgent.mqh |
//|                                  Copyright 2026, Trading Architect |
//|        Modular Analysis Framework for Multi-Agent Trading Systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property version   "1.00"
#property strict

//--- Interface for all Analysis Agents
interface IMarketObserver
  {
   void      UpdateSignals();    // Calculate new data
   double    GetSignalPulse();   // Return normalized strength (-1.0 to 1.0)
   string    GetAgentName();     // Identification for logging
  };

//+------------------------------------------------------------------+
//| AI-Agent: Pattern Recognition & Volume Flow                      |
//+------------------------------------------------------------------+
class CAIAgent : public IMarketObserver
  {
private:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_tf;
   int               m_handle_rsi;
   int               m_handle_mfi;
   double            m_signal_strength;

public:
                     CAIAgent(string symbol, ENUM_TIMEFRAMES tf);
                    ~CAIAgent();
   
   virtual void      UpdateSignals() override;
   virtual double    GetSignalPulse() override { return m_signal_strength; }
   virtual string    GetAgentName() override   { return "AI_Volume_Observer"; }
  };

//--- Constructor: Initializes indicators/buffers
CAIAgent::CAIAgent(string symbol, ENUM_TIMEFRAMES tf) 
   : m_symbol(symbol), m_tf(tf), m_signal_strength(0.0)
  {
   m_handle_rsi = iRSI(m_symbol, m_tf, 14, PRICE_CLOSE);
   m_handle_mfi = iMFI(m_symbol, m_tf, 14, VOLUME_TICK);
  }

//--- Destructor
CAIAgent::~CAIAgent()
  {
   IndicatorRelease(m_handle_rsi);
   IndicatorRelease(m_handle_mfi);
  }

//+------------------------------------------------------------------+
//| Logic: Multi-factor Signal Generation                            |
//+------------------------------------------------------------------+
void CAIAgent::UpdateSignals()
  {
   double rsi[], mfi[];
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(mfi, true);

   if(CopyBuffer(m_handle_rsi, 0, 0, 2, rsi) < 2 || 
      CopyBuffer(m_handle_mfi, 0, 0, 2, mfi) < 2) return;

   // Logic: Combining Momentum (RSI) with Money Flow (MFI)
   // This mimics the 'Observer' agent gathering intelligence
   double momentum = (rsi[0] - 50.0) / 50.0; // Normalized -1 to 1
   double flow     = (mfi[0] - 50.0) / 50.0; // Normalized -1 to 1

   m_signal_strength = (momentum * 0.4) + (flow * 0.6);
   
   // Apply thresholding for cleaner signals
   if(MathAbs(m_signal_strength) < 0.2) m_signal_strength = 0;
  }
