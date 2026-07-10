import nodemailer from "nodemailer";

// Transporter will be created lazily when needed to avoid initiating SMTP
// connections at module load time (prevents SASL errors when emails are disabled).
let transporter: nodemailer.Transporter | null = null;

const createTransporterIfNeeded = () => {
  if (transporter) return transporter;
  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || "smtp.gmail.com",
    port: Number(process.env.SMTP_PORT) || 587,
    secure: process.env.SMTP_SECURE === "true" || false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD,
    },
  });
  return transporter;
};

export interface EmailOptions {
  to: string;
  subject: string;
  html: string;
}

export const sendEmail = async (options: EmailOptions): Promise<void> => {
  console.debug('[email.service] sendEmail called for', options.to);
  // Skip sending emails during local development or when SMTP is not configured
  if (
    process.env.DISABLE_EMAILS === "true" ||
    !process.env.SMTP_USER ||
    !process.env.SMTP_PASSWORD
  ) {
    console.warn(`Email sending disabled. Would have sent to ${options.to}`);
    return;
  }

  try {
    const t = createTransporterIfNeeded();
    const mailOptions = {
      from: process.env.SMTP_FROM || process.env.SMTP_USER,
      to: options.to,
      subject: options.subject,
      html: options.html,
    };

    await t.sendMail(mailOptions);
    console.log(`Email sent successfully to ${options.to}`);
  } catch (error) {
    console.error("Error sending email:", error);
    throw new Error("Failed to send email");
  }
};

export const generateRegistrationEmail = (
  userName: string,
  registrationLink: string
): string => {
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #007bff; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .button { display: inline-block; background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin-top: 20px; }
          .footer { text-align: center; color: #666; font-size: 12px; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Complete Your Registration</h1>
          </div>
          <div class="content">
            <p>Hello ${userName},</p>
            <p>An admin has created an account for you. Please complete your registration by setting your password.</p>
            <p>Click the button below to proceed:</p>
            <a href="${registrationLink}" class="button">Complete Registration</a>
            <p><strong>Note:</strong> This link will expire in 24 hours.</p>
            <p>If you did not request this registration, please ignore this email.</p>
          </div>
          <div class="footer">
            <p>&copy; 2026 Calotex MES. All rights reserved.</p>
          </div>
        </div>
      </body>
    </html>
  `;
};

export const generatePasswordResetEmail = (
  userName: string,
  resetLink: string
): string => {
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #007bff; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .button { display: inline-block; background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin-top: 20px; }
          .footer { text-align: center; color: #666; font-size: 12px; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Password Reset Request</h1>
          </div>
          <div class="content">
            <p>Hello ${userName},</p>
            <p>We received a request to reset your password. Click the button below to proceed:</p>
            <a href="${resetLink}" class="button">Reset Password</a>
            <p><strong>Note:</strong> This link will expire in 1 hour.</p>
            <p>If you did not request this reset, please ignore this email.</p>
          </div>
          <div class="footer">
            <p>&copy; 2026 Calotex MES. All rights reserved.</p>
          </div>
        </div>
      </body>
    </html>
  `;
};
