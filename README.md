# Storm Predictor

Storm Predictor is an iOS application designed to help users monitor and understand storm risk across Ontario. The app focuses on multi-city weather tracking, city-specific deep dives, Ontario-wide map-based risk visualization, and notification history to support safer daily planning and early weather awareness. 

## Team

**Group:** G-30  
**CRN:** 50497 

### Team Members
- Rishamnoor Kaur
- Nirja Arun Dabhi
- Gia Nagpal
- Danuja Shankar 

## Project Overview

Storm Predictor is a mobile-based storm prediction app for Ontario residents. It is intended to help users prepare for upcoming weather events by combining live weather data, local storage, storm-risk presentation, and map-based visualization. The project proposal describes the app as supporting multiple Ontario locations, city-specific weather insight, map-based risk visualization, timely alerts, and notification history. 

## Features

- Splash screen with app branding and team member names
- Multi-city dashboard for tracking saved Ontario cities
- City-specific deep dive with weather conditions and storm-related insight
- Ontario map view for risk-based visualization
- Notification timeline/history screen
- Local data persistence for saved cities and cached weather
- Search and add Ontario cities to the dashboard 

## Tech Stack

- **Language:** Swift
- **Framework:** SwiftUI
- **Maps & Location:** MapKit, Core Location
- **Local Storage:** SQLite
- **Weather API:** GeoMet-OGC-API by Environment Canada

## APIs and Libraries Used

### Weather Data
The application uses **GeoMet-OGC-API by Environment Canada** for weather-related data.

### Maps and Location
The application uses:
- **MapKit** for map rendering and overlays
- **Core Location** for location-related support

## Screens

### 1. Splash Screen
Displays the app logo, app name, and team member names when the app launches before transitioning to the main dashboard. The proposal mockup also specifies that the splash screen is shown for 2–3 seconds before moving to the home screen. 

### 2. Dashboard
The dashboard supports multi-city monitoring by showing saved cities with current weather and storm risk. Selecting a city leads to a deeper city-specific screen. 

### 3. City-Specific Deep Dive
This screen presents more detailed weather information for a selected city, including current conditions, storm-related insight, and alerts.

### 4. Map Risk Visualization
An Ontario-wide map displays weather and storm-risk information using visual severity regions, allowing users to explore conditions geographically. 

### 5. Notification History
A chronological record of weather-related notifications and warnings is maintained for users to review. 

## Target Users

Storm Predictor is designed for Ontario residents who need clear and early storm warnings for daily planning, including:
- students
- commuters
- families
- outdoor workers
- event planners 

## Problem the App Addresses

Many weather apps rely heavily on static data and generalized alerts, which may arrive too late or be too broad when weather changes quickly. Storm Predictor aims to improve preparedness by offering more location-focused monitoring and risk presentation. 

## Local Storage

The app stores:
- saved city preferences
- cached weather data
- storm-related data needed for app functionality locally using SQLite 

## Getting Started

### Requirements
- Xcode
- iOS Simulator or physical iPhone
- Swift / SwiftUI support
- Internet connection for fetching weather data

### Run the Project
1. Clone the repository
2. Open the project in Xcode
3. Select an iOS Simulator or connected device
4. Build and run the app

## Future Improvements

- richer live weather integration across more Ontario cities
- improved storm severity visualization
- more advanced predictive analytics
- enhanced notification and warning workflows
