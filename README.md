# 🏛️ MQL5 Trading Systems Architecture Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MQL5](https://img.shields.io/badge/Language-MQL5-blue.svg)](https://www.mql5.com/)
[![Latency](https://img.shields.io/badge/Latency-Sub--800ms-green.svg)](#-bridge-architecture)

A professional-grade structural framework for MetaTrader 5, designed for high-performance automated trading and real-time copy-trading infrastructure. This repository provides a modular "Skill Library" that separates analysis, execution, and risk management into an institutional-grade architecture.



## 🛠️ Framework Components

This repository is organized into three core architectural pillars:

### 1. ⚡ Bridge Architecture (`BridgeInterface.mqh`)
Engineered for the modern fintech stack. This library handles the communication between the MT5 terminal and external backends (Node.js/PostgreSQL).
* **Target Latency:** Sub-800ms signal propagation.
* **REST Integration:** Standardized POST/PATCH methods for signal routing and dashboard synchronization.
* **Security:** JWT/Bearer token authentication ready.

### 2. 🤖 Multi-Agent Logic (`ObserverAgent.mqh`)
Moving beyond monolithic code. This library implements the **Observer Design Pattern** to decouple market analysis from trade execution.
* **Observer Agents:** Specialized classes for AI-driven pattern recognition and volume flow.
* **Signal Normalization:** Translates complex indicators into a normalized "Signal Pulse" (-1.0 to 1.0) for the executor.
* **Scalability:** Easily plug in new AI models or technical agents without modifying core execution logic.

### 3. 🛡️ Risk Management (`RiskManager.mqh`)
Institutional safety protocols designed to protect capital under high-volatility conditions.
* **Dynamic Sizing:** Automatic lot calculation based on account equity and broker-specific tick values.
* **Equity Kill-Switch:** Account-wide drawdown and daily loss monitoring.
* **Exposure Control:** Multi-symbol position validation to prevent over-leveraging.

---

## 📂 Repository Structure

```text
📂 MQL5-Architect-Framework
 ┣ 📂 Include
 ┃ ┣ 📜 BridgeInterface.mqh   # External API & Node.js Bridge
 ┃ ┣ 📜 ObserverAgent.mqh    # AI Analysis & Signal Generation
 ┃ ┗ 📜 RiskManager.mqh       # Capital Protection & Lot Sizing
 ┣ 📂 Experts
 ┃ ┗ 📜 ArchitectMainEA.mq5   # Implementation example
 ┣ 📜 LICENSE                 # MIT License
 ┗ 📜 README.md               # Documentation
