import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soch/models/blog_model.dart';
import 'package:soch/services/blog_services.dart';
import 'package:soch/utils/app_theme.dart';
import 'package:soch/widgets/blog_tile.dart';
import 'package:soch/widgets/skeleton_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  final _blogSvc = BlogService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field after the transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: (val) {
                              setState(() => _query = val.trim());
                            },
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search blogs, authors...',
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                CupertinoIcons.search,
                                color: AppTheme.accent,
                                size: 20,
                              ),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(CupertinoIcons.clear_circled_solid,
                                          color: Colors.grey, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.outfit(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Results or Suggestions
            Expanded(
              child: _query.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<BlogModel>>(
      stream: _blogSvc.streamAllBlogs(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        
        final allBlogs = snap.data ?? [];
        final filtered = allBlogs.where((blog) {
          final q = _query.toLowerCase();
          return blog.title.toLowerCase().contains(q) ||
              blog.authorname.toLowerCase().contains(q) ||
              blog.category.toLowerCase().contains(q);
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.search, size: 64, color: Colors.grey.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: GoogleFonts.outfit(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final blog = filtered[i];
            final isLiked = blog.likes.contains(_uid);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BlogTile(
                blog: blog,
                isLiked: isLiked,
                onLike: () async {
                   if (_uid == null) return;
                   await _blogSvc.toggleLike(
                          blogId: blog.blogid,
                          uid: _uid!,
                          alreadyLiked: isLiked,
                        );
                },
                onTap: () => Navigator.pushNamed(
                  context,
                  '/blogDetail',
                  arguments: blog.blogid,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    // Premium "Suggested" or "History" placeholder
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'TRENDING TOPICS',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTopicTag('Technology'),
              _buildTopicTag('Design'),
              _buildTopicTag('Art'),
              _buildTopicTag('Lifestyle'),
              _buildTopicTag('Productivity'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTag(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
         HapticFeedback.lightImpact();
         _searchController.text = label;
         setState(() => _query = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '#$label',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
