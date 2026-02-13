import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MainApp());
}


class AppColors {
  static const rose = Color(0xFFE91E63);
  static const lightRose = Color(0xFFF8BBD0);
  static const white = Color(0xFFFFFFFF);
  
  static const gradient = LinearGradient(
    colors: [white, lightRose, white],
  );
}

class Storage {
  final _s = const FlutterSecureStorage();
  
  Future<void> saveEmail(String v) => _s.write(key: 'email', value: v);
  Future<String?> getEmail() => _s.read(key: 'email');
  Future<void> saveName(String v) => _s.write(key: 'name', value: v);
  Future<String?> getName() => _s.read(key: 'name');
  Future<void> savePass(String v) => _s.write(key: 'pass', value: v);
  Future<String?> getPass() => _s.read(key: 'pass');
  Future<void> clear() => _s.deleteAll();
}

class Cart {
  Future<void> add(String url) async {
    final p = await SharedPreferences.getInstance();
    List<String> c = p.getStringList('cart') ?? [];
    if (!c.contains(url)) {
      c.add(url);
      await p.setStringList('cart', c);
    }
  }

  Future<List<String>> getAll() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList('cart') ?? [];
  }

  Future<void> remove(String url) async {
    final p = await SharedPreferences.getInstance();
    List<String> c = p.getStringList('cart') ?? [];
    c.remove(url);
    await p.setStringList('cart', c);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('cart');
  }
}


class Product {
  final String name, img, cat, desc;
  final double price;
  
  const Product(this.name, this.img, this.price, this.cat, this.desc);
  String get priceStr => "${price.toInt()} Gdes";
}

