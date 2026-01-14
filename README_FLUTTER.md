# TaskFlow - Flutter Task Manager

A modern, beautiful task management application built with Flutter. This app provides a clean and intuitive interface for managing your daily tasks with features like categorization, priority levels, reminders, and analytics.

## Features

- 📝 **Task Management**: Create, edit, delete, and complete tasks
- 🏷️ **Categories**: Organize tasks by Work, Personal, Urgent, Shopping, and Others
- ⚡ **Priority Levels**: Set tasks as High, Medium, or Low priority
- 🔔 **Reminders**: Set reminders with custom time and frequency
- 📊 **Analytics Dashboard**: View task statistics and distribution charts
- 🌙 **Dark Mode**: Toggle between light and dark themes
- 🎨 **Accent Colors**: Choose from 5 different accent themes
- 🔍 **Search & Filter**: Find tasks quickly with advanced filtering
- 📱 **Responsive Design**: Works beautifully on all screen sizes

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── task.dart            # Task models and enums
├── services/
│   └── task_service.dart    # Task data management
├── screens/
│   └── home_screen.dart     # Main app screen
├── widgets/
│   ├── task_card.dart       # Task card component
│   ├── task_form.dart       # Task creation/editing form
│   └── stats_dashboard.dart # Analytics dashboard
└── utils/
    └── theme_provider.dart  # Theme management
```

## Dependencies

- `provider`: State management
- `shared_preferences`: Local storage
- `uuid`: Generate unique IDs
- `fl_chart`: Charts for analytics
- `flutter_animate`: Smooth animations
- `google_fonts`: Custom typography
- `intl`: Date formatting

## Architecture

The app follows a clean architecture pattern:

- **Models**: Define data structures and business logic
- **Services**: Handle data operations and persistence
- **Screens**: UI screens and navigation
- **Widgets**: Reusable UI components
- **Utils**: Helper classes and utilities

## Data Storage

Tasks are stored locally using `shared_preferences` as JSON data. This ensures the app works offline and maintains data between sessions.

## Theme System

The app features a comprehensive theming system:

- **Light/Dark Mode**: System-wide theme switching
- **Accent Colors**: 5 customizable accent themes (Indigo, Rose, Emerald, Amber, Violet)
- **Material 3 Design**: Modern Material Design components

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

---

Built with ❤️ using Flutter
