# Hotel Booking - Lobo Village

## Project Description

This is a hotel booking system built with Node.js and Express. It provides functionality to manage rooms, spots (venues), clients, bookings, payments, reviews, and related facilities. The project uses a MySQL database to store all data and includes seed data for initial setup.

## Installation

1. Clone the repository or download the project files.
2. Ensure you have Node.js and MySQL installed on your system.
3. Install the project dependencies by running:
   ```
   npm install
   ```
4. Set up the MySQL database using the provided `database.sql` file. This file contains the schema and seed data for the application.

## Usage

- To start the server in development mode with automatic reload:
  ```
  npm run dev
  ```
- To start the server normally:
  ```
  npm start
  ```
- The server runs on port 3000 by default. Access it at `http://localhost:3000`.

## Project Structure

- `index.js`: Main application file that sets up the Express server.
- `package.json`: Project metadata and dependencies.
- `database.sql`: SQL script to create the database schema and insert seed data.

## Database Schema Overview

The database consists of the following main tables:

- **rooms**: Information about hotel rooms including type, price, label, and images.
- **spots**: Venue spots available for booking with capacity, price, and images.
- **clients**: Client details including name, email, and phone number.
- **roomBookings** and **spotBookings**: Booking records for rooms and spots respectively.
- **reviews**: Customer reviews for rooms and spots.
- **payments**: Payment records linked to bookings.
- **roomFacilities** and **spotFacilities**: Facilities available in rooms and spots.
- **checkInCheckOutLogs**: Logs for check-in and check-out times.
- **bookingNotes**: Additional notes related to bookings.

## Dependencies

- express: Web framework for Node.js
- mysql: MySQL client for Node.js
- bcrypt: Password hashing
- ejs: Embedded JavaScript templating
- express-session: Session management for Express

## Seed Data

The `database.sql` file includes sample data for rooms, spots, clients, bookings, reviews, payments, and facilities to help you get started quickly.

## Author

No author specified.

## License

ISC
