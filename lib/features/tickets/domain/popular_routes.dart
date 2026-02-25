class PopularRoute {
  final String id;
  final String name;
  final String source;
  final String destination;
  final double distanceInKm;
  final Duration estimatedDuration;
  final List<String> timings;
  final double fixedFare; // Add fixed fare field

  PopularRoute({
    required this.id,
    required this.name,
    required this.source,
    required this.destination,
    required this.distanceInKm,
    required this.estimatedDuration,
    required this.timings,
    this.fixedFare = 0.0, // Default to 0, meaning calculate based on distance
  });

  // Calculate fare - use fixed fare if provided, otherwise calculate based on distance
  double get fare => fixedFare > 0 ? fixedFare : 5.0 + (distanceInKm * 2.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'source': source,
      'destination': destination,
      'distanceInKm': distanceInKm,
      'estimatedDuration': estimatedDuration.inMinutes,
      'timings': timings,
      'fixedFare': fixedFare,
    };
  }

  factory PopularRoute.fromJson(Map<String, dynamic> json) {
    return PopularRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      source: json['source'] as String,
      destination: json['destination'] as String,
      distanceInKm: (json['distanceInKm'] as num).toDouble(),
      estimatedDuration: Duration(minutes: json['estimatedDuration'] as int),
      timings: List<String>.from(json['timings'] as List),
      fixedFare: (json['fixedFare'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PopularRoutesData {
  static List<PopularRoute> getGunturRoutes() {
    return [
      PopularRoute(
        id: '0',
        name: 'Sims - RTC Bus Stand',
        source: 'Sims',
        destination: 'RTC Bus Stand',
        distanceInKm: 2.0,
        estimatedDuration: const Duration(minutes: 10),
        timings: ['Every 10 mins from 6:00 AM to 9:00 PM'],
        fixedFare: 5.0, // 5 INR fixed fare route
      ),
      PopularRoute(
        id: '1',
        name: 'Guntur Central - Tenali',
        source: 'Guntur Central',
        destination: 'Tenali',
        distanceInKm: 10.0,
        estimatedDuration: const Duration(minutes: 25),
        timings: ['6:00 AM', '7:30 AM', '9:00 AM', '11:30 AM', '2:00 PM', '4:30 PM', '6:00 PM', '8:30 PM'],
        fixedFare: 25.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '2',
        name: 'RTC Bus Stand - Mangalagiri',
        source: 'RTC Bus Stand',
        destination: 'Mangalagiri',
        distanceInKm: 17.5,
        estimatedDuration: const Duration(minutes: 45),
        timings: ['7:00 AM', '9:30 AM', '12:00 PM', '3:00 PM', '6:00 PM', '9:00 PM'],
        fixedFare: 40.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '3',
        name: 'Lakshmipuram - Namburu',
        source: 'Lakshmipuram',
        destination: 'Namburu',
        distanceInKm: 15.0,
        estimatedDuration: const Duration(minutes: 35),
        timings: ['6:30 AM', '8:00 AM', '10:30 AM', '1:00 PM', '3:30 PM', '6:30 PM', '9:30 PM'],
        fixedFare: 30.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '4',
        name: 'Gurazala - Pedakakani',
        source: 'Gurazala',
        destination: 'Pedakakani',
        distanceInKm: 20.0,
        estimatedDuration: const Duration(minutes: 50),
        timings: ['7:15 AM', '10:15 AM', '1:15 PM', '4:15 PM', '7:15 PM', '10:15 PM'],
        fixedFare: 35.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '5',
        name: 'Guntur Junction - Vijayawada',
        source: 'Guntur Junction',
        destination: 'Vijayawada',
        distanceInKm: 35.0,
        estimatedDuration: const Duration(minutes: 75),
        timings: ['6:00 AM', '8:30 AM', '11:00 AM', '1:30 PM', '4:00 PM', '6:30 PM', '9:00 PM'],
        fixedFare: 50.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '6',
        name: 'Amaravati - Guntur RTC',
        source: 'Amaravati',
        destination: 'Guntur RTC',
        distanceInKm: 12.5,
        estimatedDuration: const Duration(minutes: 30),
        timings: ['7:00 AM', '9:00 AM', '11:00 AM', '1:00 PM', '3:00 PM', '5:00 PM', '7:00 PM', '9:00 PM'],
        fixedFare: 20.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '7',
        name: 'Prakasham - Kollipara',
        source: 'Prakasham',
        destination: 'Kollipara',
        distanceInKm: 8.0,
        estimatedDuration: const Duration(minutes: 20),
        timings: ['6:45 AM', '8:45 AM', '10:45 AM', '12:45 PM', '2:45 PM', '4:45 PM', '6:45 PM', '8:45 PM'],
        fixedFare: 15.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '8',
        name: 'Guntur - Bapatla',
        source: 'Guntur',
        destination: 'Bapatla',
        distanceInKm: 25.0,
        estimatedDuration: const Duration(minutes: 60),
        timings: ['7:30 AM', '10:00 AM', '12:30 PM', '3:00 PM', '5:30 PM', '8:00 PM'],
        fixedFare: 30.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '9',
        name: 'Kakankuntla - Guntur City',
        source: 'Kakankuntla',
        destination: 'Guntur City',
        distanceInKm: 18.0,
        estimatedDuration: const Duration(minutes: 40),
        timings: ['6:15 AM', '8:15 AM', '10:15 AM', '12:15 PM', '2:15 PM', '4:15 PM', '6:15 PM', '8:15 PM'],
        fixedFare: 25.0, // RTC provided fixed fare
      ),
      PopularRoute(
        id: '10',
        name: 'Edla - Guntur RTC',
        source: 'Edla',
        destination: 'Guntur RTC',
        distanceInKm: 22.5,
        estimatedDuration: const Duration(minutes: 55),
        timings: ['7:00 AM', '9:30 AM', '12:00 PM', '2:30 PM', '5:00 PM', '7:30 PM', '10:00 PM'],
        fixedFare: 28.0, // RTC provided fixed fare
      ),
    ];
  }
}