import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/pages/home/widgets/favorites.dart';
import 'package:movie_app/services/favorites_manager.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({Key? key, required this.movieId}) : super(key: key);

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late Future<Movie> movieDetails;
  late Future<Result> similarMovies;
  late Movie currentMovie;

  @override
  void initState() {
    super.initState();
    movieDetails = ApiServices().getMovieDetails(widget.movieId);
    similarMovies = ApiServices().getSimilarMovies(widget.movieId);
  }

  void _toggleFavorite() {
    setState(() {
      if (FavoritesManager.isFavorite(widget.movieId)) {
        FavoritesManager.removeFavorite(widget.movieId);
      } else {
        FavoritesManager.addFavorite(widget.movieId);
      }
    });
  }

  List<Widget> _buildRatingStars(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      Icon starIcon;
      if (i <= rating) {
        starIcon = const Icon(Icons.star, color: Colors.yellow);
      } else {
        starIcon = const Icon(Icons.star_border, color: Colors.grey);
      }
      stars.add(starIcon);
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
        actions: [
          FutureBuilder<Movie>(
            future: movieDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                currentMovie = snapshot.data!;
                return IconButton(
                  icon: Icon(
                    FavoritesManager.isFavorite(currentMovie.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: FavoritesManager.isFavorite(currentMovie.id)
                        ? Colors.red
                        : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                );
              }
              return Container();
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Movie>(
        future: movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.5,
                          width: screenWidth,
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          height: screenHeight * 0.5,
                          width: screenWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Release Date: ${movie.releaseDate?.year ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _buildRatingStars(movie.voteAverage / 2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      movie.overview,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filmes Parecidos',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Result>(
                      future: similarMovies,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final movies = snapshot.data!.movies.take(3).toList();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: movies.map((similarMovie) {
                              return Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      height: 150,
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w500${similarMovie.posterPath}',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text(
                                      similarMovie.title,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const Center(
                            child: Text('No similar movies found'));
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
