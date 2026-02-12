import "package:flutter/material.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MainApp());
}
────────────────────────────────────────

class MyStorage {
  final _secureStorage = FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() {
    return AndroidOptions();
  }

  Future<void> saveEmail(String email) async {
    await _secureStorage.write(
      key: 'email',
      value: email,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<String?> readEmail() async {
    return await _secureStorage.read(
      key: 'email',
      aOptions: _getAndroidOptions(),
    );
  }


  Future<void> savePassword(String password) async {
    await _secureStorage.write(
      key: 'password',
      value: password,
      aOptions: _getAndroidOptions(),
    );
  }

 
  Future<void> clearAll() async {
    await _secureStorage.deleteAll(aOptions: _getAndroidOptions());
  }
}

class CartStorage {
  
  Future<void> write(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    if (!cart.contains(imageUrl)) {
      cart.add(imageUrl);
      await prefs.setStringList('cart', cart);
    }
  }

 
  Future<List<String>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cart') ?? [];
  }

 
  Future<void> remove(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    cart.remove(imageUrl);
    await prefs.setStringList('cart', cart);
  }

  
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }
}

────────────────────────────────────────

class Product {
  final String name;
  final String imageUrl;
  final String price;
  final String category;
  final String description;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.description,
  });
}


final List<Product> products = [
  Product(
    name: "Savon Naturel",
    imageUrl: "https://images.unsplash.com/photo-1607006344380-b6775a0824a7?w=400",
    price: "\$4.99",
    category: "Kategori 1",
    description: "Savon fèt ak engredyan natirèl. Bon pou po ou. Odè floral ki agreyab.",
  ),
  Product(
    name: "Savon Lavann",
    imageUrl: "https://images.unsplash.com/photo-1600857544200-b2f666a9a2ec?w=400",
    price: "\$5.99",
    category: "Kategori 1",
    description: "Savon lavann ki kalm ak relaks. Fèt pou swen chak jou ou.",
  ),
  Product(
    name: "Savon Kokoye",
    imageUrl: "https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400",
    price: "\$6.49",
    category: "Kategori 2",
    description: "Odè kokoye frèch. Moisturizing ak nouri po ou nèt.",
  ),
  Product(
    name: "Savon Sitwon",
    imageUrl: "https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=400",
    price: "\$4.49",
    category: "Kategori 2",
    description: "Savon sitwon pou netwaye pofondman. Fre ak vivan.",
  ),
  Product(
    name: "Savon Roze",
    imageUrl: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400",
    price: "\$7.99",
    category: "Kategori 1",
    description: "Savon roze elegàn. Pafèk kòm kado pou moun ou renmen.",
  ),
  Product(
    name: "Savon Miel",
    imageUrl: "https://images.unsplash.com/photo-1549058595-15c97a36e482?w=400",
    price: "\$5.49",
    category: "Kategori 2",
    description: "Savon siwo myèl dous ak nouri. Kite po ou bèl e dousman.",
  ),
];

// ─────────────────────────────────────────
//  APP ENTRY
// ─────────────────────────────────────────

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EBoutikoo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1a3a6b),
          primary: Color(0xFF1a3a6b),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CartStorage stockage = CartStorage();
  String selectedCategory = "Tout";

  List<Product> get filteredProducts {
    if (selectedCategory == "Tout") return products;
    return products.where((p) => p.category == selectedCategory).toList();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF1a3a6b),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _achte(Product product) async {
    // stockage.write() - sove lyen imaj la
    await stockage.write(product.imageUrl);
    _showSnackBar("${product.name} ajoute nan panye!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1a3a6b),
        foregroundColor: Colors.white,
        title: Text(
          "EBoutikoo",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          // Bouton pou ale nan Lis Achte
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a3a6b), Color(0xFF2d5aa0)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Byenveni nan EBoutikoo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Dekouvri pwodwi natirèl yo pi bon",
                    style: TextStyle(color: Colors.blue[200], fontSize: 13),
                  ),
                ],
              ),
            ),

            // Kategori pills
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["Tout", "Kategori 1", "Kategori 2"].map((cat) {
                    final isSelected = selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => setState(() => selectedCategory = cat),
                        selectedColor: Color(0xFF1a3a6b),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Kategori blocks
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                "Kategori",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ["Kategori 1", "Kategori 2"].map((cat) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: cat == "Kategori 1" ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedCategory = cat),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: selectedCategory == cat
                                ? Color(0xFF1a3a6b)
                                : Color(0xFF2d5aa0),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1a3a6b).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Pwodwi
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                "Pwodwi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    product: product,
                    onAchte: () => _achte(product),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  PRODUCT CARD WIDGET
// ─────────────────────────────────────────

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAchte;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAchte,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imaj pwodwi
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: Center(child: CircularProgressIndicator()),
                        );
                },
                errorBuilder: (context, error, stack) => Container(
                  height: 120,
                  color: Color(0xFF1a3a6b).withOpacity(0.2),
                  child: Icon(Icons.image, color: Color(0xFF1a3a6b), size: 40),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1e293b)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Lorem ipsum Lorem ipsum",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 2,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.price,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a3a6b),
                          fontSize: 13,
                        ),
                      ),
                      // Bouton Achte
                      GestureDetector(
                        onTap: onAchte,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF1a3a6b),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_cart,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                "Achte",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DETAIL SCREEN
