import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ovapdygzriiojovtnngq.supabase.co',
    anonKey: 'sb_publishable_xxaS68ILN2mFPpFVVPXsVg_bRxhQ97U',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A0000),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF800000), elevation: 0),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => MainNavigationWrapperState();
}

class MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentPageIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _showPromoPoster(context);
    });
  }

  void _navigateTo(int index) {
    setState(() => _currentPageIndex = index);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF800000),
            border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("EMAS JUVITA", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                _navButton("HOME", 0),
                _navButton("SHOP", 1),
                _navButton("LIVE PRICE", 2),
                _navButton("ABOUT", 3),
                _navButton("CONTACT", 4),
                _navButton("LINKS", 5),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _getPage(_currentPageIndex),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return const HeroSection();
      case 1: return const ShopPage();
      case 2: return const LivePricePage();
      case 3: return const AboutPage();
      case 4: return const ContactPage();
      case 5: return const LinktreePage();
      default: return const HeroSection();
    }
  }

  Widget _navButton(String title, int index) {
    bool isSelected = _currentPageIndex == index;
    return TextButton(
      onPressed: () => _navigateTo(index),
      child: Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFD4AF37), fontSize: 12)),
    );
  }
}

// --- PAGE 1: HOMEPAGE ---
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late Timer _timer;

  final List<String> _sliderImages = [
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/slider%201.png",
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/slider%202.png",
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/slider%203.png",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentIndex < _sliderImages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(_currentIndex,
            duration: const Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. DYNAMIC SLIDER
        SizedBox(
          height: 600,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _sliderImages.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) => _buildSlide(_sliderImages[index], "EXCLUSIVE COLLECTION"),
              ),
              _sliderArrow(Icons.arrow_back_ios, () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut), left: 20),
              _sliderArrow(Icons.arrow_forward_ios, () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut), right: 20),
            ],
          ),
        ),
        
        const SizedBox(height: 60),
        _buildPriceCardWithButton(context, 385.50),
        
        const SizedBox(height: 60),
        _buildStoryBox(context),
        
        const SizedBox(height: 80),

        // 4. OUR PRESENCE (Responsive Wrap)
        const Text(
          "OUR PRESENCE", 
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 20, 
            runSpacing: 30, 
            alignment: WrapAlignment.center, 
            children: [
              _buildPresenceCard(
                "Kedai Emas Juvita HQ", 
                "45, Jalan Flora Utama 5, Batu Pahat", 
                "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20HQ.png",
                "https://maps.app.goo.gl/RucVvWeum682AVAeA" // REPLACE WITH REAL LINK
              ),
              _buildPresenceCard(
                "Kedai Emas Juvita Penggaram", 
                "34, Jalan Penggaram, Batu Pahat", 
                "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20Penggaram.png",
                "https://maps.app.goo.gl/PBYAKuTSL7JYQaoq6" // REPLACE WITH REAL LINK
              ),
              _buildPresenceCard(
                "Kedai Emas Juvita Parit Sulong", 
                "88, Jalan Besar, Parit Sulong", 
                "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20Parit%20Sulong.png",
                "https://maps.app.goo.gl/2oUp8N9DdXA4WvCD7" // REPLACE WITH REAL LINK
              ),
              _buildPresenceCard(
                "Kedai Emas Juvita Parit Raja", 
                "23, Jalan Perdagangan 2, Parit Raja", 
                "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20Parit%20Raja.png",
                "https://maps.app.goo.gl/BdSLE3BGj8VVrzRw5" // REPLACE WITH REAL LINK
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),

        // 5. Investment vs Jewellery Section
        _buildInvestmentSection(context),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildInvestmentSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Investment vs Jewellery: Why 916 & 999 Matter",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 50),
        
        _buildHorizontalInvestmentBox(
          context,
          imageUrl: "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/916%20img.png", 
          title: "916 GOLD (22K) – For Ornate Jewellery",
          description: "Durable and beautiful, perfect for intricate designs to be worn daily. The standard for traditional elegance. Ideal for wedding sets and daily wear.",
          buttonText: "Shop 916 Collections",
        ),

        const SizedBox(height: 30),

        _buildHorizontalInvestmentBox(
          context,
          imageUrl: "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/999%20img.png", 
          title: "999 GOLD (24K) – For Pure Investment",
          description: "The highest purity, for maximal wealth preservation and investment. Unalloyed for lasting value. Ideal for gold savings and investment portfolio diversification.",
          buttonText: "Shop 999 Collections",
        ),
      ],
    );
  }

  Widget _buildHorizontalInvestmentBox(BuildContext context, {required String imageUrl, required String title, required String description, required String buttonText}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 50),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl, width: 220, height: 220, fit: BoxFit.cover),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => context.findAncestorStateOfType<MainNavigationWrapperState>()?._navigateTo(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  ),
                  child: Text(buttonText.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceCard(String name, String address, String imageUrl, String mapUrl) {
    return Container(
      width: 320, 
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(imageUrl, height: 350, width: 320, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(address, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _launchURL(mapUrl),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD4AF37), side: const BorderSide(color: Color(0xFFD4AF37))),
                    child: const Text("VIEW ON MAP", style: TextStyle(fontSize: 12)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCardWithButton(BuildContext context, double price) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text("TODAY'S 916 PRICE", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text("RM ${price.toStringAsFixed(2)}/g", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            onPressed: () => context.findAncestorStateOfType<MainNavigationWrapperState>()?._navigateTo(2),
            child: const Text("CHECK FULL PRICE LIST", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: const Color(0xFF2A0000), 
          border: Border.all(color: const Color(0xFFD4AF37), width: 1), 
          borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          children: [
            const Text("CRAFTING TRUST IN BATU PAHAT", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 3, fontWeight: FontWeight.bold, fontSize: 26)),
            const SizedBox(height: 25),
            const Text(
              "What began in the heart of Batu Pahat has blossomed into a legacy of excellence, now spanning four branches to better serve our community with premium gold and unmatched service.", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.8)
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: () => context.findAncestorStateOfType<MainNavigationWrapperState>()?._navigateTo(3),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37), 
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)
              ),
              child: const Text("LEARN OUR STORY", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(String imageUrl, String title) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(imageUrl, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.4)),
        Center(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 8))),
      ],
    );
  }

  Widget _sliderArrow(IconData icon, VoidCallback onTap, {double? left, double? right}) {
    return Positioned(left: left, right: right, top: 0, bottom: 0, child: Center(child: IconButton(icon: Icon(icon, color: const Color(0xFFD4AF37), size: 35), onPressed: onTap)));
  }
}

