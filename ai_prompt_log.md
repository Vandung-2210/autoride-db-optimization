# Nhật Ký Tương Tác AI (AI Prompt Log) - Tối Ưu Hóa Hệ Thống AutoRide

### Prompt 1: Chọn kiểu dữ liệu cho tiền cọc và phí phạt
- **Prompt:** "Khi lưu trữ security_deposit, late_fee và damage_fee trong MySQL, tại sao kiểu FLOAT/DOUBLE lại gây nguy cơ thất thoát tài chính và DECIMAL(12,2) giải quyết vấn đề này như thế nào?"
- **Thu hoạch:** FLOAT/DOUBLE dùng chuẩn biểu diễn nhị phân dấu phẩy động (IEEE 754), gây sai số làm tròn khi thực hiện các phép trừ tài chính đối soát hoàn tiền. DECIMAL lưu dạng chuỗi số cố định (fixed-point), đảm bảo độ chính xác tuyệt đối đến từng đồng.

### Prompt 2: Thiết kế quan hệ bảng Inspections
- **Prompt:** "Nên thiết kế bảng Inspections theo quan hệ 1-1 hay 1-N với bảng Rentals? Ưu và nhược điểm của việc tách bảng thay vì thêm cột trực tiếp vào Rentals?"
- **Thu hoạch:** Tách bảng `Inspections` tuân thủ nguyên tắc chuẩn hóa dữ liệu 3NF, cho phép lưu vết nhiều lần kiểm tra (lúc nhận xe và lúc trả xe) mà không gây dư thừa cột NULL trong bảng Rentals khi khách trả xe không bị hư hỏng.

### Prompt 3: Đảm bảo toàn vẹn nghiệp vụ qua Database Triggers
- **Prompt:** "Làm thế nào để chặn câu lệnh INSERT vào bảng Inspections nếu hợp đồng thuê xe đang ở trạng thái 'BOOKED' ngay tại tầng Database?"
- **Thu hoạch:** Áp dụng `BEFORE INSERT TRIGGER` trên bảng `Inspections` để kiểm tra trạng thái tương ứng trong `Rentals`. Nếu `status = 'BOOKED'`, trigger gọi `SIGNAL SQLSTATE '45000'` phát lỗi nghiệp vụ, bảo vệ hệ thống không bị phụ thuộc hoàn toàn vào tầng ứng dụng Backend.
