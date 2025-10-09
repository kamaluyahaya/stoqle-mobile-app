import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:stoqle/component/addressSelectionInputRow.dart';
import 'package:stoqle/component/defaultInputRow.dart';
import 'package:stoqle/component/docUpload.dart';
import 'package:stoqle/component/selectionInputRow.dart';
import 'package:stoqle/data/country_hierarcy/page.dart';

import '../help-center/enterprise.dart';

class OpenStoreEnterprisePage extends StatefulWidget {
  const OpenStoreEnterprisePage({Key? key}) : super(key: key);

  @override
  State<OpenStoreEnterprisePage> createState() =>
      _OpenStoreEnterprisePageState();
}

class _OpenStoreEnterprisePageState extends State<OpenStoreEnterprisePage> {
  // State
  File? _selectedNinFile;
  File? _selectedCacFile;
  bool _isAgreed = false;

  // Constants for consistent spacing / style
  static const double _horizontalPadding = 16.0;
  static const double _cardRadius = 14.0;
  static const double _imagePreviewHeight = 180.0;

  // In a StatefulWidget:
  String? address;

  void _showNinUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) => DocumentUploadSheet(
        title: 'National ID (NIN) Upload',
        placeholderAsset: 'assets/images/nin_sample.png',
        guidelines: [
          'Please take a clear photo or upload a clear scan of your NIN card. Ensure the whole card is visible and there is no glare.',
          'Supported formats: PNG/JPG/JPEG. File size must not exceed 5MB.',
          'Ensure the name and NIN number match your profile information.',
        ],
        selectedFile: _selectedNinFile,
        onFileSelected: (file) {
          setState(() => _selectedNinFile = file);
        },
      ),
    );
  }

  void _showBusinessDocSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) => DocumentUploadSheet(
        title: 'Business CAC Certificate',
        placeholderAsset: 'assets/images/cac.png',
        guidelines: [
          'Please upload the original business license or a clear scanned copy. The photo should be complete and free of glare.',
          'Supported formats: PNG/JPG/JPEG. File size must not exceed 5MB.',
          'For companies, ensure the license information matches your business details.',
        ],
        selectedFile: _selectedCacFile,
        onFileSelected: (file) {
          setState(() => _selectedCacFile = file);
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  // Submit handler (placeholder)
  void _onSubmit() {
    // 1. Validate form fields
    if (!_formKey.currentState!.validate()) {
      return; // stop here if any required input is empty
    }

    // 2. Check uploads
    if (_selectedCacFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your Business CAC Certificate.'),
        ),
      );
      return;
    }

    if (_selectedNinFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your National ID (NIN).')),
      );
      return;
    }

    // 3. Check agreement
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms before submitting.'),
        ),
      );
      return;
    }

    // ✅ If all good
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Submitted for review ✅')));
  }

  // ----- Build pieces -----
  PreferredSizeWidget _buildHeader(Color red) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: 'Back',
      ),
      title: const Text(
        'Store Application',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EnterproseBusinessHelp()),
          ),
          icon: Icon(LucideIcons.circleQuestionMark300, color: Colors.black54),
        ),
      ],
    );
  }

  String? _selectedCategory;

  Widget _buildUploadCard({
    required String title,
    required String description,
    required File? file,
    required String placeholderAsset,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.black54)),

            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(_cardRadius),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 221, 220, 220),
                  borderRadius: BorderRadius.circular(_cardRadius),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: file != null
                              ? Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  height: _imagePreviewHeight,
                                  width: double.infinity,
                                )
                              : Image.asset(
                                  placeholderAsset,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title.startsWith('Business')
                              ? 'Upload Business CAC Certificate'
                              : 'Upload Legal Person ID Card',
                          style: const TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // floating add icon (center)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _isAgreed,
              onChanged: (value) => setState(() => _isAgreed = value ?? false),
              checkColor: Colors.white, // white tick mark
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.red; // red fill when checked
                }
                return Colors.grey.shade300; // grey background when unchecked
              }),
              shape: const CircleBorder(), // ✅ circular shape, no border
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  children: [
                    const TextSpan(
                      text: 'I have carefully read and agreed to the ',
                    ),
                    TextSpan(
                      text: '"Stoqle Merchant Service Agreement", ',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      // attach recognizer if you want to open link
                    ),
                    TextSpan(
                      text: 'Merchant Service Agreement, ',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: 'and Information Use Authorization Agreement.',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Main build -----
  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: _buildHeader(red),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),

                      // Business license card
                      _buildUploadCard(
                        title: 'Business License',
                        description:
                            'Please provide your business license information. Once approved, this information cannot be changed.',
                        file: _selectedCacFile,
                        placeholderAsset: 'assets/images/cac_placeholder1.png',
                        onTap: _showBusinessDocSheet,
                      ),
                      const SizedBox(height: 10),

                      _selectedCacFile != null
                          ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  _cardRadius,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      DefaultInputRow(
                                        title: "Business",
                                        hintText: "Business name",
                                        controller: _businessNameController,
                                        isRequired: true,
                                      ),
                                      SelectionInputRow(
                                        title: "Category",
                                        hintText: "Choose a category",
                                        isRequired: true,
                                        selectedValue: _selectedCategory,
                                        options: categories,
                                        onSelected: (value) {
                                          setState(
                                            () => _selectedCategory = value,
                                          );
                                        },
                                      ),

                                      Divider(
                                        thickness: 1,
                                        height: 1,
                                        color: Colors.grey[200],
                                      ),

                                      AddressSelectionInputRow(
                                        title: 'Address',
                                        isRequired: true,
                                        hintText:
                                            'Select Country / State / LGA',
                                        selectedValue: address,
                                        hierarchy: countries,
                                        onSelected: (fullAddress) {
                                          setState(() => address = fullAddress);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 10),

                      // Legal person identity card
                      _buildUploadCard(
                        title: 'Legal Person Identity Verification',
                        description:
                            "Please upload the legal person's identity information registered on the business license, and complete the identity verification.\n\nLegal Person Certificate Affiliation: Kaduna\nLocation: Nigeria",
                        file: _selectedNinFile,
                        placeholderAsset: 'assets/images/nin_placeholder.png',
                        onTap: _showNinUploadSheet,
                      ),
                      const SizedBox(height: 10),

                      // Agreement
                      _buildAgreementSection(),

                      const SizedBox(height: 80), // space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Fixed bottom submit button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Submit for Review',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
