# 🚨 CRITICAL FIX: App Group Configuration

Your build failed because your Provisioning Profiles **do not contain the App Group `group.io.ketal`**.

Even if "App Groups" capability is Enabled, you must **select the specific group**.

## 🛠️ Step-by-Step Fix

### 1. Create the App Group (If missing)
1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list/applicationGroups).
2. Click **(+)** -> **App Groups**.
3. **Description:** Ketal Group
4. **Identifier:** `group.io.ketal` (Must match exactly)
5. Click **Continue** -> **Register**.

### 2. Configure Main App ID (`io.ketal.app`)
1. Go to **Identifiers** -> Click `Ketal App`.
2. Scroll to **App Groups** capability.
3. Click the **Configure** button (or Edit).
4. **CHECK THE BOX** next to `group.io.ketal`.
5. Click **Save** / **Confirm**.

### 3. Configure NSE App ID (`io.ketal.app.nse`)
1. Go to **Identifiers** -> Click `Ketal NSE`.
2. Scroll to **App Groups**.
3. Click **Configure**.
4. **CHECK THE BOX** next to `group.io.ketal`.
5. Click **Save**.

### 4. Regenerate Profiles (This is mandatory)
Changes to App IDs do NOT update existing profiles automatically.

1. Go to **Profiles**.
2. Click `Ketal App Store Profile`.
3. Click **Edit**.
4. Click **Save** (this forces a refresh with new capabilities).
5. Download -> Encode -> Update Secret `PROVISIONING_PROFILE_BASE64`.
6. Repeat for `Ketal NSE App Profile` -> Update Secret `NSE_PROVISIONING_PROFILE_BASE64`.
