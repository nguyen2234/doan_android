-- ================================================================
-- CSDL Quản lý Tài chính Cá nhân
-- File: quan_ly_tai_chinh.sql
-- Mô tả: Định nghĩa toàn bộ cấu trúc bảng của ứng dụng
--        (không có dữ liệu mẫu)
-- ================================================================

-- ────────────────────────────────────────────────────────────────
-- Bảng: nguoi_dung  (Người dùng)
-- Lưu thông tin tài khoản đăng nhập
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS nguoi_dung (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ten             TEXT    NOT NULL,                  -- Họ và tên
    email           TEXT    NOT NULL UNIQUE,           -- Email đăng nhập (duy nhất)
    mat_khau        TEXT    NOT NULL,                  -- Mật khẩu
    anh_dai_dien    TEXT,                              -- Đường dẫn ảnh đại diện
    ngay_tao        TEXT                               -- Ngày tạo tài khoản (ISO 8601)
);

-- ────────────────────────────────────────────────────────────────
-- Bảng: danh_muc  (Danh mục thu/chi)
-- Phân loại các khoản thu nhập và chi tiêu
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS danh_muc (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    ten         TEXT    NOT NULL,                      -- Tên danh mục (vd: Ăn uống, Lương)
    loai        TEXT    CHECK(loai IN ('thu', 'chi')), -- Loại: thu hoặc chi
    bieu_tuong  TEXT,                                  -- Tên icon (vd: restaurant)
    mau_sac     TEXT                                   -- Mã màu hex (vd: #FF5722)
);

-- ────────────────────────────────────────────────────────────────
-- Bảng: vi_tien  (Ví tiền)
-- Quản lý các nguồn tiền (tiền mặt, ngân hàng, v.v.)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vi_tien (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    ten      TEXT    NOT NULL,                         -- Tên ví (vd: Tiền mặt, VCB)
    so_du    REAL    DEFAULT 0,                        -- Số dư hiện tại
    ngay_tao TEXT                                      -- Ngày tạo ví (ISO 8601)
);

-- ────────────────────────────────────────────────────────────────
-- Bảng: giao_dich  (Giao dịch tài chính)
-- Ghi lại từng khoản thu / chi
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS giao_dich (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    so_tien     REAL    NOT NULL,                              -- Số tiền giao dịch
    loai        TEXT    CHECK(loai IN ('thu', 'chi')),         -- Thu hoặc chi
    ma_danh_muc INTEGER,                                       -- Khóa ngoại → danh_muc.id
    ma_vi       INTEGER,                                       -- Khóa ngoại → vi_tien.id
    ghi_chu     TEXT,                                          -- Ghi chú tùy chọn
    ngay        TEXT,                                          -- Ngày giao dịch (ISO 8601)
    ngay_tao    TEXT,                                          -- Ngày tạo bản ghi (ISO 8601)
    FOREIGN KEY (ma_danh_muc) REFERENCES danh_muc(id),
    FOREIGN KEY (ma_vi)       REFERENCES vi_tien(id)
);

-- ────────────────────────────────────────────────────────────────
-- Bảng: ngan_sach  (Ngân sách)
-- Đặt hạn mức chi tiêu theo danh mục và khoảng thời gian
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ngan_sach (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ma_danh_muc     INTEGER,                           -- Khóa ngoại → danh_muc.id
    so_tien         REAL,                              -- Hạn mức ngân sách
    ngay_bat_dau    TEXT,                              -- Ngày bắt đầu (ISO 8601)
    ngay_ket_thuc   TEXT,                              -- Ngày kết thúc (ISO 8601)
    FOREIGN KEY (ma_danh_muc) REFERENCES danh_muc(id)
);

-- ────────────────────────────────────────────────────────────────
-- Bảng: thong_bao  (Thông báo nhắc nhở)
-- Lưu các thông báo định kỳ hoặc cảnh báo ngân sách
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS thong_bao (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    tieu_de   TEXT,                                    -- Tiêu đề thông báo
    noi_dung  TEXT,                                    -- Nội dung chi tiết
    thoi_gian TEXT,                                    -- Thời gian nhắc (ISO 8601)
    lap_lai   INTEGER DEFAULT 0                        -- 0 = không lặp, 1 = lặp lại
);
