import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

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
  String _selectedLocation = 'Batu Pahat';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text("PRODUCT CATALOG", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, letterSpacing: 4)),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: _selectedLocation,
            dropdownColor: const Color(0xFF800000),
            style: const TextStyle(color: Color(0xFFD4AF37)),
            items: <String>['Batu Pahat', 'Port Klang', 'Kuala Lumpur'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text("STOCK AT: $value"));
            }).toList(),
            onChanged: (val) => setState(() => _selectedLocation = val!),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 0.8, 
              crossAxisSpacing: 20, 
              mainAxisSpacing: 20
            ),
            itemCount: 4,
            itemBuilder: (context, index) => _buildProductCard("Premium 916 Ring #$index", 1250.00),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, double basePrice) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.white10, child: const Icon(Icons.image, color: Colors.white24, size: 50))),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                  onPressed: () => _launchWhatsApp("I'm interested in $name at $_selectedLocation"),
                  child: const Text("INQUIRE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- PAGE 3: LIVE PRICE PAGE ---
class LivePricePage extends StatelessWidget {
  const LivePricePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Text("TODAY'S LIVE GOLD PRICE", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Table(
            border: TableBorder.all(color: const Color(0xFFD4AF37)),
            children: [
              _tableRow("GOLD TYPE", "PRICE PER GRAM", isHeader: true),
              _tableRow("Solid Gold (999)", "RM 420.50"),
              _tableRow("Jewelry Gold (916)", "RM 385.00"),
              _tableRow("Emas (750)", "RM 315.00"),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _tableRow(String c1, String c2, {bool isHeader = false}) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(15), child: Text(c1, style: TextStyle(color: isHeader ? const Color(0xFFD4AF37) : Colors.white, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal))),
        Padding(padding: const EdgeInsets.all(15), child: Text(c2, style: TextStyle(color: Colors.white, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal))),
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