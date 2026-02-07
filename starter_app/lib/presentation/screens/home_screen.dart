import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/kml_builder.dart';
import '../providers/lg_connection_provider.dart';
import '../widgets/connection_status_widget.dart';
import 'connection_screen.dart';
import 'explore_cities_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendKMLUseCase = ref.watch(sendKMLToLGProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Explorer 360'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectionScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ConnectionStatusWidget(),
                const SizedBox(height: 24),
                Text(
                  'LG Operations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (isTablet)
                   _buildTabletLayout(context, sendKMLUseCase, ref)
                else
                   _buildMobileLayout(context, sendKMLUseCase, ref),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, dynamic sendKMLUseCase, WidgetRef ref) {
    final actions = [
      _LGActionCard(
        title: 'Fly to New York',
        description: 'Orbit view of New York City',
        icon: Icons.location_city,
        color: Colors.blueAccent,
        onPressed: () async {
          final service = ref.read(lgServiceProvider);
          try {
            await service.flyTo(40.7128, -74.0060, 5000, 60, 0);
            
             // 1. Logo -> LEFT SCREEN
             final logoKml = KMLBuilder.createScreenOverlay(
                imageUrl: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png',
                title: 'LG Logo',
                content: '',
                overlayX: 0, overlayY: 1,
                screenX: 0.02, screenY: 0.95,
                sizeX: 300, sizeY: 200,
              );
             await service.sendLogoToLeftScreen(logoKml);

             // 2. Text Balloon -> RIGHT SCREEN
              final balloonKml = KMLBuilder.createBalloon(
                title: 'New York City',
                content: '''
                  <div style="font-family: Google Sans, sans-serif; width: 300px;">
                    <h1>New York City</h1>
                    <p>New York City comprises 5 boroughs sitting where the Hudson River meets the Atlantic Ocean. At its core is Manhattan, a densely populated borough that’s among the world’s major commercial, financial and cultural centers.</p>
                  </div>
                ''',
                longitude: -74.0060,
                latitude: 40.7128,
              );
              await service.sendBalloonToRightScreen(balloonKml);

            if (context.mounted) _showSnackBar(context, 'Flying to New York!');
          } catch (e) {
            if (context.mounted) _showSnackBar(context, e.toString(), isError: true);
          }
        },
      ),
      _LGActionCard(
        title: 'Fly to Paris',
        description: 'Orbit view of Eiffel Tower',
        icon: Icons.tour,
        color: Colors.purpleAccent,
        onPressed: () async {
          final service = ref.read(lgServiceProvider);
          try {
            await service.flyTo(48.8584, 2.2945, 3000, 70, 0);
             
              // 1. Logo -> LEFT SCREEN
             final logoKml = KMLBuilder.createScreenOverlay(
                imageUrl: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png',
                title: 'LG Logo',
                content: '',
                overlayX: 0, overlayY: 1,
                screenX: 0.02, screenY: 0.95,
                sizeX: 300, sizeY: 200,
              );
             await service.sendLogoToLeftScreen(logoKml);

              // 2. Text Balloon -> RIGHT SCREEN
              final balloonKml = KMLBuilder.createBalloon(
                title: 'Paris',
                content: '''
                  <div style="font-family: Google Sans, sans-serif; width: 300px;">
                    <h1>Paris</h1>
                    <p>Paris, France's capital, is a major European city and a global center for art, fashion, gastronomy and culture. Its 19th-century cityscape is crisscrossed by wide boulevards and the River Seine.</p>
                  </div>
                ''',
                longitude: 2.2945,
                latitude: 48.8584,
              );
              await service.sendBalloonToRightScreen(balloonKml);

            if (context.mounted) _showSnackBar(context, 'Flying to Paris!');
          } catch (e) {
            if (context.mounted) _showSnackBar(context, e.toString(), isError: true);
          }
        },
      ),
      _LGActionCard(
        title: 'Show Balloon',
        description: 'Display info balloon at current location',
        icon: Icons.info,
        color: Colors.amberAccent,
        onPressed: () async {
          final service = ref.read(lgServiceProvider);
          try {
              // 1. Logo -> LEFT SCREEN
             final logoKml = KMLBuilder.createScreenOverlay(
                imageUrl: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png',
                title: 'LG Logo',
                content: '',
                overlayX: 0, overlayY: 1,
                screenX: 0.02, screenY: 0.95,
                sizeX: 300, sizeY: 200,
              );
             await service.sendLogoToLeftScreen(logoKml);

             // 2. Text Balloon -> RIGHT SCREEN
          final kml = KMLBuilder.createBalloon(
            title: 'Welcome to LG!',
            content: '''
              <div style="background-color: #121212; color: #FFFFFF; font-family: Google Sans, sans-serif; padding: 20px; border-radius: 10px; width: 300px;">
                <h1>Liquid Galaxy GSoC 2026</h1>
                <p>This is a demo balloon created with the Flutter Starter Kit.</p>
              </div>
            ''',
            longitude: 0,
            latitude: 0,
          );
          await service.sendBalloonToRightScreen(kml);

          if (!context.mounted) return;
            _showSnackBar(context, 'Balloon displayed!');
          } catch (e) {
             if (context.mounted) _showSnackBar(context, e.toString(), isError: true);
          }
        },
      ),
      _LGActionCard(
        title: 'Explore Cities',
        description: 'Take a tour of amazing cities',
        icon: Icons.travel_explore,
        color: Colors.pinkAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExploreCitiesScreen()), 
          );
        },
      ),
      _LGActionCard(
        title: 'Clear Visualization',
        description: 'Remove all KML content',
        icon: Icons.clear,
        color: Colors.redAccent,
        onPressed: () async {
          final service = ref.read(lgServiceProvider);
          try {
            await service.clearKML();
            if (context.mounted) _showSnackBar(context, 'Visualization cleared!');
          } catch (e) {
            if (context.mounted) _showSnackBar(context, e.toString(), isError: true);
          }
        },
      ),
      _LGActionCard(
        title: 'Reboot LG',
        description: 'Reboot the Liquid Galaxy rig',
        icon: Icons.restart_alt,
        color: Colors.orangeAccent,
        onPressed: () async {
          final service = ref.read(lgServiceProvider);
          try {
            await service.rebootLG();
            if (context.mounted) _showSnackBar(context, 'Rebooting LG...');
          } catch (e) {
            if (context.mounted) _showSnackBar(context, e.toString(), isError: true);
          }
        },
      ),
    ];

    return Column(
      children: List.generate((actions.length / 2).ceil(), (index) {
        final int firstIndex = index * 2;
        final int secondIndex = firstIndex + 1;
        final bool hasSecond = secondIndex < actions.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: actions[firstIndex]),
              if (hasSecond) ...[
                const SizedBox(width: 16),
                Expanded(child: actions[secondIndex]),
              ],
            ],
          ),
        ),
      );
      }),
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic sendKMLUseCase, WidgetRef ref) {
    return _buildActionGrid(context, sendKMLUseCase, ref);
  }

  Widget _buildTabletLayout(BuildContext context, dynamic sendKMLUseCase, WidgetRef ref) {
     return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: _buildActionGrid(context, sendKMLUseCase, ref),
      ),
    );
  }


  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LGActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _LGActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
