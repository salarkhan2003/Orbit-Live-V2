# Configuration Files

This directory contains configuration files and templates for the Orbit Live application.

## 📁 Files

### `.env.example`
Template for environment variables. Copy this to `.env` and fill in your actual values.

**Never commit `.env` files to version control!**

### `firebase_rules.txt`
Firebase security rules for Firestore and Storage.

## 🔧 Setup Instructions

### 1. Environment Variables

Copy the example file:
```bash
copy config\.env.example .env
```

Edit `.env` and add your credentials:
```env
TWILIO_ACCOUNT_SID=your_actual_sid
TWILIO_AUTH_TOKEN=your_actual_token
TWILIO_SERVICE_SID=your_actual_service_sid
CASHFREE_APP_ID=your_actual_app_id
CASHFREE_SECRET_KEY=your_actual_secret_key
```

### 2. Firebase Configuration

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Apply security rules from `firebase_rules.txt` to your Firebase project

### 3. Build with Environment Variables

```bash
flutter build apk \
  --dart-define=TWILIO_ACCOUNT_SID=$TWILIO_ACCOUNT_SID \
  --dart-define=TWILIO_AUTH_TOKEN=$TWILIO_AUTH_TOKEN \
  --dart-define=TWILIO_SERVICE_SID=$TWILIO_SERVICE_SID \
  --dart-define=CASHFREE_APP_ID=$CASHFREE_APP_ID \
  --dart-define=CASHFREE_SECRET_KEY=$CASHFREE_SECRET_KEY
```

## 🔐 Security Best Practices

1. **Never commit secrets** - Always use environment variables
2. **Use different keys** - Separate keys for dev/staging/production
3. **Rotate regularly** - Change API keys periodically
4. **Limit permissions** - Only grant necessary API permissions
5. **Use backend services** - For production, move API calls to a secure backend

## 📚 Additional Resources

- See `docs/SECRETS_SETUP.md` for detailed setup guide
- Check Firebase documentation for security rules
- Review API provider documentation for key management

## ⚠️ Important Notes

- `.env` files are in `.gitignore` and will not be committed
- `google-services.json` is also ignored for security
- Always verify your configuration before deploying
- Keep backup copies of your configuration in a secure location
