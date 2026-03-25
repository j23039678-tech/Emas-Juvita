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
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
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
            const FooterSection(), // This is now defined below
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
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/image_2026-03-25_165947046.png",
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/image_2026-03-25_170454523.png",
    "https://ovapdygzriiojovtnngq.supabase.co/storage/v1/object/public/Images/image_2026-03-25_170502694.png",
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

  // --- THE UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        
        const SizedBox(height: 40),
        const GoldPriceCard(price: 385.50),

        // OUR STORY BOX
        _buildStoryBox(context),

        const Text("OUR BOUTIQUES", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 22, letterSpacing: 3)),
        const SizedBox(height: 30),
        
        // BRANCH LIST (Where your error was)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildBranchCard("Batu Pahat", "No. 12, Jalan Sultanah, 83000 Batu Pahat, Johor", "https://maps.google.com/?q=Batu+Pahat"),
              _buildBranchCard("Port Klang", "45, Jalan Pelabuhan, 42000 Port Klang, Selangor", "https://maps.google.com/?q=Port+Klang"),
              _buildBranchCard("Kuala Lumpur", "L1-02, Bukit Bintang City Centre, 55100 Kuala Lumpur", "https://maps.google.com/?q=Kuala+Lumpur"),
            ],
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // --- HELPER METHODS (Must stay inside this class!) ---

  Widget _buildBranchCard(String name, String address, String mapUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0000),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(name.toUpperCase(), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(address, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () => _launchURL(mapUrl),
            icon: const Icon(Icons.location_on, size: 16),
            label: const Text("VIEW ON MAP"),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD4AF37), side: const BorderSide(color: Color(0xFFD4AF37))),
          )
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSlide(String imageUrl, String title) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(imageUrl, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.3)),
        Center(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 6))),
      ],
    );
  }

  Widget _sliderArrow(IconData icon, VoidCallback onTap, {double? left, double? right}) {
    return Positioned(left: left, right: right, top: 0, bottom: 0, child: Center(child: IconButton(icon: Icon(icon, color: const Color(0xFFD4AF37), size: 30), onPressed: onTap)));
  }

  Widget _buildStoryBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: const Color(0xFF2A0000), border: Border.all(color: const Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            const Text("OUR STORY", style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 4, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text("Specializing in the finest gold since 2026.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.findAncestorStateOfType<_MainNavigationWrapperState>()?._navigateTo(3),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
              child: const Text("READ MORE"),
            ),
          ],
        ),
      ),
    );
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      width: 300,
      child: Column(
        children: [
          _linkButton("Main Website"),
          _linkButton("Instagram"),
          _linkButton("Facebook"),
        ],
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
class GoldPriceCard extends StatelessWidget {
  final double price;
  const GoldPriceCard({super.key, required this.price});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0000),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text("TODAY'S 916 PRICE", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
          Text("RM ${price.toStringAsFixed(2)}/g", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

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

// --- UTILITIES ---
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
          SizedBox(height: 20),
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

// ADD THIS AT THE BOTTOM OF YOUR FILE
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