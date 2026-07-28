import 'package:flutter/material.dart';
import 'package:rg_food_deneme/model/restaurants_model.dart';
import 'package:rg_food_deneme/restaurant.detay.dart';
import 'package:rg_food_deneme/theme.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantsModel restaurant;
  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.brandPrimary.withOpacity(0.9),
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetay(restaurant: restaurant),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(restaurant.imageUrlNet),
              ),
              title: Text(
                restaurant.name,
                style: AppTextStyles.bodymedium20.copyWith(
                  color: AppColors.white,
                ),
              ),
              subtitle: Text(
                restaurant.ortTeslimat + " min",
                style: AppTextStyles.bodymedium16.copyWith(
                  color: AppColors.white,
                ),
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  Text(
                    restaurant.rating.toString(),
                    style: AppTextStyles.bodyregular16.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
