# 🔐 Signing & Provisioning Troubleshooting

This comprehensive guide covers how to fix "MAC verification failed", "No signing certificate found", and "Provisioning profile requires..." errors.

## ⚠️ Phase 1: Certificate Import Errors

### Problem: `MAC verification failed`
**Fix:** Re-export your P12 using `openssl -legacy` (AES-256 is not supported by macOS Keychain yet).

### Problem: "No signing certificate... with a private key was found"
**Fix:** Your P12 exported ONLY the certificate, not the private key.
1. Open Keychain Access.
2. Expand the certificate arrow.
3. Select BOTH the certificate and the key.
4. Export as `.p12` (use legacy encryption if on Linux/OpenSSL 3+).

---

## ⚠️ Phase 2: Provisioning Profile Mismatches

### Problem: "requires a provisioning profile with... features"

This means your Local Profile doesn't match the Project Entitlements. **You must ensure your App ID on Apple Developer Portal has these exact capabilities enabled.**

### ✅ Main App ID (`io.ketal.app`) Requirements:

Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) -> Click your Main App ID.

Ensure these Capabilities are **ENABLED**:
- [ ] **App Groups** (Configure with `group.io.ketal`)
- [ ] **Associated Domains**
- [ ] **Push Notifications**
- [ ] **Communication Notifications** (Critical for messaging apps)
- [ ] **Data Protection** (Complete Protection)
- [ ] **SiriKit** (Optional, but often enabled)

### ✅ NSE App ID (`io.ketal.app.nse`) Requirements:

Go to Identifiers -> Click NSE App ID.

Ensure these Capabilities are **ENABLED**:
- [ ] **App Groups** (Configure with `group.io.ketal`)
- [ ] **Push Notifications** (Usually required for extension too)

**Note:** We disabled `Notification Service Extension Filtering` in the code to simplify requirements. You don't need this capability unless you explicitly use it.

---

## ⚠️ Phase 3: Update Secrets

After fixing App IDs, you must:
1. **Regenerate Provisioning Profiles** (Edit -> Save).
2. Download them (`main.mobileprovision` and `nse.mobileprovision`).
3. **Base64 Encode** them:
   ```bash
   base64 -w 0 main.mobileprovision
   base64 -w 0 nse.mobileprovision
   ```
4. Update GitHub Secrets:
   - `PROVISIONING_PROFILE_BASE64`
   - `NSE_PROVISIONING_PROFILE_BASE64`

### 🛑 CRITICAL: Team ID Check

If you changed your Team ID to `G5AQ6D4ZY8`, ensure:
1. Your Certificate belongs to Team `G5AQ6D4ZY8`.
2. Your App IDs are created under Team `G5AQ6D4ZY8`.
3. Your Profiles are generated for Team `G5AQ6D4ZY8` using *that* Certificate.

---

## 🛠️ How to Recreate Provisioning Profiles (Manual Method)

Since you are on Ubuntu, follow these steps to generate the profiles from scratch using the Apple Developer Portal.

### Step 1: Verify Identifiers (App IDs)
1. Log in to [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list).
2. Go to **Identifiers**.
3. Ensure you have two IDs created (or create them):
   - **Name:** Ketal App, **Bundle ID:** `io.ketal.app`
     - Enable: *App Groups, Associated Domains, Push Notifications, Communication Notifications*.
   - **Name:** Ketal NSE, **Bundle ID:** `io.ketal.app.nse`
     - Enable: *App Groups, Push Notifications*.

### Step 2: Generate Profiles
**Note:** You MUST use the Certificate you recently exported/fixed.

1. Go to **Profiles** -> click **(+)**.
2. Select **App Store** (under Distribution).
3. **For Main App:**
   - Select App ID: `io.ketal.app`.
   - Select the **Correct Certificate** (Check the expiration date to match your P12).
   - Name it: `Ketal App Store Profile`.
   - Download as `main.mobileprovision`.
4. **For NSE:**
   - Select App ID: `io.ketal.app.nse`.
   - Select the **SAME Certificate**.
   - Name it: `Ketal NSE App Store Profile`.
   - Download as `nse.mobileprovision`.

### Step 3: Base64 Encode on Ubuntu
Run these commands in your terminal:

```bash
# Main Profile
base64 -w 0 main.mobileprovision > main_base64.txt

# NSE Profile
base64 -w 0 nse.mobileprovision > nse_base64.txt
```

### Step 4: Update GitHub Secrets
1. Open `main_base64.txt`, copy content -> Update `PROVISIONING_PROFILE_BASE64`.
2. Open `nse_base64.txt`, copy content -> Update `NSE_PROVISIONING_PROFILE_BASE64`.

