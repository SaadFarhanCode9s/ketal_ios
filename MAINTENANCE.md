# Ketal iOS Maintenance Guide

## Overview

This repository is a customized fork of [Element X iOS](https://github.com/element-hq/element-x-ios).
It uses a configuration isolation strategy to minimize merge conflicts when pulling upstream changes.

## Configuration

All Ketal-specific configuration is located in `ketal_config.yml`.
This file is the **Single Source of Truth** for:
- Branding (App Name, Bundle IDs)
- Domains (Matrix, Auth, Push)
- Feature Flags (OIDC, Element Call)

### Applying Configuration

After modifying `ketal_config.yml`, or after pulling upstream changes, you MUST run:

```bash
./apply_ketal_config.sh
```

This script generates `app.yml` and updates `AppSettings` via `Info.plist` injection.

## Project Generation

The Xcode project is generated using `XcodeGen`.
After applying configuration, run:

```bash
swift run tools setup-project
```

This will create `ketal.xcodeproj` using the settings from `project.yml`, `target.yml`, and the generated `app.yml`.

## Upstream Sync

To pull changes from `element-x-ios`:

1. Run the sync script:
   ```bash
   ./upstream_sync.sh
   ```
2. Resolve any conflicts.
   - `ketal_config.yml`, `project.yml`, `app.yml` are protected by `.gitattributes` to prefer OUR version (`merge=ours` or `union`).
3. The script automatically runs `./apply_ketal_config.sh`.
4. Run `swift run tools setup-project`.
5. Build and test.

## Protected Files

The following files are configured in `.gitattributes` to avoid upstream overrides:
- `ketal_config.yml` (ours)
- `project.yml` (union - be careful)
- `app.yml` (ours - generated)
- `ketal/SupportingFiles/target.yml` (union)
- `ketal/Resources/*` (branding assets)

## Directory Structure

- `ketal/` - Main source code (renamed from ElementX).
- `ketal_config.yml` - Ketal configuration.
- `apply_ketal_config.sh` - Configuration injection script.
- `upstream_sync.sh` - Upstream update script.
