import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'task_sorting.dart';

class TaskDisplay extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final void Function(int oldIndex, int newIndex) onReorder;
  final TaskSortingService sortingService;

  const TaskDisplay({
    Key? key,
    required this.tasks,
    required this.onReorder,
    required this.sortingService,
  }) : super(key: key);

  Color _getBorderColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.blue;
      case 'Medium':
        return Colors.yellow[800]!;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReorderableListView(
        onReorder: onReorder,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (int index = 0; index < tasks.length; index++)
            Container(
              key: ValueKey(tasks[index]['id']),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getBorderColor(tasks[index]['difficulty']), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  tasks[index]['task'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(tasks[index]['date'] as DateTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Difficulty: ${tasks[index]['difficulty']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    final videos = await sortingService.getYouTubeRecommendations(tasks[index]['task']);
                    Navigator.pop(context); // Close loading dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Recommended Videos'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children: videos.map((url) => ListTile(
                              title: Text(url, style: const TextStyle(fontSize: 13)),
                              onTap: () async {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                            )).toList(),
                          ),
                        ),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Error"),
                        content: Text("Failed to fetch videos: $e"),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}