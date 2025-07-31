# 📊 TradingView Pinecone Alerts to Discord/Telegram

This project enables real-time TradingView and Deriv TradingView alerts (e.g., candlestick pattern detections, indicator triggers) to be sent to Discord or Telegram via bots. The system is designed for flexibility, supporting both platforms through webhooks and bot APIs.

---

## 🚀 Features

- ⏱ Real-time TradingView & Deriv alerts
- 🕯 Candlestick pattern alerts (Doji, Engulfing, Hammer, etc.)
- 📩 Discord bot integration (via Webhooks)
- 💬 Telegram bot integration (via Bot API)
- 🔁 Flexible alert routing logic
- ✅ Pine Script examples included
- 🔐 Secure API endpoints for alerts

---

## 📦 Architecture

```text
                +------------------+
                | Pine Script Alert|
                |  (TradingView)   |
                +--------+---------+
                         |
                     HTTP Alert
                         |
                         v
       +------------------------------+
       | Flask Alert Receiver (API)  |
       | Handles POST requests       |
       +----+------------------+-----+
            |                  |
    Discord Webhook     Telegram Bot API
        Handler               Handler
            |                  |
        Discord             Telegram
        Channel             Group/DM

