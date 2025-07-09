// middleware/authMiddleware.js



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

module.exports = {authorize };