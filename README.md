# Smartwatch Haptic Backend

This repository contains the n8n automation workflows and the PostgreSQL schema required for rule-based mapping.

## 🚀 Features
- **API Enrichment:** Calls various APIs to convert coordinates into environmental data.
- **Proportional Mapping:** Logic to map sensor values (0-360 azimuth or 40-200 HR) into linear haptic intensity/duration.
- **Data Smoothing:** Implements a moving-average window to filter heart rate outliers.
- **Persistence:** High-performance logging via the `insert_sensor_data` SQL function.

## 🛠 Setup
1. **Database:** Run `DB_NEW.sql` in your PostgreSQL instance.
2. **n8n:** Import `Smartwatch Haptic Backend.json`.
3. **Rules:** Use the `feedback_config_rules` table to define your active haptic ranges.

## 🔗 Project Ecosystem
- [Researcher Dashboard](https://github.com/TTaliR/ResearcherSideApp-FULL) - The GUI for managing the rules stored in this DB.
- [Android Phone App](https://github.com/TTaliR/AndroidPhoneHapticFeedBackApp) - The client that consumes these endpoints.
- [Smartwatch Haptic App (Wear OS)](https://github.com/TTaliR/SmartWatchHapticFeedBackApp1) - Wear OS application serves as the primary edge node for the system.
