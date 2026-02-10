import 'package:flutter/material.dart';
import '../navbar/navbar.dart';

class CommunityPostsPage extends StatefulWidget {
  const CommunityPostsPage({super.key});

  @override
  State<CommunityPostsPage> createState() => _CommunityPostsPageState();
}

class _CommunityPostsPageState extends State<CommunityPostsPage> {
  final List<CommunityPost> _posts = [
    CommunityPost(
      username: 'Ahmad Rahman',
      userAvatar: Icons.person,
      timeAgo: '5 mins ago',
      location: 'Jalan Ampang, KL',
      content:
          'Jalan Ampang completely flooded! Road closed from Plaza Ampang to KLCC. Please use alternative routes.',
      hasImage: true,
      likes: 24,
      comments: 8,
      category: 'Road Closure',
      categoryColor: Colors.red,
    ),
    CommunityPost(
      username: 'Siti Nurhaliza',
      userAvatar: Icons.person_outline,
      timeAgo: '12 mins ago',
      location: 'Taman Tun Dr Ismail',
      content:
          'Water levels rising at TTDI. Residents please be alert and prepare to evacuate if needed.',
      hasImage: false,
      likes: 45,
      comments: 12,
      category: 'Warning',
      categoryColor: Colors.orange,
    ),
    CommunityPost(
      username: 'Kumar Selvam',
      userAvatar: Icons.person,
      timeAgo: '25 mins ago',
      location: 'Petaling Jaya',
      content:
          'Relief center opened at MBPJ community hall. Hot food and shelter available. Volunteers needed!',
      hasImage: true,
      likes: 67,
      comments: 15,
      category: 'Relief',
      categoryColor: Colors.green,
    ),
    CommunityPost(
      username: 'Lim Wei Cheng',
      userAvatar: Icons.person_outline,
      timeAgo: '45 mins ago',
      location: 'Kampung Baru',
      content:
          'Flood water receding slowly in our area. Cleanup efforts starting. Thank you to all volunteers!',
      hasImage: true,
      likes: 89,
      comments: 23,
      category: 'Update',
      categoryColor: Colors.blue,
    ),
    CommunityPost(
      username: 'Fatimah Zahra',
      userAvatar: Icons.person,
      timeAgo: '1 hour ago',
      location: 'Shah Alam',
      content:
          'Power outage in Section 7. TNB has been notified. Please stay safe everyone.',
      hasImage: false,
      likes: 34,
      comments: 7,
      category: 'Alert',
      categoryColor: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A83B7), Color.fromARGB(255, 29, 255, 142)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Community Updates',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real-time updates from your community',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: true,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Road Closure',
                    isSelected: false,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Warning',
                    isSelected: false,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Relief',
                    isSelected: false,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Update',
                    isSelected: false,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          // Posts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return _PostCard(post: _posts[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Create post button
          FloatingActionButton(
            onPressed: () {
              _showCreatePostDialog(context);
            },
            backgroundColor: Colors.green,
            heroTag: 'createPost',
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Monitor FAB
          const MonitorFAB(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _CreatePostSheet(),
    );
  }
}

class CommunityPost {
  final String username;
  final IconData userAvatar;
  final String timeAgo;
  final String location;
  final String content;
  final bool hasImage;
  final int likes;
  final int comments;
  final String category;
  final Color categoryColor;

  CommunityPost({
    required this.username,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    required this.content,
    required this.hasImage,
    required this.likes,
    required this.comments,
    required this.category,
    required this.categoryColor,
  });
}

class _PostCard extends StatefulWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF3A83B7).withOpacity(0.2),
                  child: Icon(
                    widget.post.userAvatar,
                    color: const Color(0xFF3A83B7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.post.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${widget.post.timeAgo}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.post.categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.post.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.post.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Post image (if any)
          if (widget.post.hasImage)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Post actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${widget.post.likes + (_isLiked ? 1 : 0)}',
                  color: _isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '${widget.post.comments}',
                  color: Colors.grey[600]!,
                  onTap: () {
                    // TODO: Show comments
                  },
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: Colors.grey[600]!,
                  onTap: () {
                    // TODO: Share post
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onPressed: () {
                    // TODO: Show more options
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedCategory = 'Update';
  bool _hasImage = false;

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Create Post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Location field
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Jalan Ampang, KL',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['Road Closure', 'Warning', 'Relief', 'Update', 'Alert']
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'Update';
                });
              },
            ),
            const SizedBox(height: 16),
            // Content field
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'What\'s happening?',
                hintText: 'Share updates about flooding in your area...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Add image button
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _hasImage = !_hasImage;
                });
                // TODO: Implement image picker
              },
              icon: Icon(
                _hasImage ? Icons.check_circle : Icons.add_photo_alternate,
              ),
              label: Text(_hasImage ? 'Image added' : 'Add Image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _hasImage
                    ? Colors.green
                    : const Color(0xFF3A83B7),
                side: BorderSide(
                  color: _hasImage ? Colors.green : const Color(0xFF3A83B7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Post button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Submit post
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A83B7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Post Update',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
