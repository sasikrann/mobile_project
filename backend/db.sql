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
('Jason','student1', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'student'),
('John','student2', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'student'),
('Harry','staff', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'staff'),
('Peter','lecturer', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'lecturer');

CREATE TABLE rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  capacity INT DEFAULT 4 NOT NULL,
  status ENUM('open', 'closed') DEFAULT 'open'
  image VARBINARY(MAX) DEFAULT NULL,
);

INSERT INTO rooms (name, description, capacity) VALUES
('Room 1', 'Room for entertainment', 6),
('Room 2', 'This is room', 8),
('Room 3', 'Room for mobile app', 3),
('Room 4', 'For reading only', 5),
('Room 5', 'For study', 3),
('Room 6', 'description wow', 6);

CREATE TABLE bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,               
  room_id INT NOT NULL,              
  approver_id INT DEFAULT NULL,       
  booking_date DATE NOT NULL,                  
  time_slot ENUM('8-10','10-12','13-15','15-17') NOT NULL,
  reason VARCHAR(255),
  status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO bookings (
  user_id, room_id, approver_id, booking_date, time_slot, reason, status) VALUES
(1, 1, NULL, CURDATE(), '8-10', 'Group study for final', 'Pending');