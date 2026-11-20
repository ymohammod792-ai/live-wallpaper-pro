import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const LiveWallpaperApp());
}

const bg = Color(0xFF08070D);
const panel = Color(0xFF171320);
const accent = Color(0xFFD6B15E);

class Wallpaper {
  final String title;
  final String category;
  final IconData icon;
  final List<Color> colors;
  final String? imageUrl;

  const Wallpaper(this.title, this.category, this.icon, this.colors, {this.imageUrl});
}

const wallpapers = [
  Wallpaper('Galaxy Dream', 'Galaxy', Icons.blur_circular, [
    Color(0xFF32116B),
    Color(0xFF071A48),
  ]),
  Wallpaper('Deep Nature', 'Nature', Icons.forest, [
    Color(0xFF075B42),
    Color(0xFF071D25),
  ]),
  Wallpaper('Rainy Night', 'Rain', Icons.water_drop, [
    Color(0xFF174D78),
    Color(0xFF091528),
  ]),
  Wallpaper('Dark Horror', 'Horror', Icons.nightlight, [
    Color(0xFF7B171F),
    Color(0xFF160912),
  ]),
  Wallpaper('Neon Abstract', 'Abstract', Icons.auto_awesome, [
    Color(0xFF7137A8),
    Color(0xFF101B50),
  ]),
  Wallpaper('3D Universe', '3D', Icons.public, [
    Color(0xFF126E91),
    Color(0xFF17134D),
  ]),
  Wallpaper('Green Forest', 'Nature', Icons.park, [
    Color(0xFF286C38),
    Color(0xFF10251A),
  ]),
  Wallpaper('Galaxy Blue', 'Galaxy', Icons.stars, [
    Color(0xFF1554A0),
    Color(0xFF100C37),
  ]),

  Wallpaper('Black Hole', 'Space & Universe', Icons.blur_circular,
    [Color(0xFF32116B), Color(0xFF071A48)],
    imageUrl: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=900'),
  Wallpaper('Earth From Space', 'Space & Universe', Icons.public,
    [Color(0xFF126E91), Color(0xFF17134D)],
    imageUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=900'),
  Wallpaper('Cosmic Galaxy', 'Space & Universe', Icons.stars,
    [Color(0xFF1554A0), Color(0xFF100C37)],
    imageUrl: 'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=900'),
  Wallpaper('Gaming Setup', 'Gaming', Icons.sports_esports,
    [Color(0xFF32116B), Color(0xFF071A48)],
    imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=900'),
  Wallpaper('Gaming Arena', 'Gaming', Icons.gamepad,
    [Color(0xFF075B42), Color(0xFF071D25)],
    imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=900'),
  Wallpaper('RGB Gaming', 'Gaming', Icons.videogame_asset,
    [Color(0xFF7137A8), Color(0xFF101B50)],
    imageUrl: 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=900'),

];

class LiveWallpaperApp extends StatelessWidget {
  const LiveWallpaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Wallpaper Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<String> saveWallpaperVideo(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedFile = await File(sourcePath).copy(
      '${directory.path}/live_wallpaper_video.mp4',
    );
    return savedFile.path;
  }

  int page = 0;
  String category = 'All';
  String language = 'English';
  final Set<String> favorites = {};
  File? selectedImage;
  VideoPlayerController? videoController;
  String? savedVideoPath;

  final categories = [
    'All',
    'Islamic',
    'Animation',
    '2D',
    '3D',
    'Movies',
    'Action',
    'Funny',
    'Nature',
    'Galaxy',
    'Space',
    'Space & Universe',
    'Gaming',
    'Rain',
    'Horror',
    'Abstract',
    'Cute Girls',
    'Beautiful Girls',
    'Anime Girls',
    'Fashion & Glamour',
    'Romantic Couple',
  ];

  final translations = {
    'English': {
      'home': 'Home',
      'gallery': 'Gallery',
      'create': 'Create',
      'favorites': 'Favorites',
      'settings': 'Settings',
      'welcome': 'Discover your world',
      'subtitle': 'Beautiful wallpapers for your screen',
      'featured': 'Featured Wallpapers',
      'categories': 'Categories',
      'popular': 'Popular Wallpapers',
      'empty': 'No favorites yet',
      'emptySub': 'Save wallpapers you love here.',
      'preview': 'Wallpaper Preview',
      'apply': 'Set Wallpaper',
      'coming': 'Coming Soon',
      'language': 'Language',
    },
    'বাংলা': {
      'home': 'হোম',
      'gallery': 'গ্যালারি',
      'create': 'তৈরি',
      'favorites': 'পছন্দের',
      'settings': 'সেটিংস',
      'welcome': 'আপনার নতুন জগৎ আবিষ্কার করুন',
      'subtitle': 'আপনার স্ক্রিনের জন্য সুন্দর ওয়ালপেপার',
      'featured': 'বিশেষ ওয়ালপেপার',
      'categories': 'ক্যাটাগরি',
      'popular': 'জনপ্রিয় ওয়ালপেপার',
      'empty': 'এখনো কোনো পছন্দের ওয়ালপেপার নেই',
      'emptySub': 'পছন্দের ওয়ালপেপার এখানে সংরক্ষণ করুন।',
      'preview': 'ওয়ালপেপার প্রিভিউ',
      'apply': 'ওয়ালপেপার সেট করুন',
      'coming': 'শীঘ্রই আসছে',
      'language': 'ভাষা',
    },
    'Arabic': {
      'home': 'الرئيسية',
      'gallery': 'المعرض',
      'create': 'إنشاء',
      'favorites': 'المفضلة',
      'settings': 'الإعدادات',
      'welcome': 'اكتشف عالمك',
      'subtitle': 'خلفيات جميلة لشاشتك',
      'featured': 'خلفيات مميزة',
      'categories': 'الفئات',
      'popular': 'خلفيات شائعة',
      'empty': 'لا توجد مفضلة بعد',
      'emptySub': 'احفظ خلفياتك المفضلة هنا.',
      'preview': 'معاينة الخلفية',
      'apply': 'تعيين الخلفية',
      'coming': 'قريباً',
      'language': 'اللغة',
    },
  };

  String tr(String key) => translations[language]?[key] ?? key;

  void toggleFavorite(Wallpaper wallpaper) {
    setState(() {
      if (favorites.contains(wallpaper.title)) {
        favorites.remove(wallpaper.title);
      } else {
        favorites.add(wallpaper.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      tr('home'),
      tr('gallery'),
      tr('create'),
      tr('favorites'),
      tr('settings'),
    ];

    return Directionality(
      textDirection: language == 'Arabic'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: page,
            children: [
              homePage(),
              galleryPage(),
              createPage(),
              favoritesPage(),
              settingsPage(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: panel,
          indicatorColor: accent.withValues(alpha: 0.25),
          selectedIndex: page,
          onDestinationSelected: (index) {
            setState(() => page = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: labels[0],
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_rounded),
              label: labels[1],
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              label: labels[2],
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border),
              selectedIcon: const Icon(Icons.favorite),
              label: labels[3],
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              label: labels[4],
            ),
          ],
        ),
      ),
    );
  }

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD6B15E),
                    Color(0xFF8B6CFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.blur_on_rounded,
                color: Colors.black,
                size: 29,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE WALLPAPER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'PRO EDITION',
                    style: TextStyle(
                      color: accent,
                      letterSpacing: 2.0,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accent.withValues(alpha: 0.25),
                ),
              ),
              child: IconButton(
                onPressed: () => setState(() => page = 4),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: accent,
                ),
                tooltip: 'Settings',
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF211832),
                Color(0xFF171320),
                Color(0xFF10101A),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.28),
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -12,
                top: -15,
                child: Icon(
                  Icons.auto_awesome,
                  size: 100,
                  color: Color(0x18D6B15E),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✦ PREMIUM EXPERIENCE',
                      style: TextStyle(
                        color: accent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('welcome'),
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    tr('subtitle'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 48,
                    height: 3,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        sectionTitle(tr('featured')),
        featuredCard(),
        const SizedBox(height: 25),
        sectionTitle(tr('categories')),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    item,
                    style: TextStyle(
                      color: category == item
                          ? const Color(0xFF08070D)
                          : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: category == item,
                  selectedColor: const Color(0xFFD6B15E),
                  backgroundColor: const Color(0xFF171320),
                  side: BorderSide(
                    color: category == item
                        ? const Color(0xFFFFD978)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  onSelected: (_) {
                    setState(() {
                      category = item;
                      page = 1;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 22),
        sectionTitle(tr('popular')),
        wallpaperGrid(wallpapers.take(4).toList()),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget featuredCard() {
    final wallpaper = wallpapers[0];

    return GestureDetector(
      onTap: () => showPreview(wallpaper),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accent.withOpacity(0.75),
            width: 1.3,
          ),
          gradient: LinearGradient(
            colors: wallpaper.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.18),
              blurRadius: 22,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              if (wallpaper.imageUrl != null)
                Positioned.fill(
                  child: Image.network(
                    wallpaper.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),

              const Positioned(
                right: -20,
                top: -35,
                child: Icon(
                  Icons.blur_circular,
                  size: 180,
                  color: Colors.white10,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: accent.withOpacity(0.7),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: accent,
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 20,
                right: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'PREMIUM COLLECTION',
                      style: TextStyle(
                        color: accent,
                        letterSpacing: 1.8,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      wallpaper.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Discover your perfect screen',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                bottom: 22,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget galleryPage() {
    final filtered = category == 'All'
        ? wallpapers
        : wallpapers.where((w) => w.category == category).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD6B15E).withValues(alpha: 0.55),
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF211832),
                Color(0xFF171320),
                Color(0xFF0D0B13),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD6B15E),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  tr('gallery'),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B15E).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD6B15E).withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  '${filtered.length}',
                  style: const TextStyle(
                    color: Color(0xFFFFD978),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        sectionTitle(tr('categories')),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    item,
                    style: TextStyle(
                      color: category == item
                          ? const Color(0xFF08070D)
                          : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: category == item,
                  selectedColor: const Color(0xFFD6B15E),
                  backgroundColor: const Color(0xFF171320),
                  side: BorderSide(
                    color: category == item
                        ? const Color(0xFFFFD978)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  onSelected: (_) => setState(() => category = item),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        wallpaperGrid(filtered),
      ],
    );
  }

  Widget wallpaperGrid(List<Wallpaper> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No wallpapers found'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final wallpaper = items[index];
        final isFavorite = favorites.contains(wallpaper.title);

        return GestureDetector(
          onTap: () => showPreview(wallpaper),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD6B15E).withValues(alpha: 0.65),
                width: 1.1,
              ),
              gradient: LinearGradient(
                colors: wallpaper.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: wallpaper.imageUrl != null
                        ? Image.network(
                            wallpaper.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              wallpaper.icon,
                              size: 82,
                              color: Colors.white38,
                            ),
                          )
                        : Icon(
                            wallpaper.icon,
                            size: 82,
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.82),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.38),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD6B15E)
                              .withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        wallpaper.category,
                        style: const TextStyle(
                          color: Color(0xFFFFD978),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => toggleFavorite(wallpaper),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.pinkAccent
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 10,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallpaper.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle_fill,
                              color: Color(0xFFFFD978),
                              size: 17,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Preview Wallpaper',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
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
          ),
        );
      },
    );
  }

  Widget favoritesPage() {
    final saved = wallpapers.where((w) => favorites.contains(w.title)).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD6B15E).withValues(alpha: 0.55),
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF302044),
                Color(0xFF171320),
                Color(0xFF0D0B13),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFD6B15E), Color(0xFF8B5CF6)],
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('favorites'),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'YOUR PERSONAL COLLECTION',
                      style: TextStyle(
                        color: Color(0xFFD6B15E),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${saved.length}',
                style: const TextStyle(
                  color: Color(0xFFD6B15E),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (saved.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 45,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF171320),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    border: Border.all(
                      color: const Color(0xFFD6B15E).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 45,
                    color: Color(0xFFD6B15E),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tr('empty'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('emptySub'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          wallpaperGrid(saved),
      ],
    );
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  Widget createPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD6B15E).withValues(alpha: 0.6),
              ),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF302044),
                  Color(0xFF171320),
                  Color(0xFF0D0B13),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFD6B15E), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: const Icon(
                    Icons.wallpaper_rounded,
                    size: 39,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tr('create'),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Create your own wallpaper using photos, videos and effects.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null && mounted) {
                            final oldController = videoController;
                            setState(() {
                              selectedImage = File(pickedFile.path);
                              videoController = null;
                              savedVideoPath = null;
                            });
                            await oldController?.dispose();
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('Choose Photo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickVideo(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile == null || !mounted) return;

                          final controller = VideoPlayerController.file(
                            File(pickedFile.path),
                          );
                          try {
                            final savedPath =
                                await saveWallpaperVideo(pickedFile.path);
                            await controller.initialize();
                            if (!mounted) {
                              await controller.dispose();
                              return;
                            }
                            final oldController = videoController;
                            setState(() {
                              selectedImage = null;
                              videoController = controller;
                              savedVideoPath = savedPath;
                            });
                            await oldController?.dispose();
                          } catch (e) {
                            await controller.dispose();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not load this video'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.video_library_rounded),
                        label: const Text('Choose Video'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (selectedImage != null) ...[
            const SizedBox(height: 22),
            sectionTitle('Photo Preview'),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                selectedImage!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
          if (videoController != null &&
              videoController!.value.isInitialized) ...[
            const SizedBox(height: 22),
            sectionTitle('Video Preview'),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              ),
            ),
            Center(
              child: IconButton(
                onPressed: () {
                  final controller = videoController!;
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  });
                },
                icon: Icon(
                  videoController!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 54,
                  color: accent,
                ),
              ),
            ),
          ],
          if (savedVideoPath != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: setAsLiveWallpaper,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD6B15E),
                  foregroundColor: const Color(0xFF08070D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.wallpaper_rounded),
                label: const Text(
                  'Set Live Wallpaper',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> setAsLiveWallpaper() async {
    if (savedVideoPath == null) return;

    try {
      await const MethodChannel('live_wallpaper_pro/wallpaper')
          .invokeMethod('setWallpaper', {'path': savedVideoPath});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open wallpaper settings: $e')),
        );
      }
    }
  }

  Widget settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD6B15E).withValues(alpha: 0.55),
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF302044),
                Color(0xFF171320),
                Color(0xFF0D0B13),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFD6B15E), Color(0xFF8B5CF6)],
                  ),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('settings'),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'PERSONALIZE YOUR EXPERIENCE',
                      style: TextStyle(
                        color: Color(0xFFD6B15E),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'PREFERENCES',
          style: TextStyle(
            color: Color(0xFFD6B15E),
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF171320),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B15E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Color(0xFFD6B15E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('language'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: language,
                dropdownColor: const Color(0xFF171320),
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFD6B15E),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                items: ['English', 'বাংলা', 'Arabic'].map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => language = value);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'ABOUT',
          style: TextStyle(
            color: Color(0xFFD6B15E),
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFF171320),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD6B15E).withValues(alpha: 0.35),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.wallpaper_rounded,
                color: Color(0xFFD6B15E),
                size: 32,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Wallpaper Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Premium Edition  •  Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.verified_rounded,
                color: Color(0xFFD6B15E),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Future<void> applyImageWallpaper(Wallpaper wallpaper, String target) async {
    if (wallpaper.imageUrl == null) return;

    try {
      await const MethodChannel('live_wallpaper_pro/wallpaper')
          .invokeMethod('setImageWallpaper', {
        'url': wallpaper.imageUrl,
        'target': target,
      });

      if (!mounted) return;

      final message = target == 'home'
          ? 'Home Screen wallpaper applied successfully!'
          : target == 'lock'
              ? 'Lock Screen wallpaper applied successfully!'
              : 'Both wallpapers applied successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not apply wallpaper: $e')),
      );
    }
  }

  void showPreview(Wallpaper wallpaper) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: panel,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('preview'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: wallpaper.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: wallpaper.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            wallpaper.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              wallpaper.icon,
                              size: 100,
                              color: Colors.white38,
                            ),
                          ),
                        )
                      : Icon(
                          wallpaper.icon,
                          size: 100,
                          color: Colors.white38,
                        ),
                ),
                const SizedBox(height: 15),
                Text(
                  wallpaper.title,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),
                if (wallpaper.imageUrl != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        applyImageWallpaper(wallpaper, 'home');
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Home Screen'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        applyImageWallpaper(wallpaper, 'lock');
                      },
                      icon: const Icon(Icons.lock_rounded),
                      label: const Text('Lock Screen'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        applyImageWallpaper(wallpaper, 'both');
                      },
                      icon: const Icon(Icons.wallpaper_rounded),
                      label: const Text('Both Screens'),
                    ),
                  ),
                ] else
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}
