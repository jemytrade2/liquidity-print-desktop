# Visual Studio Build Tools Installation

## ⚙️ Required for Flutter Windows Desktop Apps

Flutter needs Visual Studio Build Tools to compile Windows desktop applications.

---

## 📥 Download & Install

### **Step 1: Download**

Go to: https://visualstudio.microsoft.com/downloads/

Scroll down to **"Tools for Visual Studio"** → Click **"Build Tools for Visual Studio 2022"**

**Or Direct Link:**
```
https://aka.ms/vs/17/release/vs_BuildTools.exe
```

---

### **Step 2: Install**

1. Run the installer (`vs_BuildTools.exe`)
2. **Select Workload:** "Desktop development with C++"
3. **Keep all default checkboxes** (Windows SDK, MSVC compiler, etc.)
4. Click "Install" (Size: ~6 GB)
5. Wait for installation (10-15 minutes)

---

### **Step 3: Verify**

Open PowerShell and run:
```powershell
C:\src\flutter\bin\flutter.bat doctor
```

**Should show:**
```
[✓] Visual Studio version 17.0 or above
```

---

### **Step 4: Run the App!**

```powershell
cd C:\Users\Hp\.gemini\antigravity\scratch\liquidity_print_desktop
C:\src\flutter\bin\flutter.bat run -d windows
```

**You should see the login screen! 🎉**

---

## 🔍 Troubleshooting

### "Visual Studio not found"
- Restart PowerShell after installation
- Run `flutter doctor` again

### "Missing Windows SDK"
- Re-run installer
- Make sure "Windows 10 SDK" is checked

---

**بعد التثبيت، البرنامج هيشتغل مباشرة! 🚀**
