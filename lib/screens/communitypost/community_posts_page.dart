import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../navbar/navbar.dart';

// ─────────────────────────────────────────
// CLOUDINARY CONFIG
// ─────────────────────────────────────────
const String _cloudName = 'devecum8g';
const String _uploadPreset = 'overflow_ai_unsigned';

Future<String?> _uploadToCloudinary(Uint8List imageBytes) async {
  try {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'community_posts'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'post_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return jsonDecode(body)['secure_url'] as String;
    }
    return null;
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────
String _timeAgo(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

// ─────────────────────────────────────────
// FULL-SCREEN IMAGE VIEWER
// ─────────────────────────────────────────
class _FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, p) => p == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
              errorBuilder: (_, __, ___) => const Center(
                  child:
                      Icon(Icons.broken_image, color: Colors.grey, size: 64)),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────
// COMMENTS SHEET
// ─────────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final String postId;
  const _CommentsSheet({required this.postId});
  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();
  bool _isPosting = false;

  // For edit mode
  String? _editingCommentId;
  final _editCtrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final username = (user == null || user.isAnonymous)
          ? 'Anonymous'
          : (user.email?.split('@').first ?? 'Anonymous');
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'username': username,
        'userId': user?.uid ?? '',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .update({'comments': FieldValue.increment(1)});
      _ctrl.clear();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        // ← name it
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Comment'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false), // ← use dialogCtx
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true), // ← use dialogCtx
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .update({'comments': FieldValue.increment(-1)});
    }
  }

  Future<void> _saveEditComment(String commentId) async {
    final text = _editCtrl.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .update({'text': text, 'edited': true});
    setState(() => _editingCommentId = null);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            const Text('Comments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),

            // Comments list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('No comments yet.\nBe the first!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollCtrl,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, i) {
                      final doc = snap.data!.docs[i];
                      final c = doc.data() as Map<String, dynamic>;
                      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final isOwn = c['userId'] == uid;
                      final ts = c['createdAt'] as Timestamp?;
                      final isEditing = _editingCommentId == doc.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  const Color(0xFF3A83B7).withOpacity(0.15),
                              child: const Icon(Icons.person,
                                  color: Color(0xFF3A83B7), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isOwn
                                      ? const Color(0xFF3A83B7)
                                          .withOpacity(0.07)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: isOwn
                                      ? Border.all(
                                          color: const Color(0xFF3A83B7)
                                              .withOpacity(0.2))
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          c['username'] ?? 'Anonymous',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF2D3748)),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _timeAgo(ts?.toDate()),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500]),
                                        ),
                                        if (c['edited'] == true) ...[
                                          const SizedBox(width: 4),
                                          Text('(edited)',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[400],
                                                  fontStyle: FontStyle.italic)),
                                        ],
                                        const Spacer(),
                                        // Edit/Delete only for own comments
                                        if (isOwn)
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_horiz,
                                                size: 16,
                                                color: Colors.grey[500]),
                                            padding: EdgeInsets.zero,
                                            onSelected: (v) {
                                              if (v == 'edit') {
                                                _editCtrl.text =
                                                    c['text'] ?? '';
                                                setState(() =>
                                                    _editingCommentId = doc.id);
                                              } else if (v == 'delete') {
                                                _deleteComment(doc.id);
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(children: [
                                                  Icon(Icons.edit_outlined,
                                                      size: 16),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ]),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(children: [
                                                  Icon(Icons.delete_outline,
                                                      color: Colors.red,
                                                      size: 16),
                                                  SizedBox(width: 8),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ]),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Edit mode inline
                                    if (isEditing) ...[
                                      TextField(
                                        controller: _editCtrl,
                                        autofocus: true,
                                        maxLines: 3,
                                        minLines: 1,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => setState(
                                                () => _editingCommentId = null),
                                            child: const Text('Cancel'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _saveEditComment(doc.id),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF3A83B7),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 6),
                                            ),
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      ),
                                    ] else
                                      Text(c['text'] ?? '',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[800])),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Comment input
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF3A83B7).withOpacity(0.15),
                    child: const Icon(Icons.person,
                        color: Color(0xFF3A83B7), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isPosting ? null : _postComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A83B7),
                        shape: BoxShape.circle,
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send,
                              color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// EDIT POST SHEET
