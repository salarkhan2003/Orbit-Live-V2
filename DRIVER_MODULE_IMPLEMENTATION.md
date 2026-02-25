# Orbit Live - Driver/Conductor Module Implementation

## Overview
This document describes the implementation of the comprehensive Driver/Conductor module with:
- Employee login system
- Trip management (Start/End with live GPS)
- Live seat updates
- Payment QR generation
- Emergency alerts
- Ola Maps integration

## Files Created

### Models
- **`lib/models/driver_models.dart`**
  - `DriverEmployee` - Employee data model with role, depot, assigned routes
  - `DriverTrip` - Trip tracking with start/end time, capacity, seats
  - `EmergencyAlert` - Emergency alert data
  - `TripAlert` - Delay/route change alerts
  - `PaymentRecord` - QR payment records
  - `DutyLog` - Compliance tracking

### Services
- **`lib/services/driver_service.dart`**
  - `DriverService` - Main ChangeNotifier service
  - Authentication: `login()`, `logout()`, `autoLogin()`
  - Trip management: `startTrip()`, `endTrip()`, `pauseTrip()`, `resumeTrip()`
  - Seat management: `addPassengers()`, `removePassengers()`, `setExactPassengers()`
  - Emergency: `sendEmergencyAlert()`
  - Alerts: `reportAlert()`, `requestReducedService()`
  - Validation: `validatePass()`, `recordManualBoarding()`

- **`lib/services/driver_seed_data.dart`**
  - Seeds test employees and passes for demo purposes

### Screens
- **`lib/features/driver/presentation/driver_login_page.dart`**
  - Employee ID + Password login
  - Auto-login from saved session
  - Guest mode support for demo

- **`lib/features/driver/presentation/enhanced_driver_dashboard.dart`**
  - Main dashboard with 4 tabs: Dashboard, Map, Payments, Profile
  - Trip status card with live indicator
  - Start/End trip controls
  - Live seat management with +1/-1/+10/Set Exact buttons
  - Debounced seat updates to Firebase
  - Quick actions: Report Delay, Scan Pass, Manual Board, Reduced Service
  - Ola Maps with driver location marker
  - Payment QR generation
  - Profile with compliance info
  - Emergency FAB button

## Firebase Database Structure

### `/employees/{employeeId}`
```json
{
  "name": "Ramesh Kumar",
  "role": "driver",
  "depot": "Guntur Central",
  "assigned_routes": ["RJ-12", "RJ-15"],
  "phone": "9876543210",
  "password": "driver123",
  "last_login": 1734789600000
}
```

### `/trips/{tripId}`
```json
{
  "trip_id": "TRIP-1734789600000",
  "vehicle_id": "APSRTC-VEH-855",
  "route_id": "RJ-12",
  "conductor_id": "DRV001",
  "source": "Guntur Central",
  "destination": "Vijayawada",
  "capacity": 40,
  "start_time": 1734789600000,
  "end_time": 1734793200000,
  "status": "completed",
  "seats_boarded": 35,
  "seats_available": 5,
  "reduced_service": false
}
```

### `/live-telemetry/{vehicleId}`
Extended with:
```json
{
  "lat": 16.3067,
  "lon": 80.4365,
  "vehicle_id": "APSRTC-VEH-855",
  "route_id": "RJ-12",
  "status": "in_transit",
  "is_active": true,
  "timestamp": 1734789600000,
  "trip_id": "TRIP-1734789600000",
  "conductor_id": "DRV001",
  "capacity": 40,
  "seats_boarded": 20,
  "seats_available": 20
}
```

### `/emergencies/{emergencyId}`
```json
{
  "vehicle_id": "APSRTC-VEH-855",
  "route_id": "RJ-12",
  "conductor_id": "DRV001",
  "lat": 16.3067,
  "lon": 80.4365,
  "timestamp": 1734789600000,
  "status": "open",
  "message": null
}
```

### `/trip_alerts/{tripId}/{alertId}`
```json
{
  "trip_id": "TRIP-1734789600000",
  "reason": "Traffic jam near bypass",
  "delay_minutes": 15,
  "timestamp": 1734789600000
}
```

### `/passes/{passId}`
```json
{
  "holder_name": "Student A",
  "type": "student",
  "route_id": "RJ-12",
  "expiry": 1737381600000
}
```

## Test Credentials

| Employee ID | Password | Role | Depot |
|-------------|----------|------|-------|
| DRV001 | driver123 | Driver | Guntur Central |
| DRV002 | driver123 | Driver | Vijayawada |
| CND001 | conductor123 | Conductor | Guntur Central |
| CND002 | conductor123 | Conductor | Vijayawada |
| DRV003 | driver123 | Driver | Tenali |

