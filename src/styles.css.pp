#lang pollen

.header {
  font-size: 150%;
  font-weight: 700;
}

p {
    white-space: pre-wrap;
}

hr {
  border: none;
  height: 1px;
  background-color: #e5e5e5;  /* Light grey color */
  margin: 15px 0;  /* Add some vertical spacing */
}

body {
  color:#2a2b2b;
  margin: 100px 10px;
  font-family: system-ui, sans-serif;
  font-size: 110%;
}

.title-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ul{
  margin:0
}

.tabs {
  display: flex;
  gap: 20px;
  font-size: 20px;
}

.tab {
  color: grey;
  text-decoration: none;
  border-bottom: 2px solid transparent;
}
.active-tab {
  color:black;
  text-decoration: none;
  border-bottom: 2 px solid transparent;
}

.name1 {
  font-size: 25px;
  color: black;
  text-decoration: none;
  border-bottom: 2px solid transparent;
}

.name2 {
  color:grey;
  text-decoration:none;
}

.tab:hover {
color: black;
}

.footer {
  margin-top:40px;
  display: flex;
  justify-content: space-between;
}

.footer-item{
  color: grey;
  text-decoration: none;
  border-bottom: 2px solid transparent;
}

.footer-item:hover {
  color:black;
}

.subfooter-item:hover {
  color:black;
}

.container {
  max-width: min(700px, 100%);
  margin:auto;
}

.subfooter {
  margin-top 50px;
  display: flex;
  justify-content: flex-end;
}

.subfooter-item {
  color:grey;
  text-decoration: none;
  border-bottom: 2px solid transparent;
}

a {
    text-decoration: none;
}

.inline-link {
  color:grey;
  text-decoration: none;
}

.inline-link:hover {
    color:black;
}

img {
  max-width: 100%;
  height: auto;
}

a {
  color:grey;
  text-decoration: none;
}

a:hover {
  color:black;
}
