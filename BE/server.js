import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';
import solarRoutes from './routes/solarRoutes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', solarRoutes);

// Kết nối MongoDB
mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME
})
.then(() => {
    console.log('✅ Kết nối MongoDB thành công!');
    console.log(`📁 Database: ${process.env.DB_NAME}`);
    console.log(`📂 Collection: Solar`);
})
.catch((error) => {
    console.error('❌ Lỗi kết nối MongoDB:', error.message);
    process.exit(1);
});

// Route kiểm tra
app.get('/', (req, res) => {
    res.json({
        message: 'API CRUD đang chạy',
        endpoints: {
            create: 'POST /api/solar',
            getAll: 'GET /api/solar',
            getOne: 'GET /api/solar/:id',
            update: 'PUT /api/solar/:id',
            delete: 'DELETE /api/solar/:id'
        }
    });
});

// Middleware xử lý lỗi
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Có lỗi xảy ra!',
        error: err.message
    });
});

// Khởi động server
app.listen(PORT, () => {
    console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
});