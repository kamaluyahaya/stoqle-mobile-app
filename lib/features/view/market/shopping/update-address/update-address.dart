import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  void _showAddressModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddressForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Color(0xFF4a6cfa),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Return subsidy · 7-day no reason return',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pre-sale | Ship within 10 days, delay compensation',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Final price ', style: TextStyle(fontSize: 16)),
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        Text(
                          '45',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'The selected: 抱抱系列-懒羊羊 (35cm)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Pay Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showAddressModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressForm extends StatefulWidget {
  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedCountry;
  String? _selectedRegion;
  bool _isDefaultAddress = false;

  final List<String> countries = ['Nigeria'];

  final List<String> kadunaRegions = ['Kaduna South', 'Kaduna North', 'Igabi'];

  void _showRegionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return RegionSelectionDialog(
          selectedCountry: _selectedCountry,
          selectedRegion: _selectedRegion,
          countries: countries,
          kadunaRegions: kadunaRegions,
          onCountrySelected: (country) {
            setState(() {
              _selectedCountry = country;
              // Reset region when country changes
              if (country != 'Nigeria') {
                _selectedRegion = null;
              }
            });
          },
          onRegionSelected: (region) {
            setState(() {
              _selectedRegion = region;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Add delivery address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Copy address to fill in quickly',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Paste',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Recipient field without border but with rounded corners
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Recipient*',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  // Remove border
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient name';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
            // Phone field without border but with rounded corners
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Contact No.*',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Text('+234'),
                  ),
                  // Remove border
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
            // Region selection without border but with rounded corners
            GestureDetector(
              onTap: _showRegionModal,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCountry ?? 'Select Country',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _selectedRegion ?? 'Select Region',
                          style: TextStyle(
                            color: _selectedRegion != null
                                ? Colors.black
                                : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Address field without border but with rounded corners
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address*',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  hintText: 'Community, House Number, etc.',
                  // Remove border
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isDefaultAddress,
                  onChanged: (value) {
                    setState(() {
                      _isDefaultAddress = value ?? false;
                    });
                  },
                ),
                Text('Set as default address'),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Address saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Save and use'),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class RegionSelectionDialog extends StatefulWidget {
  final String? selectedCountry;
  final String? selectedRegion;
  final List<String> countries;
  final List<String> kadunaRegions;
  final Function(String) onCountrySelected;
  final Function(String) onRegionSelected;

  const RegionSelectionDialog({
    Key? key,
    required this.selectedCountry,
    required this.selectedRegion,
    required this.countries,
    required this.kadunaRegions,
    required this.onCountrySelected,
    required this.onRegionSelected,
  }) : super(key: key);

  @override
  _RegionSelectionDialogState createState() => _RegionSelectionDialogState();
}

class _RegionSelectionDialogState extends State<RegionSelectionDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set initial tab based on whether a country is already selected
    if (widget.selectedCountry != null) {
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 16, bottom: 8),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Container(
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              tabs: [
                Tab(text: 'Country'),
                Tab(text: 'Region'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Country Tab
                ListView.builder(
                  itemCount: widget.countries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final country = widget.countries[index];
                    return ListTile(
                      title: Text(country),
                      trailing: widget.selectedCountry == country
                          ? Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        widget.onCountrySelected(country);
                        // Switch to Region tab after selecting a country
                        _tabController.animateTo(1);
                      },
                    );
                  },
                ),

                // Region Tab
                widget.selectedCountry == 'Nigeria'
                    ? ListView.builder(
                        itemCount: widget.kadunaRegions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final region = widget.kadunaRegions[index];
                          return ListTile(
                            title: Text(region),
                            trailing: widget.selectedRegion == region
                                ? Icon(Icons.check, color: Colors.blue)
                                : null,
                            onTap: () {
                              widget.onRegionSelected(region);
                              Navigator.pop(context);
                            },
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Regions only available for Nigeria',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _tabController.animateTo(0);
                              },
                              child: Text('Change Country'),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
