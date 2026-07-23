# Installing Godot
 
## Prerequisites
 
- A 64-bit operating system (Windows 10+, macOS 10.15+, or Linux)
- No additional dependencies required — Godot is self-contained
---
 
## Windows
 
1. Go to the [official Godot download page](https://godotengine.org/download/windows/)
2. Download the **Godot Engine – Standard** `.exe.zip` for 64-bit
3. Extract the `.zip` file to a folder of your choice
4. Run the extracted `.exe` — no installation wizard needed
> **Tip:** Pin the `.exe` to your taskbar or create a desktop shortcut for easy access.
 
---
 
## macOS
 
1. Go to the [official Godot download page](https://godotengine.org/download/macos/)
2. Download the **Godot Engine** `.dmg` file
3. Open the `.dmg` and drag **Godot** into your `Applications` folder
4. On first launch, right-click the app and choose **Open** to bypass Gatekeeper
---
 
## Linux
 
### Option A — Download directly
 
1. Go to the [official Godot download page](https://godotengine.org/download/linux/)
2. Download the **Godot Engine** `.zip` for 64-bit
3. Extract and run the binary:
```bash
unzip Godot_v*.zip
chmod +x Godot_v*_linux.x86_64
./Godot_v*_linux.x86_64
```
 
### Option B — Flatpak
 
```bash
flatpak install flathub org.godotengine.Godot
flatpak run org.godotengine.Godot
```
 
---
 
## Verifying the Installation
 
Once launched, you should see the **Godot Project Manager** window. From here you can create a new project or open an existing one.
 
---
 
## Resources
 
- [Official Godot Documentation](https://docs.godotengine.org/)
- [Godot Community Forums](https://forum.godotengine.org/)
- [Godot GitHub Repository](https://github.com/godotengine/godot)