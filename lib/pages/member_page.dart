import 'package:flutter/material.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> members = [
      {
        'name': 'Azhar Fikri H',
        'nim': '123220042',
        'image': 'assets/human2.jpg',
      },
      {
        'name': 'Re Faiza Depta P',
        'nim': '123220050',
        'image': 'assets/human3.jpg',
      },
      {
        'name': 'Veri Anggoro W',
        'nim': '123220146',
        'image': 'assets/human1.jpg',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(member['image']!),
            ),
            title: Text(
              member['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('NIM: ${member['nim']}'),
          ),
        );
      },
    );
  }
}