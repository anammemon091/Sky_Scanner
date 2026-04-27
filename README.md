# Sky Scanner ☁️

A premium, real-time weather application built with Flutter using the OpenWeatherMap API. Sky Scanner provides a "SaaS-style" user experience with smooth animations and location-aware weather tracking.

## 🚀 Key Features

* **Real-time Weather:** Accurate current weather data via OpenWeatherMap API.
* **5-Day Forecast:** Horizontal forecast view with dynamic date parsing using the `intl` package.
* **Geolocator Integration:** Automatically detects user location (GPS) to provide local weather on startup.
* **Lottie Animations:** High-quality, vector-based weather animations for a "Premium" UI/UX.
* **Clean Architecture:** Built using the Provider pattern for state management and a modular source/repository structure.

## 🛠️ Tech Stack

* **Framework:** Flutter (Material 3)
* **State Management:** Provider
* **API:** OpenWeatherMap API
* **Animations:** Lottie
* **Location:** Geolocator
* **Formatting:** Intl (Internationalization)

## 🏗️ Project Structure

```text
lib/
├── core/           # Constants and app theme
├── data/           
│   ├── models/     # Weather & Forecast Data Models
│   └── sources/    # Remote API Source logic
├── logic/          # Provider State Management
└── presentation/   # UI Screens and Widgets