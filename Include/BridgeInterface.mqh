//+------------------------------------------------------------------+
//|                                              BridgeInterface.mqh |
//|                                  Copyright 2024, Trading Architect |
//|                                       https://github.com/your-repo |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      "https://github.com/your-repo"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Class for high-performance signal propagation to external APIs   |
//+------------------------------------------------------------------+
class CBridgeInterface
  {
private:
   string            m_api_url;      // Destination endpoint
   string            m_auth_token;   // Bearer token for Node.js Auth
   int               m_timeout;      // Max wait time (sub-800ms target)
   int               m_last_error;

   // Helper to format JSON (avoiding heavy external libraries)
   string            FormatJson(string event, string msg);

public:
                     CBridgeInterface(string url, string token, int timeout_ms=800);
                    ~CBridgeInterface();

   // Core method to send data to your Full-Stack dashboard
   bool              BroadcastTrade(string symbol, string type, double price, double volume);
   bool              SendHeartbeat(); // Confirms system is alive
   int               GetLastError() { return m_last_error; }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBridgeInterface::CBridgeInterface(string url, string token, int timeout_ms)
  {
   m_api_url = url;
   m_auth_token = token;
   m_timeout = timeout_ms;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CBridgeInterface::~CBridgeInterface() {}

//+------------------------------------------------------------------+
//| Broadcasts trade events to the Node.js/PostgreSQL backend        |
//+------------------------------------------------------------------+
bool CBridgeInterface::BroadcastTrade(string symbol, string type, double price, double volume)
  {
   char data[];
   char result[];
   string result_headers;
   
   // Build the JSON payload
   string json = StringFormat("{\"symbol\":\"%s\", \"type\":\"%s\", \"price\":%f, \"volume\":%f, \"timestamp\":\"%lld\"}",
                              symbol, type, price, volume, TimeCurrent());
                              
   StringToCharArray(json, data, 0, WHOLE_ARRAY, CP_UTF8);
   ArrayResize(data, ArraySize(data)-1); // Remove null terminator

   string headers = "Content-Type: application/json\r\n";
   headers += "Authorization: Bearer " + m_auth_token + "\r\n";

   // Perform the WebRequest
   ResetLastError();
   int res = WebRequest("POST", m_api_url, headers, m_timeout, data, result, result_headers);

   if(res == -1)
     {
      m_last_error = _LastError;
      PrintFormat("Bridge Error: Failed to send signal. Error Code: %d", m_last_error);
      return false;
     }
   
   if(res != 200 && res != 201)
     {
      PrintFormat("Server Error: Received HTTP %d", res);
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Sends a simple heartbeat to monitor system uptime                |
//+------------------------------------------------------------------+
bool CBridgeInterface::SendHeartbeat()
  {
   char data[], result[];
   string headers = "Authorization: Bearer " + m_auth_token + "\r\n";
   string result_headers;
   
   int res = WebRequest("GET", m_api_url + "/heartbeat", headers, m_timeout, data, result, result_headers);
   return (res == 200);
  }
