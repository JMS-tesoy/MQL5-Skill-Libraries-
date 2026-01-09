// BridgeInterface.mqh
// Purpose: Standardizing data flow between MT5 and external Backends

class CBridgeInterface {
private:
    string         m_server_url;
    int            m_timeout;

public:
    CBridgeInterface(string url, int timeout=800) : m_server_url(url), m_timeout(timeout) {}
    
    // Sends trade signals to Node.js/Redis
    bool BroadcastSignal(const string json_payload) {
        char data[];
        char result[];
        string headers;
        ArrayResize(data, StringToCharArray(json_payload, data, 0, WHOLE_ARRAY, CP_UTF8) - 1);
        
        // Using WebRequest for sub-800ms propagation
        int res = WebRequest("POST", m_server_url, headers, m_timeout, data, result, headers);
        
        if(res == -1) {
            Print("Network Error: ", GetLastError());
            return false;
        }
        return (res == 200);
    }
};
