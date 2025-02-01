import 'package:flutter/material.dart';

class ProjectStatusBadge extends StatelessWidget {
  final String status;

  const ProjectStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusTextColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '모집 중':
        return Colors.green.withOpacity(0.2);
      case '모집 완료':
        return Colors.orange.withOpacity(0.2);
      case '모집 취소':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case '모집 중':
        return Colors.green.shade800;
      case '모집 완료':
        return Colors.orange.shade800;
      case '모집 취소':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}