// ─────────────────────────────────────────
class _EditPostSheet extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;
  const _EditPostSheet({required this.postId, required this.postData});
  @override
  State<_EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<_EditPostSheet> {
  late TextEditingController _contentCtrl;
  late TextEditingController _locationCtrl;
  late String _selectedCategory;
  bool _isLoading = false;
  String? _error;

  final _categories = ['Road Closure', 'Warning', 'Relief', 'Update', 'Alert'];

  @override
  void initState() {
    super.initState();
    _contentCtrl =
        TextEditingController(text: widget.postData['content'] ?? '');
    _locationCtrl =
        TextEditingController(text: widget.postData['location'] ?? '');
    _selectedCategory = widget.postData['category'] ?? 'Update';
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _contentCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    if (content.isEmpty) {
      setState(() => _error = 'Content cannot be empty.');
      return;
    }
    if (location.isEmpty) {
      setState(() => _error = 'Location cannot be empty.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .update({
        'content': content,
        'location': location,
        'category': _selectedCategory,
        'edited': true,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to update. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Edit Post',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748))),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v ?? 'Update'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "What's happening?",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: TextStyle(
                                color: Colors.red[700], fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A83B7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────
class CommunityPostsPage extends StatefulWidget {
  const CommunityPostsPage({super.key});
  @override
  State<CommunityPostsPage> createState() => _CommunityPostsPageState();
}

class _CommunityPostsPageState extends State<CommunityPostsPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _filterOptions = [
    {'label': 'All', 'color': Colors.blue},
    {'label': 'Road Closure', 'color': Colors.red},
    {'label': 'Warning', 'color': Colors.orange},
    {'label': 'Relief', 'color': Colors.green},
    {'label': 'Update', 'color': Colors.blue},
    {'label': 'Alert', 'color': Colors.purple},
  ];

  Stream<QuerySnapshot> get _postsStream {
    Query query = FirebaseFirestore.instance
        .collection('community_posts')
        .orderBy('createdAt', descending: true);
    if (_selectedFilter != 'All') {
      query = query.where('category', isEqualTo: _selectedFilter);
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A83B7), Color.fromARGB(255, 29, 217, 255)],
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
                        child: Text('Community Updates',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Real-time updates from your community',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ),

          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter['label'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _selectedFilter = filter['label'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? filter['color'] as Color
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(filter['label'] as String,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Posts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No posts yet.\nBe the first to share!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 15)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) =>
                      _PostCard(doc: snapshot.data!.docs[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => const _CreatePostSheet(),
            ),
            backgroundColor: Colors.green,
            heroTag: 'createPost',
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const MonitorFAB(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

// ─────────────────────────────────────────
// POST CARD
// ─────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final DocumentSnapshot doc;
  const _PostCard({required this.doc});

  Color _categoryColor(String category) {
    switch (category) {
      case 'Road Closure':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      case 'Relief':
        return Colors.green;
      case 'Alert':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Future<void> _toggleLike(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final ref =
        FirebaseFirestore.instance.collection('community_posts').doc(doc.id);
    final data = doc.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likedBy'] ?? []);
    likes.contains(uid) ? likes.remove(uid) : likes.add(uid);
    await ref.update({'likedBy': likes, 'likes': likes.length});
  }

  // ← FIX: uses a fresh rootNavigator context so dialog works on web
  void _showPostMenu(
      BuildContext context, bool isOwner, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            if (isOwner) ...[
              ListTile(
                leading:
                    const Icon(Icons.edit_outlined, color: Color(0xFF3A83B7)),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) =>
                        _EditPostSheet(postId: doc.id, postData: data),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Post',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(sheetCtx); // close menu first
                  // short delay so sheet is fully dismissed before dialog
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (!context.mounted) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      // ← name it
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Delete Post'),
                      content:
                          const Text('Are you sure? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(
                              dialogCtx, false), // ← use dialogCtx
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(dialogCtx, true), // ← use dialogCtx
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await FirebaseFirestore.instance
                        .collection('community_posts')
                        .doc(doc.id)
                        .delete();
                  }
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.grey),
              title: const Text('Report Post'),
              onTap: () => Navigator.pop(sheetCtx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final isLiked = likedBy.contains(uid);
    final isOwner = data['userId'] == uid;
    final category = data['category'] ?? 'Update';
    final catColor = _categoryColor(category);
    final createdAt = data['createdAt'] as Timestamp?;
    final timeAgo = _timeAgo(createdAt?.toDate());
    final imageUrl = data['imageUrl'] as String?;

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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF3A83B7).withOpacity(0.15),
                  child: const Icon(Icons.person,
                      color: Color(0xFF3A83B7), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username + time on same line
                      Row(
                        children: [
                          Text(
                            data['username'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('· $timeAgo',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500])),
                          if (data['edited'] == true) ...[
                            const SizedBox(width: 4),
                            Text('(edited)',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[400],
                                    fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              data['location'] ?? '',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 3-dot → bottom sheet (fixes web dialog issue)
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onPressed: () => _showPostMenu(context, isOwner, data),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data['content'] ?? '',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
            ),
          ),
          const SizedBox(height: 12),

          // Image — tappable
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullScreenImage(imageUrl: imageUrl),
                  ),
                ),
                child: Hero(
                  tag: imageUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, p) {
                            if (p == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: p.expectedTotalBytes != null
                                      ? p.cumulativeBytesLoaded /
                                          p.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey, size: 48),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fullscreen,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _ActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${data['likes'] ?? 0}',
                  color: isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: () => _toggleLike(context),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '${data['comments'] ?? 0}',
                  color: Colors.grey[600]!,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _CommentsSheet(postId: doc.id),
                  ),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: Colors.grey[600]!,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.toUpperCase(),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CREATE POST SHEET
// ─────────────────────────────────────────
class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();
  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _contentCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedCategory = 'Update';
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _error;
  Uint8List? _imagePreviewBytes;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  final _categories = ['Road Closure', 'Warning', 'Relief', 'Update', 'Alert'];

  @override
  void dispose() {
    _contentCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
          source: source, maxWidth: 1080, maxHeight: 1080, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _imagePreviewBytes = bytes;
        _uploadedImageUrl = null;
        _isUploadingImage = true;
        _error = null;
      });
      final url = await _uploadToCloudinary(bytes);
      if (mounted) {
        setState(() {
          _uploadedImageUrl = url;
          _isUploadingImage = false;
          if (url == null) {
            _error =
                'Image upload failed. Post will be submitted without image.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _error = 'Could not pick image. Please try again.';
        });
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Add Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF3A83B7),
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    final content = _contentCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    if (content.isEmpty) {
      setState(() => _error = 'Please write something.');
      return;
    }
    if (location.isEmpty) {
      setState(() => _error = 'Please enter a location.');
      return;
    }
    if (_isUploadingImage) {
      setState(() => _error = 'Image still uploading...');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final username = (user == null || user.isAnonymous)
          ? 'Anonymous'
          : (user.email?.split('@').first ?? 'Anonymous');
      await FirebaseFirestore.instance.collection('community_posts').add({
        'username': username,
        'userId': user?.uid ?? '',
        'location': location,
        'content': content,
        'category': _selectedCategory,
        'likes': 0,
        'likedBy': [],
        'comments': 0,
        'imageUrl': _uploadedImageUrl ?? '',
        'edited': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post shared with the community!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to post. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Create Post',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748))),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Jalan Ampang, KL',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v ?? 'Update'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "What's happening?",
                  hintText: 'Share updates about flooding in your area...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              if (_imagePreviewBytes != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imagePreviewBytes!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 10),
                              Text('Uploading...',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    if (!_isUploadingImage && _uploadedImageUrl != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Ready',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _imagePreviewBytes = null;
                          _uploadedImageUrl = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _showImageSourceSheet,
                icon: Icon(_imagePreviewBytes != null
                    ? Icons.check_circle
                    : Icons.add_photo_alternate),
                label: Text(
                    _imagePreviewBytes != null ? 'Change Photo' : 'Add Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _imagePreviewBytes != null
                      ? Colors.green
                      : const Color(0xFF3A83B7),
                  side: BorderSide(
                    color: _imagePreviewBytes != null
                        ? Colors.green
                        : const Color(0xFF3A83B7),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: TextStyle(
                                color: Colors.red[700], fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A83B7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Post Update',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HELPER WIDGET
// ─────────────────────────────────────────
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
            Text(label,
                style: TextStyle(
                    fontSize: 13, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
