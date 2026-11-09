import 'package:meta/meta.dart';

/// Apariencia de un astronauta.
@immutable
class AvatarLook {
  const AvatarLook({
    this.character = 'luna',
    this.helmet = 'morado',
    this.suit = 'clasico',
    this.accessory = 'antena',
    this.expression = 'smile',
  });

  final String character;
  final String helmet;
  final String suit;
  final String accessory;
  final String expression;

  static const orbi = AvatarLook(character: 'orbi');

  AvatarLook copyWith({
    String? character,
    String? helmet,
    String? suit,
    String? accessory,
    String? expression,
  }) => AvatarLook(
    character: character ?? this.character,
    helmet: helmet ?? this.helmet,
    suit: suit ?? this.suit,
    accessory: accessory ?? this.accessory,
    expression: expression ?? this.expression,
  );

  Map<String, dynamic> toJson() => {
    'character': character,
    'helmet': helmet,
    'suit': suit,
    'accessory': accessory,
    'expression': expression,
  };

  factory AvatarLook.fromJson(Map<String, dynamic> j) => AvatarLook(
    character: j['character'] as String? ?? 'luna',
    helmet: j['helmet'] as String? ?? 'morado',
    suit: j['suit'] as String? ?? 'clasico',
    accessory: j['accessory'] as String? ?? 'antena',
    expression: j['expression'] as String? ?? 'smile',
  );
}
