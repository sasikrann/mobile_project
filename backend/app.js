const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const db = require('./db'); 
const app = express();
const port = 3000;

//------------------ Login + Register ---------------------------/
app.use(cors({
  origin: '*', 
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const JWT_SECRET = 'super_secret_key_change_this';


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
app.get('/api/me', verifyToken, (req, res) => {
  res.json({ message: 'Token valid', user: req.user });
});



//-----------------   ---------------------------/

app.get('/api/user/:id', verifyToken, (req, res) => {
  const id  = req.params.id;
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


//------------------  ---------------------------/

app.get('/api/rooms', (req, res) => {
  const sql = 'SELECT * FROM rooms';
  db.query(sql, (err, result) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ message: 'Database error' });
    }
    res.status(200).json({
      message: 'Fetched all rooms successfully',
      rooms: result,
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

//------------------ ---------------------------/
app.post('/api/bookings', verifyToken, (req, res) => {
  const { room_id, time_slot, reason } = req.body;
  const user_id = req.user.id;

  if (!room_id || !time_slot) {
    return res.status(400).json({ message: 'Room ID and time slot are required' });
  }

  // 1) กันผู้ใช้คนเดิมจองมากกว่า 1 รายการในวันเดียว (นับเฉพาะ Pending/Approved)
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

      // 3) ผ่านทั้งสองเงื่อนไข -> สร้าง booking (เป็น Pending)
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

app.get('/api/me/bookings', verifyToken, (req, res) => {
  const userId = req.user.id;

  const sql = `
    SELECT 
      b.id            AS booking_id,
      r.name          AS room_name,
      DATE_FORMAT(b.booking_date, '%Y-%m-%d')  AS booking_date,   -- DATE (yyyy-mm-dd)
      b.time_slot     AS time_slot,      -- '8-10' | '10-12' | ...
      b.status        AS status,         -- 'Pending' | 'Approved' | 'Rejected' | 'Cancelled'
      b.reason        AS reason,          -- เหตุผลการจอง (ถ้ามี)
      b.reject_reason AS reject_reason,
      appr.name       AS approver_name  -- อนุมัติโดยใคร (nullable)
    FROM bookings b
    JOIN rooms r       ON r.id = b.room_id
    LEFT JOIN users appr ON appr.id = b.approver_id
    WHERE b.user_id = ?
    ORDER BY b.created_at DESC, b.id DESC
  `;

  db.query(sql, [userId], (err, rows) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    res.json({ message: 'OK', bookings: rows });
  });
});

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

      // เก็บ "รายการล่าสุด" ต่อหนึ่ง time_slot
      const latestBySlot = new Map(); // key: '8-10' | '10-12' | ...
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
            return { time_slot: slot, status: 'Reserved' }; // อนุมัติแล้ว มีคนใช้แน่
          case 'Pending':
            return {
              time_slot: slot,
              status: booking.user_id === user_id ? 'Pending' : 'On Hold', // รออนุมัติของใคร
            };
          case 'Rejected':
          case 'Cancelled':
          default:
            return { time_slot: slot, status: 'Free' }; // ปฏิเสธ/ยกเลิก = ว่าง
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
    db.query(updateSql, [bookingId], (err2, result2) => {
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

// ให้โค้ดนี้อยู่ล่างสุดเสมอ
app.listen(port, '0.0.0.0', () => {
  console.log(`API running at http://localhost:${port}`);
});