// --- PAGE 2: SHOP PAGE ---
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String _selectedCategory = '916 GOLD';

  // --- 1. DEFINE INDIVIDUAL 916 PRODUCTS HERE ---
  final List<Product> _products916 = [
    Product(
      name: "916 Gold Bracelet Series #1",
      marketPrice: 385.00,
      labourFee: 150.0,
      description: "A premium 916 gold piece crafted with precision and traditional elegance.",
      category: "916 GOLD",
      imageUrl: "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Gold%20Bracelet.png",
    ),
    Product(
      name: "916 Gold Necklace Series #2",
      marketPrice: 385.00,
      labourFee: 120.0,
      description: "Elegant 916 gold bracelet featuring intricate floral patterns.",
      category: "916 GOLD",
      imageUrl: "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Gold%20Necklace.png", // Replace with actual image URL
    ),
    Product(
      name: "916 Gold Ring Series #3",
      marketPrice: 385.00,
      labourFee: 80.0,
      description: "Classic 916 gold ring, perfect for daily wear and traditional sets.",
      category: "916 GOLD",
      imageUrl: "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Gold%20Rings.png", // Replace with actual image URL
    ),
  ];

  // --- 2. DEFINE INDIVIDUAL 999 PRODUCTS HERE ---
  final List<Product> _products999 = [
    Product(
      name: "999 Investment Bar",
      marketPrice: 420.00,
      labourFee: 80.0,
      description: "Pure 24K gold bar, the ultimate choice for wealth preservation and investment.",
      category: "999 GOLD",
      imageUrl: "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Gold%20Bars.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine which list to display
    List<Product> currentList = (_selectedCategory == '916 GOLD') ? _products916 : _products999;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
      child: Column(
        children: [
          const Text("COLLECTIONS",
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          // CATEGORY SELECTOR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4AF37)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF1A0000),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4AF37)),
                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                items: ['916 GOLD', '999 GOLD'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // PRODUCT GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
            ),
            itemCount: currentList.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, currentList[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("RM ${product.marketPrice.toStringAsFixed(2)}/g",
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10)),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    minimumSize: const Size(double.infinity, 28),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    // FIXED: Now correctly navigates to details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(product: product),
                      ),
                    );
                  },
                  child: const Text("VIEW",
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- DYNAMIC PRODUCT DETAILS PAGE ---
class ProductDetailsPage extends StatefulWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  double _selectedWeight = 10.0; // Default variation

  double _calculateTotal() {
    return (widget.product.marketPrice * _selectedWeight) + widget.product.labourFee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0000),
      appBar: AppBar(
        title: Text(widget.product.name),
        // IMPROVED CONTRAST: Gold text and icons on dark red background
        backgroundColor: const Color(0xFF4A0000), 
        foregroundColor: const Color(0xFFD4AF37), 
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMPROVED IMAGE AREA: Not full width, better fitting
            Center(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A0000), // Slightly lighter frame
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.product.imageUrl, 
                    fit: BoxFit.contain, // Ensures the whole product is visible
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.product.category, 
                  style: const TextStyle(color: Color(0xFFD4AF37), letterSpacing: 2, fontWeight: FontWeight.w600)),
                Text("Market: RM ${widget.product.marketPrice}/g", 
                  style: const TextStyle(color: Colors.white60, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.product.name, 
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 30),
            const Text("SELECT WEIGHT VARIATION (GRAMS)", 
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Variation Buttons
            Row(
              children: [10.0, 30.0, 50.0].map((weight) {
                bool isSelected = _selectedWeight == weight;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onPressed: () => setState(() => _selectedWeight = weight),
                    child: Text("${weight.toInt()}g", 
                      style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // Price Breakdown Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A0000),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5))
              ),
              child: Column(
                children: [
                  _priceRow("Gold Value (${_selectedWeight}g x RM ${widget.product.marketPrice})", 
                            "RM ${(widget.product.marketPrice * _selectedWeight).toStringAsFixed(2)}"),
                  const SizedBox(height: 10),
                  _priceRow("Labour Fee", "RM ${widget.product.labourFee.toStringAsFixed(2)}"),
                  const Divider(color: Color(0xFFD4AF37), height: 30),
                  _priceRow("ESTIMATED TOTAL", "RM ${_calculateTotal().toStringAsFixed(2)}", isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("DESCRIPTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.product.description, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
            
            const SizedBox(height: 50),
            
            // Call to Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37), 
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () {
                  // Assuming _launchWhatsApp is defined elsewhere
                },
                child: const Text("INQUIRE VIA WHATSAPP", 
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: isTotal ? Colors.white : Colors.white60, 
          fontSize: isTotal ? 16 : 14, 
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(
          color: const Color(0xFFD4AF37), 
          fontSize: isTotal ? 20 : 14, 
          fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- UPDATED DATA MODEL ---
class Product {
  final String name;
  final double marketPrice;
  final String description;
  final String category;
  final double labourFee;
  final String imageUrl;

  Product({
    required this.name, 
    required this.marketPrice, 
    required this.description, 
    required this.category,
    required this.labourFee,
    required this.imageUrl,
  });
}

// --- PAGE 3: LIVE PRICE PAGE ---
class LivePricePage extends StatefulWidget {
  const LivePricePage({super.key});

  @override
  State<LivePricePage> createState() => _LivePricePageState();
}

class _LivePricePageState extends State<LivePricePage> {
  // 1. Centralized Data: Change these and the whole UI updates
  double gold916Price = 389.00;
  double gold999Price = 420.00;
  double gold750Price = 314.00;
  
  String lastUpdated = "March 13, 2026 5:53 am";

  // 2. Logic to update price and timestamp simultaneously
  void updateGoldPrice(double newPrice) {
    setState(() {
      gold916Price = newPrice;
      // Generates a real-time timestamp
      lastUpdated = DateFormat('MMMM dd, yyyy h:mm a').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0000),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Serif'),
                  children: [
                    TextSpan(text: "LIVE "),
                    TextSpan(text: "GOLD", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                    TextSpan(text: " PRICE (per gram):"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- CONNECTED BIG PRICE ---
              Text(
                "RM${gold916Price.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -2,
                ),
              ),
              
              // --- DYNAMIC TIMESTAMP ---
              Text(
                "Last Updated: $lastUpdated",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 60),

              // PRICE TABLE
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Table(
                    children: [
                      _tableHeader("GOLD TYPE", "PRICE (PER GRAM)"),
                      _tableRow("Gold 999 (24k)", "RM${gold999Price.toStringAsFixed(2)}"),
                      
                      // --- CONNECTED TABLE PRICE ---
                      _tableRow("Gold 916 (22k)", "RM${gold916Price.toStringAsFixed(2)}", isHighlighted: true),
                      
                      _tableRow("Gold 750 (18k)", "RM${gold750Price.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // TEMPORARY: Button to test the update (You can remove this later)
              ElevatedButton(
                onPressed: () => updateGoldPrice(395.50), 
                child: const Text("Simulate Price Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableHeader(String c1, String c2) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFFAF9F6)),
      children: [
        Padding(padding: const EdgeInsets.all(20), child: Text(c1, style: const TextStyle(color: Color(0xFFBC9340), fontWeight: FontWeight.bold, fontSize: 13))),
        Padding(padding: const EdgeInsets.all(20), child: Text(c2, style: const TextStyle(color: Color(0xFFBC9340), fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
      ],
    );
  }

  TableRow _tableRow(String label, String price, {bool isHighlighted = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFFFFBEA) : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      children: [
        Padding(padding: const EdgeInsets.all(22), child: Text(label, style: const TextStyle(color: Color(0xFF444444), fontSize: 15, fontWeight: FontWeight.w500))),
        Padding(padding: const EdgeInsets.all(22), child: Text(price, style: const TextStyle(color: Color(0xFF444444), fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
      ],
    );
  }
}

// --- PAGE 4: ABOUT PAGE ---
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(100),
      child: Text("Emas Juvita is your premium partner in fine gold jewelry.", 
        textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
    );
  }
}

// --- PAGE 5: CONTACT PAGE ---
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(100),
      child: Column(
        children: [
          const Text("VISIT OUR LOCATIONS", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24)),
          const SizedBox(height: 20),
          const Text("Batu Pahat | Port Klang | Kuala Lumpur", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _launchWhatsApp("General Inquiry"),
            child: const Text("Chat on WhatsApp"),
          )
        ],
      ),
    );
  }
}

// --- PAGE 6: LINKTREE PAGE ---
class LinktreePage extends StatelessWidget {
  const LinktreePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 80),
        width: 300,
        child: Column(
          children: [
            _linkButton("Main Website"),
            _linkButton("Instagram"),
            _linkButton("Facebook"),
          ],
        ),
      ),
    );
  }

  Widget _linkButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
          onPressed: () {},
          child: Text(title, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

// --- SHARED COMPONENTS ---
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: const Column(
        children: [
          Text("EMAS JUVITA", style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 5)),
          SizedBox(height: 10),
          Text("© 2026 Premium Gold Solutions", style: TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }
}

// --- UTILITIES (Global Scope) ---
void _showPromoPoster(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A0000),
      shape: const RoundedRectangleBorder(side: BorderSide(color: Color(0xFFD4AF37))),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("EXCLUSIVE PROMO", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text("0% Workmanship on Selected 916 Gold Items", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE"))],
    ),
  );
}

void _launchWhatsApp(String message) async {
  final url = "https://wa.me/60195666650?text=${Uri.encodeComponent(message)}";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  }
}

void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}