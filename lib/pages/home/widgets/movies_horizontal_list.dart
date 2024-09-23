import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/pages/movie_detail_page.dart'; // Importando a página de detalhes

class MoviesHorizontalList extends StatelessWidget {
  final List<Movie> movies;

  const MoviesHorizontalList({Key? key, required this.movies})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Ajuste a altura conforme necessário
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailPage(movieId: movie.id),
                ),
              );
            },
            child: Container(
              width: 120, // Ajuste a largura conforme necessário
              margin: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    fit: BoxFit.cover,
                  ),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
