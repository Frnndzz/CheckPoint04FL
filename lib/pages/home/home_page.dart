import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/pages/home/widgets/movies_horizontal_list.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:movie_app/pages/home/widgets/favorites.dart'; // Importe a página de favoritos

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiServices apiServices = ApiServices();
  late Future<Result> popular;
  late Future<Result> nowPlaying;
  late Future<Result> upcoming;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    popular = apiServices.getPopularMovies();
    nowPlaying = apiServices.getNowPlayingMovies();
    upcoming = apiServices.getUpcomingMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEFI PRIME'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                // Navegar para a página de configurações (ainda não implementada)
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  'Vistos recentemente',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                  ),
                ),
              ),
              FutureBuilder(
                future: nowPlaying,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.hasData) {
                    final movies = snapshot.data!.movies;

                    return Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: movies.length,
                          itemBuilder: (context, index, realIndex) {
                            final movie = movies[index];
                            return Card(
                              color: Colors.grey[850],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                    fit: BoxFit.cover,
                                    height: 300,
                                  ),
                                  const SizedBox(height: 10),
                                  // Removido o Text do título do filme
                                ],
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.5,
                            autoPlay: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4, // Limitar a 4 bolinhas
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (Colors.white.withOpacity(
                                        _currentPage == index ? 0.9 : 0.4)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(
                    child: Text('No data found'),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                  ),
                ),
              ),
              FutureBuilder(
                future: popular,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return MoviesHorizontalList(
                    movies: snapshot.data!.movies,
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  'Em breve',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                  ),
                ),
              ),
              FutureBuilder(
                future: upcoming,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return MoviesHorizontalList(
                    movies: snapshot.data!.movies,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
