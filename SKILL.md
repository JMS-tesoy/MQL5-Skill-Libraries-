---
name: mql5-execution-bridge
description: Use when designing or modifying an MQL5 Expert Advisor that exchanges signals or telemetry with a Node.js/PostgreSQL service using REST, JWT bearer authentication, heartbeats, or latency-sensitive execution.
---

# MQL5 Execution Bridge

Separate transport, signal production, execution, and local risk controls.

- Read `Include/BridgeInterface.mqh` for WebRequest, HTTP headers, JSON serialization, timeout handling, and heartbeats.
- Read `Include/ObserverAgent.mqh` when decoupling an indicator or model signal from the executor.
- Read `Include/RiskManager.mqh` for intended risk-control boundaries; independently validate tick-size/tick-value calculations for each broker and symbol.
- Read `Experts/ArchitectMainEA.mq5` only for integration shape.

Keep tokens and endpoints in EA inputs or secure configuration; never hard-code secrets. Treat failed, timed-out, or malformed HTTP responses as non-authoritative, make events idempotent, and run local risk validation before every order attempt. State the terminal URL-allowlist requirement before using `WebRequest`.

The sub-800 ms figure is a target, not a guarantee. Measure terminal, network, and backend latency separately. Compile and test in Strategy Tester, then use a demo account before any live deployment.
