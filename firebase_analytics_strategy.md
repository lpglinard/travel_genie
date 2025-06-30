# Firebase Analytics Strategy for Travel Genie App

## Overview

This document outlines a standardized Firebase Analytics implementation strategy for the Travel Genie mobile app. It focuses on tracking critical user actions (itinerary creation and AI optimizer usage), gamification engagement, user segmentation, funnel tracking, retention analysis, and Google Ads attribution.

---

## Key Recommendations

### 1. Replace Custom Events with Firebase Standard Events

| App Action | Firebase Event | Parameters | Notes |
|------------|----------------|------------|-------|
| User signs up | `sign_up` | `method` | Standard sign-up tracking |
| User logs in | `login` | `method` | Standard login event |
| View place details | `view_item` | `items` array: `item_id`, `item_name`, `item_category` | Standard view content |
| Search places | `search` | `search_term` | Query-based search tracking |
| Add place to itinerary | `add_to_cart` | `items` array | Treat trip building like e-commerce |
| Remove place from itinerary | `remove_from_cart` | `items` array | Opposite of add_to_cart |
| Create itinerary | `begin_checkout` | `items`, `trip_id`, `destination`, `value`, `currency` | Primary conversion event |
| Use AI optimizer | `optimize_itinerary` *(custom)* | `trip_id`, `optimizer_type` | Custom conversion event |
| Share itinerary | `share` | `method`, `content_type`, `item_id` | Sharing tracking |
| Unlock achievement | `unlock_achievement` | `achievement_id` or `achievement_name` | Gamification event |

---

### 2. Consistent Event & Parameter Naming

- Use lowercase snake_case for all event and parameter names
- Leverage Firebase standard parameters like `item_id`, `value`, `search_term`, `method`
- Keep custom parameters consistent across events

---

### 3. Define User Properties

| Property Name | Purpose |
|---------------|---------|
| `preferred_language` | Segment users by language |
| `achievement_count` | Track number of achievements |
| `onboarded` | Boolean for tutorial completion |
| `user_rank` | Engagement tier from gamification |
| `app_theme` | UI preference |
| `trip_type` | e.g., "family", "solo" if defined by user |

Register each property as a Custom Dimension in Firebase Console.

---

### 4. Funnels

**Funnel 1: Onboarding to Conversion**

1. `first_open` (auto)
2. `sign_up`
3. `tutorial_complete`
4. `begin_checkout`

**Funnel 2: Trip Planning Journey**

1. `search` or `view_item`
2. `add_to_cart`
3. `optimize_itinerary` (optional)
4. `begin_checkout`

---

### 5. Gamification Strategy

- Use `unlock_achievement` for each achievement earned
- Optionally log `level_up` for level progression
- Update `achievement_count` user property accordingly

---

### 6. Google Ads Integration

- Link Firebase with Google Ads
- Mark `begin_checkout` and `optimize_itinerary` as conversion events
- Import these into Ads for campaign optimization
- Use Firebase Audiences for remarketing (e.g., users who did `add_to_cart` but not `begin_checkout`)
- Assign a `value` to conversion events for bidding

---

## Implementation Plan

1. **Audit current events** and map to standard Firebase events
2. **Refactor `AnalyticsService`** to use a leaner structure with only business-meaningful methods
3. **Update parameter names** for consistency
4. **Define user properties** and register them in Firebase
5. **Set up custom dimensions** for important parameters
6. **Create funnels** and retention cohorts in Firebase
7. **Link Google Ads** and import conversion events
8. **Monitor & optimize** analytics and ad campaigns regularly

---

## Maintenance Guidelines

- Maintain an `analytics_events.md` catalog of all events and parameters
- Review analytics implementation on every major release
- Ensure all new features follow naming and tracking conventions

---

## Outcome

By implementing this strategy:
- Firebase’s full reporting power is unlocked
- Team gains actionable insights with less maintenance overhead
- Marketing efforts become more data-driven and effective