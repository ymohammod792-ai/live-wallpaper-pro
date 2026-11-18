import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const LiveWallpaperApp());
}

const bg = Color(0xFF090D18);
const panel = Color(0xFF151D2E);
const accent = Color(0xFF8B6CFF);

class Wallpaper {
  final String title;
  final String category;
  final IconData icon;
  final List<Color> colors;

  const Wallpaper(this.title, this.category, this.icon, this.colors);
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
    '2D',
    '3D',
    'Nature',
    'Rain',
    'Galaxy',
    'Horror',
    'Abstract',
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
            const Icon(Icons.blur_on, color: accent, size: 34),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'LIVE WALLPAPER PRO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => page = 4),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          tr('welcome'),
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(tr('subtitle'), style: const TextStyle(color: Colors.white60)),
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
                  label: Text(item),
                  selected: category == item,
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
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: wallpaper.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.blur_circular,
                size: 105,
                color: Colors.white24,
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GALAXY COLLECTION',
                    style: TextStyle(letterSpacing: 1.5, fontSize: 11),
                  ),
                  Text(
                    wallpaper.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              right: 18,
              bottom: 18,
              child: Icon(Icons.play_circle_fill, size: 38),
            ),
          ],
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
        Text(
          tr('gallery'),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item),
                  selected: category == item,
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
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: wallpaper.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(wallpaper.icon, size: 75, color: Colors.white30),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    onPressed: () => toggleFavorite(wallpaper),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.pinkAccent : Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallpaper.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        wallpaper.category,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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
    );
  }

  Widget favoritesPage() {
    final saved = wallpapers.where((w) => favorites.contains(w.title)).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          tr('favorites'),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        if (saved.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Icon(
                  Icons.favorite_border,
                  size: 65,
                  color: Colors.white38,
                ),
                const SizedBox(height: 15),
                Text(tr('empty')),
                const SizedBox(height: 8),
                Text(
                  tr('emptySub'),
                  style: const TextStyle(color: Colors.white54),
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
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wallpaper, size: 85, color: accent),
          const SizedBox(height: 20),
          Text(
            tr('create'),
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your own wallpaper using photos, videos and effects.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 25),

          FilledButton.icon(
            onPressed: () async {
              final pickedFile = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );

              if (pickedFile != null && mounted) {
                final oldController = videoController;
                setState(() {
                  selectedImage = File(pickedFile.path);
                  videoController = null;
                });
                await oldController?.dispose();
              }
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Choose Photo'),
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: () async {
              final pickedFile = await ImagePicker().pickVideo(
                source: ImageSource.gallery,
              );

              if (pickedFile == null || !mounted) return;

              final controller = VideoPlayerController.file(
                File(pickedFile.path),
              );

              try {
                final savedPath = await saveWallpaperVideo(pickedFile.path);
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
                    const SnackBar(content: Text('Could not load this video')),
                  );
                }
              }
            },
            icon: const Icon(Icons.video_library),
            label: const Text('Choose Video'),
          ),

          if (selectedImage != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                selectedImage!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],

          if (videoController != null &&
              videoController!.value.isInitialized) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              ),
            ),
            IconButton(
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
                    ? Icons.pause_circle
                    : Icons.play_circle,
                size: 45,
                color: accent,
              ),
            ),
          ],

          if (savedVideoPath != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: setAsLiveWallpaper,
                icon: const Icon(Icons.wallpaper),
                label: const Text('Set Live Wallpaper'),
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
        Text(
          tr('settings'),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        ListTile(
          leading: const Icon(Icons.language, color: accent),
          title: Text(tr('language')),
          subtitle: Text(language),
          trailing: DropdownButton<String>(
            value: language,
            dropdownColor: panel,
            items: ['English', 'বাংলা', 'Arabic'].map((lang) {
              return DropdownMenuItem(value: lang, child: Text(lang));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => language = value);
              }
            },
          ),
        ),
        const Divider(color: Colors.white12),
        const ListTile(
          leading: Icon(Icons.info_outline, color: accent),
          title: Text('About Live Wallpaper Pro'),
          subtitle: Text('Version 1.0.0'),
        ),
      ],
    );
  }

  void showPreview(Wallpaper wallpaper) {
    showDialog(
      context: context,
      builder: (context) {
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
                  child: Icon(wallpaper.icon, size: 100, color: Colors.white38),
                ),
                const SizedBox(height: 15),
                Text(wallpaper.title, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context)
                        .showSnackBar(SnackBar(content: Text(tr('coming'))));
                  },
                  child: Text(tr('apply')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
