import 'package:flutter/material.dart';
import 'package:unisphere_app/widgets/app_footer.dart';
import 'package:unisphere_app/widgets/header.dart';
import 'create_event_screen.dart';
import 'discover_event_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      AppHeader(
                        onHostEventTap: () {
                          Navigator.pushNamed(context, '/create-event');
                        },
                        onRegisterTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        onFindEventsTap: () {
                          Navigator.pushNamed(context, '/discover');
                        },
                        onCreateEventsTap: () {
                          Navigator.pushNamed(context, '/create-event');
                        },
                        onMyTicketsTap: () {
                          Navigator.pushNamed(context, '/my-tickets');
                        },
                        onAboutTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                        onSignInTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      _HeroSection(),
                      _StatsSection(),
                      _AudienceSection(),
                      _HowItWorksSection(),
                      _CTASection(),
                    ],
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppColors {
  static const background = Color(0xfff5f7fb);
  static const surface = Colors.white;
  static const primary = Color(0xff4f46e5);
  static const primaryDark = Color(0xff3730a3);
  static const accent = Color(0xffeef2ff);
  static const text = Color(0xff111827);
  static const muted = Color(0xff6b7280);
  static const border = Color(0xffe5e7eb);
}

class AppSpacing {
  static const double sectionY = 90;
  static const double sectionX = 24;
  static const double maxWidth = 1200;
}

class AppTextStyles {
  static const TextStyle heroTitle = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    height: 1.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.2,
  );

  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 17,
    color: AppColors.muted,
    height: 1.6,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.muted,
    height: 1.6,
  );
}

