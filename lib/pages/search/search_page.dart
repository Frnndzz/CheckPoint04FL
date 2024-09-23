import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/pages/movie_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Movie> searchResults = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  void _searchMovies() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final results = await ApiServices().searchMovies(query);
      setState(() {
        searchResults = results.take(10).toList(); 
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Movies')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      padding: const EdgeInsets.all(10.0),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: Colors.grey,
                      ),
                      style: const TextStyle(color: Colors.white),
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      onSubmitted: (value) {
                        _searchMovies(); 
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.grey),
                    onPressed: _searchMovies,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailPage(movieId: movie.id),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        movie.releaseDate != null
                                            ? 'Release Date: ${movie.releaseDate!.toLocal()}'
                                            : 'Release Date: N/A',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Rating: ${movie.voteAverage.toStringAsFixed(1)}/10',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
