# offline_SLM_app 📱🧠

A complete, production-ready Flutter mobile application demonstrating **100% offline on-device Small Language Models (SLMs)** powered by the [`offline_slm`](https://pub.dev/packages/offline_slm) package.

[![pub package](https://img.shields.io/pub/v/offline_slm.svg)](https://pub.dev/packages/offline_slm)
[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-blue.svg)](https://flutter.dev)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20macOS-lightgrey.svg)]()

---

## ✨ Features

- 🔒 **100% On-Device Privacy**: No prompts, chats, or personal data ever leave your device.
- ⚡ **Instant Simulator Mode**: Test token streaming, prompt suggestions, and UI flows with zero downloads or waiting.
- 📥 **Built-in Model Downloader & Catalog**: Switch between tested mobile SLMs (SmolLM2 135M, 360M, 1.7B, Qwen 2.5, Llama 3.2, Phi-3.5) with real-time download progress and caching.
- 💬 **Drop-in Chat UI**: Built with `OfflineChatWidget`, featuring animated typing cursors, token generation speed metrics (`tok/s`), prompt suggestions, and copy-to-clipboard actions.
- 🎨 **Adaptive Themes**: Instant Dark / Light Material 3 mode toggle.
- ⚙️ **Hyperparameter Tuning**: In-app controls for system prompts, temperature, and top-p sampling.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.3.0)
- Xcode (for iOS/macOS) or Android Studio (for Android)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Naveedrj/offline_SLM_app.git
   cd offline_SLM_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on your device or simulator:**
   ```bash
   # Run on iOS Simulator
   flutter run -d iPhone

   # Run on Android
   flutter run -d android
   ```

---

## 📦 Powered by offline_slm

This app is built using the **[offline_slm](https://pub.dev/packages/offline_slm)** package on pub.dev.

To add offline SLM capabilities to your own Flutter app:

```yaml
dependencies:
  offline_slm: ^0.0.2
```

```dart
import 'package:offline_slm/offline_slm.dart';

// Drop-in chat UI
OfflineChatWidget(
  controller: chatController,
);
```

---

## 📄 License

MIT License.
