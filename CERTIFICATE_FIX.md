# 🔐 Certificate Import Error Troubleshooting

## Problem
The build fails with `security: SecKeychainItemImport: MAC verification failed during PKCS12 import (wrong password?)` even though the password works on Ubuntu/Linux.

## Root Cause
This happens when a `.p12` certificate was exported using **OpenSSL 3.0+** (default on Ubuntu 22.04+) which uses newer encryption algorithms (AES-256 + PBKDF2) that macOS Keychain Access often rejects.

## Only Solution: Re-Export as Legacy

You must re-export your certificate using the `-legacy` flag or compatible algorithms.

### Step 1: Check your .p12 file locally (on your Ubuntu machine)

```bash
# If this command works, your password is correct, but the format is likely incompatible
openssl pkcs12 -info -in certificate.p12 -noout
```

### Step 2: Convert to Legacy Format (Compatible with macOS)

Run these commands on your Ubuntu machine where you have the original certificate and key (or extract them from your current p12):

1. **Extract Certificate & Key (if needed):**
   ```bash
   openssl pkcs12 -in certificate.p12 -out certificate.pem -nodes
   ```

2. **Re-Export with Legacy Encryption:**
   **⚠️ CRITICAL STEP:**
   ```bash
   openssl pkcs12 -export -legacy -in certificate.pem -out certificate_legacy.p12
   ```
   *Enter a strong password when prompted.*

### Step 3: Update GitHub Secret

1. **Base64 Encode the NEW Legacy P12:**
   ```bash
   base64 -w 0 certificate_legacy.p12
   # Or on Mac: base64 -i certificate_legacy.p12
   ```

2. **Update GitHub Secret:**
   - Go to GitHub Repo -> Settings -> Secrets -> Actions
   - Update `CERTIFICATE_P12_BASE64` with the new base64 string.
   - Update `P12_PASSWORD` if you changed the password.

### Step 4: Re-Run Deployment

Trigger the GitHub Action again. It should now successfully import the certificate.

---

## ❌ "No signing certificate matching team ID with a private key was found"

If you see this error, it means you successfully imported the certificate, but **IT IS MISSING THE PRIVATE KEY**.

### How to Fix:

1.  Open **Keychain Access** on your Mac.
2.  Find your "Apple Distribution" or "iPhone Distribution" certificate.
3.  **Click the arrow** next to it to expand.
4.  Select **BOTH** the certificate AND the private key (nested under it).
5.  Right-click -> **Export 2 items...**
6.  Save as `.p12` with a password.
7.  **Crucial:** If using OpenSSL 3+, remember to convert to **Legacy format** (Step 2 above).
8.  Base64 encode and update your GitHub Secret.
