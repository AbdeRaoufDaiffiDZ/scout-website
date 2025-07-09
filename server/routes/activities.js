const express = require('express');
const router = express.Router();
const Activity = require('../models/Activity');
const { protect, authorize } = require('../middleware/authMiddleware');

// --- No Multer configuration needed if you are only uploading URLs ---
// const multer = require('multer');
// const path = require('path');
// ... (remove multer storage setup)
// const upload = multer({ /* ... */ }); // REMOVE THIS

// --- Activity Routes ---

// GET all activities (Publicly accessible)
router.get('/', async (req, res) => {
    try {
        const activities = await Activity.find();
        res.json(activities);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// GET a single activity by ID (Publicly accessible)
router.get('/:id', async (req, res) => {
    try {
        const activity = await Activity.findById(req.params.id);
        if (!activity) return res.status(404).json({ msg: 'Activity not found' });
        res.json(activity);
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(400).json({ msg: 'Invalid Activity ID' });
        }
        res.status(500).send('Server Error');
    }
});

// POST a new activity (Protected: only admin) - Now receives JSON with 'pics' as array of URLs
router.post('/', protect, authorize(['admin', 'editor']), async (req, res) => {
    const { date, pics, translations } = req.body; // pics will now be an array of URLs

    // Basic validation (you should add more robust validation)
    if (!date || !translations || !translations.en || !translations.ar) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const newActivity = new Activity({
            date,
            pics: pics || [], // Ensure pics is an array, default to empty if not provided
            translations,
        });

        const activity = await newActivity.save();
        res.status(201).json(activity);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// PUT/PATCH update an activity (Protected: only admin) - Now receives JSON with 'pics' as array of URLs
router.put('/:id', protect, authorize(['admin', 'editor']), async (req, res) => {
    const { date, pics, translations } = req.body; // pics will now be an array of URLs

    try {
        let activity = await Activity.findById(req.params.id);
        if (!activity) return res.status(404).json({ msg: 'Activity not found' });

        // Update fields
        activity.date = date || activity.date;
        activity.pics = pics || []; // Simply replace old pics with new URLs
        activity.translations = translations || activity.translations;

        await activity.save();
        res.json(activity);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// DELETE an activity (Protected: only admin) - No change needed here
router.delete('/:id', protect, authorize(['admin']), async (req, res) => {
    try {
        const activity = await Activity.findById(req.params.id);
        if (!activity) return res.status(404).json({ msg: 'Activity not found' });

        await Activity.deleteOne({ _id: req.params.id });
        res.json({ msg: 'Activity removed' });
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(400).json({ msg: 'Invalid Activity ID' });
        }
        res.status(500).send('Server Error');
    }
});

module.exports = router;