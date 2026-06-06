enum TitleRarity { common, rare, epic, legendary }

class ProfileTitle {
  final String id;
  final String name;
  final TitleRarity rarity;
  final String description;

  const ProfileTitle({
    required this.id,
    required this.name,
    required this.rarity,
    required this.description,
  });

  static const List<ProfileTitle> allTitles = [
    ProfileTitle(
      id: 'novice',
      name: 'Novice',
      rarity: TitleRarity.common,
      description: 'Start your journey (Unlocked by default)',
    ),
    ProfileTitle(
      id: 'intercessor',
      name: 'Intercessor',
      rarity: TitleRarity.common,
      description: 'Pray for at least 1 request on the Prayer Wall',
    ),
    ProfileTitle(
      id: 'dedicated',
      name: 'Dedicated',
      rarity: TitleRarity.rare,
      description: 'Maintain a 7-day play streak',
    ),
    ProfileTitle(
      id: 'flawless',
      name: 'Flawless',
      rarity: TitleRarity.rare,
      description: 'Achieve a perfect score (100%) on any quiz',
    ),
    ProfileTitle(
      id: 'speed_demon',
      name: 'Speed Demon',
      rarity: TitleRarity.epic,
      description: 'Average answer time < 5 seconds (min 10 questions)',
    ),
    ProfileTitle(
      id: 'quiz_master',
      name: 'Quiz Master',
      rarity: TitleRarity.epic,
      description: 'Reached Level 25 or completed 50 quizzes',
    ),
    ProfileTitle(
      id: 'bible_scholar',
      name: 'Bible Scholar',
      rarity: TitleRarity.epic,
      description: 'Completed 3 Bible reading plans',
    ),
    ProfileTitle(
      id: 'lightning',
      name: 'Lightning',
      rarity: TitleRarity.legendary,
      description: 'Average answer time < 3 seconds (min 10 questions)',
    ),
    ProfileTitle(
      id: 'unstoppable',
      name: 'Unstoppable',
      rarity: TitleRarity.legendary,
      description: 'Maintain a 30-day play streak',
    ),
  ];
}
