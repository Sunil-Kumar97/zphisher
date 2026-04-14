<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sharma General Store</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
<style>
body {font-family:Poppins,sans-serif;margin:0;background:#f5f7fb;}
header {background:#2c7be5;color:#fff;padding:15px;text-align:center;}
h1 {margin:5px;}
.tagline {font-size:14px;opacity:.9;}

.filters {display:flex;overflow:auto;padding:10px;background:#fff;}
.filters button {
  margin-right:8px;padding:8px 12px;border:none;border-radius:20px;
  background:#e0e6ed;cursor:pointer;
}
.filters button.active {background:#2c7be5;color:#fff;}

.grid {
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(160px,1fr));
  gap:10px;padding:10px;
}
.card {
  background:#fff;border-radius:10px;padding:10px;
  box-shadow:0 2px 6px rgba(0,0,0,.1);
}
.card img {width:100%;border-radius:8px;}
.card h4 {margin:5px 0;font-size:14px;}
.price {color:#2c7be5;font-weight:600;}
.card button {
  width:100%;padding:6px;border:none;border-radius:5px;
  background:#2c7be5;color:#fff;cursor:pointer;
}

.cart-btn {
  position:fixed;bottom:20px;right:20px;
  background:#2c7be5;color:#fff;padding:12px 15px;
  border-radius:50px;cursor:pointer;
}

.cart {
  position:fixed;top:0;right:-100%;width:100%;max-width:400px;
  height:100%;background:#fff;box-shadow:-2px 0 10px rgba(0,0,0,.2);
  transition:.3s;padding:15px;overflow:auto;
}
.cart.open {right:0;}
.cart h2 {margin-top:0;}

.item {display:flex;justify-content:space-between;margin:10px 0;}
.qty button {padding:3px 8px;}

.total {font-weight:600;margin-top:10px;}

form input, form textarea {
  width:100%;padding:8px;margin:5px 0;border-radius:5px;border:1px solid #ccc;
}

form button {
  width:100%;padding:10px;background:#28a745;color:#fff;
  border:none;border-radius:5px;margin-top:10px;
}

.whatsapp {
  position:fixed;bottom:80px;right:20px;
  background:#25D366;color:#fff;padding:10px 15px;
  border-radius:50px;text-decoration:none;
}
</style>
</head>

<body>

<header>
  <h1>Sharma General Store</h1>
  <div class="tagline">Fresh groceries delivered to your door</div>
</header>

<div class="filters" id="filters"></div>
<div class="grid" id="products"></div>

<div class="cart-btn" onclick="toggleCart()">🛒 <span id="count">0</span></div>

<div class="cart" id="cart">
  <h2>Your Cart</h2>
  <div id="cartItems"></div>
  <div class="total" id="total"></div>

  <h3>Checkout</h3>
  <form action="https://formspree.io/f/YOUR_FORM_ID" method="POST" onsubmit="prepareOrder()">
    <input type="text" name="name" placeholder="Your Name" required>
    <input type="tel" name="phone" placeholder="Phone Number" required>
    <textarea name="address" placeholder="Delivery Address" required></textarea>
    <textarea name="notes" placeholder="Instructions (optional)"></textarea>

    <input type="hidden" name="order_details" id="orderDetails">

    <button type="submit">Place Order</button>
  </form>
</div>

<a class="whatsapp" href="https://wa.me/6239316470" target="_blank">Chat on WhatsApp</a>

<script>
const products = [
{ id:1, name:"Aashirvaad Atta (5kg)", price:280, cat:"Groceries", img:"https://i.ibb.co/8zQ1m8V/atta.jpg", desc:"Premium whole wheat flour" },
{ id:2, name:"Amul Butter (500g)", price:280, cat:"Dairy", img:"https://i.ibb.co/3cKQq5S/butter.jpg", desc:"Fresh salted butter" },
{ id:3, name:"Milk 1L", price:60, cat:"Dairy", img:"https://i.ibb.co/2y8G1Lx/milk.jpg", desc:"Fresh milk daily" },
{ id:4, name:"Maggi Noodles", price:14, cat:"Snacks", img:"https://i.ibb.co/F0s3WbS/maggi.jpg", desc:"2-minute noodles" },
{ id:5, name:"Coca Cola 1L", price:90, cat:"Beverages", img:"https://i.ibb.co/W3h1WnK/coke.jpg", desc:"Chilled soft drink" },
{ id:6, name:"Rice 5kg", price:350, cat:"Groceries", img:"https://i.ibb.co/6rXk2bX/rice.jpg", desc:"Premium basmati rice" },
{ id:7, name:"Bread", price:40, cat:"Snacks", img:"https://i.ibb.co/4Rk2sGz/bread.jpg", desc:"Fresh bakery bread" },
{ id:8, name:"Eggs (12)", price:90, cat:"Dairy", img:"https://i.ibb.co/QcZkYbW/eggs.jpg", desc:"Farm fresh eggs" }
];

let cart = JSON.parse(localStorage.getItem("cart")) || {};

function renderProducts(filter="All") {
  const grid = document.getElementById("products");
  grid.innerHTML = "";
  products.filter(p => filter==="All" || p.cat===filter)
  .forEach(p=>{
    grid.innerHTML += `
    <div class="card">
      <img src="${p.img}" loading="lazy" alt="${p.name}">
      <h4>${p.name}</h4>
      <div class="price">₹${p.price}</div>
      <button onclick="addToCart(${p.id})">Add to Cart</button>
    </div>`;
  });
}

function renderFilters() {
  const cats = ["All",...new Set(products.map(p=>p.cat))];
  const f = document.getElementById("filters");
  cats.forEach(c=>{
    const btn = document.createElement("button");
    btn.innerText=c;
    btn.onclick=()=>renderProducts(c);
    f.appendChild(btn);
  });
}

function addToCart(id) {
  cart[id] = (cart[id] || 0) + 1;
  saveCart();
}

function saveCart() {
  localStorage.setItem("cart", JSON.stringify(cart));
  updateCart();
}

function updateCart() {
  const c = document.getElementById("cartItems");
  c.innerHTML="";
  let total=0,count=0;

  for(let id in cart){
    const p = products.find(x=>x.id==id);
    const qty = cart[id];
    total += p.price*qty;
    count += qty;

    c.innerHTML += `
    <div class="item">
      ${p.name} x${qty}
      <div class="qty">
        <button onclick="changeQty(${id},-1)">-</button>
        <button onclick="changeQty(${id},1)">+</button>
      </div>
    </div>`;
  }

  document.getElementById("total").innerText="Total: ₹"+total;
  document.getElementById("count").innerText=count;
}

function changeQty(id,delta){
  cart[id]+=delta;
  if(cart[id]<=0) delete cart[id];
  saveCart();
}

function toggleCart(){
  document.getElementById("cart").classList.toggle("open");
}

function prepareOrder(){
  let text="Order Details:\n";
  let total=0;

  for(let id in cart){
    const p = products.find(x=>x.id==id);
    const qty = cart[id];
    total += p.price*qty;
    text += `${p.name} x${qty} = ₹${p.price*qty}\n`;
  }

  text += `Total: ₹${total}`;
  document.getElementById("orderDetails").value = text;

  localStorage.removeItem("cart");
  alert("Order placed! Shop will contact you soon.");
}

renderFilters();
renderProducts();
updateCart();
</script>

</body>
</html>
