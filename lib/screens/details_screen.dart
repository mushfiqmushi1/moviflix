import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/remote_config_service.dart';
import 'player_screen.dart';

class DetailsScreen extends StatelessWidget {
  final Movie movie;

  const DetailsScreen({super.key, required this.movie});


  List<Map<String, String>> _getServers(String tmdbId) {
    return [
      {
        "name": "Server 1",
        "url": "${RemoteConfigService.server1Url}$tmdbId",
      },
      {
        "name": "Server 2",
        "url": "${RemoteConfigService.server2Url}$tmdbId",
      },
      {
        "name": "Server 3",
        "url": "${RemoteConfigService.server3Url}$tmdbId",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final servers = _getServers(movie.id.toString());

    return Scaffold(
      body: Stack(
        children: [
      
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl:
                  '${ApiConstants.originalImageBaseUrl}${movie.backdropPath}',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  Container(color: AppColors.cardColor),
            ),
          ),

          
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.scaffoldBackground.withValues(alpha: 0.8),
                  AppColors.scaffoldBackground,
                ],
              ),
            ),
          ),

        
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),

               
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                   
                      Container(
                        height: 180,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 5))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl:
                                '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                    
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  "${movie.rating.toStringAsFixed(1)} / 10",
                                  style: const TextStyle(
                                      color: AppColors.textGrey, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 25, bottom: 8),
                  child: Text("Storyline",
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    movie.overview,
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 15, height: 1.5),
                  ),
                ),

                
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 30, bottom: 15),
                  child: Text("Select Streaming Server",
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),

               
                ...servers.map((server) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardColor,
                        foregroundColor: AppColors.textWhite,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color:
                                  AppColors.primaryColor.withValues(alpha: 0.3)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              serverUrl: server['url']!,
                              serverName: server['name']!,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill,
                              color: AppColors.primaryColor),
                          const SizedBox(width: 15),
                          Text(server['name']!,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: AppColors.textGrey),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 50),
              ],
            ),
          ),

        
          Positioned(
            top: 45,
            left: 15,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
