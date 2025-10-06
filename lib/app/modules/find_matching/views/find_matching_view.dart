import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/find_matching_controller.dart';
import '../models/matching_model.dart';

class FindMatchingView extends GetView<FindMatchingController> {
  const FindMatchingView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // title: Obx(() => TextConstant.titleH2(
        //   context,
        //   text: controller.matchingTitle.isNotEmpty ? controller.matchingTitle : "Find Matching",
        //   color: ColorsManager.primary,
        //   fontWeight: FontWeight.bold,
        // )),
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
      body: Obx(() {
        if (controller.matchingSession.value != null) {
          return _buildMatchingSessionView(context);
        } else if (controller.isSearching.value) {
          return _buildSearchingView(context);
        } else {
          return _buildMatchingOptionsView(context);
        }
      }),
    );
  }

  Widget _buildMatchingOptionsView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Info Header
          _buildEventInfoHeader(context),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Matching Type Info
          _buildMatchingTypeInfo(context),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Quick Match Button
          _buildQuickMatchButton(context),
        ],
      ),
    );
  }

  Widget _buildEventInfoHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(controller.matchingColor.replaceAll('#', '0xFF'))),
            Color(int.parse(controller.matchingColor.replaceAll('#', '0xFF'))).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(controller.matchingColor.replaceAll('#', '0xFF'))).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: UtilsReponsive.height(50, context),
                height: UtilsReponsive.height(50, context),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  controller.matchingIcon,
                  width: UtilsReponsive.height(30, context),
                  height: UtilsReponsive.height(30, context),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: UtilsReponsive.width(16, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.subTile1(
                      context,
                      text: controller.eventTitle,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      size: 18,
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    TextConstant.subTile2(
                      context,
                      text: controller.matchingDescription,
                      color: Colors.white.withOpacity(0.9),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingTypeInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConstant.subTile1(
            context,
            text: "How it works",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          if (controller.matchingType == MatchingType.oneOnOne) ...[
            _buildInfoItem(
              context,
              Icons.person,
              "Find an opponent",
              "We'll match you with a player of similar skill level",
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            _buildInfoItem(
              context,
              Icons.timer,
              "Quick match",
              "Start playing within 30 seconds",
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            _buildInfoItem(
              context,
              Icons.emoji_events,
              "Compete head-to-head",
              "20 questions, 15 minutes to prove your skills",
            ),
          ] else if (controller.matchingType == MatchingType.group) ...[
            _buildInfoItem(
              context,
              Icons.group,
              "Join a team",
              "We'll find 3 other players to form your team",
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            _buildInfoItem(
              context,
              Icons.handshake,
              "Work together",
              "Collaborate with teammates to win",
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            _buildInfoItem(
              context,
              Icons.emoji_events,
              "Team victory",
              "20 questions, 15 minutes for team glory",
            ),
          ] else ...[
            _buildInfoItem(
              context,
              Icons.people,
              "Auto-match players",
              "We'll automatically find 24 other players for you",
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            _buildInfoItem(
              context,
              Icons.timer,
              "Quick start",
              "Start playing within 30 seconds",
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            _buildInfoItem(
              context,
              Icons.emoji_events,
              "Global ranking",
              "20 questions, 15 minutes to climb the leaderboard",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(
          icon,
          size: UtilsReponsive.height(20, context),
          color: ColorsManager.primary,
        ),
        SizedBox(width: UtilsReponsive.width(12, context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextConstant.subTile3(
                context,
                text: title,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                size: 14,
              ),
              TextConstant.subTile4(
                context,
                text: description,
                color: Colors.grey[600]!,
                size: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMatchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.startMatching,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(int.parse(controller.matchingColor.replaceAll('#', '0xFF'))),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: UtilsReponsive.height(16, context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: UtilsReponsive.height(20, context),
            ),
            SizedBox(width: UtilsReponsive.width(8, context)),
            TextConstant.subTile1(
              context,
              text: "Quick Match",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchingView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Search Icon
          Obx(() => Container(
            width: UtilsReponsive.height(120, context),
            height: UtilsReponsive.height(120, context),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(int.parse(controller.matchingColor.replaceAll('#', '0xFF'))),
                  Color(int.parse(controller.matchingColor.replaceAll('#', '0xFF'))).withOpacity(0.7),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress Circle
                SizedBox(
                  width: UtilsReponsive.height(100, context),
                  height: UtilsReponsive.height(100, context),
                  child: CircularProgressIndicator(
                    value: controller.searchProgress.value,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                // Search Icon
                Icon(
                  Icons.search,
                  size: UtilsReponsive.height(40, context),
                  color: Colors.white,
                ),
              ],
            ),
          )),
          
          SizedBox(height: UtilsReponsive.height(32, context)),
          
          // Searching Text
          TextConstant.titleH2(
            context,
            text: "Finding ${controller.matchingType == MatchingType.oneOnOne ? 'opponent' : 
                   controller.matchingType == MatchingType.group ? 'teammates' : 'session players'}...",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          
          SizedBox(height: UtilsReponsive.height(8, context)),
          
          TextConstant.subTile2(
            context,
            text: "Looking for players with similar skill level",
            color: Colors.grey[600]!,
          ),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Cancel Button
          TextButton(
            onPressed: controller.cancelMatching,
            child: TextConstant.subTile3(
              context,
              text: "Cancel",
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingSessionView(BuildContext context) {
    final session = controller.matchingSession.value!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        children: [
          // Session Status
          _buildSessionStatusCard(context, session),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Quiz Details
          _buildSessionInfoCard(context, session),
          
          SizedBox(height: UtilsReponsive.height(24, context)),
          
          // Participants
          _buildParticipantsSection(context, session),
        ],
      ),
    );
  }

  Widget _buildSessionStatusCard(BuildContext context, MatchingSessionModel session) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        color: Color(int.parse(session.status.color.replaceAll('#', '0xFF'))).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(int.parse(session.status.color.replaceAll('#', '0xFF'))),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(session.status),
            size: UtilsReponsive.height(50, context),
            color: Color(int.parse(session.status.color.replaceAll('#', '0xFF'))),
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          TextConstant.titleH2(
            context,
            text: session.statusText,
            color: Color(int.parse(session.status.color.replaceAll('#', '0xFF'))),
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          TextConstant.subTile2(
            context,
            text: session.eventTitle,
            color: Colors.grey[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, MatchingSessionModel session) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConstant.subTile1(
            context,
            text: "Participants (${session.currentParticipants}/${session.maxParticipants})",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
          SizedBox(height: UtilsReponsive.height(16, context)),
          ...session.participants.map((participant) => _buildParticipantCard(context, participant)),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(BuildContext context, MatchingModel participant) {
    final isCurrentPlayer = participant.id == controller.currentPlayer.value.id;
    
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? ColorsManager.primary.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isCurrentPlayer ? Border.all(color: ColorsManager.primary) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: UtilsReponsive.height(20, context),
            backgroundImage: AssetImage(participant.avatar),
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.subTile3(
                  context,
                  text: isCurrentPlayer ? "You" : participant.name,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  size: 14,
                ),
                TextConstant.subTile4(
                  context,
                  text: "${participant.levelText} • ${participant.rating} rating",
                  color: Colors.grey[600]!,
                  size: 12,
                ),
              ],
            ),
          ),
          if (isCurrentPlayer)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(8, context),
                vertical: UtilsReponsive.height(4, context),
              ),
              decoration: BoxDecoration(
                color: ColorsManager.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextConstant.subTile4(
                context,
                text: "YOU",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                size: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard(BuildContext context, MatchingSessionModel session) {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConstant.subTile1(
            context,
            text: "Quiz Details",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            size: 16,
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          _buildInfoRow(context, Icons.quiz, "Questions", "${session.totalQuestions} questions"),
          _buildInfoRow(context, Icons.timer, "Duration", "${session.duration} minutes"),
          _buildInfoRow(context, Icons.school, "Difficulty", session.difficulty),
          _buildInfoRow(context, Icons.emoji_events, "Type", session.type.displayName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: UtilsReponsive.height(8, context)),
      child: Row(
        children: [
          Icon(
            icon,
            size: UtilsReponsive.height(16, context),
            color: Colors.grey[600],
          ),
          SizedBox(width: UtilsReponsive.width(12, context)),
          TextConstant.subTile3(
            context,
            text: label,
            color: Colors.grey[600]!,
            size: 14,
          ),
          const Spacer(),
          TextConstant.subTile3(
            context,
            text: value,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            size: 14,
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(MatchingStatus status) {
    switch (status) {
      case MatchingStatus.waiting:
        return Icons.search;
      case MatchingStatus.matched:
        return Icons.check_circle;
      case MatchingStatus.starting:
        return Icons.play_circle;
      case MatchingStatus.inProgress:
        return Icons.timer;
      case MatchingStatus.completed:
        return Icons.emoji_events;
    }
  }
}
