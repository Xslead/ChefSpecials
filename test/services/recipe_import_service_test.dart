import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:chef_specials/services/recipe_import_service.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

String _wrapInHtml(String jsonLd) {
  return '''
<!DOCTYPE html>
<html>
<head>
<script type="application/ld+json">$jsonLd</script>
</head>
<body></body>
</html>''';
}

Map<String, dynamic> _minimalRecipeJson({
  String name = 'Test Recipe',
  String description = 'A delicious test recipe',
  String cookTime = 'PT30M',
  String prepTime = 'PT10M',
  dynamic recipeYield = '4 servings',
  List<String>? recipeIngredient,
  List<dynamic>? recipeInstructions,
  String? recipeCategory,
  dynamic image,
}) {
  return {
    '@type': 'Recipe',
    'name': name,
    'description': description,
    'cookTime': cookTime,
    'prepTime': prepTime,
    'recipeYield': recipeYield,
    'recipeIngredient': recipeIngredient ?? ['2 cups flour', '1 tsp salt'],
    'recipeInstructions': recipeInstructions ?? ['Mix ingredients', 'Bake'],
    'recipeCategory': recipeCategory ?? 'Dinner',
    'image': image ?? 'https://example.com/image.jpg',
  };
}

String _minimalRecipeHtml({
  String name = 'Test Recipe',
  String description = 'A delicious test recipe',
  String cookTime = 'PT30M',
  String prepTime = 'PT10M',
  dynamic recipeYield = '4 servings',
  List<String>? recipeIngredient,
  List<dynamic>? recipeInstructions,
  String? recipeCategory,
  dynamic image,
}) {
  final j = _minimalRecipeJson(
    name: name,
    description: description,
    cookTime: cookTime,
    prepTime: prepTime,
    recipeYield: recipeYield,
    recipeIngredient: recipeIngredient,
    recipeInstructions: recipeInstructions,
    recipeCategory: recipeCategory,
    image: image,
  );
  return _wrapInHtml(json.encode(j));
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('RecipeImportService', () {
    // ── importFromUrl ──────────────────────────────────────────────────────

    group('importFromUrl', () {
      test('returns Recipe from valid JSON-LD HTML', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(
              name: 'Pancakes',
              description: 'Fluffy pancakes',
              cookTime: 'PT15M',
              prepTime: 'PT5M',
              recipeYield: '4 servings',
              recipeIngredient: ['2 cups flour', '1 cup milk'],
              recipeInstructions: ['Mix', 'Cook on griddle'],
              recipeCategory: 'breakfast',
              image: 'https://example.com/pancakes.jpg',
            ),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/pancakes');

        expect(recipe.title, 'Pancakes');
        expect(recipe.description, 'Fluffy pancakes');
        expect(recipe.cookTimeMinutes, 15);
        expect(recipe.prepTimeMinutes, 5);
        expect(recipe.servings, 4);
        expect(recipe.ingredients.length, 2);
        expect(recipe.steps.length, 2);
        expect(recipe.category, 'Breakfast');
        expect(recipe.imageUrl, 'https://example.com/pancakes.jpg');
        expect(recipe.authorId, '');
        expect(recipe.authorName, '');
      });

      test('throws on non-200 status code', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final service = RecipeImportService(client: mockClient);
        expect(
          () => service.importFromUrl('https://example.com/missing'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('HTTP 404'),
          )),
        );
      });

      test('throws when HTML has no JSON-LD', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            '<html><body><p>No recipe here</p></body></html>',
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        expect(
          () => service.importFromUrl('https://example.com/no-recipe'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No recipe schema found'),
          )),
        );
      });

      test('throws when JSON-LD exists but has no Recipe type', () async {
        final nonRecipeJson = json.encode({
          '@type': 'Organization',
          'name': 'Some Company',
        });
        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(nonRecipeJson), 200);
        });

        final service = RecipeImportService(client: mockClient);
        expect(
          () => service.importFromUrl('https://example.com/org'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No recipe schema found'),
          )),
        );
      });
    });

    // ── JSON-LD extraction & @graph traversal ──────────────────────────────

    group('JSON-LD extraction', () {
      test('finds Recipe inside @graph array', () async {
        final graphJson = json.encode({
          '@context': 'https://schema.org',
          '@graph': [
            {'@type': 'WebPage', 'name': 'Some Page'},
            _minimalRecipeJson(name: 'Graph Recipe'),
          ],
        });

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(graphJson), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/graph');
        expect(recipe.title, 'Graph Recipe');
      });

      test('finds Recipe when @type is a list containing Recipe', () async {
        final j = _minimalRecipeJson(name: 'Multi-type Recipe');
        j['@type'] = ['Recipe', 'HowTo'];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/multi');
        expect(recipe.title, 'Multi-type Recipe');
      });

      test('handles JSON-LD as a top-level array', () async {
        final arrayJson = json.encode([
          {'@type': 'Organization', 'name': 'Corp'},
          _minimalRecipeJson(name: 'Array Recipe'),
        ]);

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(arrayJson), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/arr');
        expect(recipe.title, 'Array Recipe');
      });

      test('picks first JSON-LD script that has a Recipe', () async {
        final html = '''
<!DOCTYPE html>
<html><head>
<script type="application/ld+json">
${json.encode({'@type': 'Organization', 'name': 'Corp'})}
</script>
<script type="application/ld+json">
${json.encode(_minimalRecipeJson(name: 'Second Script'))}
</script>
</head><body></body></html>''';

        final mockClient = MockClient((request) async {
          return http.Response(html, 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/two');
        expect(recipe.title, 'Second Script');
      });
    });

    // ── Full recipe parsing ────────────────────────────────────────────────

    group('recipe parsing', () {
      test('parses a complete JSON-LD Recipe', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(
              name: 'Chocolate Cake',
              description: 'Rich and moist chocolate cake',
              cookTime: 'PT1H30M',
              prepTime: 'PT20M',
              recipeYield: '8',
              recipeIngredient: [
                '2 cups sugar',
                '1.5 cups flour',
                '3/4 cup cocoa powder',
              ],
              recipeInstructions: [
                'Preheat oven to 350F',
                'Mix dry ingredients',
                'Bake for 30 minutes',
              ],
              recipeCategory: 'dessert',
              image: 'https://example.com/cake.jpg',
            ),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/cake');

        expect(recipe.title, 'Chocolate Cake');
        expect(recipe.description, 'Rich and moist chocolate cake');
        expect(recipe.cookTimeMinutes, 90);
        expect(recipe.prepTimeMinutes, 20);
        expect(recipe.servings, 8);
        expect(recipe.ingredients.length, 3);
        expect(recipe.steps.length, 3);
        expect(recipe.category, 'Dessert');
        expect(recipe.imageUrl, 'https://example.com/cake.jpg');
      });

      test('defaults to Dinner when no category is provided', () async {
        final mockClient = MockClient((request) async {
          return http.Response(_minimalRecipeHtml(), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/r');
        expect(recipe.category, 'Dinner');
      });

      test('defaults missing fields gracefully', () async {
        final j = {'@type': 'Recipe'};
        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/empty');

        expect(recipe.title, '');
        expect(recipe.description, '');
        expect(recipe.cookTimeMinutes, 0);
        expect(recipe.prepTimeMinutes, 0);
        expect(recipe.servings, 4);
        expect(recipe.ingredients, isEmpty);
        expect(recipe.steps.length, 1);
        expect(recipe.steps.first.instruction, '');
      });
    });

    // ── Duration parsing ───────────────────────────────────────────────────

    group('duration parsing', () {
      test('PT1H30M → 90', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(cookTime: 'PT1H30M', prepTime: 'PT0M'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/d');
        expect(recipe.cookTimeMinutes, 90);
      });

      test('PT45M → 45', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(cookTime: 'PT45M', prepTime: 'PT0M'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/d');
        expect(recipe.cookTimeMinutes, 45);
      });

      test('PT2H → 120', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(cookTime: 'PT2H', prepTime: 'PT0M'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/d');
        expect(recipe.cookTimeMinutes, 120);
      });

      test('null duration → 0 (default)', () async {
        final j = _minimalRecipeJson();
        j.remove('cookTime');
        j.remove('prepTime');

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/d');
        expect(recipe.cookTimeMinutes, 0);
        expect(recipe.prepTimeMinutes, 0);
      });

      test('empty string duration → 0', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(cookTime: '', prepTime: ''),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/d');
        expect(recipe.cookTimeMinutes, 0);
        expect(recipe.prepTimeMinutes, 0);
      });

      test('invalid duration string → 0', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(cookTime: 'not-a-duration', prepTime: 'xyz'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/d');
        expect(recipe.cookTimeMinutes, 0);
        expect(recipe.prepTimeMinutes, 0);
      });
    });

    // ── Servings parsing ───────────────────────────────────────────────────

    group('servings parsing', () {
      test('"4 servings" → 4', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeYield: '4 servings'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/s');
        expect(recipe.servings, 4);
      });

      test('["6"] → 6', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeYield: ['6']),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/s');
        expect(recipe.servings, 6);
      });

      test('integer 12 → 12', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeYield: 12),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/s');
        expect(recipe.servings, 12);
      });

      test('null → 4 (default)', () async {
        final j = _minimalRecipeJson();
        j.remove('recipeYield');

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/s');
        expect(recipe.servings, 4);
      });

      test('"Makes about 10-12 cookies" → 10 (first number)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeYield: 'Makes about 10-12 cookies'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/s');
        expect(recipe.servings, 10);
      });

      test('empty list → 4 (default)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeYield: []),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/s');
        expect(recipe.servings, 4);
      });
    });

    // ── Ingredient parsing ─────────────────────────────────────────────────

    group('ingredient parsing', () {
      test('"2 cups flour" → amount=2, unit=cups, name=flour', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeIngredient: ['2 cups flour']),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/i');

        expect(recipe.ingredients.length, 1);
        final ing = recipe.ingredients.first;
        expect(ing.amount, '2');
        expect(ing.unit, 'cups');
        expect(ing.name, 'flour');
      });

      test('"1.5 kg chicken breast" → amount=1.5, unit=kg, name=chicken breast',
          () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeIngredient: ['1.5 kg chicken breast']),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/i');

        final ing = recipe.ingredients.first;
        expect(ing.amount, '1.5');
        expect(ing.unit, 'kg');
        expect(ing.name, 'chicken breast');
      });

      test('"200g butter" → amount=200, unit=g, name=butter', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeIngredient: ['200g butter']),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/i');

        final ing = recipe.ingredients.first;
        expect(ing.amount, '200');
        expect(ing.unit, 'g');
        expect(ing.name, 'butter');
      });

      test('"salt to taste" → name="salt to taste", amount=""', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeIngredient: ['salt to taste']),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/i');

        final ing = recipe.ingredients.first;
        expect(ing.name, 'salt to taste');
        expect(ing.amount, '');
      });

      test('"1/2 tsp baking soda" → amount=1/2, unit=tsp', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeIngredient: ['1/2 tsp baking soda']),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/i');

        final ing = recipe.ingredients.first;
        expect(ing.amount, '1/2');
        expect(ing.unit, 'tsp');
        expect(ing.name, 'baking soda');
      });

      test('multiple ingredients are all parsed', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeIngredient: [
              '2 cups flour',
              '1 tsp salt',
              '3 large eggs',
              'fresh parsley',
            ]),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/i');

        expect(recipe.ingredients.length, 4);
        expect(recipe.ingredients[0].name, 'flour');
        expect(recipe.ingredients[1].name, 'salt');
        expect(recipe.ingredients[2].name, 'eggs');
        expect(recipe.ingredients[3].name, 'fresh parsley');
      });

      test('non-list recipeIngredient returns empty list', () async {
        final j = _minimalRecipeJson();
        j['recipeIngredient'] = 'just a string';

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/i');

        expect(recipe.ingredients, isEmpty);
      });
    });

    // ── Steps parsing ──────────────────────────────────────────────────────

    group('steps parsing', () {
      test('list of strings → ordered RecipeSteps', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeInstructions: [
              'Preheat oven',
              'Mix ingredients',
              'Bake',
            ]),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 3);
        expect(recipe.steps[0].order, 1);
        expect(recipe.steps[0].instruction, 'Preheat oven');
        expect(recipe.steps[1].order, 2);
        expect(recipe.steps[1].instruction, 'Mix ingredients');
        expect(recipe.steps[2].order, 3);
        expect(recipe.steps[2].instruction, 'Bake');
      });

      test('list of HowToStep objects → extracts text', () async {
        final j = _minimalRecipeJson();
        j['recipeInstructions'] = [
          {'@type': 'HowToStep', 'text': 'Step one text'},
          {'@type': 'HowToStep', 'text': 'Step two text'},
        ];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 2);
        expect(recipe.steps[0].instruction, 'Step one text');
        expect(recipe.steps[1].instruction, 'Step two text');
      });

      test('HowToStep with name fallback when text is missing', () async {
        final j = _minimalRecipeJson();
        j['recipeInstructions'] = [
          {'@type': 'HowToStep', 'name': 'Named step'},
        ];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 1);
        expect(recipe.steps[0].instruction, 'Named step');
      });

      test('HowToSection with itemListElement → flattens steps', () async {
        final j = _minimalRecipeJson();
        j['recipeInstructions'] = [
          {
            '@type': 'HowToSection',
            'name': 'Prepare Dough',
            'itemListElement': [
              {'@type': 'HowToStep', 'text': 'Mix flour and water'},
              {'@type': 'HowToStep', 'text': 'Knead for 10 minutes'},
            ],
          },
          {
            '@type': 'HowToSection',
            'name': 'Bake',
            'itemListElement': [
              {'@type': 'HowToStep', 'text': 'Preheat oven to 400F'},
              {'@type': 'HowToStep', 'text': 'Bake for 25 minutes'},
            ],
          },
        ];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 4);
        expect(recipe.steps[0].order, 1);
        expect(recipe.steps[0].instruction, 'Mix flour and water');
        expect(recipe.steps[1].order, 2);
        expect(recipe.steps[1].instruction, 'Knead for 10 minutes');
        expect(recipe.steps[2].order, 3);
        expect(recipe.steps[2].instruction, 'Preheat oven to 400F');
        expect(recipe.steps[3].order, 4);
        expect(recipe.steps[3].instruction, 'Bake for 25 minutes');
      });

      test('HowToSection with string itemListElement', () async {
        final j = _minimalRecipeJson();
        j['recipeInstructions'] = [
          {
            '@type': 'HowToSection',
            'itemListElement': [
              'Do this first',
              'Then do this',
            ],
          },
        ];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 2);
        expect(recipe.steps[0].instruction, 'Do this first');
        expect(recipe.steps[1].instruction, 'Then do this');
      });

      test('single string instruction → one step', () async {
        final j = _minimalRecipeJson();
        j['recipeInstructions'] = 'Just bake it';

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 1);
        expect(recipe.steps[0].instruction, 'Just bake it');
      });

      test('empty steps list → fallback single empty step', () async {
        final j = _minimalRecipeJson();
        j['recipeInstructions'] = <dynamic>[];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 1);
        expect(recipe.steps[0].instruction, '');
      });

      test('null instructions → fallback single empty step', () async {
        final j = _minimalRecipeJson();
        j.remove('recipeInstructions');

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 1);
        expect(recipe.steps[0].instruction, '');
      });

      test('skips empty/whitespace-only strings', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeInstructions: [
              'Real step',
              '   ',
              '',
              'Another step',
            ]),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/st');

        expect(recipe.steps.length, 2);
        expect(recipe.steps[0].instruction, 'Real step');
        expect(recipe.steps[1].instruction, 'Another step');
      });
    });

    // ── Category parsing ───────────────────────────────────────────────────

    group('category parsing', () {
      test('"breakfast" → Breakfast', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'breakfast'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Breakfast');
      });

      test('"Dessert Recipes" → Dessert', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'Dessert Recipes'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Dessert');
      });

      test('"lunch" → Lunch', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'lunch'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Lunch');
      });

      test('"main course" → Dinner', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'main course'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Dinner');
      });

      test('"sweet treats" → Dessert', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'sweet treats'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Dessert');
      });

      test('"snack" → Snack', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'snack'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Snack');
      });

      test('"beverage" → Drink', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'beverage'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Drink');
      });

      test('"salad" → Salad', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'salad'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Salad');
      });

      test('"soup" → Soup', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'soup'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Soup');
      });

      test('unknown category → defaults to Dinner', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(recipeCategory: 'exotic alien food'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Dinner');
      });

      test('category as list → uses first item', () async {
        final j = _minimalRecipeJson();
        j['recipeCategory'] = ['breakfast', 'brunch'];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/c');
        expect(recipe.category, 'Breakfast');
      });
    });

    // ── Image parsing ──────────────────────────────────────────────────────

    group('image parsing', () {
      test('string URL → extracted directly', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            _minimalRecipeHtml(image: 'https://example.com/photo.jpg'),
            200,
          );
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/img');
        expect(recipe.imageUrl, 'https://example.com/photo.jpg');
      });

      test('map with url key → extracts url', () async {
        final j = _minimalRecipeJson();
        j['image'] = {'@type': 'ImageObject', 'url': 'https://example.com/map.jpg'};

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/img');
        expect(recipe.imageUrl, 'https://example.com/map.jpg');
      });

      test('list of URLs → uses first', () async {
        final j = _minimalRecipeJson();
        j['image'] = [
          'https://example.com/first.jpg',
          'https://example.com/second.jpg',
        ];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/img');
        expect(recipe.imageUrl, 'https://example.com/first.jpg');
      });

      test('list of ImageObject maps → uses first url', () async {
        final j = _minimalRecipeJson();
        j['image'] = [
          {'url': 'https://example.com/obj1.jpg'},
          {'url': 'https://example.com/obj2.jpg'},
        ];

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/img');
        expect(recipe.imageUrl, 'https://example.com/obj1.jpg');
      });

      test('null image → null', () async {
        final j = _minimalRecipeJson();
        j.remove('image');

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/img');
        expect(recipe.imageUrl, isNull);
      });

      test('non-http string → null', () async {
        final j = _minimalRecipeJson();
        j['image'] = 'not-a-url';

        final mockClient = MockClient((request) async {
          return http.Response(_wrapInHtml(json.encode(j)), 200);
        });

        final service = RecipeImportService(client: mockClient);
        final recipe = await service.importFromUrl('https://example.com/img');
        expect(recipe.imageUrl, isNull);
      });
    });

    // ── Constructor ────────────────────────────────────────────────────────

    group('constructor', () {
      test('works without arguments (default client)', () {
        final service = RecipeImportService();
        expect(service, isA<RecipeImportService>());
      });

      test('accepts a custom http.Client', () {
        final mockClient = MockClient((request) async {
          return http.Response('', 200);
        });
        final service = RecipeImportService(client: mockClient);
        expect(service, isA<RecipeImportService>());
      });
    });
  });
}
