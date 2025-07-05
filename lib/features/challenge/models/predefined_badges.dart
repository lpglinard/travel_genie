import 'badge.dart';
import 'badge_category.dart';

// Predefined badges based on the requirements
class PredefinedBadges {
  static const List<Badge> allBadges = [
    Badge(
      id: 'first_trip',
      name: 'badgesFirstTripName',
      description: 'badgesFirstTripDescription',
      iconName: 'flight_takeoff',
      category: BadgeCategory.travel,
    ),
    Badge(
      id: 'first_login',
      name: 'badgesFirstLoginName',
      description: 'badgesFirstLoginDescription',
      iconName: 'login',
      category: BadgeCategory.general,
    ),
    Badge(
      id: 'first_invite',
      name: 'badgesFirstInviteName',
      description: 'badgesFirstInviteDescription',
      iconName: 'group_add',
      category: BadgeCategory.social,
    ),
    Badge(
      id: 'first_ai_cover',
      name: 'badgesFirstAiCoverName',
      description: 'badgesFirstAiCoverDescription',
      iconName: 'auto_awesome',
      category: BadgeCategory.creative,
    ),
  ];
}