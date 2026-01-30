# Edward Key

A modern macOS application for Vietnamese input with an integrated file tray manager. Edward Key provides seamless Vietnamese typing support using popular input methods (Telex and VNI) along with a convenient drag-and-drop file management system.

## Features

### 🇻🇳 Vietnamese Input
- **Multiple Input Methods**: Support for both Telex and VNI input methods
- **Smart Language Switching**: Quick toggle between English and Vietnamese
- **App-Specific Exclusions**: Disable Vietnamese input for specific applications
- **System-Wide Integration**: Works across all macOS applications via global key event monitoring

### 📁 DropOver File Tray
- **Floating File Tray**: Drag and drop files into a persistent floating tray
- **Modern UI**: Clean, glass-morphism design with visual effects
- **File Management**: Store, preview, and organize files temporarily
- **Quick Access**: Keep files accessible while working across different applications

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode 13.0 or later (for building from source)
- Accessibility permissions (required for keyboard event monitoring)

## Installation

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/edward-key.git
   cd edward-key
   ```

2. Open the project in Xcode:
   ```bash
   open "Edward Key.xcodeproj"
   ```

3. Build and run the project (⌘+R)

## Setup

### First Launch

When you first launch Edward Key, the app will request **Accessibility permissions**. This is required for the Vietnamese input functionality to work system-wide.

1. Launch Edward Key
2. Grant Accessibility permissions when prompted
   - If not prompted automatically, go to **System Preferences > Security & Privacy > Privacy > Accessibility**
   - Add Edward Key to the list and enable the checkbox

### Launch at Login (Optional)

To have Edward Key start automatically when you log in:
- The app includes built-in support for launch at login configuration
- Check the settings in the app's menu bar interface

## Usage

### Vietnamese Input

1. **Select Input Method**:
   - Click the menu bar icon
   - Choose between Telex or VNI input method

2. **Switch Languages**:
   - Toggle between English (EN) and Vietnamese (VN) modes
   - The current language is displayed in the status indicator

3. **Exclude Applications**:
   - Open the excluded apps modal
   - Select applications where you want to disable Vietnamese input
   - Useful for terminals, code editors, or other apps where Vietnamese input isn't needed

### File Tray (DropOver)

1. **Enable DropOver**:
   - Toggle the DropOver feature in the app settings

2. **Add Files**:
   - Drag and drop files onto the floating tray
   - Files are stored temporarily for easy access

3. **Manage Files**:
   - Hover over files to see options
   - Drag files out of the tray to use them
   - Clear the tray when you're done

## Project Structure

```
Edward Key/
├── Edward_KeyApp.swift          # App entry point
├── AppDelegate.swift            # App delegate for menu bar management
├── AppModel.swift               # Main app state and settings
├── AppObserver.swift            # Running apps observer
├── ContentView.swift            # Main UI view
├── Component/                   # Reusable UI components
│   ├── CardContainer.swift
│   ├── StatusIndicator.swift
│   └── VisualEffectView.swift
├── Core/                        # Core functionality
│   ├── KeyEventManager.swift    # Keyboard event handling
│   ├── Bridge/                  # Objective-C++ bridge
│   └── OpenKeyEngine/           # Vietnamese input engine (C++)
├── DropOver/                    # File tray feature
│   ├── FloatingTrayView.swift
│   ├── TrayManager.swift
│   ├── DragZoneDetector.swift
│   └── FileItem.swift
├── Type/                        # Data models and extensions
│   ├── Enum.swift
│   └── Extension.swift
└── View/                        # UI views
    ├── HeaderView.swift
    ├── MainContentView.swift
    ├── FooterView.swift
    └── ExcludedAppsModalView.swift
```

## Technology Stack

- **SwiftUI**: Modern declarative UI framework
- **AppKit**: macOS native framework integration
- **Core Graphics**: Low-level keyboard event monitoring
- **Combine**: Reactive programming for state management
- **C++**: Vietnamese input engine (OpenKey)
- **Objective-C++**: Bridge between Swift and C++

## Vietnamese Input Engine

Edward Key uses a customized OpenKey engine for Vietnamese input processing:
- **ConvertTool**: Character conversion utilities
- **Engine**: Core input processing logic
- **Vietnamese**: Vietnamese language-specific rules
- **SmartSwitchKey**: Intelligent key switching algorithm
- **Macro**: Text expansion support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenKey project for the Vietnamese input engine
- Vietnamese typing community for feedback and support

## Support

If you encounter any issues or have suggestions:
- Open an issue on GitHub
- Contact the maintainers

## Author

Created by Thành Công Lê

---

**Note**: Edward Key is a system-level application that requires Accessibility permissions to function properly. Your privacy and security are important - the app only monitors keyboard events for Vietnamese input processing and does not collect or transmit any data.
