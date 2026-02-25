const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Function to send SMS and email notifications when a booking is created
exports.sendBookingNotification = functions.firestore
    .document('bookings/{bookingId}')
    .onCreate(async (snap, context) => {
      const booking = snap.data();
      
      // Get user details
      const userDoc = await admin.firestore().collection('users').doc(booking.userId).get();
      const user = userDoc.data();
      
      if (!user) {
        console.log('User not found');
        return null;
      }
      
      // Send SMS notification
      await sendSmsNotification(user, booking);
      
      // Send email notification
      await sendEmailNotification(user, booking);
      
      return null;
    });

// Function to send SMS notification
async function sendSmsNotification(user, booking) {
  try {
    // This is a placeholder - you would integrate with your actual SMS service
    console.log(`Sending SMS to ${user.phoneNumber}: 
    Hi ${user.firstName}, your ${booking.type} from ${booking.source} to ${booking.destination} 
    on ${booking.travelDate.toDate()} is confirmed. Fare: ₹${booking.fare}. 
    Thank you for choosing Orbit Live!`);
    
    // Example with Twilio or other SMS service:
    /*
    const accountSid = 'your-account-sid';
    const authToken = 'your-auth-token';
    const client = require('twilio')(accountSid, authToken);
    
    await client.messages.create({
      body: `Hi ${user.firstName}, your ${booking.type} from ${booking.source} to ${booking.destination} on ${booking.travelDate.toDate()} is confirmed. Fare: ₹${booking.fare}. Thank you for choosing Orbit Live!`,
      from: '+1234567890',
      to: user.phoneNumber
    });
    */
  } catch (error) {
    console.error('Error sending SMS:', error);
  }
}

// Function to send email notification using Resend.com
async function sendEmailNotification(user, booking) {
  try {
    // Generate HTML content for email
    const htmlContent = generateBookingEmailHtml(user, booking);
    
    // Send email using Resend.com API
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer re_6wNRXr1G_KVm9qCqH97rC6uwTCTMBcJXf',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: 'notifications@orbitlive.com',
        to: user.email,
        subject: `Your ${booking.type} is confirmed!`,
        html: htmlContent
      })
    });
    
    if (response.ok) {
      console.log(`Email sent successfully to ${user.email}`);
    } else {
      console.error('Failed to send email:', await response.text());
    }
  } catch (error) {
    console.error('Error sending email:', error);
  }
}

