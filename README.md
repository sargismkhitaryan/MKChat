# iOS Messaging App

A modern iOS messaging application built with UIKit, featuring reusable components, Core Data persistence, and MVVM architecture pattern.

## Features

- 📱 **Reusable Message Component**: Customizable message cells with configurable background color, corner radius, and text size
- ⌨️ **Reusable Input Component**: Universal text input component for sending messages
- 📄 **Pagination**: Efficient message loading with configurable page size (default: 20 messages)
- 💾 **Core Data Integration**: Persistent storage for all messages using Core Data framework
- 🖼️ **Multi-media Support**: Support for both text and photo messages
- 📐 **MVVM Architecture**: Clean separation of concerns using Model-View-ViewModel pattern
- 🔄 **Combine Framework**: Reactive programming for data binding and UI updates
- 📱 **UICollectionView**: Smooth scrolling message display with optimized performance

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/sargismkhitaryan/MKChat.git
```

### 2. Open in Xcode

```bash
open MKChat.xcodeproj
```

### 3. Configure Development Team

1. Select your project in the Project Navigator
2. Go to **Signing & Capabilities** tab
3. Select your **Development Team**
4. Ensure a valid **Bundle Identifier** is set

### 4. Build and Run

⚠️ **Important: This app must be run on a physical iOS device for optimal performance and full functionality.**

1. Connect your iOS device via USB
2. Select your device from the device menu in Xcode
3. Press `Cmd + R` or click the **Run** button

## Why Physical Device is Required

- **Memory Management**: Accurate memory usage testing with large datasets
- **Scroll Performance**: Smooth UICollectionView scrolling with 1000+ messages
- **Real-world Testing**: Authentic user experience and performance metrics

### Performance Monitoring

Use Xcode Instruments to monitor:
- Memory usage
- Core Data performance
- UI responsiveness
- Image loading times

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with UIKit framework
- Uses Core Data for persistence
- Implements MVVM architecture pattern
- Utilizes Combine framework for reactive programming

**Note**: This application is optimized for physical iOS devices. Simulator testing may not provide accurate performance metrics or full functionality.
