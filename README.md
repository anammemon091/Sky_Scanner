**🌤️ Sky Scanner: Cross-Platform Weather Intelligence**
Sky Scanner is a robust, cross-platform weather application built with a single codebase using Flutter. This project demonstrates high-performance adaptation across Mobile (Android/iOS), Desktop (Windows), and Web platforms, utilizing modern UI/UX principles and efficient state management.

**🛠️ Cross-Platform Features**
This application goes beyond simple UI scaling to provide platform-specific experiences:

**🖥️ Desktop Excellence**
Adaptive Layout: Uses a side-by-side "Weekly Intelligence" grid for large screens and a vertical scroll for mobile views.

Application Menu: Full implementation of File, Edit, View, and Help menus for a native desktop feel.

Right-Click Context Menus: Quick actions available on the City Name and Forecast Cards.

**Keyboard Shortcuts:**

Ctrl + F: Focus Search Bar

Ctrl + R: Refresh Weather Data

Ctrl + G: Get Current GPS Location

Ctrl + Q: Quit Application

Ctrl + I: About Sky Scanner

**📱 Mobile & 🌐 Web**
Gestures: Smooth touch interactions and "Bouncing Physics" for mobile users.

Animations: Powered by Lottie for realistic, high-fidelity weather state transitions.

Responsive Design: Content dynamically re-organizes based on window resizing without losing app state.

**🏗️ Technical Architecture**
Framework: Flutter (Single Codebase)

State Management: Provider

Data Layer: OpenWeather API with SharedPreferences for local persistence.

Storage: Platform-agnostic storage mechanisms ensuring offline functionality.

**📦 Setup & Installation**
Clone the repository:

Bash
git clone https://github.com/anammemon091/Sky_Scanner.git
Install dependencies:

Bash
flutter pub get
Run the app:

Mobile: flutter run

Desktop: flutter run -d windows

Web: flutter run -d chrome

**👨‍💻 Development Process**
Transforming this app into a cross-platform intelligence suite involved:

Implementing Platform Conditionals to handle different input methods (Mouse vs. Touch).

Utilizing Actions & Intents for deep keyboard integration on desktop systems.

Structuring the folder system to separate shared logic (/logic, /core) from UI components.