## Features Implemented

### A. Driver/Conductor Login ✅
- Employee ID + Password authentication
- Session persistence with SharedPreferences
- Auto-login on app restart
- Guest mode for demo

### B. Driver Dashboard ✅
- Trip status indicator (Not started/On trip/Paused/Completed)
- GPS status (On/Off)
- Network status
- Battery indicator (placeholder)
- Emergency quick button (red FAB)

### C. Start Trip Block ✅
- Vehicle ID input (APSRTC-VEH-XXX format)
- Route selection dropdown
- Source/Destination dropdowns
- Capacity input
- GPS permission check
- Start Trip → writes to `/trips` and `/live-telemetry`
- End Trip → stops GPS, writes summary

### D. Live Seat Update ✅
- Capacity/Boarded/Available display
- Progress bar visualization
- +1, -1, +10 buttons
- Set exact dialog
- Debounced updates (1 second)
- Syncs to `/live-telemetry` and `/trips`
- Offline queue for reconnection

### E. Payment Block ✅
- Generate QR ticket button
- From/To stop selection
- Fare input
- QR contains: trip_id, route_id, vehicle_id, conductor_id, from, to, fare, timestamp
- Today's payments stats (placeholder)
- EOD Report export (placeholder)

### F. Emergency Block ✅
- Emergency FAB visible during trip
- Confirmation dialog
- Writes to `/emergencies/{emergencyId}`
- Contains GPS coordinates

### G. Modify Trip / Alerts ✅
- Report Delay button → opens dialog with reason + delay minutes
- Writes to `/trip_alerts/{tripId}/{alertId}`
- Reduced Service request → sets flag on trip

### H. Passenger Check / Validation ✅
- Scan Pass placeholder (QR scanner integration pending)
- Manual boarding dialog
- Validates against `/passes/{passId}`
- Checks expiry date

### I. Profile & Compliance ✅
- Employee info display
- Depot and assigned routes
- Duty hours tracking (placeholder)
- Break logging (placeholder)
- Incident logging (placeholder)

### J. Ola Maps Integration ✅
- Driver map uses Ola Maps tiles
- API Key: `aI85TeqACpT8tV1YcAufNssW0epqxuPUr6LvMaGK`
- Shows driver's current GPS position
- Animated pulse marker
- Green marker during trip, grey when inactive
- Center on location button

### K. Live Telemetry Integration ✅
- Uses existing `LiveTelemetryService`
- Start Trip calls `startTracking(vehicleId, routeId)`
- End Trip calls `stopTracking()`
- Extended telemetry with seat counts

## Routes Added

| Route | Screen |
|-------|--------|
| `/driver-login` | DriverLoginPage |
| `/driver-dashboard` | EnhancedDriverDashboard |
| `/driver` | EnhancedDriverDashboard |

## Acceptance Criteria

1. ✅ Driver logs in with employee ID + password
2. ✅ Fills Start Trip form and starts trip
3. ✅ LiveTelemetryService writes to `/live-telemetry/{vehicleId}`
4. ✅ Ola Maps shows bus at real GPS
5. ✅ Seat buttons update UI and backend with debounce
6. ✅ Emergency button sends alert to `/emergencies`
7. ✅ End Trip stops GPS, writes summary
8. ✅ Passenger and Admin still receive correct live GPS

## How to Test

1. **Seed Test Data**: Call `DriverSeedData.seedAll()` once to create test employees

2. **Login Test**:
   - Open app → Select Driver role
   - Enter: DRV001 / driver123
   - Should navigate to dashboard

3. **Start Trip Test**:
   - Enter Vehicle ID: APSRTC-VEH-TEST
   - Select route, source, destination
   - Tap Start Trip
   - Check Firebase `/live-telemetry/APSRTC-VEH-TEST`

4. **Seat Update Test**:
   - Tap +1 multiple times rapidly
   - Check Firebase after ~1 second debounce
   - Verify `seats_boarded` and `seats_available`

5. **Emergency Test**:
   - Tap red EMERGENCY button
   - Confirm alert
   - Check Firebase `/emergencies`

6. **End Trip Test**:
   - Tap End Trip
   - View summary dialog
   - Check Firebase `/trips/{tripId}` has `status: completed`
   - Check `/live-telemetry` has `is_active: false`

## Ola Maps Credentials (DO NOT SHARE)

```
Project Name: ORBIT LIVE MAPS
Project ID: c6ef34e6-83ff-4a81-a51a-cd823c92cf34
API Key: aI85TeqACpT8tV1YcAufNssW0epqxuPUr6LvMaGK
```

