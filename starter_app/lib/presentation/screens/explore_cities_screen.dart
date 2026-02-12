import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/heatmap_view_model.dart';
import '../../domain/entities/city.dart';

class ExploreCitiesScreen extends ConsumerWidget {
  const ExploreCitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapState = ref.watch(heatmapProvider);
    final viewModel = ref.read(heatmapProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('City Heatmaps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.clearHeatmap(),
            tooltip: 'Clear Heatmap',
          ),
        ],
      ),
      body: Column(
        children: [
          if (heatmapState.isLoading)
            const LinearProgressIndicator(),
            
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => viewModel.showWorldHeatmap(),
              icon: const Icon(Icons.public),
              label: const Text('View World Weather Map'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: viewModel.cities.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final city = viewModel.cities[index];
                final isSelected = heatmapState.currentCity == city;

                return Card(
                  elevation: isSelected ? 8 : 2,
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.thermostat, color: Colors.orange),
                        title: Text(
                          city.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(city.description),
                        trailing: isSelected && heatmapState.weatherData != null
                            ? Text(
                                '${heatmapState.weatherData!.temperature}°C',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => viewModel.showHeatmap(city),
                      ),
                      if (isSelected && heatmapState.weatherData != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildWeatherInfo(Icons.water_drop, Colors.blue, '${heatmapState.weatherData!.humidity}%', 'Humidity'),
                              _buildWeatherInfo(Icons.air, Colors.grey, '${heatmapState.weatherData!.windSpeed} km/h', 'Wind'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getAqiColor(heatmapState.weatherData!.aqi),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'AQI ${heatmapState.weatherData!.aqi}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          if (heatmapState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${heatmapState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tap a city to visualize its temperature heat map on Liquid Galaxy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.orangeAccent; // Moderate
    if (aqi <= 150) return Colors.orange; // Unhealthy for Sensitive
    if (aqi <= 200) return Colors.red; // Unhealthy
    if (aqi <= 300) return Colors.purple; // Very Unhealthy
    return Colors.brown; // Hazardous
  }

  Widget _buildWeatherInfo(IconData icon, Color color, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
