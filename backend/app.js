const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const db = require('./db');
const app = express();
const port = 3000;
const path = require('path');
const fs = require('fs');
const multer = require('multer');

//---------------Middleware-------------------------------/
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // serve uploaded images
const JWT_SECRET = 'super_secret_key_change_this';

//------------------ Login + Register ---------------------------/
app.post('/api/register', async (req, res) => {
  const { name, username, password } = req.body;

  if (!name || !username || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  const checkSql = 'SELECT * FROM users WHERE username = ?';
  db.query(checkSql, [username], async (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    if (result.length > 0)
      return res.status(400).json({ message: 'Username already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const insertSql = 'INSERT INTO users (name, username, password, role) VALUES (?, ?, ?, "student")';
    db.query(insertSql, [name, username, hashedPassword], (err, result) => {
      if (err) return res.status(500).json({ message: 'Registration failed' });

      res.status(201).json({
        message: 'Registration successful',
        user: {
          id: result.insertId,
          name,
          username,
          role: 'student',
        },
      });
    });
  });
});

app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ message: 'Username and password are required' });

  const sql = 'SELECT * FROM users WHERE username = ?';
  db.query(sql, [username], async (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    if (result.length === 0) return res.status(404).json({ message: 'User not found' });

    const user = result[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.status(401).json({ message: 'Invalid password' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role, username: user.username },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        username: user.username,
        role: user.role,
      },
    });
  });
});

function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(403).json({ message: 'No token provided' });

  const token = authHeader.split(' ')[1];
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(401).json({ message: 'Invalid token' });
    req.user = decoded;
    next();
  });
}

//----------------- User Info ---------------------------/

app.get('/api/user/:id', verifyToken, (req, res) => {
  const id = req.params.id;
  const sql = 'SELECT id, name, role FROM users WHERE id = ?';

  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Database Error:', err);
      return res.status(500).json({ message: 'Database error' });
    }

    if (result.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({
      message: 'Get user info successfully',
      user: result[0],
    });
  });
});

// Utility: check whether a room has active Pending/Approved bookings
function checkHasActiveBookings(roomId, callback) {
  const sql = `
    SELECT COUNT(*) AS cnt
    FROM bookings
    WHERE room_id = ?
      AND status IN ('Pending','Approved')
  `;
  db.query(sql, [roomId], (err, rows) => {
    if (err) return callback(err);
    const cnt = (rows && rows[0] && rows[0].cnt) ? rows[0].cnt : 0;
    callback(null, cnt > 0);
  });
}

//------------------ Rooms (list) ---------------------------/

