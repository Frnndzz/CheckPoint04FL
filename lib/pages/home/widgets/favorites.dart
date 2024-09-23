import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/services/favorites_manager.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Favoritos')),
      body: FutureBuilder<List<Movie>>(
        future: loadFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final movie = snapshot.data![index];
                return ListTile(
                  title: Text(movie.title),
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    width: 50,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailPage(movieId: movie.id),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('Nenhum filme favorito encontrado.'));
        },
      ),
    );
  }

  Future<List<Movie>> loadFavorites() async {
    List<Movie> favoriteMovies = [];
    List<int> favoriteIds = FavoritesManager.getFavorites();

    for (int movieId in favoriteIds) {
      try {
        Movie movie = await ApiServices().getMovieDetails(movieId);
        favoriteMovies.add(movie);
      } catch (e) {
        print('Error fetching movie with ID $movieId: $e');
      }
    }

    return favoriteMovies;
  }
}
