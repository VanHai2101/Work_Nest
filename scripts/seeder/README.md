# WorkNest Firebase Seeder

Script này giúp bạn nạp dữ liệu thực tế (Dự án, Chat 1-1, Group Chat) vào Firebase cực kỳ nhanh chóng.

## 🚀 Hướng dẫn thực hiện

### 1. Chuẩn bị tệp Quyền truy cập (Service Account)
- Truy cập [Firebase Console](https://console.firebase.google.com/).
- Chọn dự án **WorkNest**.
- Vào **Project settings** > **Service accounts**.
- Bấm **Generate new private key** để tải tệp `.json` về.
- **Quan trọng**: Đổi tên tệp vừa tải thành `service-account.json` và copy vào thư mục này (`scripts/seeder/`).

### 2. Chạy Script
Mở terminal tại thư mục này và chạy lệnh:
```bash
node index.js
```

## 🛠️ Script này làm gì?
1. **Dọn dẹp**: Xoá sạch các dữ liệu cũ trong `chats`, `groups`, `projects` (đã được bạn đồng ý).
2. **Người dùng mẫu**: Tạo 8 người dùng "ảo" với tên và ảnh đại diện chuyên nghiệp.
3. **Dự án**: Tạo 12 dự án với đầy đủ thông tin (owner là bạn).
4. **Chat 1-1**: Tạo hội thoại giữa bạn và 8 người dùng mới, mỗi bên gửi khoảng 15 tin nhắn.
5. **Group Chat**: Tạo 4 nhóm làm việc, thêm bạn vào và tạo 25 tin nhắn thảo luận mỗi nhóm.

---
*Lưu ý: Dữ liệu này được ghi trực tiếp lên Firebase nên bạn sẽ thấy kết quả ngay trên app Flutter.*