app.get('/api/rooms', (req, res) => {
  const roomsSql = 'SELECT id, name, description, capacity, status, image FROM rooms';

  db.query(roomsSql, (err, rooms) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ message: 'Database error' });
    }

    // ดึง bookings วันนี้ที่มีผลต่อการ "กันคิว"
    const bookingsSql = `
      SELECT room_id, time_slot, status
      FROM bookings
      WHERE booking_date = CURDATE()
        AND status IN ('Pending', 'Approved')
    `;
    db.query(bookingsSql, (err2, bookings) => {
      if (err2) {
        console.error('Database error:', err2);
        return res.status(500).json({ message: 'Database error' });
      }

      // map bookings ตามห้อง
      const byRoom = new Map(); // room_id -> [{time_slot, status}, ...]
      for (const b of bookings) {
        if (!byRoom.has(b.room_id)) byRoom.set(b.room_id, []);
        byRoom.get(b.room_id).push({ time_slot: b.time_slot, status: b.status });
      }

      // กำหนด end-time ของแต่ละ slot (รูปแบบ HH:MM:SS)
      const SLOT_ENDS = {
        '8-10': '10:00:00',
        '10-12': '12:00:00',
        '13-15': '15:00:00',
        '15-17': '17:00:00',
      };
      const ALL_SLOTS = Object.keys(SLOT_ENDS);

      // เวลาปัจจุบันของ server (ใช้ MySQL CURRENT_TIME() ก็ได้ แต่ทำใน JS ให้ชัดเจน)
      const now = new Date();
      const nowHH = String(now.getHours()).padStart(2, '0');
      const nowMM = String(now.getMinutes()).padStart(2, '0');
      const nowSS = String(now.getSeconds()).padStart(2, '0');
      const nowStr = `${nowHH}:${nowMM}:${nowSS}`; // ใช้เวลาจริงของ server
      //const nowStr = `13:00:00`; // ถ้าอยาก debug แบบ fix เวลา

      // Auto-enable or disable rooms daily
      if (nowHH>= '17' && nowHH <= '23') {
        db.query("UPDATE rooms SET status='disabled'", err => {
          if (err) console.error('Auto-disable failed', err);
        });
      } else if (nowHH >= '0' && nowHH < '17') {
        db.query("UPDATE rooms SET status='available'", err => {
          if (err) console.error('Auto-enable failed', err);
        });
      }

      function isPast(endHHMMSS) {
        return nowStr >= endHHMMSS; // >= end => slot หมดสิทธิ์จองแล้ว
      }

      // สร้างผลลัพธ์พร้อม status ใหม่: Free / Reserved / Disabled
      const enriched = rooms.map((r) => {
        // ถ้าโต๊ะ/ห้องถูกปิดระบบโดยตรง (เช่นมีคอลัมน์ status='disabled') ให้เป็น Disabled ทันที
        // ถ้าไม่มีนโยบายนี้ ให้คงไว้เฉย ๆ แล้วใช้ logic slot ข้างล่างตัดสิน
        if ((r.status || '').toLowerCase() === 'disabled') {
          return { ...r, status: 'Disabled' };
        }

        const roomBookings = byRoom.get(r.id) || [];

        // คัดเฉพาะ slot ที่ "ยังไม่หมดเวลา"
        const remainingSlots = ALL_SLOTS.filter(slot => !isPast(SLOT_ENDS[slot]));

        // ถ้าไม่เหลือ slot ให้จองแล้ว => Disabled
        if (remainingSlots.length === 0) {
          return { ...r, status: 'Disabled' };
        }

        // เช็คว่า remaining slot ถูกกันด้วย Pending/Approved ครบทุกช่องหรือไม่
        // (ถือว่าใครจองก็กันคิวหมด)
        const occupiedSet = new Set(
          roomBookings
            .filter(b => remainingSlots.includes(b.time_slot))
            .map(b => b.time_slot)
        );

        const allTaken = remainingSlots.every(slot => occupiedSet.has(slot));

        const derived = allTaken ? 'Reserved' : 'Free';
        return { ...r, status: derived };
      });

      res.status(200).json({
        message: 'Fetched all rooms successfully',
        rooms: enriched,
      });
    });
  });
});

app.get('/api/rooms/:id', (req, res) => {
  const roomId = req.params.id;
  const sql = 'SELECT * FROM rooms WHERE id = ?';
  db.query(sql, [roomId], (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    if (result.length === 0)
      return res.status(404).json({ message: 'Room not found' });

    res.status(200).json({
      message: 'Fetched room successfully',
      room: result[0],
    });
  });
});

//------------------ สร้าง Booking (นักศึกษา) ---------------------------/

