

-- TABEL ROLE
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nama_role VARCHAR(50) NOT NULL
);

-- TABEL USERS
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    role_id INT REFERENCES roles(id),
    nama VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABEL FASILITAS
CREATE TABLE fasilitas (
    id SERIAL PRIMARY KEY,
    nama_fasilitas VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    harga DECIMAL(12,2) NOT NULL,
    stok INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'tersedia',   -- tersedia / disewa
    foto VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1. HAPUS KEDUA TABEL (Agar bersih)
DROP TABLE IF EXISTS pembayarans CASCADE;
DROP TABLE IF EXISTS reservasis CASCADE;

-- 2. BUAT ULANG TABEL RESERVASI (Dengan kolom Jam)
CREATE TABLE reservasis (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    fasilitas_id INT REFERENCES fasilitas(id),
    tanggal_sewa DATE NOT NULL,
    jam_mulai TIME NOT NULL,                 -- Kolom Baru
    durasi INT NOT NULL,
    total_harga DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. BUAT ULANG TABEL PEMBAYARAN (Agar relasi nyambung lagi)
CREATE TABLE pembayarans (
    id SERIAL PRIMARY KEY,
    -- Di sini relasi dibuat kembali
    reservasi_id INT UNIQUE REFERENCES reservasis(id) ON DELETE CASCADE, 
    bukti VARCHAR(255),
    status VARCHAR(20) DEFAULT 'menunggu',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABEL ULASAN
CREATE TABLE ulasan (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    fasilitas_id INT REFERENCES fasilitas(id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    komentar TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- BUAT TABEL NOTIFIKASI
CREATE TABLE notifikasis (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE, 
    reservasi_id INT REFERENCES reservasis(id) ON DELETE CASCADE, 
    judul VARCHAR(255) NOT NULL,
    pesan TEXT NOT NULL,
    tipe VARCHAR(50) DEFAULT 'info', -- promo, transaksi, info
    is_read BOOLEAN DEFAULT FALSE,   -- status sudah dibaca/belum
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from users;
select * from fasilitas;
select * from roles;
select * from reservasis;
select * from ulasan;
select * from pembayarans;
select * from notifikasis;


UPDATE users 
SET role_id = 1 
WHERE email = 'admin@bulbul.com';

INSERT INTO notifikasis (judul, pesan, tipe, user_id, created_at, updated_at) 
VALUES 
('Tes Manual', 'Ini adalah notifikasi percobaan dari database.', 'info', NULL, NOW(), NOW()),
('Promo Gila-gilaan', 'Diskon 90% khusus hari ini!', 'promo', NULL, NOW(), NOW());

-- Pastikan id user (misal 2) dan id fasilitas (misal 1) SUDAH ADA di tabel users dan fasilitas.
-- Jika error, cek dulu id berapa yang ada di tabel users dan fasilitas.

INSERT INTO ulasan (user_id, fasilitas_id, rating, komentar, created_at, updated_at)
VALUES 
(2, 1, 5, 'Tempatnya sangat nyaman dan bersih, sangat recommended!', NOW(), NOW()),
(2, 1, 4, 'Pelayanan ramah, fasilitas oke punya.', NOW(), NOW());

INSERT INTO fasilitas (id, nama_fasilitas, deskripsi, harga, stok, status, created_at, updated_at)
VALUES 
(1, 'Pondok VIP Contoh', 'Pondok percobaan untuk tes ulasan', 150000, 5, 'tersedia', NOW(), NOW());

SELECT * FROM users WHERE email = 'admin@bulbul.com';
UPDATE users SET role_id = 1 WHERE email = 'admin@bulbul.com';

DELETE FROM users WHERE email = 'eben@example.com';
DELETE FROM users WHERE email = 'admin@gmail.com';

DELETE FROM reservasis WHERE id = 2;

DELETE FROM fasilitas WHERE id = 2;
DELETE FROM notifikasis WHERE id = 1;

INSERT INTO roles (id, nama_role) VALUES (1, 'admin');
INSERT INTO roles (id, nama_role) VALUES (2, 'user');


ALTER TABLE fasilitas ADD COLUMN is_promo BOOLEAN DEFAULT FALSE;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

show tables;

ALTER TABLE reservasis
ADD COLUMN jam_mulai TIME DEFAULT '08:00:00';