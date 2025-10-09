// --- PreviewProfilePage unchanged, keep as-is from your original file ---
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
