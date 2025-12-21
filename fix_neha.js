import mongoose from 'mongoose';

mongoose.connect('mongodb+srv://ctm3223:jmgfW9pIpEUWYP4D@cluster0.1pelyxu.mongodb.net/');

setTimeout(async () => {
  const Vendor = mongoose.model('Vendor', new mongoose.Schema({}, { strict: false }), 'vendors');
  
  const result = await Vendor.updateOne(
    { email: 'nehasarkar82@gmail.com' },
    { $set: { hasPhysicalShop: true, homeServiceAvailable: true } }
  );
  
  console.log('Updated:', result);
  
  const vendor = await Vendor.findOne({ email: 'nehasarkar82@gmail.com' }).lean();
  console.log('Neha hasPhysicalShop:', vendor.hasPhysicalShop);
  console.log('Neha homeServiceAvailable:', vendor.homeServiceAvailable);
  
  process.exit(0);
}, 2000);
