-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 11, 2025 at 08:29 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `room_booking`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `approver_id` int(11) DEFAULT NULL,
  `booking_date` date NOT NULL,
  `time_slot` enum('8-10','10-12','13-15','15-17') NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected','Cancelled') DEFAULT 'Pending',
  `reject_reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `user_id`, `room_id`, `approver_id`, `booking_date`, `time_slot`, `reason`, `status`, `reject_reason`, `created_at`) VALUES
(1, 1, 1, NULL, '2025-11-10', '8-10', 'Group study for final', 'Cancelled', 'No approval before date passed', '2025-11-10 16:55:36'),
(2, 1, 3, 3, '2025-11-10', '10-12', 'Presentation practice', 'Rejected', 'Room maintenance', '2025-11-10 16:55:36'),
(4, 1, 1, 4, '2025-11-11', '15-17', NULL, 'Approved', 'No approval before time passed', '2025-11-10 19:51:00'),
(7, 2, 1, 4, '2025-11-11', '13-15', NULL, 'Approved', NULL, '2025-11-11 07:00:52'),
(8, 3, 1, 4, '2025-11-11', '10-12', NULL, 'Approved', NULL, '2025-11-11 07:16:41'),
(9, 4, 1, 4, '2025-11-11', '8-10', NULL, 'Approved', NULL, '2025-11-11 07:17:16');

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `capacity` int(11) NOT NULL DEFAULT 4,
  `status` enum('available','disabled') DEFAULT 'available',
  `image` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`id`, `name`, `description`, `capacity`, `status`, `image`) VALUES
(1, 'Room 1', '7\nRoom for entertainment', 7, 'available', 'http://192.168.1.108:3000/uploads/1762849397632.png'),
(2, 'Room 2', 'This is room', 9, 'available', 'http://192.168.1.108:3000/uploads/1762849418577.jpg'),
(3, 'Room 3', 'Room for mobile app', 3, 'available', 'http://192.168.1.108:3000/uploads/1762849428926.png'),
(4, 'Room 4', 'For reading only', 5, 'available', 'http://192.168.1.108:3000/uploads/1762849439820.jpg'),
(5, 'Room 5', 'For study', 3, 'available', 'http://192.168.1.108:3000/uploads/1762849457552.png'),
(6, 'Room 6', 'description wow', 6, 'available', 'http://192.168.1.108:3000/uploads/1762849467692.png'),
(7, 'R 7', '7', 4, 'disabled', ''),
(15, 'R 2', '', 4, 'disabled', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('student','staff','lecturer') NOT NULL DEFAULT 'student'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `username`, `password`, `role`) VALUES
(1, 'Jason', 'student1', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'student'),
(2, 'John', 'student2', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'student'),
(3, 'Harry', 'staff', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'staff'),
(4, 'Peter', 'lecturer', '$2a$12$xEz3r391X.cKQJRBnmGxhewPevvlGBrBYcLDF0F9xGyn8pTvrDtkq', 'lecturer');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `room_id` (`room_id`),
  ADD KEY `approver_id` (`approver_id`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
