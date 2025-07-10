const express = require('express');
const router = express.Router();
const Activity = require('../models/Activity');
const { protect, authorize } = require('../middleware/authMiddleware');
const nodemailer = require('nodemailer');
require('dotenv').config();

// --- Activity Routes ---

// GET all activities (Publicly accessible)
router.get('/', async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1; // Default to page 1
        const limit = parseInt(req.query.limit) || 10; // Default to 10 activities per page
        const skip = (page - 1) * limit;

        // Fetch activities with pagination and sorting (e.g., by date descending)
        const activities = await Activity.find()
                                        .skip(skip)
                                        .limit(limit)
                                        .sort({ date: -1 }); // Sort by date descending (latest first)

        // Get total count of activities for pagination metadata
        const totalActivities = await Activity.countDocuments();

        res.json({
            activities,
            currentPage: page,
            totalPages: Math.ceil(totalActivities / limit),
            totalActivities,
            hasMore: (page * limit) < totalActivities // Check if there are more activities to fetch
        });
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

// Nodemailer transporter configuration
const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com', // e.g., 'smtp.gmail.com' for Gmail, 'smtp-mail.outlook.com' for Outlook
    port: 587, // Common ports are 587 (TLS) or 465 (SSL)
    secure: false, // true for 465, false for other ports
    auth: {
        user: process.env.APP_EMAIL, // Your email address from .env
        pass: process.env.APP_PASSWORD // Your email password or app-specific password from .env
    },
    // Optional: Add a timeout if you experience issues with slow connections
    // timeout: 10000 // 10 seconds
});

// Verify transporter connection (optional, but good for debugging)
transporter.verify(function (error, success) {
    if (error) {
        console.error("Nodemailer transporter verification failed:", error);
        console.error("Possible reasons: Incorrect email/password, 2-Step Verification requiring an App Password, or 'Less secure app access' is disabled.");
    } else {
        console.log("Nodemailer transporter is ready to send messages.");
    }
});

// POST route to send email
router.post('/send-email', async (req, res) => {
    // Destructure data from the request body
    const { name, email, subject, message } = req.body;

    // Basic validation
    if (!name || !email || !subject || !message) {
        return res.status(400).json({ success: false, message: 'All fields are required.' });
    }

    try {
        // Construct the email options
        const mailOptions = {
            from: process.env.APP_EMAIL, // Sender address (should be your configured email from .env)
            to: `${email}, scoutrgb@gmail.com`, // Recipient email address
            replyTo: email, // Set reply-to to the user's email
            subject: `New Message from ${name}: ${subject}`, // Subject line
            html: `
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Scout Email Message</title>
                    <!-- Inlining styles for better email client compatibility -->
                    <style>
                        /* Define custom colors as variables (though inline styles will override) */
                        :root {
                            --color-scout-green: #22c55e;
                            --color-scout-purple: #8b5cf6;
                        }
                        /* Basic reset for email clients */
                        body { margin: 0; padding: 0; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
                        table, td, div { border-collapse: collapse; }
                        img { display: block; border: 0; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; }
                        p { margin: 0; padding: 0; }
                    </style>
                </head>
                <body style="margin: 0; padding: 0; font-family: 'Inter', sans-serif, Arial, sans-serif; background-color: #f3f4f6;">
                    <div style="display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 1rem;">
                        <div style="background-color: #ffffff; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); border-radius: 0.5rem; overflow: hidden; width: 100%; max-width: 48rem;">
                            <!-- Header Section -->
                            <div style="background-color: #8b5cf6; padding: 1.5rem; color: #ffffff; text-align: center; border-top-left-radius: 0.5rem; border-top-right-radius: 0.5rem;">
                                <h1 style="font-size: 1.875rem; line-height: 2.25rem; font-weight: 700; margin-bottom: 0.5rem;">New Message Received</h1>
                            </div>

                            <!-- Message Body Section -->
                            <div style="padding: 1.5rem;">
                                <!-- Sender Information -->
                                <div style="margin-bottom: 1.5rem; padding-bottom: 1rem; border-bottom: 1px solid #22c55e;">
                                    <h2 style="font-size: 1.25rem; line-height: 1.75rem; font-weight: 600; color: #22c55e; margin-bottom: 0.75rem;">Sender Details:</h2>
                                    <div style="display: grid; grid-template-columns: 1fr; gap: 1rem; color: #4b5563;">
                                        <div>
                                            <p style="font-weight: 500; color: #1f2937; margin-bottom: 0.25rem;">Name:</p>
                                            <p style="background-color: #f9fafb; padding: 0.5rem; border-radius: 0.375rem; border: 1px solid #e5e7eb;">${name}</p>
                                        </div>
                                        <div>
                                            <p style="font-weight: 500; color: #1f2937; margin-bottom: 0.25rem;">Email:</p>
                                            <p style="background-color: #f9fafb; padding: 0.5rem; border-radius: 0.375rem; border: 1px solid #e5e7eb;">${email}</p>
                                        </div>
                                    </div>
                                </div>

                                <!-- Subject and Message -->
                                <div style="margin-bottom: 1.5rem;">
                                    <h2 style="font-size: 1.25rem; line-height: 1.75rem; font-weight: 600; color: #22c55e; margin-bottom: 0.75rem;">Message Details:</h2>
                                    <div style="margin-bottom: 1rem;">
                                        <p style="font-weight: 500; color: #1f2937; margin-bottom: 0.25rem;">Subject:</p>
                                        <p style="background-color: #f9fafb; padding: 0.75rem; border-radius: 0.375rem; border: 1px solid #e5e7eb; font-size: 1.125rem; line-height: 1.75rem; font-weight: 600;">${subject}</p>
                                    </div>
                                    <div>
                                        <p style="font-weight: 500; color: #1f2937; margin-bottom: 0.25rem;">Message:</p>
                                        <div style="background-color: #f9fafb; padding: 0.75rem; border-radius: 0.375rem; border: 1px solid #e5e7eb; line-height: 1.625; color: #4b5563;">
                                            <p>${message}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Footer Section -->
                            <div style="background-color: #0D9C41FF; padding: 1rem; color: #ffffff; text-align: center; border-bottom-left-radius: 0.5rem; border-bottom-right-radius: 0.5rem;">
                                <p style="font-size: 0.875rem; line-height: 1.25rem; opacity: 0.9;">&copy; 2025 Rahim Galia Bachir Scout Group Bouira. All rights reserved.</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
            `, // HTML body content
            text: `Name: ${name}\nEmail: ${email}\nSubject: ${subject}\nMessage: ${message}` // Plain text body for clients that don't support HTML
        };

        // Send the email
        await transporter.sendMail(mailOptions);

        // Respond with success
        res.status(200).json({ success: true, message: 'Email sent successfully!' });

    } catch (error) {
        console.error('Error sending email:', error);
        // Respond with an error
        res.status(500).json({ success: false, message: 'Failed to send email.', error: error.message });
    }
});

module.exports = router;
