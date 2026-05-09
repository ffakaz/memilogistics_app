// lib/core/config/flavor_config.dart
enum AppFlavor { development, staging, production, fake }

class FlavorConfig {
  final AppFlavor flavor;
  final String name;

  FlavorConfig._({required this.flavor, required this.name});

  static late FlavorConfig current;

  static void init({required AppFlavor flavor, String? name}) {
    current = FlavorConfig._(flavor: flavor, name: name ?? flavor.toString());
  }

  bool get isFake => flavor == AppFlavor.fake;
}
