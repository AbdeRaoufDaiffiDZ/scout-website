// middleware/authMiddleware.js
const jwt = require('jsonwebtoken'); // <--- ADD THIS LINE IF IT'S MISSING OR TYPED INCORRECTLY
const User = require('../models/User'); // Path relative to middleware

const protect = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            // Get token from header
            token = req.headers.authorization.split(' ')[1];

            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET); // `jwt` is used here

            // Attach user to the request
            req.user = await User.findById(decoded.id).select('-password');
            next();
        } catch (error) {
            console.error('Not authorized, token failed', error);
            res.status(401).json({ message: 'Not authorized, token failed' });
        }
    }

    if (!token) {
        res.status(401).json({ message: 'Not authorized, no token' });
    }
};

const authorize = (roles = []) => {
    if (typeof roles === 'string') {
        roles = [roles];
    }

    return (req, res, next) => {
        if (roles.length > 0 && req.user && !roles.includes(req.user.role)) { // Added req.user check
            return res.status(403).json({ message: 'Not authorized to access this route' });
        }
        next();
    };
};

module.exports = { protect, authorize };