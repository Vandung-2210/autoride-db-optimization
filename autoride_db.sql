-- ============================================================
-- HỆ THỐNG AUTORIDE - CƠ SỞ DỮ LIỆU TỐI ƯU HÓA
-- ============================================================

CREATE DATABASE IF NOT EXISTS autoride_db;
USE autoride_db;

DROP TABLE IF EXISTS Inspections;
DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS Cars;

-- 1. Bảng Xe (Cars)
CREATE TABLE Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

-- 2. Bảng Hợp đồng thuê xe (Rentals)
CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME NULL,
    
    -- Khóa chặt vòng đời hợp đồng bằng ENUM
    status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'BOOKED',
    
    -- Kiểu DECIMAL bảo đảm tính chính xác tuyệt đối trong kế toán
    security_deposit DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    late_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    damage_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    
    FOREIGN KEY (car_id) REFERENCES Cars(car_id) ON DELETE RESTRICT
);

-- 3. Bảng Biên bản kiểm tra xe (Inspections)
CREATE TABLE Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT NULL,
    inspector_name VARCHAR(100) NOT NULL,
    
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id) ON DELETE RESTRICT
);

-- ============================================================
-- KỊCH BẢN MÔ PHỎNG DỮ LIỆU (DML TESTING)
-- ============================================================

-- Khởi tạo danh mục xe
INSERT INTO Cars (model_name, license_plate) VALUES 
('Toyota Vios 2024', '30A-999.88'),
('Mazda CX-5 2023', '29B-123.45');

-- Kịch bản: Khách "Nguyen Van A" thuê xe, cọc 10.000.000đ, trạng thái ACTIVE
INSERT INTO Rentals (car_id, customer_name, rent_date, status, security_deposit)
VALUES (1, 'Nguyen Van A', '2026-10-20 08:00:00', 'ACTIVE', 10000000.00);

-- Khách trả xe: Nhân viên lập biên bản phát hiện vỡ đèn pha
INSERT INTO Inspections (rental_id, inspection_date, damage_description, inspector_name)
VALUES (1, '2026-10-21 18:00:00', 'Vỡ đèn pha bên trái, xước cản trước', 'Tran Kiem Dinh');

-- Cập nhật hợp đồng: Hoàn tất, phạt hỏng hóc 2.000.000đ, không trễ giờ
UPDATE Rentals
SET status = 'COMPLETED',
    return_date = '2026-10-21 18:00:00',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = 1;

-- Lệnh SELECT tính toán số tiền thực tế hoàn trả cho khách (Refund Amount)
SELECT 
    r.rental_id,
    r.customer_name,
    c.model_name,
    c.license_plate,
    r.status,
    r.security_deposit,
    r.late_fee,
    r.damage_fee,
    (r.security_deposit - r.late_fee - r.damage_fee) AS refund_amount,
    i.damage_description,
    i.inspector_name
FROM Rentals r
JOIN Cars c ON r.car_id = c.car_id
LEFT JOIN Inspections i ON r.rental_id = i.rental_id
WHERE r.rental_id = 1;
