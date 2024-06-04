import 'package:DoodhSaathi/src/views/mycow/dashboard/dashboard.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/marketplace_service.dart';
import '../../utils/marketplace_data_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductDescriptionPage extends StatefulWidget {
  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  bool _isSearching = false;
  String _searchQuery = '';
  final MarketplaceService marketplaceService = MarketplaceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : Text(
          AppLocalizations.of(context)!.marketplace,
          style: GoogleFonts.alata(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        leading: _isSearching
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Stop searching and show the regular title
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          },
        )
            : IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _buildActions(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.teal, // Lighter color
                Colors.lightGreen, // Darker color
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[700]!, // Lighter green color
              Colors.white, // Darker green color
            ],
          ),
        ),
        child: FutureBuilder<List<Cow>>(
          future: marketplaceService.getCowsFromFirestore(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error loading cows"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No cows found"));
            }

            List<Cow> filteredCows = _searchQuery.isEmpty
                ? snapshot.data!
                : snapshot.data!
                .where((cow) =>
                cow.cowName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

            return ListView.builder(
              itemCount: filteredCows.length,
              itemBuilder: (context, index) {
                return buildProductItem(context, filteredCows[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.searchCows,
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => _stopSearching(),
        ),
      ];
    }

    return [
      IconButton(
        icon: Icon(
          FontAwesomeIcons.magnifyingGlass,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => setState(() => _isSearching = true),
      ),
      ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Dashboard())
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.store,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void clearSearchQuery() {
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void handleCowSelection(Cow cow) {
    CowProvider cowProvider = Provider.of<CowProvider>(context, listen: false);
    cowProvider.selectCow(cow);
  }

  Widget buildProductItem(BuildContext context, Cow cow) {
    return GestureDetector(
      onTap: () {
        handleCowSelection(cow);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white, // Set the card color to teal
        ),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          elevation: 6,
          color: Colors.green.shade400, // Set the card color to teal
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  handleCowSelection(cow);
                  _showFullImage(context, cow.cowImages);
                },
                child: buildProductImage(cow.cowImages),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Breed on the left
                    Row(
                      children: [
                        Expanded(
                          child: _buildProductDetailRow('Name', ' ${cow
                              .cowName}'),
                        ),
                        Expanded(
                          child: _buildProductDetailRow('Breed', ' ${cow
                              .cowBreed}'),
                        ),
                      ],
                    ),
                    // Weight and Lactations on the right
                    Row(
                      children: [
                        Expanded(
                          child: _buildProductDetailRow('Weight', '${cow
                              .cowWeight} kg'),
                        ),
                        Expanded(
                          child: _buildProductDetailRow('Lactations', '${cow
                              .cowLactation}'),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      collapsedTextColor: Colors.white,
                      title: Text('Additional Information',
                          style: GoogleFonts.alata(color: Colors.white)),
                      children: [
                        _buildProductDetailRow(
                            'Medication', cow.medication ?? 'None'),
                        _buildProductDetailRow(
                            'Last Fever Date', cow.lastFeverDate ?? 'None'),
                        _buildProductDetailRow(
                            'Disease', cow.disease ?? 'None'),
                        _buildProductDetailRow(
                            'Vaccine Name', cow.vaccineName ?? 'None'),
                        _buildProductDetailRow(
                            'Vaccine Date', cow.vaccineDate ?? 'None'),
                      ],
                    ),
                    SizedBox(height: 12),
                    buildAddToCartButton(cow),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProductDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: GoogleFonts.alata(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.alata(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildProductImage(List<String> cowImage) {
    return GestureDetector(
      onTap: () => _showFullImage(context, cowImage), // Wrap cowImage in a list
      child: Container(
        height: 200,
        child: buildImageSlider(cowImage), // Wrap cowImage in a list
      ),
    );
  }

  Widget buildImageSlider(List<String> cowImages) {
    return Container(
      height: 200,
      child: CarouselSlider(
        items: cowImages.map((imageUrl) {
          return Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    imageUrl,
                    width: 150,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                          'android/assets/cow.png',
                          // Placeholder image in case of error
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
              );
            },
          );
        }).toList(),
        options: CarouselOptions(
          height: 200,
          initialPage: 0,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          autoPlay: true,
          onPageChanged: (index, reason) {
            // Handle page change if needed
          },
        ),
      ),
    );
  }

  Widget buildProductName(String name) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[800],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildProductPrice(double price) {
    return Text(
      '${AppLocalizations.of(context)!.price}: \₹${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green[700],
      ),
    );
  }

  Widget buildProductDescription(String description) {
    return Text(
      description,
      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildAddToCartButton(Cow cow) {
    return Consumer<CowProvider>(
      builder: (context, cowDataProvider, child) {
        return GestureDetector(
          onTap: () {
            handleCowSelection(cow);
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.shade900
            ),
            child: TextButton(
              onPressed: () {
                handleCowSelection(cow);
                _launchDialer(
                    "+918699466669", context);
                print(cowDataProvider.selectedCow?.phoneNumber);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: Colors.white),
                  SizedBox(width: 7),
                  Text(
                    AppLocalizations.of(context)!.enquire,
                    style: GoogleFonts.alata(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, List<String> imageUrls) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CarouselSlider(
            items: imageUrls.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              );
            }).toList(),
            options: CarouselOptions(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.7,
              initialPage: 0,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              autoPlay: true,
              onPageChanged: (index, reason) {
                // Handle page change if needed
              },
            ),
          ),
        );
      },
    );
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
}