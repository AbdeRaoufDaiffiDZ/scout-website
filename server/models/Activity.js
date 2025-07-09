const mongoose = require('mongoose');

const activityTranslationSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String, required: true },
});

const activitySchema = new mongoose.Schema({
    date: { type: String, required: true },
    pics: { type: [String], default: [] },
    translations: {
        en: activityTranslationSchema,
        ar: activityTranslationSchema,
    },
}, { timestamps: true });

const Activity = mongoose.model('Activity', activitySchema);

module.exports = Activity; // Export the model