app.post('/api/bookings', verifyToken, (req, res) => {
  const { room_id, time_slot, reason } = req.body;
  const user_id = req.user.id;

  if (!room_id || !time_slot) {
    return res.status(400).json({ message: 'Room ID and time slot are required' });
  }

  // 1) กันผู้ใช้คนเดิมจองมากกว่า 1 รายการในวันเดียว (Pending/Approved)
  const hasActiveSql = `
    SELECT 1 
    FROM bookings
    WHERE user_id = ? 
      AND booking_date = CURDATE()
      AND status IN ('Pending','Approved')
    LIMIT 1
  `;

  db.query(hasActiveSql, [user_id], (errA, rowsA) => {
    if (errA) return res.status(500).json({ message: 'Database error' });
    if (rowsA.length > 0) {
      return res.status(400).json({
        message: 'You already have an active booking today (Pending or Approved).'
      });
    }

    // 2) กันชนกันที่ห้อง/ช่วงเวลาเดียวกัน (มีคน Pending หรือ Approved ไปแล้ว)
    const roomSlotSql = `
      SELECT 1 
      FROM bookings
      WHERE room_id = ? 
        AND booking_date = CURDATE() 
        AND time_slot = ?
        AND status IN ('Pending','Approved')
      LIMIT 1
    `;
    db.query(roomSlotSql, [room_id, time_slot], (errB, rowsB) => {
      if (errB) return res.status(500).json({ message: 'Database error' });
      if (rowsB.length > 0) {
        return res.status(400).json({
          message: 'This time slot is already booked or pending approval'
        });
      }

      // 3) ผ่าน -> สร้าง booking (Pending)
      const insertSql = `
        INSERT INTO bookings (user_id, room_id, booking_date, time_slot, reason, status)
        VALUES (?, ?, CURDATE(), ?, ?, 'Pending')
      `;
      db.query(insertSql, [user_id, room_id, time_slot, reason || null], (errC, resultC) => {
        if (errC) return res.status(500).json({ message: 'Failed to create booking' });

        res.status(201).json({
          message: 'Booking created successfully',
          booking: {
            id: resultC.insertId,
            room_id,
            time_slot,
            reason: reason || null,
            status: 'Pending'
          }
        });
      });
    });
  });
});

//------------------ My Bookings (ฝั่ง Student + Auto-cancel) ---------------------------/

app.get('/api/me/bookings', verifyToken, (req, res) => {
  const userId = req.user.id;

  const baseSql = `
    SELECT 
      b.id            AS booking_id,
      r.name          AS room_name,
      DATE_FORMAT(b.booking_date, '%Y-%m-%d')  AS booking_date,   -- yyyy-mm-dd
      b.time_slot     AS time_slot,      
      b.status        AS status,         
      b.reason        AS reason,          
      b.reject_reason AS reject_reason,
      appr.name       AS approver_name  
    FROM bookings b
    JOIN rooms r         ON r.id = b.room_id
    LEFT JOIN users appr ON appr.id = b.approver_id
    WHERE b.user_id = ?
         AND DATE(b.booking_date) = CURDATE()
    ORDER BY b.created_at DESC, b.id DESC
  `;
  // AND DATE(b.booking_date) = CURDATE()

  db.query(baseSql, [userId], (err, rows) => {
    if (err) return res.status(500).json({ message: 'Database error' });

    if (!rows || rows.length === 0) {
      return res.json({ message: 'OK', bookings: [] });
    }

    // เวลา cutoff ของแต่ละสล็อต
    const SLOT_ENDS = {
      '8-10': '10:00:00',
      '10-12': '12:00:00',
      '13-15': '15:00:00',
      '15-17': '17:00:00',
    };

    // ตรวจสอบรายการที่ยัง Pending แต่หมดอายุ
    const now = new Date();
    const todayOnly = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const nowStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;
    //const nowStr = `13:00:00`;

    const expiredByDate = []; // ข้ามวัน
    const expiredByTime = []; // วันเดียวกันแต่เวลาสล็อตหมด

    for (const b of rows) {
      if (b.status !== 'Pending') continue;

      const bookingDate = new Date(b.booking_date); // 'yyyy-mm-dd'
      const bookingOnly = new Date(
        bookingDate.getFullYear(),
        bookingDate.getMonth(),
        bookingDate.getDate()
      );

      // เคสข้ามวัน
      if (bookingOnly < todayOnly) {
        expiredByDate.push(b.booking_id);
        continue;
      }

      // เคสวันนี้แต่เวลาสล็อตหมด
      if (bookingOnly.getTime() === todayOnly.getTime()) {
        const endTime = SLOT_ENDS[b.time_slot];
        if (endTime && nowStr >= endTime) {
          expiredByTime.push(b.booking_id);
        }
      }
    }

    if (expiredByDate.length === 0 && expiredByTime.length === 0) {
      return res.json({ message: 'OK', bookings: rows });
    }

    // อัปเดตทีละชุดตามเหตุผล
    const updateDateSql = `
      UPDATE bookings
      SET status = 'Cancelled',
          reject_reason = 'No approval before date passed'
      WHERE id IN (?)
        AND status = 'Pending'
    `;
    const updateTimeSql = `
      UPDATE bookings
      SET status = 'Cancelled',
          reject_reason = 'No approval before time passed'
      WHERE id IN (?)
        AND status = 'Pending'
    `;

    const doUpdateTime = () => {
      if (expiredByTime.length === 0) {
        // ดึงข้อมูลใหม่หลังอัปเดตให้ตรงกับ DB
        return db.query(baseSql, [userId], (err3, newRows) => {
          if (err3) return res.status(500).json({ message: 'Database error' });
          res.json({ message: 'OK', bookings: newRows });
        });
      }
      db.query(updateTimeSql, [expiredByTime], (errT) => {
        if (errT) {
          console.error('Auto-cancel (time) update error:', errT);
          return res.json({ message: 'OK', bookings: rows });
        }
        db.query(baseSql, [userId], (err3, newRows) => {
          if (err3) return res.status(500).json({ message: 'Database error' });
          res.json({ message: 'OK', bookings: newRows });
        });
      });
    };

    if (expiredByDate.length === 0) {
      // ไม่มีชุด date ก็ไปอัปเดต time ต่อเลย
      return doUpdateTime();
    }

    db.query(updateDateSql, [expiredByDate], (errD) => {
      if (errD) {
        console.error('Auto-cancel (date) update error:', errD);
        return res.json({ message: 'OK', bookings: rows });
      }
      doUpdateTime();
    });
  });
});

