# Restaurant App Flutter

A Flutter application for browsing restaurants with detailed information and reviews.

## Project Structure

```
lib/
├── data/
│   ├── api/
│   │   └── restaurant_api_service.dart    # API service for restaurant data
│   └── model/
│       ├── restaurant.dart                # Restaurant model and list response
│       ├── restaurant_detail.dart         # Detailed restaurant model
│       └── review.dart                    # Review models and requests
├── provider/
│   ├── restaurant_provider.dart           # State management for restaurant list
│   ├── detail_provider.dart               # State management for restaurant details
│   ├── search_provider.dart               # State management for search functionality
│   └── review_provider.dart               # State management for reviews
├── ui/
│   ├── page/
│   │   ├── home_page.dart                 # Main page showing restaurant list
│   │   ├── detail_page.dart               # Restaurant detail page
│   │   ├── search_page.dart               # Search restaurants page
│   │   └── review_form.dart               # Form to add new reviews
│   └── widget/
│       ├── restaurant_card.dart           # Card widget for restaurant display
│       ├── loading_indicator.dart         # Loading state widget
│       ├── error_message.dart             # Error state widget
│       └── review_list.dart               # Widget to display reviews list
├── utils/
│   ├── result_state.dart                  # Result state management utilities
│   └── theme.dart                         # App theme configuration
└── main.dart                              # App entry point
```

## Features

- **Home Page**: Browse all available restaurants
- **Search**: Search restaurants by name
- **Restaurant Details**: View detailed information including menu, reviews, and ratings
- **Add Reviews**: Submit reviews for restaurants
- **Responsive UI**: Clean and modern interface with loading and error states

## Dependencies

- `provider: ^6.1.2` - State management
- `http: ^1.2.0` - HTTP requests to restaurant API

## API

This app uses the Dicoding Restaurant API:
- Base URL: `https://restaurant-api.dicoding.dev`
- Endpoints:
  - GET `/list` - Get all restaurants
  - GET `/detail/{id}` - Get restaurant details
  - GET `/search?q={query}` - Search restaurants
  - POST `/review` - Add restaurant review

## Architecture

The app follows a clean architecture pattern with:

- **Data Layer**: Models and API services
- **Provider Layer**: State management with Provider pattern
- **UI Layer**: Pages and reusable widgets
- **Utils**: Shared utilities and themes

## Getting Started

1. Ensure Flutter is installed and set up
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## State Management

The app uses the Provider pattern for state management:
- `RestaurantProvider` - Manages restaurant list state
- `DetailProvider` - Manages restaurant detail state
- `SearchProvider` - Manages search functionality
- `ReviewProvider` - Manages review submission

Each provider follows the Result pattern with states: `loading`, `hasData`, `noData`, and `error`.
