import express from 'express';
import Solar from '../models/Solar.js';

const router = express.Router();

// CREATE - Tạo mới một solar item
router.post('/solar', async (req, res) => {
    try {
        const solar = new Solar(req.body);
        const savedSolar = await solar.save();
        res.status(201).json({
            success: true,
            data: savedSolar,
            message: 'Tạo mới thành công'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
});

// READ - Lấy tất cả solar items
router.get('/solar', async (req, res) => {
    try {
        const solarList = await Solar.find().sort({ createdAt: -1 });
        res.status(200).json({
            success: true,
            count: solarList.length,
            data: solarList
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// READ - Lấy một solar item theo ID
router.get('/solar/:id', async (req, res) => {
    try {
        const solar = await Solar.findById(req.params.id);
        if (!solar) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy item với ID này'
            });
        }
        res.status(200).json({
            success: true,
            data: solar
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// UPDATE - Cập nhật một solar item theo ID
router.put('/solar/:id', async (req, res) => {
    try {
        const solar = await Solar.findByIdAndUpdate(
            req.params.id,
            req.body,
            {
                new: true,
                runValidators: true
            }
        );
        
        if (!solar) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy item với ID này'
            });
        }
        
        res.status(200).json({
            success: true,
            data: solar,
            message: 'Cập nhật thành công'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
});

// DELETE - Xóa một solar item theo ID
router.delete('/solar/:id', async (req, res) => {
    try {
        const solar = await Solar.findByIdAndDelete(req.params.id);
        
        if (!solar) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy item với ID này'
            });
        }
        
        res.status(200).json({
            success: true,
            data: solar,
            message: 'Xóa thành công'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

export default router;