// ====================== Lecturer API ========================== //
app.get('/api/lecturer/requests', verifyToken, (req, res) => {
  if (req.user.role !== 'lecturer')
    return res.status(403).json({ message: 'Forbidden' });

  const sql = `
    SELECT b.id AS booking_id, u.name AS student_name, r.name AS room_name,
           DATE_FORMAT(b.booking_date, '%Y-%m-%d') AS booking_date,
           b.time_slot, b.reason, b.status
    FROM bookings b
    JOIN users u ON u.id = b.user_id
    JOIN rooms r ON r.id = b.room_id
    WHERE b.status = 'Pending'
    ORDER BY b.created_at DESC
  `;
  db.query(sql, (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    res.json({ message: 'OK', requests: result });
  });
});

app.post('/api/lecturer/approve', verifyToken, (req, res) => {
  if (req.user.role !== 'lecturer')
    return res.status(403).json({ message: 'Forbidden' });

  const { booking_id, decision, reason } = req.body;
  const approver_id = req.user.id;

  if (!booking_id || !decision)
    return res.status(400).json({ message: 'Missing fields' });

  const status = decision === 'Approved' ? 'Approved' : 'Rejected';
  const sql = `
    UPDATE bookings
    SET status = ?, approver_id = ?, reject_reason = ?
    WHERE id = ?
  `;
  db.query(sql, [status, approver_id, reason || null, booking_id], (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    res.json({ message: 'Updated successfully', status });
  });
});

app.get('/api/lecturer/history', verifyToken, (req, res) => {
  if (req.user.role !== 'lecturer')
    return res.status(403).json({ message: 'Forbidden' });

  const sql = `
    SELECT 
      b.id AS booking_id, 
      u.name AS student_name, 
      r.name AS room_name,
      DATE_FORMAT(b.booking_date, '%Y-%m-%d') AS booking_date,
      b.time_slot, 
      b.status, 
      b.reject_reason
    FROM bookings b
    JOIN users u ON u.id = b.user_id
    JOIN rooms r ON r.id = b.room_id
    WHERE b.status IN ('Approved', 'Rejected')
      AND DATE(b.booking_date) = CURDATE()
    ORDER BY b.created_at DESC
  `;

  db.query(sql, (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    res.json({ message: 'OK', history: result });
  });
});



