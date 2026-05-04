import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../logic/weather_provider.dart';
import '../../core/constants.dart';
import 'forecast_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; 

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();
    _initializeWeatherData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); 
    super.dispose();
  }

  Future<void> _initializeWeatherData() async {
    final weatherProvider = context.read<WeatherProvider>();
    final prefs = await SharedPreferences.getInstance();
    String? lastCity = prefs.getString('last_city');

    if (lastCity != null) {
      _searchController.text = lastCity;
      await weatherProvider.fetchWeather(lastCity);
    } else {
      await weatherProvider.initApp();
    }
  }

  void _handleRefresh() {
    final provider = context.read<WeatherProvider>();
    if (_searchController.text.isNotEmpty) {
      provider.fetchWeather(_searchController.text);
    } else {
      provider.fetchWeatherByCurrentLocation();
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Sky Scanner",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(Icons.cloud, color: Colors.cyanAccent),
      children: [const Text("A cross-platform weather intelligence app built for HNG Stage 4.")],
    );
  }

  String _getWeatherAnimation(String? condition, String? iconCode) {
    if (condition == null || iconCode == null) return 'assets/animations/sunny.json';
    bool isNight = iconCode.endsWith('n');
    switch (condition.toLowerCase()) {
      case 'clouds':
        return isNight ? 'assets/animations/cloudy_night.json' : 'assets/animations/cloudy.json';
      case 'rain':
      case 'drizzle':
        return 'assets/animations/rainy.json';
      case 'clear':
        return isNight ? 'assets/animations/moon.json' : 'assets/animations/sunny.json';
      case 'snow':
        return 'assets/animations/snow.json';
      default:
        return isNight ? 'assets/animations/moon.json' : 'assets/animations/sunny.json';
    }
  }

  // Helper to build the context menu wrapper
  Widget _buildContextMenuRegion({required Widget child, required List<ContextMenuEntry> items}) {
    return ContextMenuRegion(
      items: items,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Actions(
      actions: <Type, Action<Intent>>{
        FocusSearchIntent: CallbackAction<FocusSearchIntent>(
          onInvoke: (intent) => _searchFocusNode.requestFocus(),
        ),
        RefreshWeatherIntent: CallbackAction<RefreshWeatherIntent>(
          onInvoke: (intent) => _handleRefresh(),
        ),
        GpsLocationIntent: CallbackAction<GpsLocationIntent>(
          onInvoke: (intent) {
            _searchController.clear();
            return context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
          },
        ),
        QuitAppIntent: CallbackAction<QuitAppIntent>(
          onInvoke: (intent) => SystemNavigator.pop(),
        ),
        AboutAppIntent: CallbackAction<AboutAppIntent>(
          onInvoke: (intent) => _showAboutDialog(),
        ),
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1D1E33), Color(0xFF111328)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (isDesktop) _buildMenuBar(), 
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.padding, vertical: 10),
                  child: _buildTopBar(isDesktop),
                ),
                Expanded(
                  child: Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return Center(
                            child: Lottie.asset('assets/animations/loading.json',
                                width: 180));
                      }

                      if (provider.error.isNotEmpty) return _buildErrorState(provider);

                      final weather = provider.weather;
                      if (weather == null) {
                        return const Center(
                            child: Text("Search for a city",
                                style: TextStyle(color: Colors.white24)));
                      }

                      return isDesktop
                          ? _buildDesktopContent(provider, weather)
                          : _buildMobileContent(provider, weather);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          _buildMenuButton("File", ["New Search", "Quit"], [
            () => _searchFocusNode.requestFocus(),
            () => SystemNavigator.pop()
          ]),
          _buildMenuButton("Edit", ["Clear Search", "Copy City Name"], [
            () => _searchController.clear(),
            () => Clipboard.setData(ClipboardData(text: _searchController.text))
          ]),
          _buildMenuButton("View", ["Refresh Weather", "Use GPS"], [
            () => _handleRefresh(),
            () => context.read<WeatherProvider>().fetchWeatherByCurrentLocation()
          ]),
          _buildMenuButton("Help", ["About Sky Scanner"], [_showAboutDialog]),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, List<String> items, List<VoidCallback> actions) {
    return PopupMenuButton<int>(
      onSelected: (index) => actions[index](),
      offset: const Offset(0, 30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ),
      itemBuilder: (context) => List.generate(
        items.length,
        (index) => PopupMenuItem(
          value: index,
          child: Text(items[index], style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Center(
      child: Container(
        constraints:
            BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
        child: Row(
          children: [
            const Icon(Icons.cloud, color: Colors.cyanAccent, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode, 
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search city...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
                onSubmitted: (value) => value.isNotEmpty
                    ? context.read<WeatherProvider>().fetchWeather(value)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              tooltip: "Current Location (Ctrl+G)",
              icon: const Icon(Icons.my_location, color: Colors.cyanAccent),
              onPressed: () {
                _searchController.clear();
                context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent(WeatherProvider provider, dynamic weather) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCurrentWeather(weather),
          const SizedBox(height: 40),
          _buildForecastSection(provider),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(WeatherProvider provider, dynamic weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCurrentWeather(weather),
                ],
              ),
            ),
          ),
          const VerticalDivider(
              color: Colors.white10, indent: 50, endIndent: 50, width: 60),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Weekly Intelligence",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 30),
                Expanded(child: _buildForecastGrid(provider)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(dynamic weather) {
    return Column(
      children: [
        _buildContextMenuRegion(
          items: [
            ContextMenuEntry("Copy City Name", () => Clipboard.setData(ClipboardData(text: weather.cityName))),
            ContextMenuEntry("Refresh Weather", _handleRefresh),
          ],
          child: Text(weather.cityName,
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: const TextStyle(color: Colors.white54, fontSize: 18)),
        const SizedBox(height: 20),
        Lottie.asset(_getWeatherAnimation(weather.condition, weather.iconCode),
            height: 250),
        Text("${weather.temperature.toStringAsFixed(0)}°C",
            style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.w100,
                color: Colors.white)),
        Text(weather.condition.toUpperCase(),
            style: const TextStyle(
                fontSize: 18,
                letterSpacing: 5,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildForecastSection(WeatherProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("5-Day Forecast",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.dailySummary.length,
            itemBuilder: (context, index) =>
                _buildForecastCard(provider.dailySummary[index], provider),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastGrid(WeatherProvider provider) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: provider.dailySummary.length,
      itemBuilder: (context, index) =>
          _buildForecastCard(provider.dailySummary[index], provider,
              isGrid: true),
    );
  }

  Widget _buildForecastCard(dynamic day, WeatherProvider provider,
      {bool isGrid = false}) {
    final dateObj = DateTime.parse(day.date);
    final dateKey = day.date.split(' ')[0];
    final hourly = provider.fullForecast.where((f) => f.date.contains(dateKey)).toList();

    return _buildContextMenuRegion(
      items: [
        ContextMenuEntry("View Details", () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ForecastDetail(
                      selectedDate: dateObj, hourlyForecasts: hourly)));
        }),
        ContextMenuEntry("Share Forecast", () {
          Clipboard.setData(ClipboardData(text: "Forecast for ${DateFormat('EEEE').format(dateObj)}: ${day.temp.toStringAsFixed(0)}°C"));
        }),
      ],
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ForecastDetail(
                      selectedDate: dateObj, hourlyForecasts: hourly)));
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: isGrid ? null : 110,
          margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('EEEE').format(dateObj),
                  style: const TextStyle(color: Colors.white54)),
              Lottie.asset(_getWeatherAnimation(day.condition, day.iconCode),
                  height: 60),
              Text("${day.temp.toStringAsFixed(0)}°C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WeatherProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 80, color: Colors.white24),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(provider.error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
              onPressed: () => provider.fetchWeatherByCurrentLocation(),
              child: const Text("Retry GPS",
                  style: TextStyle(color: Colors.cyanAccent))),
        ],
      ),
    );
  }
}

// --- CUSTOM CLASSES FOR CONTEXT MENU ---

class ContextMenuEntry {
  final String label;
  final VoidCallback onPressed;
  ContextMenuEntry(this.label, this.onPressed);
}

class ContextMenuRegion extends StatelessWidget {
  const ContextMenuRegion({
    super.key,
    required this.child,
    required this.items,
  });

  final Widget child;
  final List<ContextMenuEntry> items;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        final Offset offset = details.globalPosition;
        
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            offset.dx + 1.0,
            offset.dy + 1.0,
          ),
          items: items.map((item) {
            return PopupMenuItem(
              onTap: item.onPressed,
              child: Text(item.label, style: const TextStyle(color: Colors.white, fontSize: 13)),
            );
          }).toList(),
          elevation: 8.0,
          color: const Color(0xFF1D1E33), // Themed to match SaaS interface
        );
      },
      child: child,
    );
  }
}