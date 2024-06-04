import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/products_model.dart';
import '../../services/fetch_category_service.dart';
import '../../services/fetch_image_banner_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../../services/product_info_service.dart';
import '../../services/user_profile_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../commodity_detail/supplies.dart';
import '../loan_views/loan_application_page.dart';
import '../loan_views/loan_page.dart';
import '../mycow/cattle_management_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'marketplace.dart';
import 'nearest_vet_page.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  PageController pageController = PageController(viewportFraction: 0.8);
  double _currPageValue = 0.0;
  List<File> imageFiles = [];
  List<String> categoryImageUrls = [];
  late List<String> categoryNames;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _welcomeTextIndex = 0;
  late Timer _textSwitchTimer;
  late AnimationController _shiningController;
  late Animation<double> _shiningAnimation;
  List<Product> products = [];
  int _currentImageIndex = 0;
  List<String> _welcomeTexts = [];

  @override
  void initState() {
    super.initState();
    fetchAndCacheImages();
    fetchCategoryData();
    fetchCategoryNamesFromService();
    _startSlideshow();
    fetchProducts();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shiningController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    _shiningAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shiningController, curve: Curves.linear),
    );

    _animationController.forward();
    _shiningController.repeat();
  }

  void _startSlideshow() {
    _textSwitchTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      setState(() {
        _welcomeTextIndex = (_welcomeTextIndex + 1) % _welcomeTexts.length;
      });
    });
  }

  void _checkAndNavigate() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        bool hasCompleted = await UserService.hasCompletedLoanApplication(currentUser.uid);

        if (!hasCompleted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoanApplicationPage()));
        } else {
          // User has completed the loan application
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoanPage()));
        }
      } else {
        // Handle the case when no user is logged in
        // You can show a login screen or handle it based on your application flow
      }
    } catch (e) {
      print('Error checking and navigating: $e');
      // Handle errors here
    }
  }




  void fetchCategoryData() async {
    List<String> fetchedUrls = await fetchCategoryImageUrls();
    setState(() {
      categoryImageUrls = fetchedUrls;
    });
  }

  void fetchCategoryNamesFromService() async {
    var fetchedNames = await NamesService.fetchCategoryNames();
    setState(() {
      categoryNames = fetchedNames;
    });
  }

  Future<void> fetchAndCacheImages() async {
    List<String> imageUrls = await fetchProductImageUrls();
    var cacheManager = DefaultCacheManager();

    List<File> files = await Future.wait(imageUrls.map((url) async {
      File file = (await cacheManager.getSingleFile(url)) as File;
      return file;
    }));

    if (files.isNotEmpty) {
      setState(() {
        imageFiles = [files.last, ...files, files.first];
      });
    }
  }

  void fetchProducts() async {
    products = await NamesService.fetchProducts();
    setState(() {});
  }

  void _launchDialer(String number, BuildContext context) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to dial $number')));
    }
  }

  @override
  void dispose() {
    _textSwitchTimer.cancel();
    _animationController.dispose();
    _shiningController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> carouselImageUrls =
        imageFiles.map((file) => file.path).toList();
    int minListLength = categoryImageUrls.isNotEmpty && categoryNames.isNotEmpty
        ? (categoryImageUrls.length < categoryNames.length
            ? categoryImageUrls.length
            : categoryNames.length)
        : 0;
    _welcomeTexts = [
      AppLocalizations.of(context)!.welcomeToDoodhSaathi,
      "${AppLocalizations.of(context)!.buyNow}!"
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: <Widget>[
            Image.asset(
              'android/assets/mooFarm.png',
              fit: BoxFit.contain,
              height: 90,
              width: 70,
            ),
            Text(
              "",
              style: GoogleFonts.alata(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: <Widget>[
          InkWell(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NearestVetPage()),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.help,
                style: GoogleFonts.alata(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu_rounded, size: 35, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.green, // Lighter color
                Colors.teal, // Darker color
              ],
            ),
          ),
        ),
      ),
      endDrawer: CustomDrawer(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ContactUsButton(
          onPressed: () => _launchDialer('+918699466669', context),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (imageFiles.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    height: 200.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: carouselImageUrls.map((url) {
                    return Container(
                      margin: EdgeInsets.only(
                        top: 18, // Add top margin
                        left: 8, // Add left margin
                        right: 8, // Add right margin
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        child: Image.file(
                          File(url),
                          fit: BoxFit.cover,
                          width: 1000.0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(
                height: 10,
              ),
              imageFiles.isNotEmpty ?
              DotsIndicator(
                dotsCount: imageFiles.length,
                position: _currentImageIndex.toDouble().round(),
                decorator: DotsDecorator(
                  activeColor: Colors.teal,
                  color: Colors.green,
                  size: const Size.square(9.0),
                  // Size for inactive dots
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ): Container(
                child: Center(child: CircularProgressIndicator(color: Colors.teal,),),
              ),
              // FadeTransition
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: AnimatedBuilder(
                    animation: _shiningAnimation,
                    builder: (context, child) {
                      return Container(
                          // Your container configuration
                          );
                    },
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: AnimatedBuilder(
                    animation: _shiningAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.green, Colors.teal],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _shiningAnimation,
                                builder: (context, _) {
                                  return ShaderMask(
                                    blendMode: BlendMode.srcATop,
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        begin: Alignment(
                                            -1.0 + _shiningAnimation.value,
                                            -1.0),
                                        end: Alignment(
                                            2.0 - _shiningAnimation.value, 1.0),
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.5),
                                          Colors.white.withOpacity(0.2),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Center(
                              child: AnimatedSwitcher(
                                duration: Duration(seconds: 1),
                                child: Text(
                                  _welcomeTexts[_welcomeTextIndex],
                                  key: ValueKey<int>(_welcomeTextIndex),
                                  style: GoogleFonts.alata(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green, Colors.teal],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 12, right: 16, left: 16, bottom: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.1,
                    ),
                    itemCount: minListLength < 3 ? minListLength : 3,
                    itemBuilder: (context, index) {
                      if (index < categoryImageUrls.length &&
                          index < categoryNames.length) {
                        return InkWell(
                          onTap: () {
                            if (index == 0) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDescriptionPage()));
                            } else if (index == 1) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      MyCowPage() // Your cattle management page
                                  ));
                            } else if (index == 2) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CategoryPage()));
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.width / 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    categoryImageUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1),
                              Flexible(
                                child: Text(
                                  categoryNames[index % categoryNames.length],
                                  style: GoogleFonts.alata(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
              _buildMooWalletSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMooWalletSection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _shiningAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green, Colors.teal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.saathiWallet,
                    style: GoogleFonts.alata(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _checkAndNavigate();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.teal, backgroundColor: Colors.white,
                      // Text color
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ).copyWith(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.teal),
                        ),
                      ),
                      // Additional unique design properties
                      shadowColor: MaterialStateProperty.all(Colors.teal),
                      surfaceTintColor:
                          MaterialStateProperty.all(Colors.teal.shade100),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.open,
                      style: GoogleFonts.alata(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