//------------------ Room Status (use on choose slot) ---------------------------/

app.get('/api/rooms/:id/status', verifyToken, (req, res) => {
  const room_id = req.params.id;
  const user_id = req.user.id;

  const roomSql = 'SELECT * FROM rooms WHERE id = ?';
  db.query(roomSql, [room_id], (err, roomResult) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    if (roomResult.length === 0)
      return res.status(404).json({ message: 'Room not found' });

    const bookingSql = `
      SELECT *
      FROM bookings
      WHERE room_id = ? AND booking_date = CURDATE()
      ORDER BY created_at DESC, id DESC
    `;
    db.query(bookingSql, [room_id], (err2, rows) => {
      if (err2) return res.status(500).json({ message: 'Database error' });

      const latestBySlot = new Map(); // key: '8-10' ...
      for (const b of rows) {
        if (!latestBySlot.has(b.time_slot)) {
          latestBySlot.set(b.time_slot, b);
        }
      }

      const allSlots = ['8-10', '10-12', '13-15', '15-17'];
      const slotStatus = allSlots.map((slot) => {
        const booking = latestBySlot.get(slot);

        if (!booking) {
          return { time_slot: slot, status: 'Free' };
        }

        // map สถานะ
        switch (booking.status) {
          case 'Approved':
            return { time_slot: slot, status: 'Reserved' };
          case 'Pending':
            return {
              time_slot: slot,
              status: booking.user_id === user_id ? 'Pending' : 'On Hold',
            };
          case 'Rejected':
          case 'Cancelled':
          default:
            return { time_slot: slot, status: 'Free' };
        }
      });

      res.status(200).json({
        message: 'Fetched room status successfully',
        room: {
          id: roomResult[0].id,
          name: roomResult[0].name,
          description: roomResult[0].description,
          capacity: roomResult[0].capacity,
        },
        slots: slotStatus,
      });
    });
  });
});

//------------------ Cancel Booking (นักศึกษา) ---------------------------/

app.post('/api/bookings/:id/cancel', verifyToken, (req, res) => {
  const bookingId = req.params.id;
  const userId = req.user.id;

  // ตรวจสอบว่าการจองนี้เป็นของ user คนนั้นหรือไม่
  const checkSql = 'SELECT * FROM bookings WHERE id = ?';
  db.query(checkSql, [bookingId], (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    if (result.length === 0)
      return res.status(404).json({ message: 'Booking not found' });

    const booking = result[0];
    if (booking.user_id !== userId)
      return res.status(403).json({ message: 'You cannot cancel someone else’s booking' });

    if (booking.status === 'Cancelled')
      return res.status(400).json({ message: 'Booking already cancelled' });

    // อัปเดตสถานะ
    const updateSql = 'UPDATE bookings SET status = "Cancelled" WHERE id = ?';
    db.query(updateSql, [bookingId], (err2) => {
      if (err2) return res.status(500).json({ message: 'Failed to cancel booking' });

      res.status(200).json({
        message: 'Booking cancelled successfully',
        booking: {
          id: booking.id,
          room_id: booking.room_id,
          time_slot: booking.time_slot,
          previous_status: booking.status,
          new_status: 'Cancelled'
        }
      });
    });
  });
});

// ================== Multer for Room Images ==================
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = './uploads/';
    if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// ---------------- Add room --------------------//
