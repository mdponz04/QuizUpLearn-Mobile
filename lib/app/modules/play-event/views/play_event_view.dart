import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

import '../controllers/play_event_controller.dart';
import '../models/quiz_event_model.dart';

class PlayEventView extends GetView<PlayEventController> {
  const PlayEventView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Quiz Events",
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
          // Filter Section
          _buildFilterSection(context),
          
          // Events List
          Expanded(
            child: _buildEventsList(context),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        UtilsReponsive.width(16, context),
        UtilsReponsive.height(16, context),
        UtilsReponsive.width(16, context),
        0,
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: "Search events...",
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
                  "All Types",
                  controller.selectedType.value == QuizEventType.solo,
                  () => controller.setSelectedType(QuizEventType.solo),
                ),
                ...controller.allTypes.map((type) => _buildFilterChip(
                  context,
                  type.displayName,
                  controller.selectedType.value == type,
                  () => controller.setSelectedType(type),
                )),
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

  Widget _buildEventsList(BuildContext context) {
    return Obx(() {
      final events = controller.filteredEvents;
      
      if (events.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: UtilsReponsive.height(80, context),
                color: Colors.grey[400],
              ),
              SizedBox(height: UtilsReponsive.height(16, context)),
              TextConstant.titleH3(
                context,
                text: "No events found",
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

      return ListView.builder(
        padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(context, events[index]);
        },
      );
    });
  }

  Widget _buildEventCard(BuildContext context, QuizEventModel event) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
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
          // Event Header
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(int.parse(event.type.color.replaceAll('#', '0xFF'))),
                  Color(int.parse(event.type.color.replaceAll('#', '0xFF'))).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Event Icon
                Container(
                  width: UtilsReponsive.height(50, context),
                  height: UtilsReponsive.height(50, context),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    event.type.icon,
                    width: UtilsReponsive.height(30, context),
                    height: UtilsReponsive.height(30, context),
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(width: UtilsReponsive.width(12, context)),
                
                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConstant.subTile1(
                        context,
                        text: event.title,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 16,
                      ),
                      SizedBox(height: UtilsReponsive.height(4, context)),
                      TextConstant.subTile4(
                        context,
                        text: event.type.displayName,
                        color: Colors.white.withOpacity(0.9),
                        size: 12,
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(8, context),
                    vertical: UtilsReponsive.height(4, context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextConstant.subTile4(
                    context,
                    text: event.status.displayName,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // Event Details
          Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                TextConstant.subTile2(
                  context,
                  text: event.description,
                  color: Colors.grey[600]!,
                  size: 14,
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Event Stats
                Row(
                  children: [
                    _buildEventStat(
                      context,
                      Icons.schedule,
                      "${event.duration}m",
                      "Duration",
                    ),
                    SizedBox(width: UtilsReponsive.width(16, context)),
                    _buildEventStat(
                      context,
                      Icons.quiz,
                      "${event.totalQuestions}",
                      "Questions",
                    ),
                    SizedBox(width: UtilsReponsive.width(16, context)),
                    _buildEventStat(
                      context,
                      Icons.people,
                      event.participantsText,
                      "Participants",
                    ),
                  ],
                ),
                
                SizedBox(height: UtilsReponsive.height(12, context)),
                
                // Topics
                Wrap(
                  spacing: UtilsReponsive.width(8, context),
                  runSpacing: UtilsReponsive.height(4, context),
                  children: event.topics.take(3).map((topic) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(8, context),
                      vertical: UtilsReponsive.height(4, context),
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextConstant.subTile4(
                      context,
                      text: topic,
                      color: ColorsManager.primary,
                      size: 10,
                    ),
                  )).toList(),
                ),
                
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Time and Actions
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextConstant.subTile4(
                            context,
                            text: event.timeRemaining,
                            color: event.isOngoing ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            size: 12,
                          ),
                          TextConstant.subTile4(
                            context,
                            text: "Entry: ${event.entryFee} pts • Reward: ${event.rewardPoints} pts",
                            color: Colors.grey[500]!,
                            size: 10,
                          ),
                        ],
                      ),
                    ),
                    
                    // Action Buttons - Only show for ongoing events
                    if (event.isOngoing) ...[
                      if (event.type == QuizEventType.solo)
                        ElevatedButton(
                          onPressed: () => controller.startEvent(event.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: TextConstant.subTile4(
                            context,
                            text: "Start Quiz",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 12,
                          ),
                        )
                      else if (event.type == QuizEventType.oneOnOne)
                        ElevatedButton(
                          onPressed: () => controller.startEvent(event.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: TextConstant.subTile4(
                            context,
                            text: "Find Opponent",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 12,
                          ),
                        )
                      else if (event.type == QuizEventType.group)
                        ElevatedButton(
                          onPressed: () => controller.startEvent(event.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: TextConstant.subTile4(
                            context,
                            text: "Join Team",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 12,
                          ),
                        )
                      else if (event.type == QuizEventType.multiplayerSolo)
                        ElevatedButton(
                          onPressed: () => controller.startEvent(event.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: TextConstant.subTile4(
                            context,
                            text: "Join Session",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 12,
                          ),
                        ),
                    ] else if (event.isUpcoming) ...[
                      // Show upcoming status for events that haven't started yet
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(12, context),
                          vertical: UtilsReponsive.height(8, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: TextConstant.subTile4(
                          context,
                          text: "Starts ${event.timeRemaining}",
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          size: 12,
                        ),
                      ),
                    ] else if (event.isCompleted) ...[
                      // Show completed status
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(12, context),
                          vertical: UtilsReponsive.height(8, context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextConstant.subTile4(
                          context,
                          text: "Completed",
                          color: Colors.grey[600]!,
                          fontWeight: FontWeight.bold,
                          size: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventStat(BuildContext context, IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: UtilsReponsive.height(16, context),
          color: Colors.grey[600],
        ),
        SizedBox(width: UtilsReponsive.width(4, context)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextConstant.subTile4(
              context,
              text: value,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              size: 12,
            ),
            TextConstant.subTile4(
              context,
              text: label,
              color: Colors.grey[500]!,
              size: 9,
            ),
          ],
        ),
      ],
    );
  }
}
