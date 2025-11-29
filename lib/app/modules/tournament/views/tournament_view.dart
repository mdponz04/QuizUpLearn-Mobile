import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/tournament_controller.dart';
import '../widgets/tournament_card.dart';

class TournamentView extends GetView<TournamentController> {
  const TournamentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Tournament",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorsManager.primary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: controller.loadTournaments,
            icon: Icon(
              Icons.refresh,
              color: ColorsManager.primary,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context);
        }
        
        if (controller.tournaments.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildTournamentList(context);
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColorsManager.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.subTile1(
            context,
            text: "Loading tournaments...",
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: UtilsReponsive.height(48, context),
                color: Colors.red,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(24, context)),
            TextConstant.titleH3(
              context,
              text: "Oops!",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: controller.errorMessage.value,
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: UtilsReponsive.height(32, context)),
            ElevatedButton.icon(
              onPressed: controller.loadTournaments,
              icon: Icon(Icons.refresh, color: Colors.white),
              label: TextConstant.subTile1(
                context,
                text: "Try Again",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: UtilsReponsive.width(24, context),
                  vertical: UtilsReponsive.height(14, context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
              decoration: BoxDecoration(
                color: ColorsManager.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: UtilsReponsive.height(64, context),
                color: ColorsManager.primary,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(24, context)),
            TextConstant.titleH3(
              context,
              text: "No Tournaments",
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile2(
              context,
              text: "There are no tournaments available at the moment.\nCheck back later!",
              color: Colors.grey[600]!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadTournaments,
      color: ColorsManager.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: UtilsReponsive.width(16, context),
          vertical: UtilsReponsive.height(16, context),
        ),
        itemCount: controller.tournaments.length,
        itemBuilder: (context, index) {
          final tournament = controller.tournaments[index];
          return TournamentCard(
            tournament: tournament,
            index: index,
            controller: controller,
          );
        },
      ),
    );
  }
}