app.post('/api/rooms', verifyToken, upload.single('image'), (req, res) => {
  if (!req.user || req.user.role !== 'staff') {
    return res.status(403).json({ message: 'Only staff can create rooms' });
  }

  const { name, description, capacity } = req.body;
  if (!name) return res.status(400).json({ message: 'Room name is required' });

  const imageUrl = req.file
    ? `/uploads/${req.file.filename}`
    : null;

  const insertSql = 'INSERT INTO rooms (name, description, capacity, image, status) VALUES (?, ?, ?, ?, ?)';
  const values = [
    name,
    description || null,
    capacity ? parseInt(capacity, 10) : 4,
    imageUrl,
    'available'
  ];

  db.query(insertSql, values, (err, result) => {
    if (err) {
      console.error('POST /api/rooms error:', err);
      return res.status(500).json({ message: 'Failed to create room' });
    }

    const newId = result.insertId;
    db.query('SELECT * FROM rooms WHERE id = ?', [newId], (err2, rows) => {
      if (err2) return res.status(500).json({ message: 'Room created but fetch failed' });
      res.status(201).json({ message: 'Room created', room: rows[0] });
    });
  });
});

// --------------- Update rooms ------------------------//
app.put('/api/rooms/:id', verifyToken, upload.single('image'), (req, res) => {
  if (!req.user || req.user.role !== 'staff')
    return res.status(403).json({ message: 'Only staff can edit rooms' });

  const roomId = req.params.id;

  checkHasActiveBookings(roomId, (errCheck, hasActive) => {
    if (errCheck) {
      console.error('Booking check error:', errCheck);
      return res.status(500).json({ message: 'Database error' });
    }
    if (hasActive) {
      return res.status(400).json({ message: 'Cannot edit a room with active (Pending/Approved) bookings' });
    }

    const { name, description, status, capacity } = req.body;
    const imagePath = req.file ? `/uploads/${req.file.filename}` : null;

    const fields = [];
    const values = [];

    if (name !== undefined) { fields.push('name = ?'); values.push(name); }
    if (description !== undefined) { fields.push('description = ?'); values.push(description); }
    if (capacity !== undefined) { fields.push('capacity = ?'); values.push(parseInt(capacity, 10) || 4); }
    if (imagePath) { fields.push('image = ?'); values.push(imagePath); }
    if (status !== undefined) { fields.push('status = ?'); values.push(status || 'available'); }

    if (fields.length === 0) {
      return res.status(400).json({ message: 'No fields provided for update' });
    }

    const sql = `UPDATE rooms SET ${fields.join(', ')} WHERE id = ?`;
    values.push(roomId);

    db.query(sql, values, err => {
      if (err) {
        console.error('PUT /api/rooms/:id error:', err);
        return res.status(500).json({ message: 'Update failed' });
      }
      res.json({ message: 'Room updated successfully' });
    });
  });
});

//  PATCH Toggle open/closed -----------------------//
app.patch('/api/rooms/:id/status', verifyToken, (req, res) => {
  if (!req.user || req.user.role !== 'staff')
    return res.status(403).json({ message: 'Only staff can change status' });

  const roomId = req.params.id;
  const { status } = req.body;

  if (!status) return res.status(400).json({ message: 'Missing status' });

  if ((status || '').toLowerCase() === 'disabled') {
    checkHasActiveBookings(roomId, (errCheck, hasActive) => {
      if (errCheck) {
        console.error('Booking check error:', errCheck);
        return res.status(500).json({ message: 'Database error' });
      }
      if (hasActive) {
        return res.status(400).json({ message: 'Cannot disable a room with active (Pending/Approved) bookings' });
      }

      db.query('UPDATE rooms SET status = ? WHERE id = ?', [status, roomId], err => {
        if (err) {
          console.error('PATCH /api/rooms/:id/status error:', err);
          return res.status(500).json({ message: 'Failed to update status' });
        }
        res.json({ message: 'Status updated successfully' });
      });
    });
  } else {
    db.query('UPDATE rooms SET status = ? WHERE id = ?', [status, roomId], err => {
      if (err) {
        console.error('PATCH /api/rooms/:id/status error:', err);
        return res.status(500).json({ message: 'Failed to update status' });
      }
      res.json({ message: 'Status updated successfully' });
    });
  }
});

// Ensure this runs last
app.listen(port, '0.0.0.0', () => {
  console.log(`API running at http://localhost:${port}`);
});