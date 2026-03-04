import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/recipe.dart';

class SearchResultTile extends StatelessWidget {
  final Recipe recipe;

  const SearchResultTile({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: recipe.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )
            : const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.restaurant),
              ),
      ),
      title: Text(recipe.title),
      subtitle: Text(
        '${recipe.category} • ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min',
      ),
      trailing: recipe.caloriesPerServing != null
          ? Text('${recipe.caloriesPerServing} cal')
          : null,
      onTap: () => context.push('/recipe/${recipe.id}', extra: recipe),
    );
  }
}
