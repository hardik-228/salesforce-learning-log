# ☁️ Salesforce Learning Log & Sandbox

Welcome to my Salesforce Learning Log!

This repository is a collection of my hands-on experiments, proof-of-concepts (PoCs), and deep dives into specific Salesforce features. I created this primarily as a personal knowledge base to refer back to, but it is entirely open-source.

Anyone in the Salesforce Ohana is welcome to clone it, explore the code, and deploy these features to their own Developer Edition orgs to learn alongside me!

---

## 📂 Project Structure

This repository follows a feature-based directory structure to keep everything modular and conflict-free. Instead of throwing everything into one giant `force-app` folder, each learning topic or reusable component is isolated in its own folder under `features/`.

```text
salesforce-learning-log/
│
├── sfdx-project.json
├── README.md                <-- Global Documentation (You are here)
│
└── features/                <-- Isolated Learning Modules & Components
    │
    ├── security-in-apex/    <-- Example Feature
    │   ├── README.md        <-- Feature-specific instructions
    │   └── main/default/
    │
    ├── gen-confirmation-dialog/
    │   └── main/default/
    │
    └── gen-custom-lookup/
        └── main/default/
```

---

## 🚀 How to Use This Repository

Because every feature might require a slightly different setup (different data, specific Users, OWD settings, etc.), you should **not deploy this entire repository at once**. Instead, follow this process:

1. Browse the `features/` folder and find a topic or component you want to explore.
2. Open that specific folder's `README.md` file (if one exists) to check for any prerequisite org setup.
3. Deploy only that specific folder using the Salesforce CLI:

```bash
sf project deploy start --source-dir features/<feature-folder-name>
```

---

## 🏗️ Architecture & Naming Conventions

To ensure this repository remains clean and easy to maintain, I follow a simple "Soft Namespace" naming convention. We use specific prefixes to denote the intent of the component and prevent collisions with standard Salesforce components or installed packages.
