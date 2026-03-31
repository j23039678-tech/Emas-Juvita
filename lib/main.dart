import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Recommended for social icons

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
  bool _isLoggedIn = false;
  final ScrollController _scrollController = ScrollController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        final userId = session.user.id;
        final profile = await supabase.from('profiles').select('is_approved').eq('id', userId).maybeSingle();

        if (profile == null || profile['is_approved'] != true) {
          await supabase.auth.signOut(); 
          if (mounted) {
            setState(() => _isLoggedIn = false);
            _navigateTo(0);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("ACCESS DENIED: Awaiting VIP approval."), backgroundColor: Colors.redAccent),
            );
          }
        } else {
          if (mounted) setState(() => _isLoggedIn = true);
        }
      } else {
        if (mounted) setState(() => _isLoggedIn = false);
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _showPromoPoster(context); 
    });
  }

  void _navigateTo(int index) {
    setState(() => _currentPageIndex = index);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeIn
      );
    }
  }

  Future<void> _handleAuthAction() async {
    if (_isLoggedIn) {
      await supabase.auth.signOut();
      _navigateTo(0); 
    } else {
      _navigateTo(6); 
    }
  }

  // --- MOBILE DRAWER ITEM HELPER ---
  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        _navigateTo(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0000),
      
      // --- DRAWER (Mobile Only) ---
      drawer: isMobile ? Drawer(
        backgroundColor: const Color(0xFF1A0000),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF800000)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.stars, color: Color(0xFFD4AF37), size: 40),
                    SizedBox(height: 10),
                    Text("EMAS JUVITA", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            _drawerItem(Icons.home, "HOME", 0),
            _drawerItem(Icons.shopping_bag, "SHOP", 1),
            _drawerItem(Icons.trending_up, "LIVE PRICE", 2),
            _drawerItem(Icons.info, "ABOUT", 3),
            _drawerItem(Icons.contact_mail, "CONTACT", 4),
            _drawerItem(Icons.link, "LINKS", 5),
            const Spacer(),
            const Divider(color: Colors.white12),
            ListTile(
              leading: Icon(_isLoggedIn ? Icons.logout : Icons.login, color: const Color(0xFFD4AF37)),
              title: Text(_isLoggedIn ? "LOGOUT" : "LOGIN", style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _handleAuthAction();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ) : null,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          color: const Color(0xFF800000),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: 10),
              child: Row(
                children: [
                  if (isMobile)
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFFD4AF37)),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  
                  InkWell(
                    onTap: () => _navigateTo(0),
                    child: Row(
                      children: [
                        // UPDATED: Standard icon changed to Supabase Logo Network Image
                        Image.network(
                          'https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Logo.png',
                          height: isMobile ? 40 : 50,
                          fit: BoxFit.contain,
                          // Optional fallback if image fails to load
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 28),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "EMAS JUVITA", 
                          style: TextStyle(
                            color: const Color(0xFFD4AF37), 
                            fontSize: isMobile ? 18 : 22, 
                            letterSpacing: 2, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Desktop Navigation
                  if (!isMobile) ...[
                    _navButton("HOME", 0),
                    _navButton("SHOP", 1),
                    _navButton("LIVE PRICE", 2),
                    _navButton("ABOUT", 3),
                    _navButton("CONTACT", 4),
                    _navButton("LINKS", 5),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: _handleAuthAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(_isLoggedIn ? "LOGOUT" : "LOGIN", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _getPage(_currentPageIndex),
            _buildFooter(isMobile), // Updated Footer
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    final String? userEmail = supabase.auth.currentUser?.email;
    bool isAdmin = _isLoggedIn && userEmail == 'admin@email.com';

    switch (index) {
      case 0: return const HeroSection();
      case 1: return const ShopPage();
      case 2: return const LivePricePage();
      case 3: return const AboutPage();
      case 4: return const ContactPage();
      case 5: return const LinktreePage();
      case 6: 
        if (!_isLoggedIn) return const AuthPage();
        if (isAdmin) return const AdminApprovalPage();
        return const HeroSection(); 
      default: return const HeroSection();
    }
  }

  Widget _navButton(String title, int index) {
    bool isSelected = _currentPageIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => _navigateTo(index),
        style: TextButton.styleFrom(overlayColor: Colors.transparent),
        child: Text(
          title, 
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFD4AF37).withOpacity(0.8), 
            fontSize: 13, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
          )
        ),
      ),
    );
  }

  // --- RESPONSIVE FOOTER ---
Widget _buildFooter(bool isMobile) {
  return Container(
    width: double.infinity,
    color: Colors.black,
    padding: EdgeInsets.symmetric(vertical: 60, horizontal: isMobile ? 24 : 40),
    child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the left
          children: [
            Wrap(
              spacing: 40, // Horizontal space between items
              runSpacing: 40, // Vertical space between items when they stack
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Brand Section
                SizedBox(
                  width: isMobile ? double.infinity : 300,
                  child: _footerBrandSection(),
                ),
                
                // Quick Links
                SizedBox(
                  width: 150, // Fixed width helps the wrap decide when to stack
                  child: _footerLinksSection(),
                ),
                
                // Contact Section
                SizedBox(
                  width: 200,
                  child: _footerContactSection(),
                ),
              ],
            ),
            const SizedBox(height: 60),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),
            Text(
              "© 2026 EMAS JUVITA. All rights reserved.",
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _footerBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("EMAS JUVITA", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 15),
        Text("Trusted Gold Trading and Investment.", 
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.5)),
      ],
    );
  }

  Widget _footerLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("QUICK LINKS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 20),
        _footerLink("Home", 0),
        _footerLink("Shop", 1),
        _footerLink("Live Prices", 2),
      ],
    );
  }

  Widget _footerContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CONTACT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 20),
        Text("support@emasjuvita.com", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        const SizedBox(height: 10),
        Text("+60 12-345 6789", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
      ],
    );
  }

  Widget _footerLink(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _navigateTo(index),
        child: Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
      ),
    );
  }
}

