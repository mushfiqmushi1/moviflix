import 'dart:convert';
import 'dart:async'; // Timer এর জন্য ইমপোর্ট করা হলো
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Movie> searchResults = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // লাইভ সার্চ কন্ট্রোল করার জন্য টাইমার

  // লাইভ সার্চের ফাংশন
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // ইউজার টাইপ করার মাঝে ৫০০ মিলি-সেকেন্ড থামলে তবেই API কল হবে
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMovies(query);
    });
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String url = '${ApiConstants.baseUrl}/search/movie?api_key=${ApiConstants.apiKey}&query=$query';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['results'] as List;
        setState(() {
          searchResults = data.map((m) => Movie.fromJson(m)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textWhite),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            hintStyle: TextStyle(color: AppColors.textGrey),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged, // কীবোর্ডে টাইপ করার সাথে সাথেই সার্চ শুরু হবে
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.textWhite),
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchResults = [];
              });
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _searchController.text.isEmpty
              ? const SizedBox.shrink() // সার্চবক্স ফাঁকা থাকলে স্ক্রিন একদম ক্লিন থাকবে (কোনো লেখা নেই)
              : searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        "No movies found",
                        style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(movie: movie),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: movie.posterPath.isNotEmpty 
                                  ? '${ApiConstants.imageBaseUrl}${movie.posterPath}'
                                  : 'https://via.placeholder.com/150x225?text=No+Image',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.cardColor),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.cardColor,
                                child: const Icon(Icons.broken_image, color: AppColors.textGrey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}