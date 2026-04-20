const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');
const { faker } = require('@faker-js/faker');
const serviceAccount = require('./service-account.json');

// Khởi tạo Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const targetUserId = '2Qai7V4MqBP4SESLy5hjYqSnyu72'; // UID của bạn

/**
 * Xóa toàn bộ document trong một collection
 */
async function wipeCollection(collectionName) {
  const snapshot = await db.collection(collectionName).get();
  if (snapshot.empty) {
    console.log(`Collection ${collectionName} is already empty.`);
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();
  console.log(`Wiped collection: ${collectionName}`);
}

/**
 * Script chính xử lý Seeding
 */
async function seed() {
  try {
    console.log('--- Bắt đầu quá trình Seeding dữ liệu ---');

    // 1. Dọn dẹp dữ liệu cũ (Dự án, Chat, Group)
    console.log('Đang dọn dẹp dữ liệu cũ...');
    await wipeCollection('chats');
    await wipeCollection('groups');
    await wipeCollection('projects');
    
    // Dọn dẹp người dùng mẫu cũ (giữ lại tài khoản chính của bạn)
    const userSnapshot = await db.collection('users').get();
    const userBatch = db.batch();
    let deletedUsersCount = 0;
    userSnapshot.docs.forEach(doc => {
      if (doc.id.startsWith('dummy_')) {
        userBatch.delete(doc.ref);
        deletedUsersCount++;
      }
    });
    if (deletedUsersCount > 0) {
      await userBatch.commit();
      console.log(`Đã xóa ${deletedUsersCount} người dùng mẫu cũ.`);
    }

    // 2. Tạo Người dùng mẫu mới (Dummy Users)
    console.log('Đang tạo người dùng mẫu mới...');
    const dummyUsers = [];
    for (let i = 0; i < 8; i++) {
      const uid = `dummy_${uuidv4().substring(0, 8)}`;
      const displayName = faker.person.fullName();
      const user = {
        uid,
        email: faker.internet.email().toLowerCase(),
        displayName: displayName,
        photoURL: `https://i.pravatar.cc/150?u=${uid}`,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        plan: 'free'
      };
      await db.collection('users').doc(uid).set(user);
      dummyUsers.push(user);
    }
    console.log(`Đã tạo ${dummyUsers.length} người dùng mẫu.`);

    // 3. Tạo Dự án (Projects)
    console.log('Đang tạo dự án mẫu...');
    const statuses = ['ongoing', 'completed', 'on-hold'];
    const tags = ['coding', 'design', 'marketing', 'research', 'fix', 'ui', 'backend', 'mobile'];
    const colors = ['#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50'];
    
    for (let i = 0; i < 12; i++) {
      const id = uuidv4();
      const project = {
        id,
        title: faker.company.catchPhrase(),
        description: faker.lorem.sentences(2),
        ownerId: targetUserId,
        memberIds: [targetUserId, ...faker.helpers.arrayElements(dummyUsers.map(u => u.uid), 2)],
        status: faker.helpers.arrayElement(statuses),
        progress: parseFloat(Math.random().toFixed(2)),
        dueDate: admin.firestore.Timestamp.fromDate(faker.date.future()),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        color: faker.helpers.arrayElement(colors),
        tags: faker.helpers.arrayElements(tags, 3)
      };
      await db.collection('projects').doc(id).set(project);
    }
    console.log('Đã tạo 12 dự án mẫu.');

    // 4. Tạo Chat 1-1
    console.log('Đang tạo các cuộc hội thoại 1-1...');
    for (const otherUser of dummyUsers) {
      const ids = [targetUserId, otherUser.uid].sort();
      const chatId = `${ids[0]}_${ids[1]}`;
      const chatRef = db.collection('chats').doc(chatId);
      
      const lastMsgText = 'Chào bạn, mình vừa gửi tài liệu cập nhật cho dự án mới.';
      await chatRef.set({
        participantIds: [targetUserId, otherUser.uid],
        lastMessage: lastMsgText,
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        unreadCount: {}
      });

      // Thêm 15 tin nhắn cho mỗi chat
      for (let i = 0; i < 15; i++) {
        const isMe = i % 2 === 0;
        await chatRef.collection('messages').add({
          senderId: isMe ? targetUserId : otherUser.uid,
          text: i === 14 ? lastMsgText : faker.lorem.sentence(),
          sentAt: admin.firestore.Timestamp.fromDate(faker.date.recent({ days: 7 })),
          readBy: [isMe ? targetUserId : otherUser.uid],
          type: 'text'
        });
      }
    }
    console.log(`Đã tạo ${dummyUsers.length} cuộc hội thoại 1-1.`);

    // 5. Tạo Group Chats
    console.log('Đang tạo các Group Chat...');
    const groupNames = ['Đội ngũ WorkNest Core', 'Dự án Alpha Feedback', 'Phòng Sales Marketing', 'Hội Quản lý Dự án'];
    for (let i = 0; i < groupNames.length; i++) {
      const id = uuidv4();
      const groupRef = db.collection('groups').doc(id);
      const members = [targetUserId, ...dummyUsers.map(u => u.uid)];
      
      const lastMsgText = 'Mọi người đã nhận được thông báo về buổi meeting sáng mai chưa?';
      await groupRef.set({
        id,
        name: groupNames[i],
        description: faker.company.buzzPhrase(),
        photoURL: `https://ui-avatars.com/api/?name=${encodeURIComponent(groupNames[i])}&background=random`,
        adminIds: [targetUserId],
        memberIds: members,
        lastMessage: lastMsgText,
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        unreadCount: {}
      });

      // Thêm 25 tin nhắn cho mỗi group
      for (let j = 0; j < 25; j++) {
        const senderId = faker.helpers.arrayElement(members);
        await groupRef.collection('messages').add({
          senderId,
          text: j === 24 ? lastMsgText : faker.lorem.sentence(),
          sentAt: admin.firestore.Timestamp.fromDate(faker.date.recent({ days: 5 })),
          readBy: [senderId],
          type: 'text'
        });
      }
    }
    console.log(`Đã tạo ${groupNames.length} Group Chat.`);

    console.log('--- Hoàn tất Seeding thành công! ---');
    console.log('Bây giờ bạn có thể mở ứng dụng Flutter để kiểm tra dữ liệu.');
  } catch (error) {
    console.error('Lỗi trong quá trình Seeding:', error);
  } finally {
    process.exit();
  }
}

seed();
