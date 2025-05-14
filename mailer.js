const nodemailer = require("nodemailer");
require("dotenv").config(); // Load environment variables from .env file

const transporter = nodemailer.createTransport({
  host: process.env.HOST,
  port: process.env.PORT ? parseInt(process.env.PORT) : 465,
  secure: true,
  auth: {
    user: process.env.SENDER,
    pass: process.env.PASSWORD,
  },
});

console.log("SMTP Config:");
console.log("Host:", process.env.HOST);
console.log("Port:", process.env.PORT);
console.log("User:", process.env.SENDER);
console.log("Password:", process.env.PASSWORD);

transporter.sendMail(
  {
    from: process.env.SENDER,
    to: "albert@eldohub.co.ke",
    subject: "Test Email: OTP",
    text: "This is a test email sent using Nodemailer from Lobo class.",
  },
  (error, info) => {
    if (error) {
      console.log(error);

      return console.log("Error occurred: " + error.message);
    }
    console.log("Email sent successfully: " + info.response);
  }
);
