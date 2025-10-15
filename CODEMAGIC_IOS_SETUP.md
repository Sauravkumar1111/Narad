# Codemagic iOS App Builder Setup Guide for Jarvis App

This guide will help you set up Codemagic iOS app builder for your Jarvis Flutter app.

## 📋 Prerequisites

1. **Codemagic Account**: Sign up at [codemagic.io](https://codemagic.io)
2. **Apple Developer Account**: For iOS distribution
3. **App Store Connect Account**: For TestFlight and App Store distribution

## 🔧 Setup Instructions

### 1. Add Your App to Codemagic

1. Log into your Codemagic account
2. Click **"Add application"**
3. Connect your Git repository
4. Select **"Flutter"** as the project type
5. Set the **Working directory** to `front end/jarvis_app`
6. Click **"Finish: Add application"**

### 2. Configure Environment Variables

In your Codemagic app settings, add these environment variables:

#### Required Variables:
- `AI_BACKEND_URL`: Default AI backend API endpoint (users can override in app settings)

#### iOS Signing (Configure in Codemagic UI):
- App Store Connect API key (Issuer ID, Key ID, Private Key)
- iOS distribution certificate
- Provisioning profile

### 3. Code Signing Setup

#### iOS Signing:
1. **Configure App Store Connect Integration in Codemagic UI:**
   - Go to Codemagic dashboard → Integrations → App Store Connect
   - Add your App Store Connect integration named `jarvis_app_store`
   - Upload your iOS distribution certificate
   - Upload provisioning profile
   - Configure App Store Connect API key

### 4. Customize the Configuration

Before running your first build, update these values in `codemagic.yaml`:

```yaml
# Update bundle identifier to match your App Store Connect app
bundle_identifier: com.yourcompany.jarvis

# Update email recipients
recipients:
  - your-email@example.com

# Customize beta groups
beta_groups:
  - your-beta-group-name
```

### 5. Build Configuration Details

The `codemagic.yaml` file includes 2 workflows:

#### 🍎 **ios-build** (Production)
- **Purpose**: Production iOS builds
- **Output**: IPA file for App Store
- **Publishing**: App Store Connect + TestFlight
- **Duration**: ~60 minutes
- **Working Directory**: `front end/jarvis_app`

#### 🛠️ **ios-dev-build** (Development)
- **Purpose**: Development builds for testing
- **Output**: Debug iOS app
- **Publishing**: Email notifications only
- **Duration**: ~45 minutes
- **Working Directory**: `front end/jarvis_app`

### 6. Build Triggers

The workflows will automatically trigger on:
- Push to main/master branch
- Pull request creation
- Manual trigger from Codemagic UI

### 7. Publishing Configuration

#### App Store:
- Publishes to **TestFlight** for beta testing
- **Does not** auto-submit to App Store (requires manual review)
- Auto-increments build numbers

## 📱 iOS Project Structure

Your iOS project is now properly configured with:

```
front end/jarvis_app/ios/
├── Runner.xcodeproj/          # Xcode project file
├── Podfile                    # CocoaPods dependencies
├── Runner/
│   ├── Info.plist            # App configuration
│   ├── AppDelegate.swift      # App delegate
│   ├── GeneratedPluginRegistrant.h/m  # Plugin registration
│   ├── Base.lproj/
│   │   ├── Main.storyboard   # Main storyboard
│   │   └── LaunchScreen.storyboard  # Launch screen
│   └── Assets.xcassets/      # App icons and assets
└── Flutter/
    ├── Generated.xcconfig     # Flutter configuration
    ├── Debug.xcconfig        # Debug configuration
    ├── Release.xcconfig      # Release configuration
    └── AppFrameworkInfo.plist # Framework info
```

## 🔐 Security & Secrets

### iOS Signing:
1. **Configure App Store Connect Integration in Codemagic UI:**
   - Go to Codemagic dashboard → Integrations → App Store Connect
   - Add your App Store Connect integration named `jarvis_app_store`
   - Upload your iOS distribution certificate
   - Upload provisioning profile
   - Configure App Store Connect API key

### AI Backend Configuration:
- Set `AI_BACKEND_URL` to your default API endpoint
- **Users can override this URL in the app settings** - the Codemagic variable is just a default
- Use different URLs for different environments (dev/staging/prod)
- **Default URL**: `http://192.168.1.4:8000/api/v1`

## 📱 Platform-Specific Notes

### iOS
- **Min iOS**: 11.0
- **Permissions**: Camera, Microphone, Photo Library, Speech Recognition
- **Build Types**: Debug app + Release IPA
- **Code Signing**: Automatic with uploaded certificates
- **Bundle ID**: `com.yourcompany.jarvis` (update this to match your App Store Connect app)

## 🔄 Customization

### Adding New Workflows
```yaml
workflows:
  your-custom-workflow:
    name: Custom Workflow
    environment:
      flutter: stable
    scripts:
      - name: Custom step
        script: |
          cd "front end/jarvis_app"
          echo "Your custom command"
```

### Environment-Specific Builds
```yaml
vars:
  # Development (users can override in app)
  AI_BACKEND_URL: "http://192.168.1.4:8000/api/v1"
  
  # Staging (users can override in app)
  AI_BACKEND_URL: "https://staging-api.yourcompany.com/api/v1"
  
  # Production (users can override in app)
  AI_BACKEND_URL: "https://api.yourcompany.com/api/v1"
```

## 🐛 Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Flutter version compatibility
   - Verify all dependencies in `pubspec.yaml`
   - Review build logs for specific errors

2. **Signing Issues**
   - Ensure certificates are valid and not expired
   - Check bundle identifier matches provisioning profile
   - Verify App Store Connect API key permissions

3. **Publishing Failures**
   - Check App Store Connect app information
   - Review publishing logs for specific errors

### Debug Commands
```bash
# Test Flutter setup
flutter doctor

# Test local build (on macOS)
flutter build ios --release

# Check dependencies
flutter pub deps
```

## 📊 Monitoring

### Build Status
- Monitor builds in Codemagic dashboard
- Set up email notifications for success/failure
- Use webhooks for integration with other tools

### Performance
- Track build duration trends
- Optimize build scripts for faster builds
- Use build caching where possible

## 🔗 Integration

### Slack Notifications
```yaml
publishing:
  slack:
    channel: '#mobile-releases'
    notify_on_build_start: true
```

### GitHub Integration
- Automatic status checks on PRs
- Release notes generation
- Issue linking

## 📚 Additional Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/ci)
- [App Store Connect](https://appstoreconnect.apple.com/)

---

## ✅ Ready to Build!

Your iOS project is now ready for Codemagic iOS app builder. The key files have been created:

1. ✅ **Xcode Project**: `Runner.xcodeproj/project.pbxproj`
2. ✅ **Podfile**: `ios/Podfile`
3. ✅ **Storyboards**: Main and Launch screen storyboards
4. ✅ **Assets**: App icons configuration
5. ✅ **Flutter Config**: Debug, Release, and Generated xcconfig files
6. ✅ **Codemagic Config**: `codemagic.yaml` with iOS workflows
7. ✅ **Permissions**: Camera, Microphone, Photo Library, Speech Recognition

**Next Steps:**
1. Commit these files to your repository
2. Set up your Codemagic account and connect your repository
3. Configure App Store Connect integration
4. Run your first build!

**Need Help?** Check the Codemagic documentation or create an issue in your repository for support.