class _SectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const _SectionContainer({required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sectionX,
            vertical: AppSpacing.sectionY,
          ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 920;

    return _SectionContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _HeroText(),
                SizedBox(height: 40),
                _HeroVisual(),
              ],
            )
          : const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: _HeroText()),
                SizedBox(width: 40),
                Expanded(flex: 10, child: _HeroVisual()),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Event discovery & organiser tools in one platform',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Discover local events.\nHost unforgettable ones.',
          style: AppTextStyles.heroTitle,
        ),
        const SizedBox(height: 22),
        const Text(
          'UniSphere helps attendees explore nearby events through a live map, '
          'smart filters, and social discovery tools — while giving organisers '
          'everything they need to create, promote, manage, and grow events.',
          style: AppTextStyles.sectionSubtitle,
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 18,
          runSpacing: 12,
          children: [
            _HeroBullet(text: 'Live event map'),
            _HeroBullet(text: 'Social sharing'),
            _HeroBullet(text: 'Ticket management'),
            _HeroBullet(text: 'Organiser dashboard'),
          ],
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiscoverEventScreen(),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(AppColors.primary),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
                elevation: MaterialStatePropertyAll(0),
                padding: MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
              child: Text('Discover Events'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              style: ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(AppColors.primary),
                side: MaterialStatePropertyAll(
                  BorderSide(color: AppColors.border),
                ),
                padding: MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
              child: const Text('Host an Event'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroBullet extends StatelessWidget {
  final String text;

  const _HeroBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroVisual extends StatefulWidget {
  const _HeroVisual();

  static final List<_EventMarkerData> events = [
    _EventMarkerData(
      title: 'Tech Meetup',
      subtitle: 'Today • 6:30 PM',
      location: LatLng(50.8198, -1.0880), // Portsmouth
      count: 9,
      color: Color(0xff9bd36a),
    ),
    _EventMarkerData(
      title: 'Live Music Night',
      subtitle: 'Fri • 8:00 PM',
      location: LatLng(51.5072, -0.1276), // London
      count: 19,
      color: Color(0xffe8c75f),
    ),
    _EventMarkerData(
      title: 'Food Festival',
      subtitle: 'Sat • 1:00 PM',
      location: LatLng(52.4862, -1.8904), // Birmingham
      count: 12,
      color: Color(0xff9bd36a),
    ),
    _EventMarkerData(
      title: 'Startup Talks',
      subtitle: 'Sun • 5:00 PM',
      location: LatLng(53.4808, -2.2426), // Manchester
      count: 7,
      color: Color(0xff9bd36a),
    ),
  ];

  @override
  State<_HeroVisual> createState() => _HeroVisualState();
}

class _HeroVisualState extends State<_HeroVisual> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffeef2ff), Color(0xffffffff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscoverEventScreen(
                                initialSearchQuery: value,
                              ),
                            ),
                          );
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search events, categories, places...',
                        hintStyle: TextStyle(color: AppColors.muted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(color: AppColors.text),
                    ),
                  ),
                  const Icon(Icons.tune_rounded, color: AppColors.primary),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 120,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(51.0, -0.8),
                  initialZoom: 5.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.unisphere_app',
                  ),
                  MarkerLayer(
                    markers: _HeroVisual.events.map((event) {
                      return Marker(
                        point: event.location,
                        width: 60,
                        height: 60,
                        child: _EventBubble(
                          count: event.count,
                          color: event.color,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMarkerData {
  final String title;
  final String subtitle;
  final LatLng location;
  final int count;
  final Color color;

  const _EventMarkerData({
    required this.title,
    required this.subtitle,
    required this.location,
    required this.count,
    required this.color,
  });
}

class _EventBubble extends StatelessWidget {
  final int count;
  final Color color;

  const _EventBubble({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.92),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ...existing code...

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 20,
        spacing: 20,
        children: const [
          _StatItem(value: '10K+', label: 'Events discovered'),
          _StatItem(value: '2K+', label: 'Active organisers'),
          _StatItem(value: '25+', label: 'Event categories'),
          _StatItem(value: '99%', label: 'Mobile-friendly experience'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _AudienceSection extends StatelessWidget {
  const _AudienceSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      child: Column(
        children: [
          const Text(
            'Built for both sides of the event experience',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 760,
            child: Text(
              'UniSphere connects attendees looking for memorable local experiences '
              'with organisers who need simple, powerful tools to grow successful events.',
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionSubtitle,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              return isMobile
                  ? const Column(
                      children: [
                        _AudiencePanel(
                          title: 'For Attendees',
                          subtitle:
                              'Find what’s happening nearby and plan better with friends.',
                          icon: Icons.explore_rounded,
                          items: [
                            'Browse events on a live interactive map',
                            'Filter by category, date, price, and distance',
                            'Save favourites and revisit them later',
                            'Share events with friends and discover together',
                          ],
                        ),
                        SizedBox(height: 24),
                        _AudiencePanel(
                          title: 'For Organisers',
                          subtitle:
                              'Launch, promote, and manage events with less friction.',
                          icon: Icons.campaign_rounded,
                          items: [
                            'Create event listings quickly',
                            'Sell and manage tickets in one place',
                            'Track attendance and engagement',
                            'Promote events with a clearer organiser dashboard',
                          ],
                        ),
                      ],
                    )
                  : const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AudiencePanel(
                            title: 'For Attendees',
                            subtitle:
                                'Find what’s happening nearby and plan better with friends.',
                            icon: Icons.explore_rounded,
                            items: [
                              'Browse events on a live interactive map',
                              'Filter by category, date, price, and distance',
                              'Save favourites and revisit them later',
                              'Share events with friends and discover together',
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _AudiencePanel(
                            title: 'For Organisers',
                            subtitle:
                                'Launch, promote, and manage events with less friction.',
                            icon: Icons.campaign_rounded,
                            items: [
                              'Create event listings quickly',
                              'Sell and manage tickets in one place',
                              'Track attendance and engagement',
                              'Promote events with a clearer organiser dashboard',
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _AudiencePanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;

  const _AudiencePanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 24)),
          const SizedBox(height: 10),
          Text(subtitle, style: AppTextStyles.body),
          const SizedBox(height: 20),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: AppTextStyles.body)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'How UniSphere works',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 14),
          const Text(
            'A simple flow for discovering events or launching your own.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionSubtitle,
          ),
          const SizedBox(height: 46),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              return isMobile
                  ? const Column(
                      children: [
                        _StepCard(
                          step: '01',
                          title: 'Explore',
                          text:
                              'Search through local events using map-based discovery and smart filters.',
                          icon: Icons.search_rounded,
                        ),
                        SizedBox(height: 18),
                        _StepCard(
                          step: '02',
                          title: 'Choose',
                          text:
                              'Save, share, or book the events that match your interests and schedule.',
                          icon: Icons.favorite_border_rounded,
                        ),
                        SizedBox(height: 18),
                        _StepCard(
                          step: '03',
                          title: 'Host',
                          text:
                              'Create listings, manage attendance, and promote events from one organiser space.',
                          icon: Icons.event_available_rounded,
                        ),
                      ],
                    )
                  : const Row(
                      children: [
                        Expanded(
                          child: _StepCard(
                            step: '01',
                            title: 'Explore',
                            text:
                                'Search through local events using map-based discovery and smart filters.',
                            icon: Icons.search_rounded,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _StepCard(
                            step: '02',
                            title: 'Choose',
                            text:
                                'Save, share, or book the events that match your interests and schedule.',
                            icon: Icons.favorite_border_rounded,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _StepCard(
                            step: '03',
                            title: 'Host',
                            text:
                                'Create listings, manage attendance, and promote events from one organiser space.',
                            icon: Icons.event_available_rounded,
                          ),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String text;
  final IconData icon;

  const _StepCard({
    required this.step,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xfff9fafb),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(title, style: AppTextStyles.cardTitle),
          const SizedBox(height: 10),
          Text(text, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  const _CTASection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 42),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.22),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 850;

            return isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start discovering or hosting with UniSphere',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Bring attendees and organisers together on one modern platform.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DiscoverEventScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Explore Events'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateEventScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Create an Event'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start discovering or hosting with UniSphere',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Bring attendees and organisers together on one modern platform.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DiscoverEventScreen(),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.white,
                              ),
                              foregroundColor: MaterialStatePropertyAll(
                                AppColors.primary,
                              ),
                              elevation: MaterialStatePropertyAll(0),
                              padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 18,
                                ),
                              ),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            child: const Text('Explore Events'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateEventScreen(),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStatePropertyAll(
                                Colors.white,
                              ),
                              side: MaterialStatePropertyAll(
                                BorderSide(color: Colors.white30),
                              ),
                              padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 18,
                                ),
                              ),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            child: const Text('Create an Event'),
                          ),
                        ],
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
