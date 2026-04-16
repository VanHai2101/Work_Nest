# WorkNest - Complete Setup Guide

## ✅ Hoàn thiện (Completed)

### 1. **Firestore Rules** (`firestore.rules`)
- ✅ Fixed formatting issues
- ✅ Blocked client from creating notifications (only Cloud Functions)
- ✅ Added proper ICE candidate validation
- ✅ Complete security rules for all collections

### 2. **Data Models** (`lib/core/domain/models/`)
- ✅ `message_model.dart` - Chat & Group messages
- ✅ `chat_model.dart` - 1-1 Chat metadata
- ✅ `group_model.dart` - Group Chat data
- ✅ `call_model.dart` - Video/Audio calls + ICE candidates
- ✅ `notification_model.dart` - In-app notifications

### 3. **Firestore Repositories** (`lib/core/data/repositories/`)
- ✅ `chat_repository.dart` - 1-1 chat operations
- ✅ `group_repository.dart` - Group chat operations
- ✅ `call_repository.dart` - Call signaling
- ✅ `notification_repository.dart` - Notification management

### 4. **Riverpod Providers** (`lib/core/providers/firestore_providers.dart`)
- ✅ Chat streams & messages
- ✅ Group streams & messages
- ✅ Call providers
- ✅ Notification providers
- ✅ Send message providers

### 5. **Chat UI** (`lib/features/chat/presentation/screens/`)
- ✅ `chats_list_screen.dart` - List of 1-1 chats
- ✅ `chat_screen.dart` - Active chat with message input
- ✅ `groups_list_screen.dart` - List of groups
- ✅ `group_chat_screen.dart` - Active group chat

### 6. **Notifications UI** (`lib/features/notifications/presentation/screens/`)
- ✅ `notifications_screen.dart` - Full notification system
  - Color-coded by type
  - Unread indicator
  - Time formatting (now, 1m, 5h, 2d)
  - Mark as read
  - Delete functionality

### 7. **Video Call UI** (`lib/features/calls/presentation/screens/`)
- ✅ `call_screen.dart` - Active call with controls
- ✅ `incoming_call_screen.dart` - Incoming call overlay

### 8. **Cloud Functions** (`functions/index.js`)
- ✅ Notifications on task assignment
- ✅ Notifications on messages (1-1 & group)
- ✅ Notifications on incoming calls
- ✅ Plan upgrade handler
- ✅ Plan expiration check (daily)
- ✅ Member limit validation
- ✅ Cleanup old notifications
- ✅ Cleanup old call records

---

## 🚀 Installation & Setup

### Step 1: Install Dependencies
```bash
cd /path/to/work_nest
flutter pub get
cd functions
npm install
```

### Step 2: Update pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  cloud_firestore: ^latest
  firebase_auth: ^latest
  flutter_riverpod: ^latest
  riverpod_generator: ^latest
  build_runner: ^latest
  flutter_webrtc: ^latest  # For video calls (optional)

dev_dependencies:
  build_runner: ^latest
  riverpod_generator: ^latest
```

### Step 3: Setup Firebase Cloud Functions
```bash
cd functions
npm install firebase-functions firebase-admin
firebase deploy --only functions
```

### Step 4: Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

---

## 📱 Integration Examples

### Send a Chat Message
```dart
// In your widget
ref.read(sendMessageProvider((chatId, messageText)).future);
```

### Listen to Chat Messages
```dart
final messages = ref.watch(messagesProvider(chatId));

messages.when(
  data: (msgs) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### Create a Call
```dart
final call = await ref.read(callRepositoryProvider).createCall(
  callerUid: currentUser.uid,
  calleeUid: recipientId,
  type: CallType.video,
);
```

### Get Notifications
```dart
final notifications = ref.watch(userNotificationsProvider);
final unreadCount = ref.watch(unreadNotificationCountProvider);
```

---

## 🔐 Security Features

### Firestore Rules Protection
- ✅ Users can only read their own data & other users' names/avatars
- ✅ Chat participants can only access their conversations
- ✅ Group members can only access group messages
- ✅ Plan restrictions enforced (Pro, Business limits)
- ✅ Member count limits by plan
- ✅ Notifications only created by Cloud Functions
- ✅ No client-side plan modification

### Plan Limits
- **Free**: 3 members per project, no groups
- **Pro**: 10 members per project, groups up to 20 people
- **Business**: Unlimited members & groups

---

## 🛠️ Next Steps to Complete

### 1. **WebRTC Integration**
If using video/audio calls, integrate `flutter_webrtc`:
- Connect local/remote streams
- Handle ICE candidates from Firestore
- Implement SDP offer/answer exchange

### 2. **Push Notifications**
Add FCM (Firebase Cloud Messaging):
- Send notifications to users
- Update notification badges
- Handle notification taps

### 3. **File Uploads**
Implement file sharing:
- Add to Firestore storage
- Update message model with attachments
- Add file picker to UI

### 4. **User Profile UI**
Create user profile screens:
- Edit display name, photo
- Plan/subscription management
- Device settings

### 5. **Internationalization**
Already have `l10n.yaml`:
- Translate chat, notifications, calls
- Add language switching

---

## 📊 Firestore Structure

```
users/
  {userId}/
    settings/
      {settingId}

chats/
  {chatId}/
    messages/
      {messageId}

groups/
  {groupId}/
    messages/
      {messageId}

calls/
  {callId}/
    callerCandidates/
      {candidateId}
    calleeCandidates/
      {candidateId}

notifications/
  {notificationId}

subscriptions/
  {subscriptionId}

projects/
  {projectId}/
    tasks/
      {taskId}
```

---

## 🐛 Troubleshooting

### Messages not appearing?
- Check Firestore Rules are deployed
- Verify user is authenticated
- Check chat permissions in rules

### Notifications not received?
- Cloud Functions must be deployed
- Check Cloud Functions logs
- Verify notification structure matches model

### Calls not connecting?
- Ensure call document exists in Firestore
- Check ICE candidates are being saved
- Verify WebRTC permissions on mobile

---

## 📚 Files Reference

| File | Purpose |
|------|---------|
| `firestore.rules` | Security rules for all collections |
| `lib/core/domain/models/*` | Data models for Firestore documents |
| `lib/core/data/repositories/*` | Firestore CRUD operations |
| `lib/core/providers/firestore_providers.dart` | Riverpod state management |
| `lib/features/chat/presentation/screens/*` | Chat UI screens |
| `lib/features/notifications/presentation/screens/*` | Notification UI |
| `lib/features/calls/presentation/screens/*` | Call UI screens |
| `functions/index.js` | Backend logic (Cloud Functions) |

---

## 💡 Tips

1. **Always use Riverpod providers** - Don't call repositories directly
2. **Handle async states properly** - Use `.when()` for AsyncValue
3. **Test rules in Firebase Console** - Before deploying to production
4. **Monitor Cloud Functions logs** - For debugging notification issues
5. **Use batch operations** - For multiple writes (better performance)

---

Created: 2026-04-15
