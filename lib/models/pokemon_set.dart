class PokemonSet {
  final String id;
  final String name;
  final String logo;
  final int price;
  final String description;
  final String hp;
  final String rarity;
  final List<String> types;

  PokemonSet({
    required this.id,
    required this.name,
    required this.logo,
    required this.price,
    required this.description,
    this.hp = 'HP 110',
    this.rarity = 'Uncommon',
    this.types = const ['Normal'],
  });

  factory PokemonSet.fromJson(Map<String, dynamic> json) {
    return PokemonSet(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      logo: json['logo'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      hp: json['hp']?.toString() ?? 'HP 110', // Jika API belum ada hp
      rarity: json['rarity']?.toString() ?? 'Uncommon',
      types: json['types'] != null 
          ? List<String>.from(json['types']) 
          : ['Normal'],
    );
  }
}
