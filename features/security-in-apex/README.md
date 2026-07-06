# 🔐 Feature: Security in Apex

This module demonstrates how to properly enforce Object, Field, and Record-level security in Apex using `WITH SHARING`, `WITH USER_MODE`, and `Security.stripInaccessible()`.

---

## ⚠️ Prerequisites & Org Setup

To see how the security features actually work, you **must** configure your Developer Edition org before running the code. If you run this as a System Administrator, everything will succeed and defeat the purpose of the demo!

Please complete these steps before testing:

### 1. Configure Organization-Wide Defaults (OWD)

- Go to **Setup → Sharing Settings**.
- Set the Default Internal Access for **Account** to **Private**.

*(This ensures users cannot see Accounts they do not own unless explicitly shared.)*

### 2. Set Up the "Demo User"

- Create a new User (or use an existing one) with a standard Salesforce License. We will call this the **"Demo User"**.
- Assign them a Profile with **Minimum Access** (e.g., clone the **Minimum Access - Salesforce** profile).
- Ensure this Profile has **no** Object or Field permissions for the **Account** object.
- We have 2 permission set which gives All Account access **SEC_Demo_Full_PS**, and another permission set which gives only Account object and add default field access **SEC_Demo_Name_Only_PS**

*(We want to grant access strictly via Permission Sets in this module.)*

### 3. Prepare Test Data

- Ensure your org has a small number of Account records (around **10** is ideal to keep the demo queries clean and readable).
- As the System Administrator, manually share **at least 2** of those Account records with the **Demo User** (Grant **Read/Write** access).

### 4. Deploy the Code

Once the org is prepped, deploy this specific feature using the Salesforce CLI:

```bash
sf project deploy start --source-dir features/security-in-apex
```

### 5. Assign Permissions

After deployment, toggle the permission set assignment for the **Demo User** and see how the output changes in the LWC accordingly.

---

## 🧪 How to Test

1. Login as System Admin place the lwc "sec_BlocksTabs" on your App page, which is accessible to Demo User also.

2. Now Log in as the Demo User and interact with the LWC.