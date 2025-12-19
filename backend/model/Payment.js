import mongoose from 'mongoose';

const paymentSchema = new mongoose.Schema({
  vendor:    { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  user:      { type: mongoose.Schema.Types.ObjectId, ref: 'User',   required: false },
  amount:    { type: Number, required: true },
  method:    { type: String, enum: ['card','wallet','cash'], default: 'card' },
  status:    { type: String, enum: ['pending','completed','failed'], default: 'pending' },
  type:      { type: String, enum: ['booking','subscription'], default: 'booking' },
  reference: { type: String },
  createdAt: { type: Date, default: Date.now }
});

export const Payment = mongoose.model('Payment', paymentSchema);
