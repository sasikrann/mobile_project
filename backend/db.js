const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',          
  password: '',
  database: 'room_booking'
});

db.connect((err) => {
  if (err) {
    console.error('❌ Please connect MySQL!', err);
  } else {
    console.log('✅ Complete to connect MySQL!');
  }
});

module.exports = db;