import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../models/movie_model.dart';
import '../services/ad_service.dart';
import '../services/remote_config_service.dart';
import 'details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchAllHomeData();
    });

    // ✅ Firebase config update হলে UI rebuild করো
    // Data clear না করলেও ads/config instantly update হবে
    RemoteConfigService.addListener(_onConfigUpdated);
  }

  @override
  void dispose() {
    RemoteConfigService.removeListener(_onConfigUpdated);
    super.dispose();
  }

  // ✅ Config update হলে এই function call হবে → setState → UI rebuild
  void _onConfigUpdated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoviFlix',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textWhite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: movieProvider.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryColor))
          : _buildBody(movieProvider),
    );
  }

  Widget _buildBody(MovieProvider movieProvider) {
    final categories = [
      _CategoryData("Trending Now", movieProvider.trendingMovies),
      _CategoryData("Top Rated", movieProvider.topRatedMovies),
      _CategoryData("Action Packed", movieProvider.actionMovies),
      _CategoryData("Sci-Fi & Fantasy", movieProvider.sciFiMovies),
    ];

    final nonEmpty = categories.where((c) => c.movies.isNotEmpty).toList();
    final List<Widget> widgets = [];

    for (int i = 0; i < nonEmpty.length; i++) {
      widgets.add(
        _buildMovieCategory(context, nonEmpty[i].title, nonEmpty[i].movies),
      );

      // প্রতি ২টা category এর পর banner ad
      if ((i + 1) % 2 == 0) {
        widgets.add(const BannerAdWidget());
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          ...widgets,
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMovieCategory(
      BuildContext context, String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () async {
                  await AdService.showInterstitial();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(movie: movie),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.cardColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl:
                          '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryDark,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _CategoryData {
  final String title;
  final List<Movie> movies;
  const _CategoryData(this.title, this.movies);
}