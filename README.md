# Smartwatch Haptic Workflow Backend

n8n workflows and a PostgreSQL database for the smartwatch haptic-feedback research system. The backend receives study and sensor requests, resolves participant mappings, stores readings and feedback decisions, and returns haptic commands.

## 🚀 Features

- **AI agent:** Routes researcher chat to mapping, scheduling, use-case, knowledge, participant-data, literature, and expert-panel workflows.
- **Haptic orchestration:** Handles heart rate, sun and moon azimuth, pollution, temperature, humidity, precipitation, and wind-speed use cases.
- **Participant-specific mappings:** Converts value ranges into pulse, intensity, duration, and interval settings while retaining assignment history.
- **Study operations:** Supports participants, use cases, mappings, schedules, monitoring state, sensor data, and alerts for the ResearcherSideApp.
- **Heart-rate processing:** Rejects implausible values, smooths readings, detects trends, and rate-limits feedback.
- **Use-case dictionary:** Stores required parameters, formats, API sources, and context for existing and new use cases.

## 🔄 Workflows

| Area | Workflow files |
| --- | --- |
| Public entrypoints | `Vibration Orchestrator.json`, `DB Manager.json`, `Chat Orchestrator.json` |
| Study actions | `Mapping Manager.json`, `Schedule Manager.json`, `Dictionary Manager.json`, `Use Case Builder.json` |
| AI support | `Knowledge Agent.json`, `Expert Panel Agent.json`, and the four `Agent Expert - *.json` workflows |


- `POST /usecase-routing` — routes live phone/watch data by use-case type.
- `POST /chat` — serves the ResearcherSideApp AI assistant.
- `DB Manager` exposes the dashboard endpoints, including users, mappings, schedules, monitoring, sensor data, and connection checks.

The use-case-specific endpoints in `Vibration Orchestrator.json` remain available for direct or legacy integrations.

## 🛠 Running Locally

1. Install PostgreSQL 18 and n8n. The current dump was produced by PostgreSQL 18.0.
2. Create and restore the project database:

   ```bash
   createdb -U postgres smartwatchsys_db
   psql -U postgres -d smartwatchsys_db -f DB-18072026.sql
   ```

3. Import all root-level `.json` workflow files into the same n8n instance.
4. Configure the credentials used by the imported nodes:
   - **Postgres:** point both imported Postgres credential references at `smartwatchsys_db`.
   - **OpenAI:** required by the current chat and agent workflows.
   - **SMTP:** required only for monitoring-stopped email alerts in `DB Manager`.
5. Re-select the target workflow in every **Execute Workflow** or workflow-tool node. Several exported references contain IDs that do not match the workflow IDs in this repository and may not survive a clean import.
6. Verify and activate `DB Manager`, `Vibration Orchestrator`, and `Chat Orchestrator`, then test with known non-live participant and device IDs.


## 🗄 Database Model

The current schema stores:

- Participants and devices in `User`, `Watch`, `AndroidPhone`, and their link tables.
- Use cases and dictionary/API metadata in `UseCase`, `UseCaseDictionary`, and `api_pool`.
- Haptic ranges and assignment history in `feedback_config_rules` and `User_UC_Mappings`.
- Readings and feedback decisions in `SensorData` and `Alert`.
- Schedules and assistant context in `user_schedules`, `agent_session`, and `v_agent_context`.

`resolve_fb_range(...)` selects a participant-specific active rule with a use-case fallback. `insert_sensor_data(...)` validates the active assignment, registers missing devices, and stores the reading and alert together.

## ➕ Adding a Use Case

Create the use case and its dictionary entry in ResearcherSideApp, then connect a copy of the template branch to the matching switch case in `Vibration Orchestrator`. Keep the name identical across the app, dictionary, database, and workflow, and test the branch before using it with a participant.

## ⚠️ Security and Data

- `Vibration Orchestrator.json` currently contains embedded third-party API tokens. These are publicly available API tokens. To use a private token move it into n8n credentials or environment-backed configuration before sharing or deploying the workflow.

- Keep database passwords, OpenAI keys, and SMTP credentials in n8n credentials, never in exported JSON or source control.

## 📚 Documentation

See the [Smartwatch Haptic Feedback Hub](https://app.notion.com/p/Smartwatch-Haptic-Feedback-Hub-6a46a244173d829c88ff81e199649cfe) for the system architecture, n8n developer guide, database operations, credential setup, use-case workflow, and application documentation.

## 🔗 Project Ecosystem

- [Researcher Dashboard](https://github.com/TTaliR/ResearcherSideApp-FULL) — configures participants, mappings, schedules, and study context.
- [Android Phone App](https://github.com/TTaliR/AndroidPhoneHapticFeedBackApp) — relays data and haptic commands between n8n and the watch.
- [Smartwatch Haptic App (Wear OS)](https://github.com/TTaliR/SmartWatchHapticFeedBackApp1) — collects participant readings and performs haptic feedback.
