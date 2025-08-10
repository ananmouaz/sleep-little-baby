import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:white_noise/presentation/pages/sound_grid_screen.dart';

import '../../constants/app_styles.dart';
import '../widgets/animated_button.dart';

enum PaywallType {
  yearlyWithFreeYear,
  lifetime,
  yearlyWithTrial
}

class PremiumPaywall extends StatefulWidget {
  const PremiumPaywall({super.key});

  @override
  State<PremiumPaywall> createState() => _PremiumPaywallState();
}

class _PremiumPaywallState extends State<PremiumPaywall> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  ProductDetails? _product;
  ProductDetails? _trialProduct;
  late PaywallType _paywallType = PaywallType.yearlyWithFreeYear;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      _initializeConfig(),
      _initializePurchase(),
    ]);

    // Add a small delay to show the animation
    await Future.delayed(const Duration(milliseconds: 3200));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final type = remoteConfig.getString('paywall_type');
    setState(() {
      switch (type) {
          case 'yearly_free_year':
          _paywallType = PaywallType.yearlyWithFreeYear;
          break;
        case 'premium_lifetime':
          _paywallType = PaywallType.lifetime;
          break;
        case 'yearly_trial':
          _paywallType = PaywallType.yearlyWithTrial;
          break;
        default:
          _paywallType = PaywallType.yearlyWithFreeYear;
      }
    });
  }

  Future<void> _initializePurchase() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) return;

    final String productId = switch (_paywallType) {
      PaywallType.lifetime => 'premium_lifetime',
      PaywallType.yearlyWithFreeYear => 'slp_yearly_premium',
      PaywallType.yearlyWithTrial => 'slp_yearly_premium_main',
    };

    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails({productId});

    if (response.productDetails.isNotEmpty) {
      setState(() {
        if(response.productDetails.length == 1) {
          _product = response.productDetails.first;
        }
        else {
          _product = response.productDetails.firstWhere((product) => product.rawPrice > 0);
          _trialProduct = response.productDetails.firstWhere((product) => product.rawPrice == 0.0);
        }
      });
    }

    _subscription = _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate);
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _isLoading = true;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${purchaseDetails.error!.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SoundGridScreen()),
                (Route<dynamic> route) => false,
          );
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }

        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  String get _headerTitle => switch (_paywallType) {
    PaywallType.yearlyWithFreeYear => '🎁 Special Launch Offer!',
    PaywallType.lifetime => '⭐ Exclusive Lifetime Deal!',
    PaywallType.yearlyWithTrial => '🌟 Experience Premium Free!',
  };

  String get _headerSubtitle => switch (_paywallType) {
    PaywallType.yearlyWithFreeYear => 'First 100 people will Get a FULL YEAR of Premium access completely FREE!',
    PaywallType.lifetime => 'One-time payment, lifetime of benefits',
    PaywallType.yearlyWithTrial => 'Try all Premium features free for 3 days',
  };

  String get _priceDisplay => switch (_paywallType) {
    PaywallType.yearlyWithFreeYear => '1 Year ${_trialProduct?.price ?? 'Free'}',
    PaywallType.lifetime => _product?.price ?? '',
    PaywallType.yearlyWithTrial => '3 Days Free',
  };

  String get _subPrice => switch (_paywallType) {
    PaywallType.yearlyWithFreeYear => 'Then ${_product?.price}/year (After a year)',
    PaywallType.lifetime => 'One-time payment only',
    PaywallType.yearlyWithTrial => 'Then ${_product?.price}/year',
  };

  String get _ctaButtonText => switch (_paywallType) {
    PaywallType.yearlyWithFreeYear => 'START FREE YEAR',
    PaywallType.lifetime => 'GET LIFETIME ACCESS',
    PaywallType.yearlyWithTrial => 'START 3-DAY FREE TRIAL',
  };

  List<String> get _benefits => switch (_paywallType) {
    PaywallType.yearlyWithFreeYear => [
      '✓ Full year of Premium completely FREE',
      '✓ Cancel anytime before renewal',
    ],
    PaywallType.lifetime => [
      '✓ Lifetime access to ALL features',
      '✓ All future updates included',
      '✓ No recurring charges ever',
    ],
    PaywallType.yearlyWithTrial => [
      '✓ 3-day free trial to explore Premium',
      '✓ Cancel anytime during trial',
      '✓ ${_product?.price}/year after trial',
    ],
  };

  // Update the main build method to adjust the bottom padding
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple[100]!, Colors.blue[100]!],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.indigo[900]),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SoundGridScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeaderSection(),
                            const SizedBox(height: 24),
                            _buildFeatureGrid(),
                            const SizedBox(height: 24),
                            _buildPriceDisplay(),
                            const SizedBox(height: 16),
                            _buildBenefitsList(),
                            const SizedBox(height: 24),
                            _buildSecurityBadges(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildFixedBottomButton(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 400,
                      height: 400,
                      child: Lottie.asset(
                        'assets/animations/gift_unwrap.json',
                        fit: BoxFit.contain,
                        repeat: false
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unwrapping something special...',
                      style: AppStyles.h4.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay() {
    if (_product == null) return const SizedBox();

    return Column(
      children: [
        Text(
          _priceDisplay,
          style: AppStyles.h2.copyWith(
            fontSize: 36,
            color: Colors.deepPurple,
            shadows: [Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _subPrice,
          style: AppStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFixedBottomButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.purple[100]!.withOpacity(0.8),
            Colors.blue[100]!.withOpacity(0.95),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 32, 24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo[900]!,
                Colors.deepPurple[800]!,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          child: AnimatedButton(
            onPressed: () {
              if(_product != null && (_product!.id) == 'premium_lifetime') {
                _inAppPurchase.buyNonConsumable(
                  purchaseParam: PurchaseParam(
                    productDetails:  _product!,
                  ),
                );
              }
              else if (_product != null) {
                _inAppPurchase.buyConsumable(
                  purchaseParam: PurchaseParam(
                    productDetails: _trialProduct ?? _product!,
                  ),
                );
              }
            },
              text: _ctaButtonText,
          ),
        ),
      ),
    );
  }


  Widget _buildHeaderSection() {
    return Column(
      children: [
        Text(
          _headerTitle,
          style: AppStyles.h2.copyWith(
            fontSize: 22,
            color: Colors.indigo[900],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _headerSubtitle,
          style: AppStyles.title.copyWith(
            height: 1.4,
            color: Colors.indigo[800],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'emoji': '🎵', 'title': 'Unlimited Access'},
      {'emoji': '🔕', 'title': 'Ad-Free Experience'},
      {'emoji': '⏰', 'title': 'Advanced Timer'},
      {'emoji': '📱', 'title': 'Monthly New Sounds'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(features[index]['emoji']!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  maxLines: 2,
                  features[index]['title']!,
                  style: AppStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBenefitsList() {
    return Column(
      children: _benefits.map((benefit) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          benefit,
          style: AppStyles.caption.copyWith(
            height: 1.5,
            fontSize: 14,
            color: Colors.indigo[900],
          ),
          textAlign: TextAlign.center,
        ),
      )).toList(),
    );
  }

  Widget _buildSecurityBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        children: [
          _buildSecurityBadge(Icons.lock, 'Secure Payment'),
          _buildSecurityBadge(Icons.verified_user, 'Guaranteed'),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.indigo[900], size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppStyles.caption.copyWith(
            color: Colors.indigo[900],
            fontSize: 13,
          ),
        ),
      ],
    );
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}