import mongoose from 'mongoose';

const solarSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Tên là bắt buộc'],
        trim: true
    },
    size: {
        type: String,
        required: [true, 'Kích thước là bắt buộc'],
        trim: true
    },
    describe: {
        type: String,
        required: [true, 'Mô tả là bắt buộc'],
        trim: true
    }
}, {
    timestamps: true
});

const Solar = mongoose.model('Solar', solarSchema);
export default Solar;