// Generate HTML content for booking confirmation email
function generateBookingEmailHtml(user, booking) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Booking Confirmation</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #006064; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .booking-details { background-color: white; padding: 15px; border-radius: 5px; margin: 15px 0; }
            .qr-code { text-align: center; margin: 20px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Orbit Live</h1>
                <p>Your Booking is Confirmed!</p>
            </div>
            
            <div class="content">
                <h2>Hello ${user.firstName},</h2>
                <p>Thank you for choosing Orbit Live. Your ${booking.type} has been successfully booked.</p>
                
                <div class="booking-details">
                    <h3>Booking Details</h3>
                    <p><strong>Booking ID:</strong> ${booking.id}</p>
                    <p><strong>Route:</strong> ${booking.source} to ${booking.destination}</p>
                    <p><strong>Date:</strong> ${booking.travelDate.toDate().toLocaleDateString()}</p>
                    <p><strong>Fare:</strong> ₹${booking.fare.toFixed(2)}</p>
                    <p><strong>Status:</strong> Confirmed</p>
                </div>
                
                ${booking.qrCode ? `
                <div class="qr-code">
                    <h3>Your QR Code</h3>
                    <img src="https://api.qrserver.com/v1/create-qr-code/?data=${encodeURIComponent(booking.qrCode)}&size=200x200" alt="QR Code">
                    <p>Please show this QR code at the bus entrance</p>
                </div>
                ` : ''}
                
                <p>If you have any questions, please contact our support team.</p>
                <p>Have a safe journey!</p>
            </div>
            
            <div class="footer">
                <p>© 2025 Orbit Live. All rights reserved.</p>
                <p>This is an automated message. Please do not reply to this email.</p>
            </div>
        </div>
    </body>
    </html>
  `;
}

// Function to send frequent, randomized, and personalized promotional notifications every 10 minutes
exports.sendFrequentPromotionalNotifications = functions.pubsub
    .schedule('every 10 minutes from 09:00 to 21:00')
    .timeZone('Asia/Kolkata')
    .onRun(async (context) => {
      try {
        // Get all users
        const usersSnapshot = await admin.firestore().collection('users').get();
        
        // Define notification templates
        const notificationTemplates = [
          {
            category: 'travel_tip',
            title: 'Travel Tip',
            body: 'Avoid peak hours for a more comfortable journey!',
            frequency: 'daily',
            personalization: false,
          },
          {
            category: 'feature_highlight',
            title: 'New Feature',
            body: 'Try our new TravelBuddy feature to find companions for your journey!',
            frequency: 'weekly',
            personalization: false,
          },
          {
            category: 'discount',
            title: 'Special Offer',
            body: 'Get 10% off on your next ticket booking. Limited time offer!',
            frequency: 'weekly',
            personalization: false,
          },
          {
            category: 'reminder',
            title: 'Plan Your Next Trip',
            body: 'Plan your next trip with discounts on passes!',
            frequency: 'daily',
            personalization: false,
          },
          {
            category: 'safety',
            title: 'Safety First',
            body: 'Remember to wear your mask and maintain social distancing.',
            frequency: 'daily',
            personalization: false,
          },
          {
            category: 'eco_friendly',
            title: 'Eco-Friendly Travel',
            body: 'Choose public transport to reduce your carbon footprint!',
            frequency: 'weekly',
            personalization: false,
          },
          {
            category: 'feedback',
            title: 'Rate Your Experience',
            body: 'How was your last journey? Share your feedback with us.',
            frequency: 'weekly',
            personalization: false,
          },
          {
            category: 'advance_booking',
            title: 'Did you know?',
            body: 'Booking tickets in advance gets you better prices!',
            frequency: 'daily',
            personalization: false,
          },
          {
            category: 'voice_chat',
            title: 'TravelBuddy Update',
            body: 'TravelBuddy now supports voice chat. Try it today for safer trips.',
            frequency: 'weekly',
            personalization: false,
          },
          {
            category: 'cashback',
            title: 'SPECIAL OFFER',
            body: '15% cashback on monthly passes this week only!',
            frequency: 'weekly',
            personalization: false,
          },
          {
            category: 'quiet_hours',
            title: 'Avoid the rush hour!',
            body: 'Check out quieter bus timings in your area.',
            frequency: 'daily',
            personalization: true,
          },
          {
            category: 'new_routes',
            title: 'New Routes Available',
            body: 'Your city\'s new routes are live! Explore and plan your journey.',
            frequency: 'weekly',
            personalization: true,
          },
        ];
        
        // Track notification counts per user to avoid spamming
        const userNotificationCounts = {};
        
        // Process users in batches to avoid memory issues
        const batchSize = 100;
        const users = usersSnapshot.docs;
        
        for (let i = 0; i < users.length; i += batchSize) {
          const batch = users.slice(i, Math.min(i + batchSize, users.length));
          
          // Process each user in the batch
          for (const userDoc of batch) {
            const user = userDoc.data();
            
            // Skip users without FCM tokens
            if (!user.fcmToken) {
              console.log(`Skipping user ${user.email} - no FCM token`);
              continue;
            }
            
            // Check if user has exceeded daily limit (max 3 notifications per day)
            const today = new Date().toISOString().split('T')[0];
            const userCountKey = `${userDoc.id}_${today}`;
            const notificationCount = userNotificationCounts[userCountKey] || 0;
            
            if (notificationCount >= 3) {
              console.log(`Skipping user ${user.email} - daily limit reached`);
              continue;
            }
            
            // Randomly decide whether to send a notification (30% chance)
            if (Math.random() > 0.3) {
              console.log(`Skipping user ${user.email} - random selection`);
              continue;
            }
            
            // Select a random notification template
            const randomTemplate = notificationTemplates[Math.floor(Math.random() * notificationTemplates.length)];
            
            // Personalize message based on user data
            const personalizedMessage = await personalizeMessage(randomTemplate, user);
            
            // Send FCM notification
            const payload = {
              notification: {
                title: personalizedMessage.title,
                body: personalizedMessage.body,
              },
              data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                screen: getScreenForCategory(randomTemplate.category),
                category: randomTemplate.category,
              }
            };
            
            try {
              await admin.messaging().sendToDevice(user.fcmToken, payload);
              console.log(`Notification sent to ${user.email}: ${personalizedMessage.title}`);
              
              // Update notification count
              userNotificationCounts[userCountKey] = notificationCount + 1;
              
              // Track notification in analytics
              await trackNotificationDelivery(userDoc.id, randomTemplate.category);
            } catch (error) {
              console.error(`Error sending notification to ${user.email}:`, error);
              
              // If the token is invalid, remove it from the user record
              if (error.code === 'messaging/invalid-registration-token' || 
                  error.code === 'messaging/registration-token-not-registered') {
                await admin.firestore().collection('users').doc(userDoc.id).update({
                  fcmToken: admin.firestore.FieldValue.delete()
                });
                console.log(`Removed invalid FCM token for user ${user.email}`);
              }
            }
          }
          
          // Add a small delay between batches to avoid rate limiting
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
        
        console.log('Frequent promotional notifications completed');
        return null;
      } catch (error) {
        console.error('Error in sendFrequentPromotionalNotifications:', error);
        return null;
      }
    });

// Personalize message based on user data
async function personalizeMessage(template, user) {
  // In a real implementation, you would use user data to personalize messages
  // For example, using location data, booking history, preferences, etc.
  
  let title = template.title;
  let body = template.body;
  
  // Example personalization - add user's first name to some messages
  if (template.personalization && user.firstName) {
    if (template.category === 'reminder' || template.category === 'feedback') {
      title = `Hi ${user.firstName}, ${template.title}`;
    }
  }
  
  return { title, body };
}

// Get screen to navigate to based on notification category
function getScreenForCategory(category) {
  switch (category) {
    case 'travel_tip':
    case 'safety':
    case 'eco_friendly':
      return 'home';
    case 'feature_highlight':
    case 'voice_chat':
      return 'travel_buddy';
    case 'discount':
    case 'cashback':
      return 'tickets';
    case 'reminder':
    case 'advance_booking':
      return 'bookings';
    case 'new_routes':
      return 'map';
    default:
      return 'home';
  }
}

// Track notification delivery for analytics
async function trackNotificationDelivery(userId, category) {
  try {
    await admin.firestore().collection('notificationAnalytics').add({
      userId: userId,
      category: category,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      delivered: true,
    });
  } catch (error) {
    console.error('Error tracking notification delivery:', error);
  }
}

// Function to track notification opens
exports.trackNotificationOpen = functions.https.onCall(async (data, context) => {
  try {
    const { userId, category, timestamp } = data;
    
    await admin.firestore().collection('notificationAnalytics').add({
      userId: userId,
      category: category,
      timestamp: admin.firestore.Timestamp.fromDate(new Date(timestamp)),
      opened: true,
    });
    
    return { success: true };
  } catch (error) {
    console.error('Error tracking notification open:', error);
    return { success: false, error: error.message };
  }
});

// Function to get notification analytics
exports.getNotificationAnalytics = functions.https.onCall(async (data, context) => {
  try {
    const { days = 30 } = data;
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);
    
    const snapshot = await admin.firestore()
      .collection('notificationAnalytics')
      .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(cutoffDate))
      .get();
    
    const analytics = {};
    
    snapshot.forEach(doc => {
      const data = doc.data();
      const category = data.category || 'unknown';
      const type = data.opened ? 'opened' : 'delivered';
      
      if (!analytics[category]) {
        analytics[category] = { delivered: 0, opened: 0 };
      }
      
      analytics[category][type]++;
    });
    
    return { analytics };
  } catch (error) {
    console.error('Error getting notification analytics:', error);
    return { success: false, error: error.message };
  }
});