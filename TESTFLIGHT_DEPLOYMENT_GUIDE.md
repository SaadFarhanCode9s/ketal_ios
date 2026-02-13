# TestFlight Deployment - Ready to Execute Checklist

## ✅ Configuration Complete

Your TestFlight deployment is now configured and ready to execute via GitHub Actions. This document provides a final checklist and execution guide.

---

## 📋 Pre-Deployment Checklist

### 1. GitHub Secrets Verification

Ensure these secrets are set in your GitHub repository (`Settings` → `Secrets and variables` → `Actions`):

| Secret Name | Required | Description | Status |
|-------------|----------|-------------|--------|
| `ASC_KEY_ID` | ✅ Yes | App Store Connect API Key ID | Should be set |
| `ASC_ISSUER_ID` | ✅ Yes | App Store Connect Issuer ID | Should be set |
| `ASC_KEY_CONTENT` | ✅ Yes | App Store Connect API Key (.p8 content) | Should be set |
| `CERTIFICATE_P12_BASE64` | ✅ Yes | Base64-encoded distribution certificate | Should be set |
| `P12_PASSWORD` | ✅ Yes | Password for .p12 certificate | Should be set |
| `PROVISIONING_PROFILE_BASE64` | ✅ Yes | Main app provisioning profile (base64) | Should be set |
| `NSE_PROVISIONING_PROFILE_BASE64` | ✅ Yes | NSE provisioning profile (base64) | Should be set |

**To verify secrets:**
1. Go to `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`
2. Confirm all 7 secrets above are listed

### 2. App Configuration Verification

Based on your `project.yml` and `app.yml`:

- **App Name:** Ketal
- **Bundle ID (Main):** `io.ketal.app`
- **Bundle ID (NSE):** `io.ketal.app.nse`
- **Version:** `26.01.1`
- **Build Number:** `1`
- **Team ID:** `DQM48A6L3K`

### 3. App Store Connect Verification

**Before running the workflow, ensure:**

