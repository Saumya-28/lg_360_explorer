import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/city_tour_view_model.dart';
import '../../domain/entities/city.dart';

class ExploreCitiesScreen extends ConsumerWidget {
  const ExploreCitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(cityTourProvider);
    final isPlaying = tourState.isPlaying;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Cities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(cityTourProvider.notifier).stopTour();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(
              Icons.travel_explore, 
              size: 100, 
              color: isPlaying ? Colors.pinkAccent : Colors.grey,
            ),
            const SizedBox(height: 32),
            Text(
              isPlaying ? 'Tour in Progress...' : 'Ready to Explore?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (isPlaying && tourState.currentCityIndex != null)
              Text(
                'Visiting City #${tourState.currentCityIndex! + 1}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                if (isPlaying) {
                  ref.read(cityTourProvider.notifier).stopTour();
                } else {
                  ref.read(cityTourProvider.notifier).startTour();
                }
              },
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? 'Stop Tour' : 'Start Tour'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: isPlaying ? Colors.redAccent : Colors.green,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
