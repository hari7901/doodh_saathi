import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/products_model.dart';
import '../../services/fetch_category_service.dart';
import '../../services/fetch_image_banner_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../../services/product_info_service.dart';

class VetView extends StatefulWidget {
  const VetView({Key? key}) : super(key: key);

  @override
  State<VetView> createState() => _VetViewState();
}

class _VetViewState extends State<VetView> with TickerProviderStateMixin {
  PageController pageController = PageController(viewportFraction: 0.8);
  List<File> imageFiles = [];
  List<String> categoryImageUrls = [];
  List<String> categoryNames = [];
  int _currentImageIndex = 0;
  Map<String, dynamic>? cattleInformation; // Holds fetched cattle information
  List<Map<String, dynamic>> herdActivities = []; // Holds fetched herd activities
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _welcomeTextIndex = 0;
  late Timer _textSwitchTimer;
  late AnimationController _shiningController;
  late Animation<double> _shiningAnimation;
  List<Product> products = [];
  List<String> _welcomeTexts = [];
  bool isLoading = false;

  TextEditingController tagController = TextEditingController();
  Map<String, dynamic>? cattleInfo; // Holds fetched cattle info

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchInitialData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(_animationController);
    _shiningController = AnimationController(vsync: this, duration: Duration(seconds: 3))..repeat();
    _shiningAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(_shiningController);

    _animationController.forward();
  }

  void _fetchInitialData() {
    fetchAndCacheImages();
    fetchCategoryData();
    fetchCategoryNamesFromService();
    _startSlideshow();
    fetchProducts();
  }

  @override
  void dispose() {
    tagController.dispose();
    _textSwitchTimer.cancel();
    _animationController.dispose();
    _shiningController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> fetchCattleInfo() async {
    setState(() => isLoading = true);
    String tagNumber = tagController.text.trim();

    if (tagNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a tag number.")));
      setState(() => isLoading = false);
      return;
    }

    try {
      // Fetching cattle info
      var doc = await FirebaseFirestore.instance.collection('cattle_vet').where('tagNumber', isEqualTo: tagNumber).get();
      if (doc.docs.isNotEmpty) {
        var cattleDoc = doc.docs.first;
        cattleInfo = cattleDoc.data();

        // Fetching herd activities for this cattle
        var activitiesDocs = await cattleDoc.reference.collection('herd_activity').get();
        herdActivities = activitiesDocs.docs.map((doc) => doc.data()).toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No cattle found with tag number: $tagNumber")));
        cattleInfo = null;
        herdActivities = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch data: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _startSlideshow() {
    _textSwitchTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      setState(() {
        _welcomeTextIndex = (_welcomeTextIndex + 1) % _welcomeTexts.length;
      });
    });
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


  @override
  Widget build(BuildContext context) {
    List<String> carouselImageUrls = imageFiles.map((file) => file.path).toList();
    _welcomeTexts = ["Welcome To Doodh Saathi","Get health cards for cattle instantly!" ];
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
              "Doodh Saathi",
              style: GoogleFonts.alata(color: Colors.white,fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
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
                    margin:EdgeInsets.only(
                      top: 18,  // Add top margin
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
            SizedBox(height: 10,),
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
                    borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ): Container(
              child: Center(child: CircularProgressIndicator(),),
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
                          Center(
                            child: AnimatedSwitcher(
                              duration: Duration(seconds: 1),
                              child: Text(
                                _welcomeTexts[_welcomeTextIndex],
                                key: ValueKey<int>(_welcomeTextIndex),
                                style: GoogleFonts.alata(
                                  fontSize: 20,
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
            Column(
              children: [
                buildTagInputField(),
                SizedBox(height: 10),
                isLoading
                    ? CircularProgressIndicator()
                    : buildFetchButton(),
                if (cattleInfo != null) buildCattleInfoCard(context),
                if (herdActivities.isNotEmpty) buildHerdActivitiesList(context),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget buildTagInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: tagController,
        decoration: InputDecoration(
          labelText: "Enter Cow Tag Number",
          hintText: "e.g. 123",
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: fetchCattleInfo,
          ),
        ),
      ),
    );
  }

  Widget buildFetchButton() {
    return ElevatedButton(
      onPressed: fetchCattleInfo,
      style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.teal),
      child: const Text('Fetch Cattle Info'),
    );
  }
  Widget buildCattleInfoCard(BuildContext context) {
    return Card(
      color: Colors.teal[700],
      elevation: 5,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cattle Information",
              style: GoogleFonts.alata(
                color: Colors.white,fontWeight: FontWeight.bold,
                fontSize: 22
              ),
            ),
            Divider(color: Colors.teal.shade100),
            ...cattleInfo!.entries
                .where((entry) => entry.key != "ownerId")
                .map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "${entry.key.capitalize()}:  ${entry.value}",
                  style: GoogleFonts.alata(color: Colors.white,fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildHerdActivitiesList(BuildContext context) {
    return Card(
      color: Colors.teal[700],
      elevation: 5,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Herd Activities",
              style: GoogleFonts.alata(
                  color: Colors.white,fontWeight: FontWeight.bold,
                  fontSize: 22
              ),
            ),
            Divider(color: Colors.teal.shade100),
            ...herdActivities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "${activity['title']} - ${activity['date']}",
                  style: GoogleFonts.alata(color: Colors.white,fontSize: 16),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}