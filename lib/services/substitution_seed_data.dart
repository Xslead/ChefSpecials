import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_substitution.dart';

/// Curated, verified starter data for the substitutions collection.
/// Written with `isVerified: true` and no `submittedBy`.
const List<Map<String, dynamic>> substitutionSeed = [
  // --- Butter ---
  {
    'original': 'butter',
    'name': 'Coconut oil',
    'ratio': '1:1',
    'notes': 'Best for baking. Use refined for neutral flavor.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'butter',
    'name': 'Unsweetened applesauce',
    'ratio': '1/2 cup per 1 cup',
    'notes': 'Lower fat; results in softer, denser baked goods.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'butter',
    'name': 'Greek yogurt',
    'ratio': '1/2 cup per 1 cup',
    'notes': 'Reduces fat; adds slight tang.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'butter',
    'name': 'Olive oil',
    'ratio': '3/4 cup per 1 cup',
    'notes': 'Great for savory dishes and some cakes.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'butter',
    'name': 'Mashed avocado',
    'ratio': '1:1',
    'notes': 'Works well in brownies and chocolate cakes.',
    'tags': ['Vegan', 'Dairy Free'],
  },

  // --- Eggs ---
  {
    'original': 'egg',
    'name': 'Flax egg',
    'ratio': '1 tbsp flax + 3 tbsp water per egg',
    'notes': 'Let sit 5 min to gel. Best in muffins and cookies.',
    'tags': ['Vegan'],
  },
  {
    'original': 'egg',
    'name': 'Chia egg',
    'ratio': '1 tbsp chia + 3 tbsp water per egg',
    'notes': 'Let sit 10 min. Adds a slightly nutty flavor.',
    'tags': ['Vegan'],
  },
  {
    'original': 'egg',
    'name': 'Mashed banana',
    'ratio': '1/4 cup per egg',
    'notes': 'Adds sweetness and moisture; works in quick breads.',
    'tags': ['Vegan'],
  },
  {
    'original': 'egg',
    'name': 'Unsweetened applesauce',
    'ratio': '1/4 cup per egg',
    'notes': 'Binds baked goods without adding much flavor.',
    'tags': ['Vegan'],
  },
  {
    'original': 'egg',
    'name': 'Silken tofu',
    'ratio': '1/4 cup blended per egg',
    'notes': 'Great for custards and dense cakes.',
    'tags': ['Vegan'],
  },
  {
    'original': 'egg',
    'name': 'Aquafaba',
    'ratio': '3 tbsp per egg',
    'notes': 'Whips like egg whites; use in meringues and macarons.',
    'tags': ['Vegan'],
  },

  // --- Milk ---
  {
    'original': 'milk',
    'name': 'Oat milk',
    'ratio': '1:1',
    'notes': 'Creamy texture, neutral flavor. Excellent all-around.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'milk',
    'name': 'Almond milk',
    'ratio': '1:1',
    'notes': 'Slightly nutty; use unsweetened for savory dishes.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'milk',
    'name': 'Soy milk',
    'ratio': '1:1',
    'notes': 'Highest protein dairy-free milk; works in most recipes.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'milk',
    'name': 'Coconut milk',
    'ratio': '1:1',
    'notes': 'Rich and creamy; adds a mild coconut flavor.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'milk',
    'name': 'Cashew milk',
    'ratio': '1:1',
    'notes': 'Very creamy; good for sauces and soups.',
    'tags': ['Vegan', 'Dairy Free'],
  },

  // --- Flour ---
  {
    'original': 'flour',
    'name': 'Almond flour',
    'ratio': '1:1',
    'notes': 'Adds moisture; reduce liquid by 25%. Not suitable for bread.',
    'tags': ['Gluten Free', 'Keto', 'Low Carb'],
  },
  {
    'original': 'flour',
    'name': 'Coconut flour',
    'ratio': '1/4 cup per 1 cup',
    'notes': 'Highly absorbent; add more liquid and eggs.',
    'tags': ['Gluten Free', 'Keto', 'Low Carb'],
  },
  {
    'original': 'flour',
    'name': 'Oat flour',
    'ratio': '1:1',
    'notes': 'Mild flavor; use certified GF oats if needed.',
    'tags': ['Gluten Free'],
  },
  {
    'original': 'flour',
    'name': 'Rice flour',
    'ratio': '7/8 cup per 1 cup',
    'notes': 'Finer texture; often blended with other GF flours.',
    'tags': ['Gluten Free'],
  },
  {
    'original': 'flour',
    'name': 'Chickpea flour',
    'ratio': '1:1',
    'notes': 'High protein; best for savory recipes and flatbreads.',
    'tags': ['Gluten Free', 'Vegan'],
  },

  // --- Sugar ---
  {
    'original': 'sugar',
    'name': 'Honey',
    'ratio': '3/4 cup per 1 cup',
    'notes': 'Reduce liquid by 1/4 cup; lower oven temp by 25°F.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'sugar',
    'name': 'Maple syrup',
    'ratio': '3/4 cup per 1 cup',
    'notes': 'Reduce liquid; adds pleasant caramel notes.',
    'tags': ['Vegan'],
  },
  {
    'original': 'sugar',
    'name': 'Stevia',
    'ratio': '1 tsp per 1 cup',
    'notes': 'Very concentrated; add bulking agent for baking.',
    'tags': ['Keto', 'Low Carb'],
  },
  {
    'original': 'sugar',
    'name': 'Coconut sugar',
    'ratio': '1:1',
    'notes': 'Lower glycemic index; slight caramel flavor.',
    'tags': ['Vegan'],
  },
  {
    'original': 'sugar',
    'name': 'Mashed banana',
    'ratio': '1/2 cup per 1 cup',
    'notes': 'Also reduces other liquid. Works in muffins and breads.',
    'tags': ['Vegan'],
  },
  {
    'original': 'sugar',
    'name': 'Erythritol',
    'ratio': '1:1',
    'notes': 'Bakes similarly to sugar; may cause cooling sensation.',
    'tags': ['Keto', 'Low Carb'],
  },

  // --- Cream ---
  {
    'original': 'cream',
    'name': 'Coconut cream',
    'ratio': '1:1',
    'notes': 'Rich and whippable; chill before whipping.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'cream',
    'name': 'Cashew cream',
    'ratio': '1:1',
    'notes': 'Soak cashews and blend with water. Very versatile.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'cream',
    'name': 'Silken tofu',
    'ratio': '1:1',
    'notes': 'Blend until smooth; great for dairy-free soups.',
    'tags': ['Vegan', 'Dairy Free'],
  },

  // --- Sour cream ---
  {
    'original': 'sour cream',
    'name': 'Greek yogurt',
    'ratio': '1:1',
    'notes': 'Similar tang and texture; use full fat for best results.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'sour cream',
    'name': 'Coconut yogurt',
    'ratio': '1:1',
    'notes': 'Works well in sauces and baked goods.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'sour cream',
    'name': 'Cashew cream + lemon juice',
    'ratio': '1 cup cream + 1 tbsp lemon',
    'notes': 'Tangy and dairy-free.',
    'tags': ['Vegan', 'Dairy Free'],
  },

  // --- Heavy cream ---
  {
    'original': 'heavy cream',
    'name': 'Full-fat coconut milk',
    'ratio': '1:1',
    'notes': 'Use the solid cream at the top of a chilled can.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'heavy cream',
    'name': 'Evaporated milk',
    'ratio': '1:1',
    'notes': 'Lower fat; fine for cooking but won\'t whip.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'heavy cream',
    'name': 'Silken tofu + plant milk',
    'ratio': '1 cup tofu + 1/4 cup milk',
    'notes': 'Blend for a rich plant-based substitute.',
    'tags': ['Vegan', 'Dairy Free'],
  },

  // --- Breadcrumbs ---
  {
    'original': 'breadcrumbs',
    'name': 'Crushed cornflakes',
    'ratio': '1:1',
    'notes': 'Crunchier coating; great for oven-fried dishes.',
    'tags': ['Dairy Free'],
  },
  {
    'original': 'breadcrumbs',
    'name': 'Almond meal',
    'ratio': '1:1',
    'notes': 'Low-carb, gluten-free binding agent.',
    'tags': ['Gluten Free', 'Keto', 'Low Carb'],
  },
  {
    'original': 'breadcrumbs',
    'name': 'Crushed pork rinds',
    'ratio': '1:1',
    'notes': 'Zero-carb crispy coating.',
    'tags': ['Keto', 'Low Carb', 'Gluten Free'],
  },
  {
    'original': 'breadcrumbs',
    'name': 'Rolled oats',
    'ratio': '1:1',
    'notes': 'Pulse briefly in a blender. Use GF oats if needed.',
    'tags': ['Gluten Free'],
  },

  // --- Soy sauce ---
  {
    'original': 'soy sauce',
    'name': 'Coconut aminos',
    'ratio': '1:1',
    'notes': 'Slightly sweeter and less salty.',
    'tags': ['Gluten Free', 'Vegan'],
  },
  {
    'original': 'soy sauce',
    'name': 'Tamari',
    'ratio': '1:1',
    'notes': 'Richer flavor, often gluten-free (check label).',
    'tags': ['Gluten Free', 'Vegan'],
  },
  {
    'original': 'soy sauce',
    'name': 'Worcestershire sauce',
    'ratio': '1:1',
    'notes': 'Use in marinades; not vegan unless specified.',
    'tags': [],
  },

  // --- Extras to push count above 50 ---
  {
    'original': 'buttermilk',
    'name': 'Milk + lemon juice',
    'ratio': '1 cup milk + 1 tbsp lemon',
    'notes': 'Let sit 5 min to curdle.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'buttermilk',
    'name': 'Plain yogurt + water',
    'ratio': '3/4 cup yogurt + 1/4 cup water',
    'notes': 'Similar tang and texture.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'buttermilk',
    'name': 'Plant milk + vinegar',
    'ratio': '1 cup milk + 1 tbsp vinegar',
    'notes': 'Dairy-free buttermilk alternative.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'mayonnaise',
    'name': 'Greek yogurt',
    'ratio': '1:1',
    'notes': 'Lower fat, higher protein.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'mayonnaise',
    'name': 'Mashed avocado',
    'ratio': '1:1',
    'notes': 'Good creamy texture for sandwiches.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'cheese',
    'name': 'Nutritional yeast',
    'ratio': '2 tbsp per 1/4 cup',
    'notes': 'Adds cheesy, umami flavor.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'cheese',
    'name': 'Cashew cheese',
    'ratio': '1:1',
    'notes': 'Blend soaked cashews with nutritional yeast.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'honey',
    'name': 'Maple syrup',
    'ratio': '1:1',
    'notes': 'Fully vegan alternative with similar sweetness.',
    'tags': ['Vegan'],
  },
  {
    'original': 'honey',
    'name': 'Agave nectar',
    'ratio': '1:1',
    'notes': 'Milder flavor than honey.',
    'tags': ['Vegan'],
  },
  {
    'original': 'yogurt',
    'name': 'Coconut yogurt',
    'ratio': '1:1',
    'notes': 'Creamy dairy-free alternative.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'yogurt',
    'name': 'Silken tofu + lemon',
    'ratio': '1 cup tofu + 1 tsp lemon',
    'notes': 'Blend for a tangy, plant-based base.',
    'tags': ['Vegan', 'Dairy Free'],
  },

  // --- Brown sugar ---
  {
    'original': 'brown sugar',
    'name': 'White sugar + molasses',
    'ratio': '1 cup sugar + 1 tbsp molasses',
    'notes': 'Mix well to recreate the caramel flavor.',
    'tags': ['Vegan'],
  },
  {
    'original': 'brown sugar',
    'name': 'Coconut sugar',
    'ratio': '1:1',
    'notes': 'Similar color and mild caramel notes.',
    'tags': ['Vegan'],
  },
  {
    'original': 'brown sugar',
    'name': 'Maple syrup',
    'ratio': '3/4 cup per 1 cup',
    'notes': 'Reduce other liquid by 3 tbsp.',
    'tags': ['Vegan'],
  },

  // --- Cornstarch ---
  {
    'original': 'cornstarch',
    'name': 'All-purpose flour',
    'ratio': '2 tbsp flour per 1 tbsp cornstarch',
    'notes': 'Less glossy finish; cook longer to remove raw taste.',
    'tags': ['Vegan'],
  },
  {
    'original': 'cornstarch',
    'name': 'Arrowroot powder',
    'ratio': '1:1',
    'notes': 'Clear, glossy thickening; works at lower temps.',
    'tags': ['Gluten Free', 'Vegan'],
  },
  {
    'original': 'cornstarch',
    'name': 'Tapioca starch',
    'ratio': '1:1',
    'notes': 'Great for fruit pies and puddings.',
    'tags': ['Gluten Free', 'Vegan'],
  },

  // --- Baking powder / baking soda ---
  {
    'original': 'baking powder',
    'name': 'Baking soda + cream of tartar',
    'ratio': '1/4 tsp soda + 1/2 tsp cream of tartar per 1 tsp',
    'notes': 'Classic homemade swap; use immediately.',
    'tags': ['Vegan'],
  },
  {
    'original': 'baking soda',
    'name': 'Baking powder (3x)',
    'ratio': '3 tsp powder per 1 tsp soda',
    'notes': 'Less reliable rise; may affect flavor.',
    'tags': ['Vegan'],
  },

  // --- Vegetable oil ---
  {
    'original': 'vegetable oil',
    'name': 'Unsweetened applesauce',
    'ratio': '1:1',
    'notes': 'Cuts fat significantly in baking.',
    'tags': ['Vegan'],
  },
  {
    'original': 'vegetable oil',
    'name': 'Melted butter',
    'ratio': '1:1',
    'notes': 'Richer flavor; works in most baked goods.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'vegetable oil',
    'name': 'Coconut oil',
    'ratio': '1:1',
    'notes': 'Solid at room temp; melt before mixing.',
    'tags': ['Vegan', 'Dairy Free'],
  },

  // --- Vanilla extract ---
  {
    'original': 'vanilla extract',
    'name': 'Maple syrup',
    'ratio': '1:1',
    'notes': 'Adds sweetness; works in pancakes and cookies.',
    'tags': ['Vegan'],
  },
  {
    'original': 'vanilla extract',
    'name': 'Almond extract',
    'ratio': '1/2 tsp per 1 tsp vanilla',
    'notes': 'Very concentrated; use less.',
    'tags': ['Vegan'],
  },
  {
    'original': 'vanilla extract',
    'name': 'Vanilla bean paste',
    'ratio': '1:1',
    'notes': 'Richer flavor with visible specks.',
    'tags': ['Vegan'],
  },

  // --- Lemon / lime juice ---
  {
    'original': 'lemon juice',
    'name': 'White vinegar',
    'ratio': '1/2 tsp per 1 tsp juice',
    'notes': 'Provides acidity, missing citrus flavor.',
    'tags': ['Vegan'],
  },
  {
    'original': 'lemon juice',
    'name': 'Lime juice',
    'ratio': '1:1',
    'notes': 'Similar acidity with a different citrus note.',
    'tags': ['Vegan'],
  },
  {
    'original': 'lime juice',
    'name': 'Lemon juice',
    'ratio': '1:1',
    'notes': 'Common interchangeable swap.',
    'tags': ['Vegan'],
  },

  // --- Chocolate / cocoa ---
  {
    'original': 'chocolate',
    'name': 'Cocoa powder + butter',
    'ratio': '3 tbsp cocoa + 1 tbsp butter per 1 oz',
    'notes': 'Stand-in for unsweetened baking chocolate.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'cocoa powder',
    'name': 'Melted dark chocolate',
    'ratio': '3 tbsp cocoa = 1 oz chocolate',
    'notes': 'Reduce other fat in the recipe to compensate.',
    'tags': ['Vegetarian'],
  },

  // --- Molasses ---
  {
    'original': 'molasses',
    'name': 'Maple syrup',
    'ratio': '1:1',
    'notes': 'Lighter flavor; fine for most recipes.',
    'tags': ['Vegan'],
  },
  {
    'original': 'molasses',
    'name': 'Honey + brown sugar',
    'ratio': '3/4 cup honey + 1/4 cup brown sugar',
    'notes': 'Closest flavor match to molasses.',
    'tags': ['Vegetarian'],
  },

  // --- Asian/world ingredients ---
  {
    'original': 'fish sauce',
    'name': 'Soy sauce + lime juice',
    'ratio': '2 tbsp soy + 1 tsp lime per 1 tbsp fish sauce',
    'notes': 'Vegan umami with a touch of acidity.',
    'tags': ['Vegan'],
  },
  {
    'original': 'fish sauce',
    'name': 'Miso paste',
    'ratio': '1/2 tsp miso + 1 tsp water per 1 tsp',
    'notes': 'Deep, salty umami; good for stir-fries.',
    'tags': ['Vegan'],
  },
  {
    'original': 'rice vinegar',
    'name': 'Apple cider vinegar',
    'ratio': '1:1',
    'notes': 'Slightly sharper; add a pinch of sugar.',
    'tags': ['Vegan'],
  },
  {
    'original': 'rice vinegar',
    'name': 'White wine vinegar',
    'ratio': '1:1',
    'notes': 'Mild flavor; works in dressings and sushi rice.',
    'tags': ['Vegan'],
  },
  {
    'original': 'sesame oil',
    'name': 'Olive oil + sesame seeds',
    'ratio': '1 tbsp oil + 1 tsp toasted seeds',
    'notes': 'Mimics nutty flavor in stir-fries.',
    'tags': ['Vegan'],
  },
  {
    'original': 'mirin',
    'name': 'Rice vinegar + sugar',
    'ratio': '1 tbsp vinegar + 1/2 tsp sugar',
    'notes': 'Recreates mirin\'s sweet-tangy profile.',
    'tags': ['Vegan'],
  },
  {
    'original': 'mirin',
    'name': 'White wine + sugar',
    'ratio': '3 tbsp wine + 1 tsp sugar',
    'notes': 'Closest Western pantry swap.',
    'tags': ['Vegan'],
  },

  // --- Healthy / low-carb swaps ---
  {
    'original': 'pasta',
    'name': 'Zucchini noodles',
    'ratio': '2 medium zucchini per 2 oz pasta',
    'notes': 'Spiralize and lightly sauté.',
    'tags': ['Keto', 'Low Carb', 'Gluten Free', 'Vegan'],
  },
  {
    'original': 'pasta',
    'name': 'Spaghetti squash',
    'ratio': '1 cup cooked = 1 cup pasta',
    'notes': 'Roast and shred with a fork.',
    'tags': ['Keto', 'Low Carb', 'Gluten Free', 'Vegan'],
  },
  {
    'original': 'pasta',
    'name': 'Shirataki noodles',
    'ratio': '1:1',
    'notes': 'Rinse well; very low calorie.',
    'tags': ['Keto', 'Low Carb', 'Gluten Free', 'Vegan'],
  },
  {
    'original': 'rice',
    'name': 'Cauliflower rice',
    'ratio': '1:1',
    'notes': 'Pulse florets in a food processor; sauté briefly.',
    'tags': ['Keto', 'Low Carb', 'Gluten Free', 'Vegan'],
  },
  {
    'original': 'rice',
    'name': 'Quinoa',
    'ratio': '1:1',
    'notes': 'Higher protein; rinse before cooking.',
    'tags': ['Gluten Free', 'Vegan'],
  },
  {
    'original': 'rice',
    'name': 'Brown rice',
    'ratio': '1:1',
    'notes': 'More fiber; longer cook time.',
    'tags': ['Gluten Free', 'Vegan'],
  },
  {
    'original': 'ground beef',
    'name': 'Lentils',
    'ratio': '1 cup cooked lentils per 1/2 lb beef',
    'notes': 'Great in chili, tacos, bolognese.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'ground beef',
    'name': 'Mushrooms (finely chopped)',
    'ratio': '1 cup per 1/2 lb beef',
    'notes': 'Meaty umami; use cremini or portobello.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'ground beef',
    'name': 'Plant-based meat crumbles',
    'ratio': '1:1',
    'notes': 'Closest texture match to beef.',
    'tags': ['Vegan'],
  },
  {
    'original': 'bacon',
    'name': 'Turkey bacon',
    'ratio': '1:1',
    'notes': 'Lower fat; crisps up well.',
    'tags': ['Halal'],
  },
  {
    'original': 'bacon',
    'name': 'Tempeh bacon',
    'ratio': '1:1',
    'notes': 'Marinate in soy + maple + smoke; pan-fry.',
    'tags': ['Vegan', 'Halal'],
  },
  {
    'original': 'bacon',
    'name': 'Coconut bacon',
    'ratio': '1:1',
    'notes': 'Baked coconut flakes with smoky seasoning.',
    'tags': ['Vegan', 'Halal'],
  },

  // --- Broths ---
  {
    'original': 'chicken broth',
    'name': 'Vegetable broth',
    'ratio': '1:1',
    'notes': 'Lighter flavor; works in most recipes.',
    'tags': ['Vegan', 'Halal'],
  },
  {
    'original': 'chicken broth',
    'name': 'Bouillon cube + water',
    'ratio': '1 cube per 1 cup water',
    'notes': 'Pantry-friendly; check sodium content.',
    'tags': [],
  },
  {
    'original': 'beef broth',
    'name': 'Vegetable broth + soy sauce',
    'ratio': '1 cup broth + 1 tsp soy',
    'notes': 'Adds depth and umami.',
    'tags': ['Vegan'],
  },
  {
    'original': 'beef broth',
    'name': 'Mushroom broth',
    'ratio': '1:1',
    'notes': 'Rich, earthy flavor.',
    'tags': ['Vegan', 'Halal'],
  },

  // --- Turkish kitchen staples ---
  {
    'original': 'labne',
    'name': 'Greek yogurt (strained)',
    'ratio': '1:1',
    'notes': 'Strain overnight through cheesecloth for similar thickness.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'kaymak',
    'name': 'Mascarpone',
    'ratio': '1:1',
    'notes': 'Rich, creamy, similar fat content.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'kaymak',
    'name': 'Clotted cream',
    'ratio': '1:1',
    'notes': 'Closest Western equivalent.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'kaymak',
    'name': 'Whipped heavy cream',
    'ratio': '1:1',
    'notes': 'Less thick; add mascarpone for body.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'tahini',
    'name': 'Cashew butter',
    'ratio': '1:1',
    'notes': 'Creamy, mild; works in dressings.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'tahini',
    'name': 'Sunflower seed butter',
    'ratio': '1:1',
    'notes': 'Nut-free alternative with similar texture.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'tahini',
    'name': 'Peanut butter',
    'ratio': '1:1',
    'notes': 'Sweeter; works in dressings but changes flavor.',
    'tags': ['Vegan', 'Dairy Free'],
  },
  {
    'original': 'yufka',
    'name': 'Phyllo dough',
    'ratio': '1:1',
    'notes': 'Thinner and crispier; layer with butter.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'yufka',
    'name': 'Flour tortilla',
    'ratio': '1:1',
    'notes': 'Thicker; works for wraps but not börek.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'pekmez',
    'name': 'Molasses',
    'ratio': '1:1',
    'notes': 'Deep flavor; good for desserts and marinades.',
    'tags': ['Vegan'],
  },
  {
    'original': 'pekmez',
    'name': 'Maple syrup',
    'ratio': '1:1',
    'notes': 'Milder; works in breakfast dishes.',
    'tags': ['Vegan'],
  },
  {
    'original': 'sucuk',
    'name': 'Chorizo',
    'ratio': '1:1',
    'notes': 'Spanish spicy sausage; closest flavor match.',
    'tags': [],
  },
  {
    'original': 'sucuk',
    'name': 'Spicy Italian sausage',
    'ratio': '1:1',
    'notes': 'Milder spice; add paprika to match.',
    'tags': [],
  },
  {
    'original': 'beyaz peynir',
    'name': 'Feta cheese',
    'ratio': '1:1',
    'notes': 'Very similar; Greek feta is closest.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'kaşar',
    'name': 'Mild cheddar',
    'ratio': '1:1',
    'notes': 'Similar melting properties.',
    'tags': ['Vegetarian'],
  },
  {
    'original': 'kaşar',
    'name': 'Provolone',
    'ratio': '1:1',
    'notes': 'Mild, melts well on pide and tost.',
    'tags': ['Vegetarian'],
  },

  // --- Aromatics ---
  {
    'original': 'garlic',
    'name': 'Garlic powder',
    'ratio': '1/8 tsp powder per 1 clove',
    'notes': 'Use in sauces and dry rubs.',
    'tags': ['Vegan'],
  },
  {
    'original': 'onion',
    'name': 'Shallots',
    'ratio': '3 shallots per 1 onion',
    'notes': 'Milder, slightly sweeter flavor.',
    'tags': ['Vegan'],
  },
  {
    'original': 'onion',
    'name': 'Onion powder',
    'ratio': '1 tbsp powder per 1 medium onion',
    'notes': 'Good for dry rubs; loses texture.',
    'tags': ['Vegan'],
  },
  {
    'original': 'ginger',
    'name': 'Ground ginger',
    'ratio': '1/4 tsp ground per 1 tsp fresh',
    'notes': 'Less zing; works in baking.',
    'tags': ['Vegan'],
  },
];

List<IngredientSubstitution> defaultSubstitutions() {
  return substitutionSeed
      .map((e) => IngredientSubstitution(
            originalIngredient: e['original'] as String,
            substituteName: e['name'] as String,
            ratio: e['ratio'] as String,
            notes: e['notes'] as String?,
            dietaryTags: List<String>.from(e['tags'] as List),
            isVerified: true,
          ))
      .toList();
}

/// One-shot seeder. Writes each entry if no verified entry for that
/// (originalIngredient, substituteName) pair already exists.
Future<int> seedSubstitutions(FirebaseFirestore db) async {
  final ref = db.collection('substitutions');
  int added = 0;
  for (final sub in defaultSubstitutions()) {
    final existing = await ref
        .where('originalIngredient',
            isEqualTo: IngredientSubstitution.normalize(sub.originalIngredient))
        .where('substituteName', isEqualTo: sub.substituteName)
        .limit(1)
        .get();
    if (existing.docs.isEmpty) {
      await ref.add(sub.toMap());
      added++;
    }
  }
  return added;
}
