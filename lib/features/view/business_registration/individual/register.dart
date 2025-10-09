import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:stoqle/component/addressSelectionInputRow.dart';
import 'package:stoqle/component/defaultInputRow.dart';
import 'package:stoqle/component/docUpload.dart';
import 'package:stoqle/component/selectionInputRow.dart';
import 'package:stoqle/data/country_hierarcy/page.dart';
import '../help-center/help.dart';
import '../help-center/individual-business-help.dart';

class OpenStoreIndividualPage extends StatefulWidget {
  const OpenStoreIndividualPage({Key? key}) : super(key: key);

  @override
  State<OpenStoreIndividualPage> createState() =>
      _OpenStoreIndividualPageState();
}

class _OpenStoreIndividualPageState extends State<OpenStoreIndividualPage> {
  // State
  File? _selectedNinFile;
  bool _isAgreed = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  String? _selectedCategory;
  String? address;

  // Constants
  static const double _horizontalPadding = 16.0;
  static const double _cardRadius = 14.0;
  static const double _imagePreviewHeight = 180.0;

  // NIN upload bottom sheet
  void _showNinUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) => DocumentUploadSheet(
        title: 'National ID (NIN) Upload',
        placeholderAsset: 'assets/images/nin_sample.png',
        guidelines: [
          'Upload a clear photo or scan of your NIN card.',
          'Supported: PNG/JPG/JPEG (max 5MB).',
          'Ensure name & NIN number match your profile.',
        ],
        selectedFile: _selectedNinFile,
        onFileSelected: (file) {
          setState(() => _selectedNinFile = file);
        },
      ),
    );
  }

  // Upload card widget
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
                        const Text(
                          'Upload your NIN card',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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

  // Agreement section
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
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                  children: [
                    TextSpan(
                      text:
                          'I have carefully read and agreed to the Stoqle Merchant Service Agreement and Information Use Authorization Agreement.',
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

  // Submit handler
  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedNinFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your NIN card.')),
      );
      return;
    }

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms before submitting.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Submitted for review ✅')));
  }

  PreferredSizeWidget _buildHeader(Color red) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Individual Store Application',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => IndividualBusinessHelp()),
            );
          },
          icon: Icon(LucideIcons.circleQuestionMark, color: Colors.black54),
        ),
      ],
    );
  }

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
                      const SizedBox(height: 10),

                      // NIN upload
                      _buildUploadCard(
                        title: 'Identity Verification',
                        description:
                            "Upload your National Identification Number (NIN) card for verification.",
                        file: _selectedNinFile,
                        placeholderAsset: 'assets/images/nin_placeholder.png',
                        onTap: _showNinUploadSheet,
                      ),
                      const SizedBox(height: 10),

                      _selectedNinFile != null
                          ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  _cardRadius,
                                ),
                              ),
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
                                    AddressSelectionInputRow(
                                      title: 'Address',
                                      isRequired: true,
                                      hintText: 'Select Country / State / LGA',
                                      selectedValue: address,
                                      hierarchy: countries,
                                      onSelected: (fullAddress) {
                                        setState(() => address = fullAddress);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 10),

                      _buildAgreementSection(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
