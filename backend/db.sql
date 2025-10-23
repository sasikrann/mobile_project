CREATE DATABASE IF NOT EXISTS room_booking;
USE room_booking;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('student','staff','lecturer') NOT NULL DEFAULT 'student'
);

INSERT INTO users (name, username, password, role) VALUES
('john','student', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'student'),
('harry','staff', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'staff'),
('peter','lecturer', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'lecturer');

CREATE TABLE rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  status ENUM('active', 'disabled') DEFAULT 'active'
);

INSERT INTO rooms (name, description) VALUES
('Room 1', 'Room 1'),
('Room 2', 'Room 2'),
('Room 3', 'Room 3'),
('Room 4', 'Room 4'),
('Room 5', 'Room 5'),
('Room 6', 'Room 6');

CREATE TABLE bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,               
  room_id INT NOT NULL,              
  approver_id INT DEFAULT NULL,       
  date DATE NOT NULL,                  
  time_slot ENUM('8-10','10-12','13-15','15-17') NOT NULL,
  reason VARCHAR(255),
  status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO bookings (
    user_id, room_id, approver_id, date, time_slot, reason, status) VALUES
(1, 1, NULL, CURDATE(), '8-10', 'Group study for final', 'Pending');

DELIMITER $$

CREATE TRIGGER limit_one_booking_per_day
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
  DECLARE booking_count INT;
  SELECT COUNT(*) INTO booking_count
  FROM bookings
  WHERE user_id = NEW.user_id
  AND date = CURDATE()
  AND status IN ('Pending','Approved');

  IF booking_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'You can book only one slot per day!';
  END IF;
END$$

DELIMITER ;