1. **App Record Created:**
   - Log in to [App Store Connect](https://appstoreconnect.apple.com/)
   - Navigate to **My Apps**
   - Verify "Ketal" app exists with Bundle ID `io.ketal.app`
   - If not created, create it now:
     - Click **+** button → **New App**
     - Platform: iOS
     - Name: Ketal
     - Bundle ID: `io.ketal.app`
     - SKU: `ketal-ios` (or your preference)

2. **Provisioning Profiles Match:**
   - Your provisioning profiles must include Bundle IDs:
     - `io.ketal.app` (Main App)
     - `io.ketal.app.nse` (Notification Service Extension)
   - Provisioning profile names in Fastfile:
     - Main: "Ketal App Store Profile"
     - NSE: "Ketal NSE App Store Profile"

3. **API Key Permissions:**
   - Your App Store Connect API key must have **Admin** or **App Manager** role
   - Verify at: `App Store Connect` → `Users and Access` → `Keys` → `App Store Connect API`

---

## 🚀 Deployment Execution

### Option 1: Push to Main Branch (Automatic)

The workflow will automatically trigger when you push to the `main` branch:

```bash
cd /media/saad/Code9s/Dimitry_iOS/ketal_ios
git add .
git commit -m "Configure TestFlight deployment"
git push origin main
```

### Option 2: Manual Trigger (Recommended for First Deploy)

1. **Push the workflow file first:**
   ```bash
   cd /media/saad/Code9s/Dimitry_iOS/ketal_ios
   git add .github/workflows/deploy_testflight.yml
   git commit -m "Add TestFlight deployment workflow"
   git push origin main
   ```

2. **Go to GitHub Actions:**
   - Navigate to: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`
   - Click on **Deploy to TestFlight** workflow
   - Click **Run workflow** button
   - Select branch: `main`
   - Click **Run workflow**

3. **Monitor the workflow:**
   - Click on the running workflow to see live logs
   - Watch for each step to complete successfully

---

## 📊 Expected Workflow Steps

The workflow will execute these steps (approximately 30-60 minutes):

1. ✅ **Checkout repository** (~30 seconds)
2. ✅ **Setup Xcode 16.1** (~2 minutes)
3. ✅ **Install dependencies** (~3 minutes)
   - xcodegen
   - bundler
   - Ruby gems
4. ✅ **Generate Xcode project** (~30 seconds)
5. ✅ **Deploy to TestFlight** (~30-45 minutes)
   - Import certificates and provisioning profiles
   - Build the app
   - Upload to TestFlight
   - Cleanup keychain

---

## ✅ Success Indicators

### In GitHub Actions Logs:

Look for these messages in the workflow output:

```
✓ Successfully imported certificates and provisioning profiles
✓ Building the app...
✓ Uploading to TestFlight...
✓ Successfully uploaded to TestFlight
✓ Cleaned up keychain: fastlane_keychain
```

### In App Store Connect:

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **My Apps** → **Ketal**
3. Click **TestFlight** tab
4. Look under **iOS builds** section
5. You should see: **Version 26.01.1 (1)** with status "Processing"
6. After 10-30 minutes, status will change to "Ready to Test"

---

## ❌ Troubleshooting Common Issues

### Issue 1: "CERTIFICATE_P12_BASE64 is missing"
**Cause:** Secret not set in GitHub repository  
**Fix:** 
1. Go to `Settings` → `Secrets and variables` → `Actions`
2. Add the missing secret
3. Re-run the workflow

### Issue 2: "Failed to import certificate"
**Cause:** Incorrect P12 password  
**Fix:** 
1. Verify the password used when exporting the .p12 file
2. Update `P12_PASSWORD` secret with correct password
3. Re-run the workflow

### Issue 3: "No matching provisioning profile found"
**Cause:** Provisioning profile doesn't match bundle identifier or profile name  
**Fix:** 
1. Verify provisioning profiles include Bundle IDs:
   - `io.ketal.app`
   - `io.ketal.app.nse`
2. Ensure profile names match what's specified in Fastfile (lines 364-365):
   - "Ketal App Store Profile"
   - "Ketal NSE App Store Profile"
3. Re-export and re-encode your provisioning profiles
4. Update the GitHub secrets

### Issue 4: "Code signing failed"
**Cause:** Certificate or provisioning profile base64 encoding has issues  
**Fix:**
1. Re-export your certificate and provisioning profiles
2. Encode them correctly:
   ```bash
   # For certificate:
   base64 -i certificate.p12 | pbcopy
   
   # For provisioning profiles:
   base64 -i main.mobileprovision | pbcopy
   base64 -i nse.mobileprovision | pbcopy
   ```
3. Update the secrets (ensure no extra whitespace or newlines)

### Issue 5: "Build failed" or "Compilation errors"
**Cause:** Code issues or missing dependencies  
**Fix:**
1. Test build locally first:
   ```bash
   cd /media/saad/Code9s/Dimitry_iOS/ketal_ios
   xcodegen
   xcodebuild -project ketal.xcodeproj -scheme ketal -configuration Release clean build
   ```
2. Fix any compilation errors
3. Push fixes and re-run workflow

### Issue 6: "Upload to TestFlight failed"
**Cause:** App Store Connect API key issues or app record not created  
**Fix:**
1. Verify app "Ketal" exists in App Store Connect
2. Verify API key has correct permissions
3. Check API key hasn't expired

---

## 🔐 Security Reminders

### ⚠️ CRITICAL: Exposed GitHub Token

From the walkthrough, there's an exposed GitHub token in your `ketal_keys/Matchfile`.

**You MUST immediately:**
1. Revoke this token: https://github.com/settings/tokens
2. Remove it from `ketal_keys/Matchfile`
3. If `ketal_keys` repository is public, regenerate ALL certificates

### Best Practices:
- Never commit secrets to the repository
- Always use GitHub Secrets for sensitive data
- Rotate certificates and tokens regularly
- Use different certificates for development and production

---

## 📝 Next Steps After Successful Deployment

1. **Verify in TestFlight:**
   - Check build appears in App Store Connect
   - Add internal testers
   - Distribute build to testers

2. **Add External Testers (Optional):**
   - Fill out required App Store information
   - Submit for external testing (requires Apple review)

3. **Monitor Crash Reports:**
   - Check TestFlight for crash reports
   - Monitor Sentry (if configured)

4. **Iterate:**
   - Make updates to your app
   - Push to main branch
   - Workflow will automatically deploy new builds

---

## 📞 Support

If you encounter issues not covered in this guide:

1. **Check GitHub Actions logs** for detailed error messages
2. **Review Fastlane logs** in the build artifacts (uploaded on failure)
3. **Verify all secrets** are correctly set
4. **Test locally** using: `bundle exec fastlane deploy_testflight` (requires macOS)

---

## 🎉 You're Ready to Deploy!

Everything is configured. Choose your deployment method above and execute the workflow.

**Quick Start (Manual Trigger):**
1. Push the workflow file to GitHub
2. Go to Actions tab in your GitHub repository
3. Click "Deploy to TestFlight"
4. Click "Run workflow"
5. Monitor the logs
6. Check App Store Connect for your build

Good luck! 🚀
