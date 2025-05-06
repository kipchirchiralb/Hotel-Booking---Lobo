const express = require("express");
const path = require("path");
const mysql = require("mysql");
const bcrypt = require("bcrypt");
const session = require("express-session");

const dbConnection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "hotel_lobo",
});

const app = express();

// middleware
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
        res.status(401).send("Unauthorized - 401");
      }
    }
  } else {
    // user is not logged in
    if (
      superAdminRoutes.includes(req.path) ||
      receptionistRoutes.includes(req.path)
    ) {
      res.status(401).send("Unauthorized - 401");
    } else {
      next();
    }
  }
});

// PUBLIC ROUTES
app.get("/", (req, res) => {
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
  res.render("book.ejs");
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
  res.render("reception/dash.ejs");
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
        res.status(500).send("Server Error: 500");
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
