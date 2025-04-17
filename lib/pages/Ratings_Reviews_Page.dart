import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingsReviewsPage extends StatefulWidget {
  final String sellerId;
  final String userId;

  const RatingsReviewsPage({
    Key? key,
    required this.sellerId,
    required this.userId,
  }) : super(key: key);

  @override
  State<RatingsReviewsPage> createState() => _RatingsReviewsPageState();
}

class _RatingsReviewsPageState extends State<RatingsReviewsPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  DocumentSnapshot? _userReviewDoc;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserReviewed();
  }

  Future<void> _checkIfUserReviewed() async {
    final query = await FirebaseFirestore.instance
        .collection('reviews')
        .where('sellerId', isEqualTo: widget.sellerId)
        .where('userId', isEqualTo: widget.userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      setState(() {
        _userReviewDoc = doc;
        _hasSubmitted = true;
        _rating = doc['rating']?.toDouble() ?? 0;
        _reviewController.text = doc['comment'];
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) return;

    final reviewData = {
      'sellerId': widget.sellerId,
      'userId': widget.userId,
      'rating': _rating,
      'comment': _reviewController.text.trim(),
      'timestamp': Timestamp.now(),
    };

    if (_hasSubmitted && _userReviewDoc != null) {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(_userReviewDoc!.id)
          .update(reviewData);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Review updated")));
    } else {
      final doc =
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);
      _userReviewDoc = await doc.get();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Review submitted")));
    }

    setState(() => _hasSubmitted = true);
  }

  Future<void> _deleteReview() async {
    if (_userReviewDoc != null) {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(_userReviewDoc!.id)
          .delete();

      setState(() {
        _hasSubmitted = false;
        _userReviewDoc = null;
        _reviewController.clear();
        _rating = 0;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Review deleted")));
    }
  }

  Widget _buildReviewList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('sellerId', isEqualTo: widget.sellerId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error loading reviews."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No reviews yet."));
        }

        final reviews = snapshot.data!.docs;

        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: reviews.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final reviewDate =
            (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0];

            return ListTile(
              title: Text(data['comment']),
              subtitle: Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text("${data['rating']}"),
                  SizedBox(width: 16),
                  Text("Date: $reviewDate", style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF002B49),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF002B49)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Seller Name Here", // You can make this dynamic if needed
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "You're rating this delivery",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "You ordered 1 gas cylinder on April 5, 2025", // Optionally dynamic
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildReviewList(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your opinion matters to us!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF002B49),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "How was your experience with the service?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 36,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) => setState(() => _rating = rating),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _reviewController,
                      style: TextStyle(fontSize: 14),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Leave a message, if you want",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002B49),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: Colors.black45,
                        ),
                        onPressed: _submitReview,
                        child: Text(
                          _hasSubmitted ? "Update Review" : "Rate now",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    if (_hasSubmitted)
                      Center(
                        child: TextButton(
                          onPressed: _deleteReview,
                          child: const Text(
                            "Delete My Review",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
            ,
          ],
        ),
      ),
    );
  }
}
