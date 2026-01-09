//+------------------------------------------------------------------+
//|                                              BridgeInterface.mqh |
//|                                  Copyright 2026, Trading Architect |
//|     High-Performance MT5 to Node.js/PostgreSQL Communication     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property version   "1.50"
#property strict

//+------------------------------------------------------------------+
//| Class to manage external API communication and signal routing    |
//+------------------------------------------------------------------+
class CBridgeInterface
  {
private:
   string            m_api_base_url; // Endpoint for the Node.js API
   string            m_bearer_token; // JWT or API Key for security
   int               m_timeout;      // Targeted sub-800ms timeout
   int               m_last_http_res;

   // Internal helper for character conversion
   void              PrepareData(string json, char &data[]);

public:
                     CBridgeInterface(string url, string token, int timeout_ms=800);
                    ~CBridgeInterface();

   // Core Communication Methods
   bool              PushSignal(string type, string symbol, double price, double vol);
   bool              UpdateDashboard(double equity, double balance, double margin);
   int               GetLastResponseCode() { return m_last_http_res; }
  };

//--- Constructor
CBridgeInterface::CBridgeInterface(string url, string token, int timeout_ms)
   : m_api_base_url(url), m_bearer_token(token), m_timeout(timeout_ms)
  {
  }

//--- Destructor
CBridgeInterface::~CBridgeInterface() {}

//+------------------------------------------------------------------+
//| Broadcasts a trading signal to the external copy-trading backend |
//+------------------------------------------------------------------+
bool CBridgeInterface::PushSignal(string type, string symbol, double price, double vol)
  {
   char data[], result[];
   string result_headers;
   
   // Architect Note: Constructing JSON manually to avoid library dependencies
   string json = StringFormat("{\"event\":\"%s\",\"sym\":\"%s\",\"px\":%f,\"lot\":%f,\"ts\":%lld}",
                              type, symbol, price, vol, TimeCurrent());
   
   PrepareData(json, data);

   string headers = "Content-Type: application/json\r\n";
   headers += "Authorization: Bearer " + m_bearer_token + "\r\n";

   ResetLastError();
   m_last_http_res = WebRequest("POST", m_api_base_url + "/v1/signals", headers, m_timeout, data, result, result_headers);

   if(m_last_http_res == -1)
     {
      Print("Bridge Error: Network Timeout or URL not whitelisted. Code: ", GetLastError());
      return false;
     }

   return (m_last_http_res == 200 || m_last_http_res == 201);
  }

//+------------------------------------------------------------------+
//| Updates the Web Dashboard with real-time account metrics         |
//+------------------------------------------------------------------+
bool CBridgeInterface::UpdateDashboard(double equity, double balance, double margin)
  {
   char data[], result[];
   string result_headers;
   string json = StringFormat("{\"equity\":%f,\"balance\":%f,\"margin\":%f}", equity, balance, margin);
   
   PrepareData(json, data);
   string headers = "Authorization: Bearer " + m_bearer_token + "\r\n";

   m_last_http_res = WebRequest("PATCH", m_api_base_url + "/v1/account", headers, m_timeout, data, result, result_headers);
   return (m_last_http_res == 200);
  }

//+------------------------------------------------------------------+
//| Helper: String to Byte Array for WebRequest                      |
//+------------------------------------------------------------------+
void CBridgeInterface::PrepareData(string json, char &data[])
  {
   ArrayResize(data, StringToCharArray(json, data, 0, WHOLE_ARRAY, CP_UTF8) - 1);
  }
