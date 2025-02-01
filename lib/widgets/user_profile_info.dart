import 'package:flutter/material.dart';

class UserProfileInfo extends StatelessWidget {
  final String nickname;
  final VoidCallback onNicknameEdit;

  const UserProfileInfo({
    super.key,
    required this.nickname,
    required this.onNicknameEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onNicknameEdit,
                icon: const Icon(Icons.edit, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
