import 'dart:ui'; // For BackdropFilter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stoqle/component/colors/color.dart';

import '../../../../component/default/defaultButton.dart';

// <-- Import your custom spinner widget (adjust the path to where you kept it)
import '../../../../component/loader/custom_loader.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? profileImageUrl;
  String? coverImageUrl;

  final TextEditingController _nameController = TextEditingController(
    text: 'KAMALU YAHAYA',
  );
  final TextEditingController _stoqleIdController = TextEditingController(
    text: 'STQ-00123',
  );
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _regionController = TextEditingController(
    text: 'Kaduna',
  );
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _stateController = TextEditingController(
    text: 'Kaduna',
  );

  // <-- Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stoqleIdController.dispose();
    _bioController.dispose();
    _genderController.dispose();
    _birthdayController.dispose();
    _regionController.dispose();
    _occupationController.dispose();
    _schoolController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  Future<void> _editTextField({
    required String title,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        final _tmpController = TextEditingController(text: controller.text);
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: _tmpController,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hintText),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_tmpController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() => controller.text = result);
    }
  }

  Future<void> _editBio() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final _tmp = TextEditingController(text: _bioController.text);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Bio', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _tmp,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Introduce yourself',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_tmp.text.trim()),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) setState(() => _bioController.text = result);
  }

  Future<void> _pickGender() async {
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Select Gender'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop('Male'),
            child: const Text('Male'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop('Female'),
            child: const Text('Female'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop('Other'),
            child: const Text('Other'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );

    if (choice != null) setState(() => _genderController.text = choice);
  }

  Widget _editableRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    // Layout: label left, value centered, icon right
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: const BoxDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: kBlack10),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value.isNotEmpty ? value : 'Select $label',
                style: TextStyle(
                  fontSize: 15,
                  color: value.isNotEmpty ? Colors.black87 : Colors.grey[500],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_ios, size: 12, color: kBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => _showPreview(),
            child: const Text('Preview', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: SizedBox(
          child: DefaultButton(
            title: "Save",
            color: AppColors.kDefault,
            loader: Text(""),
            onPressed: _saveProfile,
          ),
        ),
      ),

      // ---- BODY with overlay stack ----
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Avatar & Cover
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          key: const ValueKey("avatar"),
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            PhosphorIcons.cat(),
                            size: 50,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Card 1
                  _buildCard(
                    child: Column(
                      children: [
                        _editableRow(
                          label: 'Name',
                          value: _nameController.text,
                          onTap: () => _editTextField(
                            title: 'Name',
                            controller: _nameController,
                          ),
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Stoqle ID',
                          value: _stoqleIdController.text,
                          onTap: () => _editTextField(
                            title: 'Stoqle ID',
                            controller: _stoqleIdController,
                          ),
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Background',
                          value: _stoqleIdController.text,
                          onTap: () => _editTextField(
                            title: 'Stoqle ID',
                            controller: _stoqleIdController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Card 2: Bio
                  _buildCard(
                    child: Column(
                      children: [
                        _editableRow(
                          label: 'Bio',
                          value: _bioController.text.isNotEmpty
                              ? _bioController.text
                              : 'Introduce yourself',
                          onTap: _editBio,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Card 3: Details
                  _buildCard(
                    child: Column(
                      children: [
                        _editableRow(
                          label: 'Gender',
                          value: _genderController.text,
                          onTap: _pickGender,
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Birthday',
                          value: _birthdayController.text,
                          onTap: () =>
                              Navigator.of(context).pushNamed("/gender_age"),
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Region',
                          value: _regionController.text,
                          onTap: () => _editTextField(
                            title: 'Region',
                            controller: _regionController,
                          ),
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Occupation',
                          value: _occupationController.text,
                          onTap: () => _editTextField(
                            title: 'Occupation',
                            controller: _occupationController,
                          ),
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'School',
                          value: _schoolController.text,
                          onTap: () => _editTextField(
                            title: 'School',
                            controller: _schoolController,
                          ),
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'State',
                          value: _stateController.text,
                          onTap: () => _editTextField(
                            title: 'State',
                            controller: _stateController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // ---- Loader overlay: visible when _isLoading is true ----
          if (_isLoading)
            AbsorbPointer(
              absorbing: true,
              child: SizedBox.expand(
                child: Container(
                  // full white background
                  color: CupertinoColors.systemGroupedBackground,
                  child: SafeArea(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomCircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewProfilePage(
          name: _nameController.text,
          stoqleId: _stoqleIdController.text,
          profileImageUrl: profileImageUrl,
          coverImageUrl: coverImageUrl,
          bio: _bioController.text,
          gender: _genderController.text,
          birthday: _birthdayController.text,
          region: _regionController.text,
          occupation: _occupationController.text,
          school: _schoolController.text,
          state: _stateController.text,
        ),
      ),
    );
  }
}

// --- PreviewProfilePage unchanged, keep as-is from your original file ---
class PreviewProfilePage extends StatelessWidget {
  final String name;
  final String stoqleId;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String bio;
  final String gender;
  final String birthday;
  final String region;
  final String occupation;
  final String school;
  final String state;

  const PreviewProfilePage({
    Key? key,
    required this.name,
    required this.stoqleId,
    this.profileImageUrl,
    this.coverImageUrl,
    required this.bio,
    required this.gender,
    required this.birthday,
    required this.region,
    required this.occupation,
    required this.school,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Profile Preview',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (coverImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  coverImageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('No cover image')),
              ),
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 48,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: profileImageUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0] : '',
                      style: const TextStyle(fontSize: 28),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(stoqleId, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 18),
            _previewRow('Bio', bio),
            const SizedBox(height: 8),
            _previewRow('Gender', gender),
            const SizedBox(height: 8),
            _previewRow('Birthday', birthday),
            const SizedBox(height: 8),
            _previewRow('Region', region),
            const SizedBox(height: 8),
            _previewRow('Occupation', occupation),
            const SizedBox(height: 8),
            _previewRow('School', school),
            const SizedBox(height: 8),
            _previewRow('State', state),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 7,
          child: Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
