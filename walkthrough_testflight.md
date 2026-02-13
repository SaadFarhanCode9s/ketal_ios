# TestFlight Deployment Configuration - Walkthrough

## Changes Made

Successfully configured the Fastlane and GitHub Actions workflow to use manual certificate import instead of Fastlane Match. This enables TestFlight deployment from your Ubuntu machine via GitHub Actions runners.

---

## Files Modified

### 1. Fastlane Configuration

#### [Fastfile](file:///media/saad/Code9s/Dimitry_iOS/ketal_ios/fastlane/Fastfile#L343-L443)

**Changes:**
- ✅ Replaced `match()` call with custom `import_code_signing_assets()` lane
- ✅ Added manual certificate import from base64-encoded environment variables
- ✅ Created temporary keychain for storing certificates during build
- ✅ Added provisioning profile installation for both main app and NSE
- ✅ Added cleanup logic to remove temporary keychain and files
- ✅ Configured explicit provisioning profile mapping in `build_app()`

**Key Features:**
```ruby
# Creates temporary keychain
# Decodes base64 certificates and profiles
# Imports certificate with password
# Installs provisioning profiles
# Cleans up after build completes
```

---

### 2. GitHub Actions Workflow

#### [deploy_testflight.yml](file:///media/saad/Code9s/Dimitry_iOS/ketal_ios/.github/workflows/deploy_testflight.yml#L29-L39)

**Changes:**
- ✅ Added `CERTIFICATE_P12_BASE64` environment variable
- ✅ Added `P12_PASSWORD` environment variable  
- ✅ Added `PROVISIONING_PROFILE_BASE64` environment variable
- ✅ Added `NSE_PROVISIONING_PROFILE_BASE64` environment variable
- ❌ Removed `MATCH_PASSWORD` (no longer needed)
- ❌ Removed `MATCH_GIT_URL` (no longer needed)

---

## GitHub Secrets Configuration

### ✅ Secrets You Already Have

Based on your message, you've already configured these secrets in your GitHub repository:

| Secret Name | Status | Purpose |
|-------------|--------|---------|
| `ASC_KEY_ID` | ✅ Set | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | ✅ Set | App Store Connect Issuer ID |
| `ASC_KEY_CONTENT` | ✅ Set | App Store Connect API Key (raw .p8 content) |
| `CERTIFICATE_P12_BASE64` | ✅ Set | Base64-encoded signing certificate |
| `P12_PASSWORD` | ✅ Set | Password for the .p12 certificate |
| `PROVISIONING_PROFILE_BASE64` | ✅ Set | Base64-encoded main app provisioning profile |
| `NSE_PROVISIONING_PROFILE_BASE64` | ✅ Set | Base64-encoded NSE provisioning profile |

### ⚠️ Unused Secrets (Can Be Removed)

These secrets are no longer used after switching to manual certificate import:
- `MATCH_PASSWORD` - Can be deleted
- `MATCH_GIT_URL` - Can be deleted

---

## Verification Steps

Since this requires macOS runners and App Store Connect access, you must verify this manually through GitHub Actions:

### Step 1: Push Changes to GitHub

```bash
cd /media/saad/Code9s/Dimitry_iOS/ketal_ios
git add .github/workflows/deploy_testflight.yml fastlane/Fastfile
git commit -m "Configure manual certificate import for TestFlight deployment"
git push origin main  # Or push to a test branch first
```

### Step 2: Trigger GitHub Actions Workflow

**Option A: Manual Trigger (Recommended for Testing)**
1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Select **Deploy to TestFlight** workflow
4. Click **Run workflow** button
5. Select the branch (main or your test branch)
6. Click **Run workflow**

**Option B: Automatic Trigger**
- Push to [main](file:///media/saad/Code9s/Dimitry_iOS/ketal_ios/fastlane/Fastfile#253-269) branch will automatically trigger the workflow

### Step 3: Monitor Workflow Execution

Watch for these key steps in the workflow logs:

#### ✅ Expected Success Indicators:
- [ ] "Installing dependencies" completes successfully
- [ ] "Successfully imported certificates and provisioning profiles" message appears
- [ ] Certificate import shows no errors
- [ ] Provisioning profiles installed successfully
- [ ] Build completes without code signing errors
- [ ] "Successfully uploaded to TestFlight" message appears
- [ ] "Cleaned up keychain" message appears

#### ❌ Potential Issues to Watch For:
- Certificate password mismatch (check `P12_PASSWORD`)
- Provisioning profile doesn't match bundle identifier
- Provisioning profile expired
- Certificate expired or invalid

### Step 4: Verify in App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Apps** → **Ketal** (or your app name)
3. Go to **TestFlight** tab
4. Check that a new build appears under **iOS builds**
5. Build should show version `26.01.1` (from your project.yml)

---

## Troubleshooting Common Issues

### Issue: "CERTIFICATE_P12_BASE64 is missing"
**Solution:** Ensure the secret is set in GitHub repository settings

### Issue: "Failed to import certificate"
**Solution:** Verify `P12_PASSWORD` matches the password used when creating the .p12 file

### Issue: "No matching provisioning profile found"
**Solution:** Ensure provisioning profiles include:
- Main app: `io.ketal.app`
- NSE: `io.ketal.app.nse`

### Issue: "Code signing failed"
**Solution:** Verify all base64 encodings are correct (no extra whitespace or newlines)

---

## Security Reminders

> [!CAUTION]
> **Immediate Action Required:** Your [ketal_keys/Matchfile](file:///media/saad/Code9s/Dimitry_iOS/ketal_keys/Matchfile) contains a hardcoded GitHub personal access token.
> 
> **You must:**
> 1. Revoke this token at https://github.com/settings/tokens
> 2. Remove it from the Matchfile
> 3. If the `ketal_keys` repository is public, consider it compromised and regenerate all certificates

---

## Next Steps

1. ✅ Push the changes to GitHub
2. ✅ Trigger the workflow manually to test
3. ✅ Monitor the workflow logs for any errors
4. ✅ Verify the build appears in App Store Connect
5. ✅ Revoke the exposed GitHub token in [ketal_keys/Matchfile](file:///media/saad/Code9s/Dimitry_iOS/ketal_keys/Matchfile)

If the deployment succeeds, you can now push builds to TestFlight directly from GitHub Actions! 🎉
