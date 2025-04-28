const express = require("express");
const path = require("path");

const app = express();

// middleware
app.use(express.static(path.join(__dirname, "public"))); // path -- nested routs /booking/user/id
app.use(express.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded - form data

// routes

app.get("/", (req, res) => {
  res.render("index.ejs");
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
