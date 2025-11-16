# Fulminant Cloud Functions

Server-side Firebase Cloud Functions for secure points management.

## Security Features

- **Server-side points validation**: Points are calculated on the server, not the client
- **Duplicate completion prevention**: Checks if module/activity already completed
- **Authentication required**: All functions require authenticated users
- **Atomic operations**: Uses batch writes for data consistency

## Functions

### `completeModule(courseId, moduleId)`
Awards points for completing a module. Points value is fetched from Firestore (server-side), preventing client manipulation.

### `completeActivity(courseId, moduleId, activityId, answer?)`
Awards points for completing an activity. Validates activity exists and fetches server-side point values.

## Setup

1. Install dependencies:
```bash
cd functions
npm install
```

2. Deploy to Firebase:
```bash
npm run deploy
```

## Local Development

Run functions locally with emulator:
```bash
npm run serve
```

## Usage from Client

Update `course_repository.dart` to call these Cloud Functions instead of directly updating Firestore:

```dart
final callable = FirebaseFunctions.instance.httpsCallable('completeModule');
final result = await callable.call({
  'courseId': courseId,
  'moduleId': moduleId,
});
```

## Security Notes

- Client can no longer manipulate points values
- All point calculations happen server-side
- Server validates completion status
- Future: Add answer validation for quizzes
