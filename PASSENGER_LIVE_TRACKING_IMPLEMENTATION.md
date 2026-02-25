# Orbit Live - Passenger Live Tracking Implementation

## Overview
This document describes the implementation of the real-time passenger bus tracking feature using Ola Maps and Firebase Realtime Database.

## Files Created/Modified

### New Files Created

#### 1. `lib/models/vehicle_telemetry.dart`
- Model class representing real-time vehicle data from Firebase
- Parses data from `/live-telemetry/{vehicleId}` path
- Fields: `vehicleId`, `lat`, `lon`, `routeId`, `status`, `isActive`, `timestamp`
- Includes computed properties: `busType` (AC/Non-AC based on naming), `formattedTime`, `displayLabel`

#### 2. `lib/services/passenger_telemetry_service.dart`
- ChangeNotifier service that streams live vehicle data from Firebase
- Connects to: `https://orbit-live-3836f-default-rtdb.firebaseio.com/live-telemetry`
- Features:
  - Real-time listener for active vehicles
  - Filters: `is_active == true` AND `status == 'in_transit'`
  - Bus type filter (AC/Non-AC)
  - Accessibility filter (stub for future)
  - Low crowd filter (stub for future)
  - Methods: `startListening()`, `stopListening()`, `refresh()`

#### 3. `lib/core/ola_maps_config.dart`
- Configuration for Ola Maps API
- API Key: `aI85TeqACpT8tV1YcAufNssW0epqxuPUr6LvMaGK`
- Project ID: `c6ef34e6-83ff-4a81-a51a-cd823c92cf34`
- Default center: Guntur, Andhra Pradesh (16.3067, 80.4365)

#### 4. `lib/features/passenger/presentation/live_track_bus_page.dart`
- Main passenger live tracking screen
- Features:
  - **Map Display**: Using flutter_map with Ola Maps tile layer
  - **Real-time Bus Markers**: Animated markers from Firebase `/live-telemetry`
  - **User Location**: GPS-based with pulsing animation
  - **Bus Stops**: Static layer for Guntur region
  - **Search**: Source/destination with autocomplete
  - **Filters**: AC/Non-AC, Accessibility, Low Crowd
  - **Bus Details Sheet**: Vehicle info, status, navigate button
  - **Navigate to Bus**: Opens Google Maps for 3D walking navigation

### Modified Files

#### 1. `lib/main.dart`
- Added import for `LiveTrackBusPage`
- Added route: `/live-track-bus`

#### 2. `lib/features/passenger/presentation/passenger_dashboard.dart`
- Added "Live Track" quick action tile (green, with location icon)
- Updated Live Tracking card to link to LiveTrackBusPage
- Reorganized quick actions grid with new items

#### 3. `pubspec.yaml`
- Added `webview_flutter: ^4.4.2` dependency

## How It Works

### Data Flow
1. **Driver Side**: Drivers use Start Trip to broadcast GPS to Firebase `/live-telemetry/{vehicleId}`
2. **Firebase**: Stores real-time data with `is_active`, `status`, `lat`, `lon`, `route_id`, `timestamp`
3. **Passenger Side**: `PassengerTelemetryService` listens to `/live-telemetry` and filters active buses
4. **UI Update**: `LiveTrackBusPage` displays buses on Ola Maps tiles via flutter_map

### Map Integration
- **Tile Layer**: Ola Maps API (`api.olamaps.io`) with fallback to OpenStreetMap
- **Markers**:
  - Blue circles: Bus stops (static)
  - Green/Orange circles: Live buses (AC=Green, Non-AC=Orange)
  - Blue dot: User location (animated pulse)

### Navigation Feature
When user taps "Navigate to this Bus":
```
https://www.google.com/maps/dir/?api=1&origin={userLat},{userLon}&destination={busLat},{busLon}&travelmode=walking
```
Opens Google Maps with walking directions for 3D navigation view.

## Acceptance Criteria Status

✅ **A. Ola Maps Integration**: flutter_map with Ola Maps tiles (with OSM fallback)
✅ **B. Remove Mock Buses**: Only real buses from Firebase are shown
✅ **C. Live Track Bus Screen**: Complete with search, filters, route chips
✅ **D. Passenger Location**: GPS-based with permission handling
✅ **E. Bus Tap → Details**: Bottom sheet with info and navigate button
✅ **F. Passenger Home Tiles**: "Live Track" quick action added
✅ **G. Admin Alignment**: Same Firebase path `/live-telemetry`
✅ **H. Clean Code**: Shared `PassengerTelemetryService` provider

## Testing Instructions

1. **Multiple Drivers Test**:
   - Have multiple drivers press "Start Trip"
   - Verify Firebase shows multiple `/live-telemetry` nodes
   - Passenger sees all active buses on map

2. **Real-time Updates**:
   - Driver moves location
   - Passenger map updates within ~5 seconds

3. **Stop Trip Test**:
   - Driver presses "Stop Trip"
   - `is_active` becomes `false` in Firebase
   - Bus disappears from passenger map

4. **Navigation Test**:
   - Tap any bus marker
   - Tap "Navigate to this Bus"
   - Google Maps opens with walking route

## Ola Maps Credentials (DO NOT SHARE)

```
Project Name: ORBIT LIVE MAPS
Project ID: c6ef34e6-83ff-4a81-a51a-cd823c92cf34
API Key: aI85TeqACpT8tV1YcAufNssW0epqxuPUr6LvMaGK
```

OAuth Client Secret is NOT included in the app code (server-side only).