// ─────────────────────────────────────────

class DetailScreen extends StatelessWidget {
  final Product product;
  final CartStorage stockage = CartStorage();

  DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1a3a6b),
        foregroundColor: Colors.white,
        title: Text("DETAY"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imaj prensipal
            Image.network(
              product.imageUrl,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : Container(
                        height: 260,
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      );
              },
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF1a3a6b).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                              color: Color(0xFF1a3a6b),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.price,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a3a6b),
                    ),
                  ),
                  Divider(height: 24),
                  Text(
                    product.description,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum.",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.6),
                  ),
                  SizedBox(height: 32),
                  // Bouton Achte prensipal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // stockage.write() - sove lyen imaj la
                        await stockage.write(product.imageUrl);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${product.name} ajoute nan panye!"),
                            backgroundColor: Color(0xFF1a3a6b),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(Icons.shopping_cart),
                      label: Text(
                        "Achte Kounye a",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1a3a6b),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  CART SCREEN (Lis Achte)
// ─────────────────────────────────────────

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartStorage stockage = CartStorage();
  List<String> cartImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    // stockage.readAll() - li tout lyen imaj ki anrejistre
    final images = await stockage.readAll();
    setState(() {
      cartImages = images;
      isLoading = false;
    });
  }

  Future<void> _removeItem(String imageUrl) async {
    await stockage.remove(imageUrl);
    _loadCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Pwodwi retire nan panye."),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _clearCart() async {
    await stockage.clearCart();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1a3a6b),
        foregroundColor: Colors.white,
        title: Text("Lis Pwodwi (${cartImages.length})"),
        actions: [
          if (cartImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: _clearCart,
              tooltip: "Efase tout",
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        "Panye ou vid",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Ajoute pwodwi pou kòmanse achte",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1a3a6b),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Ale achte"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: cartImages.length,
                        itemBuilder: (context, index) {
                          final imageUrl = cartImages[index];
                          // Jwenn pwodwi ki koresponn ak imaj la
                          final product = products.firstWhere(
                            (p) => p.imageUrl == imageUrl,
                            orElse: () => Product(
                              name: "Pwodwi ${index + 1}",
                              imageUrl: imageUrl,
                              price: "—",
                              category: "—",
                              description: "",
                            ),
                          );
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Imaj
                                ClipRRect(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(12)),
                                  child: Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, progress) {
                                      return progress == null
                                          ? child
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                strokeWidth: 2,
                                              )),
                                            );
                                    },
                                  ),
                                ),
                                // Info
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          product.category,
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          product.price,
                                          style: TextStyle(
                                            color: Color(0xFF1a3a6b),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bouton retire
                                IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.red[400]),
                                  onPressed: () => _removeItem(imageUrl),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Total
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total (${cartImages.length} atik)",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                "\$${_calculateTotal()}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1a3a6b),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFf5a623),
                                foregroundColor: Color(0xFF1a3a6b),
                                padding:
                                    EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                "Pase lòd",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  String _calculateTotal() {
    double total = 0;
    for (final url in cartImages) {
      final product = products.firstWhere(
        (p) => p.imageUrl == url,
        orElse: () => Product(
            name: "", imageUrl: "", price: "\$0", category: "", description: ""),
      );
      final price =
          double.tryParse(product.price.replaceAll("\$", "")) ?? 0;
      total += price;
    }
    return total.toStringAsFixed(2);
  }
}

// ─────────────────────────────────────────
//  DRAWER / MENU
// ─────────────────────────────────────────

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final MyStorage _myStorage = MyStorage();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final email = await _myStorage.readEmail();
    setState(() => isLoggedIn = email != null && email.isNotEmpty);
  }

  Future<void> _konekte() async {
    await _myStorage.saveEmail("user@eboutikoo.com");
    await _myStorage.savePassword("password123");
    setState(() => isLoggedIn = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Ou konekte!"),
          backgroundColor: Color(0xFF16a34a)),
    );
  }

  Future<void> _dekonekte() async {
    await _myStorage.clearAll();
    setState(() => isLoggedIn = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Ou dekonekte!"),
          backgroundColor: Colors.grey[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF1a3a6b),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0f2347),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF2d5aa0),
                    child: Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  SizedBox(height: 12),
                  Text(
                    isLoggedIn ? "user@eboutikoo.com" : "Pa konekte",
                    style: TextStyle(
                      color: isLoggedIn ? Colors.blue[200] : Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Konekte
            if (!isLoggedIn)
              ListTile(
                leading: Icon(Icons.login, color: Colors.white),
                title: Text("Konekte",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: _konekte,
              ),

            // Lis pwodwi
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.white),
              title: Text("Lis pwodwi",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen()),
                );
              },
            ),

            // Dekonekte
            if (isLoggedIn)
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red[300]),
                title: Text("Dekonekte",
                    style:
                        TextStyle(color: Colors.red[300], fontSize: 16)),
                onTap: _dekonekte,
              ),
          ],
        ),
      ),
    );
  }
}