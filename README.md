# SkyScanner 🌦️

SkyScanner is a sleek, modern weather application built with Flutter that provides real-time weather updates and a 5-day forecast. Designed with a focus on clean UI/UX and robust data persistence, it helps users stay ahead of the weather whether they are searching for a specific city or using their current GPS location.

## 🚀 Features

* **Real-time Weather:** Accurate current temperature, weather conditions, and high/lows.
* **5-Day Forecast:** Detailed daily summary with a click-through for hourly details.
* **Smart Search:** Search weather by city name with automatic persistence of your last search.
* **GPS Integration:** One-tap weather updates based on your current location using `Geolocator`.
* **Offline Support:** Caches the last searched city using `SharedPreferences` for instant access upon app restart.
* **Dynamic UI:** Beautiful Lottie animations that change based on weather conditions (Sunny, Rainy, Cloudy, etc.).
* **Error Handling:** Robust handling for network issues, invalid city names, and location permission denials.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** [Kotlin](https://kotlinlang.org/) (Android) / [Dart](https://dart.dev/)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Storage:** [shared_preferences](https://pub.dev/packages/shared_preferences)
* **API:** [OpenWeatherMap API](https://openweathermap.org/api)
* **Animations:** [Lottie for Flutter](https://pub.dev/packages/lottie)
* **Date Formatting:** [intl](https://pub.dev/packages/intl)

## 📦 Installation & Setup

1.  **Clone the repository:**
    
    git clone [https://github.com/anammemon091/Sky_Scanner]
    ```
2.  **Navigate to the project folder:**
    
    cd sky_scanner
    
3.  **Install dependencies:**

    flutter pub get
    
4.  **Add your API Key:**
    * Create a file named `constants.dart` in `lib/core/`.
    * Add your OpenWeather API key: `const String apiKey = "YOUR_API_KEY_HERE";`
5.  **Run the app:**
    
    flutter run


## 🏗️ Architecture

The project follows a clean directory structure to ensure scalability and maintainability:

* `lib/data`: Models and data sources (Remote/Local).
* `lib/logic`: State management using Provider.
* `lib/presentation`: UI screens and custom widgets.
* `lib/core`: App constants and theme configurations.

## 👤 Author

**Anam Memon**
* Mobile Application Developer
* [GitHub](https://github.com/anammemon091)