import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';

class FavoritesManager {
  static final List<int> _favorites = []; 

  static void addFavorite(int movieId) {
    if (!_favorites.contains(movieId)) {
      _favorites.add(movieId);
    }
  }

  static void removeFavorite(int movieId) {
    _favorites.remove(movieId);
  }

  static List<int> getFavorites() {
    return List.unmodifiable(_favorites); 
  }

  static bool isFavorite(int movieId) {
    return _favorites.contains(movieId);
  }
}
