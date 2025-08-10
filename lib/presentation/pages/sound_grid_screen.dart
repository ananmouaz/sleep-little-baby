import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:white_noise/presentation/pages/paywall_screen.dart';
import 'package:white_noise/presentation/widgets/sound_card.dart';

import '../../constants/app_styles.dart';

class SoundGridScreen extends StatefulWidget {

  SoundGridScreen({super.key});

  @override
  State<SoundGridScreen> createState() => _SoundGridScreenState();
}

class _SoundGridScreenState extends State<SoundGridScreen> {
  final List<Map<String, dynamic>> sounds = [
    {"name": "Rain", "emoji": "🌧️", "file": "sounds/rain.mp3"},
    {"name": "Heartbeat", "emoji": "💗", "file": "sounds/heartbeat.mp3"},
    {"name": "Washing Machine", "emoji": "🌀", "file": "sounds/washing_machine.mp3"},
    {"name": "Blow Dryer", "emoji": "💨", "file": "sounds/blowdryer.mp3"},
    {"name": "Fan", "emoji": "❄️", "file": "sounds/fan.mp3"},
    {"name": "Road", "emoji": "🚗", "file": "sounds/road.mp3"},
    {"name": "Ocean", "emoji": "🌊", "file": "sounds/ocean.mp3"},
    {"name": "Forest", "emoji": "🌳", "file": "sounds/forest.mp3"},
    {"name": "Space", "emoji": "🚀", "file": "sounds/space.mp3"},
    {"name": "White Noise", "emoji": "📻", "file": "sounds/white_noise.mp3"},
    {"name": "Birds", "emoji": "🐦", "file": "sounds/birds.mp3"},
    {"name": "Lullaby", "emoji": "🎵", "file": "sounds/lullaby.mp3"},
    {"name": "Flame", "emoji": "🔥", "file": "sounds/flame.mp3"},
    {"name": "Bubbles", "emoji": "🫧", "file": "sounds/bubbles.mp3"},
    {"name": "Stream", "emoji": "🏞️", "file": "sounds/stream.mp3"},
    {"name": "Piano", "emoji": "🎹", "file": "sounds/piano.mp3"},
  ];

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _listenToPurchases();
  }

  void _listenToPurchases() {
    _iap.purchaseStream.listen((purchases) {
      bool isSubscribed = purchases.any((purchase) =>
      (purchase.productID == 'yearly_free_year' || purchase.productID == 'premium_lifetime' || purchase.productID == 'yearly_trial') &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored));

      if (mounted) {
        setState(() {
          _isSubscribed = isSubscribed;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple[100]!, Colors.blue[100]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sleep Little Baby',
                      style: AppStyles.h4,
                    ),
                    const SizedBox(width: 12),
                    if(!_isSubscribed)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.indigo[900]!,
                            Colors.deepPurple[800]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PremiumPaywall(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Premium',
                                  style: AppStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: sounds.length,
                    itemBuilder: (context, index) {
                      return SoundCard(
                        name: sounds[index]["name"],
                        emoji: sounds[index]["emoji"],
                        audioFile: sounds[index]["file"],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}