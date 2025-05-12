const express = require("express");
const path = require("path");
const mysql = require("mysql");
const bcrypt = require("bcrypt");
const session = require("express-session");
const cors = require("cors");

const dbConnection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "hotel_lobo",
});

const app = express();

// middleware --------- Cors , crsf ,
app.use(cors()); // enable CORS for all routes
app.use(express.json()); // for parsing application/json
app.use(express.static(path.join(__dirname, "public"))); // path -- nested routs /booking/user/id
app.use(express.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded - form data
app.use(
  session({
    secret: "ujipower", // secret key for signing the session ID cookie
    resave: false, // forces session to be saved back to the session store, even if the session was never modified during the request
    saveUninitialized: true, // forces a session that is "uninitialized" to be saved to the store
  })
);

// authorizarion middleware
const receptionistRoutes = ["/roomUpdates", "/dash/reception"];
const managerRoutes = [
  ...receptionistRoutes,
  "/addReceptionist",
  "/addNewSpot",
  "/addNewRoom",
  "/dash/manager",
];
const superAdminRoutes = [
  ...receptionistRoutes,
  ...managerRoutes,
  "/dash/superadmin",
]; // js spread operator - combine all routes

// all other routes are public
app.use((req, res, next) => {
  console.log(req.path);

  if (req.session.user) {
    res.locals.user = req.session.user; // send user data to views/ejs
    // user islogged in  --- go ahead and check role and route they are accessing
    const userRole = req.session.user.role; // get user role from session
    if (userRole === "superadmin" && superAdminRoutes.includes(req.path)) {
      // super admin - allow access to super admin routes
      next();
    } else if (
      userRole === "reception" &&
      receptionistRoutes.includes(req.path)
    ) {
      // receptionist - allow access to receptionist routes
      next();
    } else if (userRole === "manager" && managerRoutes.includes(req.path)) {
      // manager - allow access to manager routes
      next();
    } else {
      // user is not authorized to access this route
      // check if the route is public
      if (
        req.path === "/" ||
        req.path === "/login" ||
        req.path === "/about" ||
        req.path === "/book" ||
        req.path === "/checkout" ||
        req.path === "/checkin" ||
        req.path === "/logout"
      ) {
        next(); // allow access to public routes
      } else {
        res.status(401).render("401.ejs");
      }
    }
  } else {
    // user is not logged in
    if (
      superAdminRoutes.includes(req.path) ||
      receptionistRoutes.includes(req.path)
    ) {
      res.status(401).render("401.ejs");
    } else {
      next();
    }
  }
});

// PUBLIC ROUTES
app.get("/", (req, res) => {
  if (req.session.user) {
    if (req.session.user.role == "superadmin") {
      res.redirect("/dash/superadmin");
    } else if (req.session.user.role == "manager") {
      res.redirect("/dash/manager");
    } else {
      res.redirect("/dash/reception");
    }
  } else {
    dbConnection.query("SELECT * FROM rooms", (roomsSelectError, rooms) => {
      if (roomsSelectError) {
        res.status(500).send("Server Error: 500");
      } else {
        dbConnection.query("SELECT * FROM spots", (spotsSelectError, spots) => {
          if (spotsSelectError) {
            res.status(500).send("Server Error: 500");
          } else {
            res.render("index.ejs", { rooms, spots });
          }
        });
      }
    });
  }
});
app.get("/login", (req, res) => {
  res.render("login.ejs");
});
app.get("/checkout", (req, res) => {
  res.render("checkout.ejs");
});
app.get("/checkin", (req, res) => {
  res.render("checkin.ejs");
});
app.get("/about", (req, res) => {
  res.render("about.ejs");
});
app.get("/book", (req, res) => {
  if (req.query.type == "room") {
    dbConnection.query(
      `SELECT * FROM rooms WHERE room_id=${req.query.id}`,
      (error, roomData) => {
        if (error) {
          res.status(500).render("500.ejs");
        } else {
          res.render("book.ejs", {
            image: roomData[0].image_url,
            type: roomData[0].room_type,
            price: roomData[0].price_per_night,
            id: roomData[0].room_id,
            room: true,
          });
        }
      }
    );
  } else {
    dbConnection.query(
      `SELECT * FROM spots WHERE spot_id= '${req.query.id}'`,
      (error, spotData) => {
        if (error) {
          res.status(500).render("500.ejs");
        } else {
          res.render("book.ejs", {
            image: spotData[0].image_url,
            type: spotData[0].label,
            price: spotData[0].price,
            capacity: spotData[0].capacity_range,
            id: spotData[0].spot_id,
            room: false,
          });
        }
      }
    );
  }
});
app.post("/client-info", (req, res) => {
  const { name, email, phone } = req.body;
  // check if the client already exists in the database
  dbConnection.query(
    `SELECT * FROM clients WHERE email = '${email}'`,
    (error, clientData) => {
      if (error) {
        res.status(500).json({ message: "Server Error: 500", success: false });
      } else {
        if (clientData.length > 0) {
          // client already exists - update the client data
          dbConnection.query(
            `UPDATE clients SET full_name = "${name}", phone_number = "${phone}" WHERE email = "${email}"`,
            (error) => {
              if (error) {
                res
                  .status(500)
                  .json({ message: "Server Error: 500", success: false });
              } else {
                res.json({
                  message: "Client data updated successfully",
                  success: true,
                  clientID: clientData[0].client_id,
                });
              }
            }
          );
        } else {
          // client does not exist - insert new client data
          dbConnection.query(
            `INSERT INTO clients(full_name, email, phone_number) VALUES ("${name}", "${email}", "${phone}")`,
            (error) => {
              if (error) {
                res
                  .status(500)
                  .json({ message: "Server Error: 500", success: false });
              } else {
                // get the client ID of the newly inserted client
                dbConnection.query(
                  `SELECT * FROM clients WHERE email = '${email}'`,
                  (error, clientData) => {
                    if (error) {
                      res
                        .status(500)
                        .json({ message: "Server Error: 500", success: false });
                    } else {
                      res.json({
                        message: "Client data inserted successfully",
                        success: true,
                        clientID: clientData[0].client_id,
                      });
                    }
                  }
                );
              }
            }
          );
        }
      }
    }
  );
});

app.post("/completeBooking", (req, res) => {
  console.log(req.body);
  const { id, type, client, number, checkin } = req.body; // object destructuring
  if (type == "room") {
    // client_id INT,room INT,number_of_nights INT,checkin_date DATE,
    dbConnection.query(
      `INSERT INTO roomBookings(room, client_id, number_of_nights, checkin_date) VALUES(${id}, ${client}, ${number}, "${checkin}")`,
      (error) => {
        if (error) {
          res.status(500).render("500.ejs");
        } else {
          res.render("bookingsuccess.ejs", {
            message: "Room booked successfully",
          });
        }
      }
    );
  } else {
    //  client_id INT,spot VARCHAR(20),checkin_datetime DATETIME, meals VARCHAR(60), booking_status VARCHAR(50) DEFAULT 'pending', number_of_guests INT
    dbConnection.query(
      `INSERT INTO spotBookings(spot, client_id, checkin_datetime, number_of_guests,meals) VALUES("${id}", ${client}, "${checkin}", ${number}, "all")`,
      (error) => {
        if (error) {
          res.status(500).render("500.ejs");
        } else {
          res.render("bookingsuccess.ejs", {
            message: "Spot booked successfully",
          });
        }
      }
    );
  }
});
// END OF PUBLIC ROUTES
app.get("/bookings", (req, res) => {
  res.render("bookings.ejs");
});
// Manager Routes
app.get("/dash/manager", (req, res) => {
  res.render("manager/dash.ejs");
});
app.get("/addNewSpot", (req, res) => {
  res.render("manager/newSpot.ejs");
});
app.get("/addNewRoom", (req, res) => {
  res.render("manager/newRoom.ejs");
});
app.get("/addReceptionist", (req, res) => {
  res.render("manager/addReceptionist.ejs");
});
// END OF MANAGER ROUTES
// Receptionist Routes
app.get("/dash/reception", (req, res) => {
  // get all the data from db
  res.render("reception/dash.ejs", {
    spotbookings: [],
    roombookings: [],
    totalCheckins: 5,
  });
});
// end of receptionist routes
// super admin routes
app.get("/dash/superadmin", (req, res) => {
  res.render("superadmin/dash.ejs");
});
// end of super admin routes

app.post("/login", (req, res) => {
  const { email, password } = req.body;
  dbConnection.query(
    `SELECT * FROM users WHERE email="${email}"`,
    (error, userData) => {
      if (error) {
        res.status(500).render("500.ejs");
      } else {
        if (userData.length == 0) {
          res.status(401).send("User not found");
        } else {
          // user found - compate password using bcrypt
          const user = userData[0];
          const isPasswordValid = bcrypt.compareSync(password, user.password);
          if (isPasswordValid) {
            // password is valid - create session - express session middleware
            req.session.user = user; // creating a session for the user
            res.redirect("/"); // redirect to home page
          } else {
            // password is invalid
            res.status(401).send("Invalid password");
          }
        }
      }
    }
  );
});

app.get("/logout", (req, res) => {
  req.session.destroy(); // destroy the session);
  res.redirect("/"); // redirect to home page
});

// console.log(bcrypt.hashSync("admin678", 3)); // hash password - for testing

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
