import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/badge_controller.dart';
import '../models/badge_model.dart';

class BadgeView extends GetView<BadgeController> {
  const BadgeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Badge Collection",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorsManager.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Statistics Header
          _buildStatisticsHeader(context),
          
          // Filter Section
          _buildFilterSection(context),
          
          // Badge Grid
          Expanded(
            child: _buildBadgeGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(UtilsReponsive.width(16, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primary,
            ColorsManager.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Bar
           TextConstant.subTile1(
                context,
                text: "Collection Progress",
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: UtilsReponsive.height(4, context)),
              TextConstant.subTile1(
                context,
                text: controller.progressText,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  "Total Points",
                  controller.totalPoints.value.toString(),
                  Icons.stars,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  "Unlocked",
                  controller.unlockedBadges.value.toString(),
                  Icons.emoji_events,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  "Total",
                  controller.totalBadges.value.toString(),
                  Icons.collections,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: UtilsReponsive.height(24, context),
        ),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile2(
          context,
          text: value,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        TextConstant.subTile4(
          context,
          text: label,
          color: Colors.white.withOpacity(0.8),
          size: 10,
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: UtilsReponsive.width(16, context)),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: "Search badges...",
              prefixIcon: Icon(Icons.search, color: ColorsManager.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorsManager.primary),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          SizedBox(height: UtilsReponsive.height(12, context)),
          
          // Filter Chips
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  "All",
                  controller.selectedType.value == BadgeType.quiz,
                  () => controller.setSelectedType(BadgeType.quiz),
                ),
                ...controller.allTypes.map((type) => _buildFilterChip(
                  context,
                  type.displayName,
                  controller.selectedType.value == type,
                  () => controller.setSelectedType(type),
                )),
                SizedBox(width: UtilsReponsive.width(8, context)),
                _buildFilterChip(
                  context,
                  "Unlocked Only",
                  controller.showOnlyUnlocked.value,
                  controller.toggleShowOnlyUnlocked,
                  isToggle: true,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap, {bool isToggle = false}) {
    return Container(
      margin: EdgeInsets.only(right: UtilsReponsive.width(8, context)),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : ColorsManager.primary,
            fontWeight: FontWeight.w600,
            fontSize: UtilsReponsive.formatFontSize(12, context),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: isToggle ? Colors.orange : ColorsManager.primary,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.transparent : ColorsManager.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(BuildContext context) {
    return Obx(() {
      final badges = controller.filteredBadges;
      
      if (badges.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: UtilsReponsive.height(80, context),
                color: Colors.grey[400],
              ),
              SizedBox(height: UtilsReponsive.height(16, context)),
              TextConstant.titleH3(
                context,
                text: "No badges found",
                color: Colors.grey[600]!,
              ),
              SizedBox(height: UtilsReponsive.height(8, context)),
              TextConstant.subTile2(
                context,
                text: "Try adjusting your filters",
                color: Colors.grey[500]!,
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: UtilsReponsive.width(12, context),
          mainAxisSpacing: UtilsReponsive.height(12, context),
          childAspectRatio: 0.8,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          return _buildBadgeCard(context, badges[index]);
        },
      );
    });
  }

  Widget _buildBadgeCard(BuildContext context, BadgeModel badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Badge Icon
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: badge.isUnlocked
                        ? _getRarityGradient(badge.rarity)
                        : [Colors.grey[300]!, Colors.grey[400]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        badge.iconPath,
                        width: UtilsReponsive.height(50, context),
                        height: UtilsReponsive.height(50, context),
                        color: badge.isUnlocked ? null : Colors.grey[600],
                      ),
                    ),
                    if (!badge.isUnlocked)
                      Positioned(
                        top: UtilsReponsive.height(8, context),
                        right: UtilsReponsive.width(8, context),
                        child: Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: UtilsReponsive.height(16, context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Badge Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.subTile2(
                      context,
                      text: badge.name,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      size: 12,
                    ),
                    SizedBox(height: UtilsReponsive.height(2, context)),
                    TextConstant.subTile4(
                      context,
                      text: badge.rarity.displayName,
                      color: _getRarityColor(badge.rarity),
                      fontWeight: FontWeight.w600,
                      size: 9,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextConstant.subTile4(
                          context,
                          text: "${badge.points} pts",
                          color: Colors.grey[600]!,
                          size: 9,
                        ),
                        if (badge.isUnlocked)
                          Icon(
                            Icons.check_circle,
                            color: ColorsManager.primary,
                            size: UtilsReponsive.height(16, context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getRarityGradient(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return [Colors.grey[400]!, Colors.grey[500]!];
      case BadgeRarity.rare:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case BadgeRarity.epic:
        return [Colors.purple[400]!, Colors.purple[600]!];
      case BadgeRarity.legendary:
        return [Colors.amber[400]!, Colors.orange[600]!];
    }
  }

  Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.grey[600]!;
      case BadgeRarity.rare:
        return Colors.blue[600]!;
      case BadgeRarity.epic:
        return Colors.purple[600]!;
      case BadgeRarity.legendary:
        return Colors.amber[600]!;
    }
  }

  void _showBadgeDetails(BuildContext context, BadgeModel badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBadgeDetailsSheet(context, badge),
    );
  }

  Widget _buildBadgeDetailsSheet(BuildContext context, BadgeModel badge) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: UtilsReponsive.height(12, context)),
            width: UtilsReponsive.width(40, context),
            height: UtilsReponsive.height(4, context),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Badge Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
              child: Column(
                children: [
                  // Badge Icon
                  Container(
                    width: UtilsReponsive.height(120, context),
                    height: UtilsReponsive.height(120, context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: badge.isUnlocked
                            ? _getRarityGradient(badge.rarity)
                            : [Colors.grey[300]!, Colors.grey[400]!],
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            badge.iconPath,
                            width: UtilsReponsive.height(60, context),
                            height: UtilsReponsive.height(60, context),
                            color: badge.isUnlocked ? null : Colors.grey[600],
                          ),
                        ),
                        if (!badge.isUnlocked)
                          Positioned(
                            top: UtilsReponsive.height(8, context),
                            right: UtilsReponsive.width(8, context),
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: UtilsReponsive.height(24, context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: UtilsReponsive.height(24, context)),
                  
                  // Badge Name
                  TextConstant.titleH1(
                    context,
                    text: badge.name,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    size: 24,
                  ),
                  
                  SizedBox(height: UtilsReponsive.height(8, context)),
                  
                  // Rarity
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(16, context),
                      vertical: UtilsReponsive.height(6, context),
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(badge.rarity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getRarityColor(badge.rarity).withOpacity(0.3),
                      ),
                    ),
                    child: TextConstant.subTile2(
                      context,
                      text: badge.rarity.displayName,
                      color: _getRarityColor(badge.rarity),
                      fontWeight: FontWeight.bold,
                      size: 12,
                    ),
                  ),
                  
                  SizedBox(height: UtilsReponsive.height(16, context)),
                  
                  // Description
                  TextConstant.subTile1(
                    context,
                    text: badge.description,
                    color: Colors.grey[600]!,
                    size: 16,
                  ),
                  
                  SizedBox(height: UtilsReponsive.height(24, context)),
                  
                  // Condition
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConstant.subTile2(
                          context,
                          text: badge.isUnlocked ? "Achievement Unlocked!" : "Condition to Unlock",
                          color: badge.isUnlocked ? ColorsManager.primary : Colors.grey[600]!,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: UtilsReponsive.height(8, context)),
                        TextConstant.subTile2(
                          context,
                          text: badge.condition,
                          color: Colors.black,
                        ),
                        if (badge.isUnlocked && badge.unlockedAt != null) ...[
                          SizedBox(height: UtilsReponsive.height(8, context)),
                          TextConstant.subTile4(
                            context,
                            text: "Unlocked on ${_formatDate(badge.unlockedAt!)}",
                            color: Colors.grey[500]!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Points
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorsManager.primary,
                          ColorsManager.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.white,
                          size: UtilsReponsive.height(20, context),
                        ),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.subTile1(
                          context,
                          text: "${badge.points} Points",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
