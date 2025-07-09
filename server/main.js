// main.js (or server.js)
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path'); // For serving static files

// Import your routes
const activitiesRouter = require('./routes/activities');
const authRouter = require('./routes/auth'); // New auth route

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Serve static files from the 'uploads' directory
// This allows your Flutter app to access images at http://localhost:5000/uploads/filename.jpg
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


const mongoURI = process.env.MONGO_URI;

mongoose.connect(mongoURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB Connected Successfully'))
.catch(err => {
    console.error('MongoDB Connection Error:', err.message);
    process.exit(1);
});

// Use your routes
app.use('/api/activities', activitiesRouter);
app.use('/api/auth', authRouter); // New auth endpoint

// Basic root route
app.get('/', (req, res) => {
    res.send('API is running...');
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

// Optional: Create a default admin user if one doesn't exist (for first run)
const User = require('./models/User');
const createAdminUser = async () => {
    try {
        const adminExists = await User.findOne({ username: 'admin' });
        if (!adminExists) {
            const adminUser = new User({
                username: 'admin',
                password: 'adminpassword', // Change this in production!
                role: 'admin'
            });
            await adminUser.save();
            console.log('Default admin user created: admin/adminpassword');
        }
    } catch (error) {
        console.error('Error creating default admin user:', error);
    }
};
createAdminUser();