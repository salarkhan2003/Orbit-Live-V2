@echo off
echo Fixing Git history to remove secrets...
echo.

REM Reset to the commit before the problematic one
git reset --soft HEAD~1

REM Stage the fixed files
git add lib/services/twilio_otp_service.dart
git add lib/core/cashfree_payment_service.dart
git add .gitignore
git add .env.example

REM Commit with the same message but without secrets
git commit -m "Update: new changes added (secrets removed)"

echo.
echo Fixed! Now you can push with:
echo git push origin main
echo.
pause