final products = [
  Product("Chokola Nwa", "https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400", 520, "Chokola", "Chokola 85% kakao"),
  Product("Bwat Valanten", "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=400", 999, "Spesyal", "Bwat Sen Valanten"),
  Product("Chokola Wouj", "https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=400", 399, "Spesyal", "Chokola wouj"),
  Product("Trüf", "https://images.unsplash.com/photo-1548907040-4baa42d10919?w=400", 759, "Trüf", "Trüf chokola"),
  Product("Lèt Karamel", "https://images.unsplash.com/photo-1547592180-85f173990554?w=400", 599, "Chokola", "Chokola lèt"),
  Product("Platine", "https://images.unsplash.com/photo-1576618148400-f54bed99fcfd?w=400", 1399, "Spesyal", "Koleksyon eksklizyf"),
];


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: AppColors.rose, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final email = await Storage().getEmail();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => (email?.isNotEmpty ?? false) ? const HomeScreen() : const AuthScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("BM", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("BMaxBoutik", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.rose)),
              const Text("🍫 Chokola & Sen Valanten ❤️", style: TextStyle(color: AppColors.rose)),
            ],
          ),
        ),
      ),
    );
  }
}


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final s = Storage();
    if (isSignIn) {
      
      final e = await s.getEmail();
      final p = await s.getPass();
      if (e != _email.text || p != _pass.text) {
        setState(() => loading = false);
        msg("❌ Email oswa modpas pa bon");
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      
      await s.saveEmail(_email.text);
      await s.savePass(_pass.text);
      if (_name.text.isNotEmpty) await s.saveName(_name.text);
      setState(() => loading = false);
      msg("✅ Kont kreye!");
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        isSignIn = true;
        _pass.clear();
        _name.clear();
      });
    }
  }

  void msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.rose));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // ── Logo ──
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
                    child: const Center(child: Text("BM", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 30),
                  
                 
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightRose.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.rose, width: 2),
                    ),
                    child: Text(
                      isSignIn ? "👋 Bon retou!\nKonekte pou kontinye" : "✨ Kreye kont ou\nEnskri pou kòmanse",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.rose),
                    ),
                  ),
                  const SizedBox(height: 30),

                 
                  if (!isSignIn) ...[
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: "Non",
                        prefixIcon: const Icon(Icons.person, color: AppColors.rose),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? "Antre non" : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email, color: AppColors.rose),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return "Antre email";
                      if (!v!.contains('@')) return "Email pa valid";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _pass,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Modpas",
                      prefixIcon: const Icon(Icons.lock, color: AppColors.rose),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return "Antre modpas";
                      if (v!.length < 6) return "Min 6 karaktè";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

              
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rose,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isSignIn ? "🔐 Konekte" : "✨ Kreye kont", style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSignIn = !isSignIn;
                        _email.clear();
                        _pass.clear();
                        _name.clear();
                      });
                    },
                    child: Text(isSignIn ? "Pa gen kont? 📝 Kreye" : "Gen kont? 🔑 Konekte", style: const TextStyle(color: AppColors.rose)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String cat = "Tout";
  int count = 0;
  final cart = Cart();

  List<Product> get filtered => cat == "Tout" ? products : products.where((p) => p.cat == cat).toList();

  @override
  void initState() {
    super.initState();
    loadCount();
  }

  Future<void> loadCount() async {
    final items = await cart.getAll();
    setState(() => count = items.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMaxBoutik", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.rose,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  loadCount();
                },
              ),
              if (count > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Text("$count", style: const TextStyle(color: AppColors.rose, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(onUpdate: loadCount),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: CustomScrollView(
          slivers: [
            
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: AppColors.rose,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Byenveni 👋", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("🍫 Chokola Sen Valanten ❤️", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _Card("Pwodwi", "${products.length}", Icons.inventory_2, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllProducts()))),
                    _Card("Panye", "$count", Icons.shopping_cart, () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                      loadCount();
                    }),
                    _Card("Kategori", "3", Icons.category, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Categories()))),
                    _Card("Espesyal", "❤️", Icons.favorite, () {}),
                  ],
                ),
              ),
            ),

           
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["Tout", "Chokola", "Spesyal", "Trüf"].map((c) {
                      final sel = cat == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => cat = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.rose : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.rose),
                            ),
                            child: Text(c, style: TextStyle(color: sel ? Colors.white : AppColors.rose, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final p = filtered[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Detail(p))),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(p.img, fit: BoxFit.cover, width: double.infinity),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1),
                                  Text(p.priceStr, style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await cart.add(p.img);
                                        loadCount();
                                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ ${p.name} ajoute!"), backgroundColor: AppColors.rose));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.rose,
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                      ),
                                      child: const Text("🛒", style: TextStyle(fontSize: 16, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _Card extends StatelessWidget {
  final String title, sub;
  final IconData icon;
  final VoidCallback onTap;
  const _Card(this.title, this.sub, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.rose,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class AllProducts extends StatelessWidget {
  const AllProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tout Pwodwi"), backgroundColor: AppColors.rose, foregroundColor: Colors.white),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
          itemCount: products.length,
          itemBuilder: (_, i) {
            final p = products[i];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Detail(p))),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(p.img, fit: BoxFit.cover, width: double.infinity))),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(p.priceStr, style: const TextStyle(color: AppColors.rose)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = ["Chokola", "Spesyal", "Trüf"];
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori"), backgroundColor: AppColors.rose, foregroundColor: Colors.white),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final c = cats[i];
            final cnt = products.where((p) => p.cat == c).length;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                tileColor: AppColors.rose,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.category, color: Colors.white),
                title: Text(c, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("$cnt pwodwi", style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatDetail(c))),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CatDetail extends StatelessWidget {
  final String cat;
  const CatDetail(this.cat, {super.key});

  @override
  Widget build(BuildContext context) {
    final ps = products.where((p) => p.cat == cat).toList();
    return Scaffold(
      appBar: AppBar(title: Text(cat), backgroundColor: AppColors.rose, foregroundColor: Colors.white),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
          itemCount: ps.length,
          itemBuilder: (_, i) {
            final p = ps[i];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Detail(p))),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(p.img, fit: BoxFit.cover, width: double.infinity))),
                    Padding(padding: const EdgeInsets.all(8), child: Column(children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(p.priceStr, style: const TextStyle(color: AppColors.rose))])),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Detail extends StatelessWidget {
  final Product p;
  const Detail(this.p, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(p.name), backgroundColor: AppColors.rose, foregroundColor: Colors.white),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(p.img, height: 300, width: double.infinity, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightRose.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.rose, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.rose)),
                          const SizedBox(height: 8),
                          Text(p.priceStr, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.rose)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("📂 ${p.cat}", style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(p.desc, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await Cart().add(p.img);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ ${p.name} ajoute!"), backgroundColor: AppColors.rose));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose, padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text("🛒 Ajoute nan panye", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<String> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final i = await Cart().getAll();
    setState(() {
      items = i;
      loading = false;
    });
  }

  double get total {
    double t = 0;
    for (var url in items) {
      final p = products.firstWhere((p) => p.img == url);
      t += p.price;
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🛒 Panye (${items.length})"),
        backgroundColor: AppColors.rose,
        foregroundColor: Colors.white,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                await Cart().clear();
                load();
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.rose))
            : items.isEmpty
                ? const Center(child: Text("Panye vid", style: TextStyle(fontSize: 20, color: AppColors.rose)))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final url = items[i];
                            final p = products.firstWhere((p) => p.img == url);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)), child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover)),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(p.priceStr, style: const TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.rose),
                                    onPressed: () async {
                                      await Cart().remove(url);
                                      load();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text("${total.toInt()} Gdes", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.rose)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Lòd pase!"), backgroundColor: Colors.green));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose, padding: const EdgeInsets.symmetric(vertical: 16)),
                                child: const Text("💳 Pase lòd", style: TextStyle(fontSize: 18, color: Colors.white)),
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

class AppDrawer extends StatefulWidget {
  final VoidCallback? onUpdate;
  const AppDrawer({super.key, this.onUpdate});
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? name;

  @override
  void initState() {
    super.initState();
    Storage().getName().then((n) => setState(() => name = n));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.rose),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Text("BM", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.rose))),
                  const SizedBox(height: 12),
                  Text(name ?? "Itilizatè", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text("Akèy"), onTap: () => Navigator.pop(context)),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Panye"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.rose),
              title: const Text("Dekonekte", style: TextStyle(color: AppColors.rose)),
              onTap: () async {
                await Storage().clear();
                if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
