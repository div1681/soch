import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blog_model.dart';

class BlogService {
  final _firestore = FirebaseFirestore.instance;

  // Create a new blog
  Future<void> createBlog(BlogModel blog) async {
    try {
      await _firestore.collection('blogs').doc(blog.blogid).set({
        'blogId': blog.blogid,
        'authorId': blog.authorid,
        'authorName': blog.authorname,
        'title': blog.title,
        'content': blog.content,
        'timestamp': blog.timestamp,
        'likes': blog.likes,
        'comments': [], // Init empty list or use subcollection
      });
    } catch (e) {
      print('Error creating blog: $e');
    }
  }

  // Fetch all blogs
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final snapshot = await _firestore
          .collection('blogs')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BlogModel(
          blogid: data['blogId'],
          authorid: data['authorId'],
          authorname: data['authorName'],
          title: data['title'],
          content: data['content'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          likes: List.from(data['likes']),
          comments: List.from(data['comments']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching blogs: $e');
      return [];
    }
  }

  // Fetch blogs by user
  Future<List<BlogModel>> getBlogsByUser(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('blogs')
          .where('authorId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BlogModel(
          blogid: data['blogId'],
          authorid: data['authorId'],
          authorname: data['authorName'],
          title: data['title'],
          content: data['content'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          likes: List.from(data['likes']),
          comments: List.from(data['comments']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching user blogs: $e');
      return [];
    }
  }
}
