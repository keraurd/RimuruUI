# RimuruUI - Automated WoW Installer Addon

**RimuruUI** is a lightweight, high-performance World of Warcraft addon designed to fully automate the user profile deployment and migration process. It streamlines the onboarding flow for players by eliminating manual interface configuration.

## 🚀 Key Features

* **Zero-Interaction Deployment:** Automatically imports complex layout, profile, and media databases into the game client upon first launch, bypassing manual import strings.
* **Addon Ecosystem Sync:** Native support for exporting, serializing, and dynamic side-checking configurations for major interface components (including BigWigs and base UI dependencies).
* **Robust Client-Side Checks:** Utilizes the `## RequiredDeps` structural directive combined with runtime Lua checks to safely query and validate active game dependencies before layout initialization.
* **Secure Serialization:** Embedded custom encoding logic to prevent cross-profile data corruption and maintain client integrity across updates.

## 🛠️ Technical Architecture & Stack

* **Language:** Lua
* **Framework:** World of Warcraft API (Targeting WoW Midnight architecture client structures)
* **Data Flow:** Structured state management using native `SavedVariables` database mechanics.
* **Libraries Considered/Integrated:** Advanced serialization approaches leveraging high-efficiency compression paradigms (similar to LibSerialize/LibDeflate logic patterns).

## 📂 Codebase Overview

* `RimuruUI.toc` - Manifest file managing metadata, structural `## RequiredDeps` bindings, and load priorities.
* `RimuruUI.lua` - Core engine handling event registries, environment lifecycle initialization, and database injection logic.
* `Core/` - UI component trees, graphic templates, and specific framework scripts.

## 💻 Environment & Tooling

Developed inside a localized workspace using advanced AI-driven code generation infrastructure (**Cline**) tailored to parse complex, multi-nested API endpoints and optimize execution paths under memory-constrained processing limits.