// --- UTILITY ---
double getResponsivePadding(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width < 600) return 24.0; 
  if (width < 1200) return 50.0;
  return 100.0;
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
  late Future<double> _priceFuture;

  final List<String> _sliderImages = [
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/slider%201.png",
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/slider%202.png",
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/slider%203.png",
  ];

  Future<double> _getLivePrice() async {
    try {
      final response = await Supabase.instance.client
          .from('market_prices')
          .select('price_per_gram')
          .eq('category', '916 GOLD')
          .single();
      return (response['price_per_gram'] as num).toDouble();
    } catch (e) {
      debugPrint("Error fetching price: $e");
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _priceFuture = _getLivePrice();

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentIndex < _sliderImages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(_currentIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn);
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
    double screenWidth = MediaQuery.of(context).size.width;
    // Responsive slider height: shrinks as width shrinks
    double sliderHeight = screenWidth > 900 ? 600 : screenWidth * 0.6;

    return Column(
      children: [
        // 1. DYNAMIC SLIDER (Responsive)
        SizedBox(
          height: sliderHeight,
          width: screenWidth,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _sliderImages.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) =>
                    _buildSlide(_sliderImages[index], ""),
              ),
              _sliderArrow(
                  Icons.arrow_back_ios,
                  () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut),
                  left: 20),
              _sliderArrow(
                  Icons.arrow_forward_ios,
                  () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut),
                  right: 20),
            ],
          ),
        ),

        const SizedBox(height: 60),

        // LIVE PRICE SECTION
        FutureBuilder<double>(
          future: _priceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
            }
            return _buildPriceCardWithButton(context, snapshot.data ?? 0.00);
          },
        ),

        const SizedBox(height: 60),
        _buildStoryBox(context),

        const SizedBox(height: 80),

        // 4. OUR PRESENCE
        const Text("OUR PRESENCE",
            style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 24,
                letterSpacing: 4,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: [
                _buildPresenceCard(
                    "Kedai Emas Juvita HQ",
                    "45, Jalan Flora Utama 5, Batu Pahat",
                    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20HQ.png",
                    "https://maps.google.com"),
                _buildPresenceCard(
                    "Kedai Emas Juvita Penggaram",
                    "34, Jalan Penggaram, Batu Pahat",
                    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20Penggaram.png",
                    "https://maps.google.com"),
                _buildPresenceCard(
                    "Kedai Emas Juvita Parit Sulong",
                    "88, Jalan Besar, Parit Sulong",
                    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20Parit%20Sulong.png",
                    "https://maps.google.com"),
                _buildPresenceCard(
                    "Kedai Emas Juvita Parit Raja",
                    "23, Jalan Perdagangan 2, Parit Raja",
                    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/Kedai%20Emas%20Juvita%20Parit%20Raja.png",
                    "https://maps.google.com"),
              ],
            ),
          ),
        ),

        const SizedBox(height: 100),

        // 5. Investment vs Jewellery Section (Stacked Layout)
        _buildInvestmentSection(context),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildInvestmentSection(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Investment vs Jewellery: Why 916 & 999 Matter",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 28,
                letterSpacing: 2,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 50),
        _buildVerticalInvestmentBox(
          context,
          imageUrl:
              "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/916%20img.png",
          title: "916 GOLD (22K) – For Ornate Jewellery",
          description:
              "Durable and beautiful, perfect for intricate designs to be worn daily. The standard for traditional elegance. Ideal for wedding sets and daily wear.",
          buttonText: "Shop 916 Collections",
        ),
        const SizedBox(height: 30),
        _buildVerticalInvestmentBox(
          context,
          imageUrl:
              "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/999%20img.png",
          title: "999 GOLD (24K) – For Pure Investment",
          description:
              "The highest purity, for maximal wealth preservation and investment. Unalloyed for lasting value. Ideal for gold savings and investment portfolio diversification.",
          buttonText: "Shop 999 Collections",
        ),
      ],
    );
  }

  Widget _buildVerticalInvestmentBox(BuildContext context,
      {required String imageUrl,
      required String title,
      required String description,
      required String buttonText}) {
    bool isSmall = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            imageUrl,
            width: double.infinity,
            height: isSmall ? 250 : 400,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16, height: 1.6)),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => context
                      .findAncestorStateOfType<MainNavigationWrapperState>()
                      ?._navigateTo(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
                  ),
                  child: Text(buttonText.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceCard(
      String name, String address, String imageUrl, String mapUrl) {
    return Container(
      width: 320,
      height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(imageUrl,
                height: 350, width: 320, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text(address,
                          style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _launchURL(mapUrl),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4AF37),
                          side: const BorderSide(color: Color(0xFFD4AF37))),
                      child: const Text("VIEW ON MAP",
                          style: TextStyle(fontSize: 12)),
                    ),
                  )
                ],
              ),
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
          const Text("TODAY'S 916 PRICE",
              style: TextStyle(
                  color: Color(0xFFD4AF37), fontSize: 14, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text("RM ${price.toStringAsFixed(2)}/g",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            onPressed: () => context
                .findAncestorStateOfType<MainNavigationWrapperState>()
                ?._navigateTo(2),
            child: const Text("CHECK FULL PRICE LIST",
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            const Text("CRAFTING TRUST IN BATU PAHAT",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    fontSize: 26)),
            const SizedBox(height: 25),
            const Text(
                "What began in the heart of Batu Pahat has blossomed into a legacy of excellence, now spanning four branches to better serve our community with premium gold and unmatched service.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70, fontSize: 18, height: 1.8)),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: () => context
                  .findAncestorStateOfType<MainNavigationWrapperState>()
                  ?._navigateTo(3),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20)),
              child: const Text("LEARN OUR STORY",
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
        Center(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8))),
      ],
    );
  }

  Widget _sliderArrow(IconData icon, VoidCallback onTap,
      {double? left, double? right}) {
    return Positioned(
        left: left,
        right: right,
        top: 0,
        bottom: 0,
        child: Center(
            child: IconButton(
                icon: Icon(icon, color: const Color(0xFFD4AF37), size: 35),
                onPressed: onTap)));
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
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
      child: Column(
        children: [
          const Text("COLLECTIONS",
              style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 24,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          // CATEGORY SELECTOR
          _buildCategoryDropdown(),

          const SizedBox(height: 40),

          // DYNAMIC RESPONSIVE PRODUCT GRID
          FutureBuilder<List<Product>>(
            future: _fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text("Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white)));
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return const Center(
                    child: Text("No products found in this category.",
                        style: TextStyle(color: Colors.white60)));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // --- UPDATED FOR RESPONSIVENESS ---
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250, // Each card will be at most 250px wide
                  childAspectRatio: 0.7,   // Adjusted for a bit more vertical space
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(context, products[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select('*, market_prices(price_per_gram)')
          .eq('category', _selectedCategory);

      final List data = response as List;
      return data.map((item) => Product.fromMap(item)).toList();
    } catch (e) {
      debugPrint("Error fetching: $e");
      return [];
    }
  }

  Widget _buildCategoryDropdown() {
    return Container(
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
          style: const TextStyle(
              color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          items: ['916 GOLD', '999 GOLD']
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (val) {
            setState(() => _selectedCategory = val!);
          },
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text("RM ${product.marketPrice.toStringAsFixed(2)}/g",
                    style: const TextStyle(
                        color: Color(0xFFD4AF37), fontSize: 12)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsPage(product: product),
                        ),
                      );
                    },
                    child: const Text("VIEW",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final String category;
  final double labourFee;
  final String imageUrl;
  final double marketPrice;

  Product({
    required this.name,
    required this.description,
    required this.category,
    required this.labourFee,
    required this.imageUrl,
    required this.marketPrice,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final priceData = map['market_prices'];
    double fetchedPrice = 0.0;

    if (priceData != null) {
      if (priceData is List && priceData.isNotEmpty) {
        fetchedPrice = (priceData[0]['price_per_gram'] as num).toDouble();
      } else if (priceData is Map) {
        fetchedPrice = (priceData['price_per_gram'] as num).toDouble();
      }
    }

    return Product(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      labourFee: (map['labour_fee'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] ?? '',
      marketPrice: fetchedPrice,
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  double _selectedWeight = 10.0;

  double _calculateTotal() {
    return (widget.product.marketPrice * _selectedWeight) +
        widget.product.labourFee;
  }

  @override
  Widget build(BuildContext context) {
    // Check screen size for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0000),
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: const Color(0xFF4A0000),
        foregroundColor: const Color(0xFFD4AF37),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: isMobile ? 250 : 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A0000),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.contain,
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
                        style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600)),
                    Text("Market: RM ${widget.product.marketPrice}/g",
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(widget.product.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.bold)),

                const SizedBox(height: 30),
                const Text("SELECT WEIGHT VARIATION (GRAMS)",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Variation Buttons - Wrap ensures they don't overflow on tiny screens
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [10.0, 30.0, 50.0].map((weight) {
                    bool isSelected = _selectedWeight == weight;
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFFD4AF37)
                            : Colors.transparent,
                        side: const BorderSide(color: Color(0xFFD4AF37)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                      ),
                      onPressed: () => setState(() => _selectedWeight = weight),
                      child: Text("${weight.toInt()}g",
                          style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold)),
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
                      border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.5))),
                  child: Column(
                    children: [
                      _priceRow(
                          "Gold Value (${_selectedWeight}g x RM ${widget.product.marketPrice})",
                          "RM ${(widget.product.marketPrice * _selectedWeight).toStringAsFixed(2)}"),
                      const SizedBox(height: 10),
                      _priceRow("Labour Fee",
                          "RM ${widget.product.labourFee.toStringAsFixed(2)}"),
                      const Divider(color: Color(0xFFD4AF37), height: 30),
                      _priceRow(
                          "ESTIMATED TOTAL",
                          "RM ${_calculateTotal().toStringAsFixed(2)}",
                          isTotal: true),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("DESCRIPTION",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(widget.product.description,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16, height: 1.6)),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {},
                    child: const Text("INQUIRE VIA WHATSAPP",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: isTotal ? Colors.white : Colors.white60,
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ),
        Text(value,
            style: TextStyle(
                color: const Color(0xFFD4AF37),
                fontSize: isTotal ? 20 : 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- PAGE 3: LIVE PRICE PAGE ---
class LivePricePage extends StatefulWidget {
  const LivePricePage({super.key});

  @override
  State<LivePricePage> createState() => _LivePricePageState();
}

class _LivePricePageState extends State<LivePricePage> {
  final supabase = Supabase.instance.client;

  final Stream<List<Map<String, dynamic>>> _priceStream = Supabase.instance.client
      .from('market_prices')
      .stream(primaryKey: ['category'])
      .order('category', ascending: false);

  @override
  Widget build(BuildContext context) {
    // --- RESPONSIVE CHECK ---
    double screenWidth = MediaQuery.of(context).size.width;
    // We increase this threshold to 450 to be safer against wrapping
    bool isSmallScreen = screenWidth < 450; 

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A0000),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _priceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Error loading prices", style: TextStyle(color: Colors.white)));
          }

          final prices = snapshot.data!;
          
          double getPrice(String cat) => 
            (prices.firstWhere((e) => e['category'] == cat, orElse: () => {'price_per_gram': 0.0})['price_per_gram'] as num).toDouble();

          // --- FIXED FORMATTING LOGIC ---
          // This forces decimals to disappear on smaller screens so they don't wrap
          String formatPrice(double price) {
            return isSmallScreen ? "RM${price.floor()}" : "RM${price.toStringAsFixed(2)}";
          }

          String rawTime = prices.firstWhere((e) => e['category'] == '916 GOLD')['last_updated'];
          String formattedTime = DateFormat('MMMM dd, yyyy h:mm a').format(DateTime.parse(rawTime).toLocal());

          double gold916 = getPrice('916 GOLD');
          double gold999 = getPrice('999 GOLD');
          double gold750 = getPrice('750 GOLD');

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  
                  // --- FIXED BIG NUMBER ---
                  // FittedBox ensures that if the text is STILL too wide, it shrinks 
                  // the font size instead of dropping the decimals to a new line.
                  SizedBox(
                    width: screenWidth * 0.9, 
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatPrice(gold916), 
                        style: TextStyle(
                          color: const Color(0xFFD4AF37),
                          fontSize: isSmallScreen ? 70 : 100, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                  ),
                  
                  Text(
                    "Last Updated: $formattedTime",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  
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
                        // columnWidths are set to give the price column only as much space as it needs
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: IntrinsicColumnWidth(), 
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          _tableHeader("GOLD TYPE", "PRICE (PER GRAM)"),
                          _tableRow("Gold 999 (24k)", formatPrice(gold999)),
                          _tableRow("Gold 916 (22k)", formatPrice(gold916), isHighlighted: true),
                          _tableRow("Gold 750 (18k)", formatPrice(gold750)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                    onPressed: () async {
                      await supabase.from('market_prices').update({
                        'price_per_gram': 395.50,
                        'last_updated': DateTime.now().toIso8601String(),
                      }).eq('category', '916 GOLD');
                    },
                    child: const Text("Update 916 Gold (Live Update)", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          );
        },
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
    bool isSmall = MediaQuery.of(context).size.width < 450;
    return TableRow(
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFFFFBEA) : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 22, vertical: 18), 
          child: Text(label, style: const TextStyle(color: Color(0xFF444444), fontSize: 14, fontWeight: FontWeight.w500))
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 22, vertical: 18),
          child: Text(price, 
            style: const TextStyle(color: Color(0xFF444444), fontSize: 15, fontWeight: FontWeight.bold, 
            // This prevents wrapping in the table row
            overflow: TextOverflow.visible), 
            textAlign: TextAlign.right,
            maxLines: 1,
          )
        ),
      ],
    );
  }
}

// --- PAGE 4: ABOUT PAGE ---
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if we are on a smaller screen (Mobile/Tablet)
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900; // Standard threshold for stacking layout

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- SECTION 1: MORE THAN JUST GOLD ---
          Container(
            color: const Color(0xFF4A0E0E),
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 40 : 80, 
              horizontal: isMobile ? 20 : 100,
            ),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // If mobile, show image at the TOP
                if (isMobile) ...[
                  _buildImageSection('https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/About%20img1.png', isMobile),
                  const SizedBox(height: 40),
                ],

                // Text Content
                Expanded(
                  flex: isMobile ? 0 : 3,
                  child: Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      RichText(
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                        text: const TextSpan(
                          style: TextStyle(fontSize: 32, fontFamily: 'Serif', color: Colors.white),
                          children: [
                            TextSpan(text: "More Than Just "),
                            TextSpan(text: "Gold", style: TextStyle(color: Color(0xFFD4AF37))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Emas Juvita was founded on a simple belief: that fine jewelry should not just be a luxury, but a meaningful milestone accessible to everyone in our community. Based in the heart of Batu Pahat, we have spent years building a reputation centered on transparency, integrity, and exquisite craftsmanship.",
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "We specialize in premium 916 and 999 gold, ensuring that every piece you take home is a lasting investment in quality. To us, you aren’t just a customer; we treat every transaction as a long-term partnership built on trust.",
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      ),
                    ],
                  ),
                ),

                // If Desktop, show image on the RIGHT
                if (!isMobile) ...[
                  const SizedBox(width: 60),
                  _buildImageSection('https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/About%20img1.png', isMobile),
                ],
              ],
            ),
          ),

          // --- SECTION 2: THE JUVITA STANDARDS ---
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 40 : 80, 
              horizontal: isMobile ? 20 : 100,
            ),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                // Image on TOP for mobile
                _buildImageSection('https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/About%20img2.png', isMobile),
                
                SizedBox(height: isMobile ? 40 : 0, width: isMobile ? 0 : 60),

                // Standards Content
                Expanded(
                  flex: isMobile ? 0 : 3,
                  child: Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "The Juvita Standards",
                        style: TextStyle(fontSize: 32, fontFamily: 'Serif', color: Colors.white),
                      ),
                      const SizedBox(height: 40),
                      _buildStandardItem("Transparent Pricing", "We offer competitive workmanship rates with no hidden surprises.", isMobile),
                      _buildStandardItem("Quality Guaranteed", "Every item in our catalog is strictly vetted for purity and authenticity.", isMobile),
                      _buildStandardItem("Customer-First Service", "From free professional cleaning to high-value buy-backs, we support you long after your initial purchase.", isMobile),
                      _buildStandardItem("Flexible Savings", "We provide accessible gold saving plans (STE) to help you grow your wealth at your own pace.", isMobile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Extracted image builder for cleaner code
  Widget _buildImageSection(String url, bool isMobile) {
    return Expanded(
      flex: isMobile ? 0 : 2,
      child: Container(
        height: isMobile ? 300 : 500, // Shorter height on mobile
        width: isMobile ? double.infinity : null,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Updated helper with alignment logic
  Widget _buildStandardItem(String title, String description, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              const Icon(Icons.circle, size: 6, color: Colors.white),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(left: isMobile ? 0 : 16),
            child: Text(
              description, 
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

// --- PAGE 5: CONTACT PAGE ---
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  void initState() {
    super.initState();
    _registerMap("hq-map", "https://maps.google.com/maps?q=Jalan%20Flora%20Utama%205%20Batu%20Pahat&t=&z=15&ie=UTF8&iwloc=&output=embed");
    _registerMap("penggaram-map", "https://maps.google.com/maps?q=Jalan%20Penggaram%20Batu%20Pahat&t=&z=15&ie=UTF8&iwloc=&output=embed");
    _registerMap("raja-map", "https://maps.google.com/maps?q=Parit%20Raja%20Batu%20Pahat&t=&z=15&ie=UTF8&iwloc=&output=embed");
    _registerMap("sulong-map", "https://maps.google.com/maps?q=Parit%20Sulong%20Batu%20Pahat&t=&z=15&ie=UTF8&iwloc=&output=embed");
  }

  void _registerMap(String viewId, String url) {
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => web.HTMLIFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = url
        ..style.border = 'none',
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800; // Threshold for mobile/tablet

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A0000), 
      child: SingleChildScrollView(
        // Reduce padding on mobile so cards don't get squished
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 80, 
          horizontal: isMobile ? 20 : 100
        ),
        child: Column(
          children: [
            Text(
              "VISIT OUR LOCATIONS",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFD4AF37), 
                fontSize: isMobile ? 24 : 32, 
                fontWeight: FontWeight.bold, 
                fontFamily: 'Serif'
              ),
            ),
            const SizedBox(height: 60),

            // Using MaxCrossAxisExtent to handle responsive columns
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 600, // Cards will be max 600px wide
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                // Adjust aspect ratio for mobile vs desktop
                childAspectRatio: isMobile ? 0.85 : 1.05, 
              ),
              children: [
                _buildMapCard(
                  "Kedai Emas Juvita HQ", 
                  "45, Jalan Flora Utama 5, 83000 Batu Pahat, Johor", 
                  "hq-map",
                  "https://maps.app.goo.gl/HQ_LINK"
                ),
                _buildMapCard(
                  "Kedai Emas Juvita Penggaram", 
                  "34, Jalan Penggaram, 83000 Batu Pahat, Johor", 
                  "penggaram-map",
                  "https://maps.app.goo.gl/PENGGARAM_LINK"
                ),
                _buildMapCard(
                  "Kedai Emas Juvita Parit Raja", 
                  "Pekan Parit Raja, 86400 Batu Pahat, Johor", 
                  "raja-map",
                  "https://maps.app.goo.gl/RAJA_LINK"
                ),
                _buildMapCard(
                  "Kedai Emas Juvita Parit Sulong", 
                  "Pekan Parit Sulong, 83500 Batu Pahat, Johor", 
                  "sulong-map",
                  "https://maps.app.goo.gl/SULONG_LINK"
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(String title, String address, String mapId, String googleMapsUrl) {  
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D0A0A), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5), 
            blurRadius: 15, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 15 : 25),
      child: Column(
        children: [
          Text(
            title, 
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white, 
              fontSize: isMobile ? 18 : 22, 
              fontFamily: 'Serif',
              fontWeight: FontWeight.w600,
            )
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: HtmlElementView(viewType: mapId),
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextButton(
            onPressed: () => _launchUrl(googleMapsUrl),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(Icons.location_on, color: Color(0xFFD4AF37), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: isMobile ? 14 : 16,        
                      fontWeight: FontWeight.bold, 
                      height: 1.4,
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
}

// --- PAGE 6: LINKTREE PAGE ---
class LinktreePage extends StatelessWidget {
  const LinktreePage({super.key});

  // 2. Helper function to launch URLs
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A0000), 
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link, color: Color(0xFFD4AF37), size: 40),
                  const SizedBox(height: 20),
                  const Text(
                    "Follow Us for Daily Rates",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 3. Add your actual links here
                  _linkButton(
                    "Emas Juvita | Whatsapp 1", 
                    FontAwesomeIcons.whatsapp, 
                    const Color(0xFF25D366),
                    "https://wassap.my/60195666650/emasjuvita" // Replace with real number
                  ),
                  _linkButton(
                    "Emas Juvita | Whatsapp 2", 
                    FontAwesomeIcons.whatsapp, 
                    const Color(0xFF25D366),
                    "https://wassap.my/60109346650/emasjuvita" // Replace with real number
                  ),
                  _linkButton(
                    "Instagram: @emasjuvita", 
                    FontAwesomeIcons.instagram, 
                    const Color(0xFFE4405F),
                    "https://www.instagram.com/emasjuvita/?hl=en"
                  ),
                  _linkButton(
                    "Instagram: @emasjuvita.prt.raja", 
                    FontAwesomeIcons.instagram, 
                    const Color(0xFFE4405F),
                    "https://www.instagram.com/emasjuvita.prt.raja/?hl=en"
                  ),
                  _linkButton(
                    "Instagram: @emas.juvita", 
                    FontAwesomeIcons.instagram, 
                    const Color(0xFFE4405F),
                    "https://www.instagram.com/emas.juvita/?hl=en"
                  ),
                  _linkButton(
                    "Facebook: Kedai Emas Juvita", 
                    FontAwesomeIcons.facebook, 
                    const Color(0xFF1877F2),
                    "https://www.facebook.com/KedaiEmasJuvita"
                  ),
                  _linkButton(
                    "Telegram Official", 
                    FontAwesomeIcons.telegram, 
                    const Color(0xFF26A5E4),
                    "https://t.me/emasjuvita"
                  ),
                  _linkButton(
                    "TikTok: @emasjuvita", 
                    FontAwesomeIcons.tiktok, 
                    Colors.white,
                    "https://www.tiktok.com/@emasjuvita"
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. Updated button to accept and use the URL
  Widget _linkButton(String title, dynamic icon, Color iconColor, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _launchURL(url), // 5. Call the launch function
        child: Row(
          children: [
            const SizedBox(width: 5),
            SizedBox(
              width: 30,
              child: icon is IconData 
                ? Icon(icon, color: iconColor, size: 24)
                : FaIcon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 15, 
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}

// --- PAGE 7: REGISTRATION PAGE ---
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  bool _isLoginMode = true; // Toggle between Login and Register

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (_isLoginMode) {
        // --- LOGIN LOGIC ---
        await supabase.auth.signInWithPassword(email: email, password: password);
        // Supabase listener in your NavWrapper will handle the UI switch
      } else {
        // --- REGISTER LOGIC ---
        final response = await supabase.auth.signUp(email: email, password: password);
        if (response.user != null) {
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': response.user!.email,
            'is_vip': true,
            'is_approved': false,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Request sent! Awaiting Admin Approval.")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLoginMode ? "VIP LOGIN" : "VIP REGISTRATION",
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                _isLoginMode ? "Welcome back, Member." : "Request exclusive access to live gold rates",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 40),
              _buildField(_emailController, "Email Address", Icons.email),
              const SizedBox(height: 20),
              _buildField(_passwordController, "Password", Icons.lock, isPass: true),
              const SizedBox(height: 40),
              
              // --- MAIN BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                  onPressed: _isLoading ? null : _handleAuth,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text(_isLoginMode ? "SIGN IN" : "REQUEST ACCESS", 
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),

              // --- TOGGLE BUTTON ---
              TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                child: Text(
                  _isLoginMode ? "New here? Request VIP Access" : "Already a member? Sign In",
                  style: const TextStyle(color: Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}

// --- PAGE 8: ADMIN PAGE ---
class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _pendingUsers = [];
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    try {
      final data = await supabase
          .from('profiles')
          .select('*')
          .eq('is_approved', false);
      
      if (mounted) {
        setState(() {
          _pendingUsers = data;
          _isFetching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _approveUser(String userId) async {
    await supabase
        .from('profiles')
        .update({'is_approved': true})
        .eq('id', userId);
        
    _fetchPendingUsers(); 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PENDING APPROVALS",
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "${_pendingUsers.length} users awaiting VIP access",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          if (_isFetching)
            const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          else if (_pendingUsers.isEmpty)
            const Text("No pending requests.", style: TextStyle(color: Colors.white38))
          else
            // Changed from Expanded to ListView with shrinkWrap to fix scrolling
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingUsers.length,
              itemBuilder: (context, index) {
                final user = _pendingUsers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    title: Text(user['email'] ?? 'No Email', style: const TextStyle(color: Colors.white)),
                    subtitle: const Text("Requesting VIP Access", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        minimumSize: const Size(100, 36),
                      ),
                      onPressed: () => _approveUser(user['id']),
                      child: const Text("APPROVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
        ],
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