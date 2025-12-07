import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import '../controllers/player_game_room_controller_v2.dart';

/// PlayerGameRoomView V2 - Improved version based on Web app structure
/// 
/// Key improvements:
/// - GetX pattern with Controller V2
/// - Better UI structure matching Web app
/// - Boss Fight mode UI
/// - TOEIC grouped questions support
/// - Auto-next question with 2-second delay
class PlayerGameRoomViewV2 extends StatelessWidget {
  const PlayerGameRoomViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlayerGameRoomControllerV2());
    
    // Initialize gamePin from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null && args['gamePin'] != null) {
        controller.gamePin = args['gamePin'] as String;
      }
      if (args != null && args['playerName'] != null) {
        controller.playerName = args['playerName'] as String;
        controller.playerNameController.text = controller.playerName ?? '';
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: TextConstant.titleH2(
          context,
          text: "Chơi Game",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            controller.leaveGame();
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.primary),
        ),
      ),
      body: Obx(() => _buildCurrentPhase(context, controller)),
    );
  }

  Widget _buildCurrentPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    switch (controller.gamePhase.value) {
      case 'enteringPin':
        return _buildEnterPlayerName(context, controller);
      case 'connecting':
        return _buildConnectingPhase(context, controller);
      case 'lobby':
        return _buildLobbyPhase(context, controller);
      case 'countdown':
        return _buildCountdownPhase(context, controller);
      case 'playing':
        return _buildPlayingPhase(context, controller);
      case 'answered':
        return _buildAnsweredPhase(context, controller);
      case 'finalResult':
        return _buildFinalResultPhase(context, controller);
      default:
        return _buildErrorPhase(context, controller);
    }
  }

  // ==================== ENTER PLAYER NAME PHASE ====================

  Widget _buildEnterPlayerName(BuildContext context, PlayerGameRoomControllerV2 controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: UtilsReponsive.height(40, context)),
          Icon(
            Icons.person_add,
            size: UtilsReponsive.height(80, context),
            color: ColorsManager.primary,
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
          TextConstant.titleH2(
            context,
            text: "Nhập tên người chơi",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          if (controller.gamePin != null)
            TextConstant.subTile2(
              context,
              text: "Game PIN: ${controller.gamePin}",
              color: Colors.grey[600]!,
            ),
          SizedBox(height: UtilsReponsive.height(32, context)),
          TextField(
            controller: controller.playerNameController,
            decoration: InputDecoration(
              hintText: "Tên người chơi",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.person, color: ColorsManager.primary),
            ),
          ),
          SizedBox(height: UtilsReponsive.height(24, context)),
          if (controller.errorMessage.value != null) ...[
            Container(
              margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: TextConstant.subTile1(
                context,
                text: controller.errorMessage.value ?? '',
                color: Colors.red,
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      final args = Get.arguments as Map<String, dynamic>?;
                      final baseUrl = args?['baseUrl'] ?? 'https://qul-api.onrender.com';
                      controller.connectAndJoin(baseUrl);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primary,
                padding: EdgeInsets.symmetric(
                  vertical: UtilsReponsive.height(16, context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? CircularProgressIndicator(color: Colors.white)
                  : TextConstant.subTile1(
                      context,
                      text: "Tham gia",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CONNECTING PHASE ====================

  Widget _buildConnectingPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: UtilsReponsive.height(24, context)),
          TextConstant.titleH2(
            context,
            text: "Đang kết nối...",
            color: ColorsManager.primary,
            fontWeight: FontWeight.bold,
          ),
          if (controller.errorMessage.value != null) ...[
            SizedBox(height: UtilsReponsive.height(16, context)),
            Container(
              margin: EdgeInsets.symmetric(horizontal: UtilsReponsive.width(20, context)),
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: TextConstant.subTile1(
                context,
                text: controller.errorMessage.value ?? '',
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== LOBBY PHASE ====================

  Widget _buildLobbyPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorsManager.primary, ColorsManager.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConstant.titleH2(
                  context,
                  text: "Xin chào, ${controller.playerName ?? 'Player'}!",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile1(
                  context,
                  text: "Mã PIN: ${controller.gamePin ?? 'N/A'}",
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),

          SizedBox(height: UtilsReponsive.height(20, context)),

          // Boss Fight Info (if enabled)
          if (controller.isBossFightMode.value) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.red, size: 28),
                      SizedBox(width: UtilsReponsive.width(8, context)),
                      TextConstant.titleH3(
                        context,
                        text: "🐉 BOSS FIGHT",
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: UtilsReponsive.height(16, context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.favorite,
                        value: "${controller.bossMaxHP.value} HP",
                        label: "Máu Boss",
                        color: Colors.red,
                      ),
                      if (controller.matchTotalTime.value != null)
                        _buildStatCard(
                          context,
                          icon: Icons.timer,
                          value: "${controller.matchTotalTime.value! ~/ 60} phút",
                          label: "Thời gian",
                          color: Colors.orange,
                        ),
                      _buildStatCard(
                        context,
                        icon: Icons.timer_outlined,
                        value: "${controller.questionTimeLimitSeconds.value}s",
                        label: "Mỗi câu",
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: UtilsReponsive.height(20, context)),
          ],

          // Waiting message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH3(
                  context,
                  text: "Đang chờ Host bắt đầu game...",
                  color: Colors.grey[700]!,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextConstant.subTile1(
                  context,
                  text: controller.isBossFightMode.value
                      ? "Chuẩn bị chiến đấu với Boss!"
                      : "Chuẩn bị cho game...",
                  color: Colors.grey[600]!,
                ),
              ],
            ),
          ),

          SizedBox(height: UtilsReponsive.height(20, context)),

          // Player list
          TextConstant.titleH3(
            context,
            text: "Danh sách người chơi (${controller.players.length})",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: UtilsReponsive.height(12, context)),
          if (controller.players.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(UtilsReponsive.width(40, context)),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: UtilsReponsive.height(16, context)),
                    TextConstant.subTile1(
                      context,
                      text: "Đang chờ thêm người chơi...",
                      color: Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: UtilsReponsive.width(12, context),
                mainAxisSpacing: UtilsReponsive.height(12, context),
              ),
              itemCount: controller.players.length,
              itemBuilder: (context, index) {
                final player = controller.players[index];
                final playerName = player['playerName'] ?? player['PlayerName'] ?? 'Player';
                final isMe = playerName == controller.playerName;
                return Container(
                  padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                  decoration: BoxDecoration(
                    color: isMe
                        ? ColorsManager.primary.withOpacity(0.2)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMe ? ColorsManager.primary : Colors.grey[300]!,
                      width: isMe ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: UtilsReponsive.width(25, context),
                        backgroundColor: isMe ? ColorsManager.primary : Colors.grey[600]!,
                        child: Text(
                          playerName[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: UtilsReponsive.width(18, context),
                          ),
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      Text(
                        isMe ? "$playerName (Bạn)" : playerName,
                        style: TextStyle(
                          fontSize: UtilsReponsive.width(12, context),
                          color: Colors.black,
                          fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: UtilsReponsive.height(8, context)),
        TextConstant.titleH3(
          context,
          text: value,
          color: color,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile2(
          context,
          text: label,
          color: Colors.grey[600]!,
        ),
      ],
    );
  }

  // ==================== COUNTDOWN PHASE ====================

  Widget _buildCountdownPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🐉',
              style: TextStyle(fontSize: UtilsReponsive.width(80, context)),
            ),
            SizedBox(height: UtilsReponsive.height(40, context)),
            Text(
              controller.countdownValue.value == 0 ? 'FIGHT!' : '${controller.countdownValue.value}',
              style: TextStyle(
                fontSize: UtilsReponsive.width(
                  controller.countdownValue.value == 0 ? 80 : 120,
                  context,
                ),
                fontWeight: FontWeight.bold,
                color: controller.countdownValue.value == 0 ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(24, context)),
            TextConstant.titleH2(
              context,
              text: controller.countdownValue.value == 0
                  ? 'Tiêu diệt Boss!'
                  : 'Chuẩn bị chiến đấu...',
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PLAYING PHASE ====================

  Widget _buildPlayingPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    final question = controller.currentQuestion.value;
    if (question == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Leave button
        Padding(
          padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
          child: Align(
            alignment: Alignment.topRight,
            child: OutlinedButton.icon(
              onPressed: () {
                controller.leaveGame();
                Get.back();
              },
              icon: Icon(Icons.exit_to_app, size: 16),
              label: TextConstant.subTile2(
                context,
                text: "Rời game",
                color: Colors.red,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
              ),
            ),
          ),
        ),

        // Boss HP Bar (if Boss Fight mode)
        if (controller.isBossFightMode.value) _buildBossHPBar(context, controller),

        // Question header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorsManager.primary, ColorsManager.primary.withOpacity(0.8)],
            ),
            color: ColorsManager.primary,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextConstant.titleH3(
                    context,
                    text: "Câu ${question['questionNumber'] ?? question['QuestionNumber'] ?? 1}",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(12, context),
                      vertical: UtilsReponsive.height(6, context),
                    ),
                    decoration: BoxDecoration(
                      color: controller.timeLeft.value <= 5
                          ? Colors.red
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: Colors.white, size: 16),
                        SizedBox(width: UtilsReponsive.width(4, context)),
                        TextConstant.subTile2(
                          context,
                          text: "${controller.timeLeft.value}s",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: UtilsReponsive.height(12, context)),
              LinearProgressIndicator(
                value: controller.timeLeft.value /
                    (question['timeLimit'] ?? question['TimeLimit'] ?? controller.questionTimeLimitSeconds.value),
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  controller.timeLeft.value <= 5 ? Colors.red : Colors.white,
                ),
                minHeight: 8,
              ),
            ],
          ),
        ),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Item (TOEIC grouped questions)
                if (controller.currentGroupItem.value != null)
                  _buildGroupItem(context, controller),

                SizedBox(height: UtilsReponsive.height(16, context)),

                // Question text
                if (question['questionText'] != null || question['QuestionText'] != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextConstant.titleH3(
                      context,
                      text: question['questionText'] ?? question['QuestionText'] ?? '',
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                SizedBox(height: UtilsReponsive.height(24, context)),

                // Answer options
                _buildAnswerOptions(context, controller, question),

                SizedBox(height: UtilsReponsive.height(24, context)),

                // Submit button
                if (!controller.isAnswerSubmitted.value)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.selectedAnswerId.value == null
                          ? null
                          : () {
                              controller.submitAnswer(controller.selectedAnswerId.value);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: UtilsReponsive.height(16, context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextConstant.subTile1(
                        context,
                        text: "Gửi câu trả lời",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.subTile1(
                          context,
                          text: "Đã gửi câu trả lời",
                          color: Colors.green,
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
    );
  }

  Widget _buildBossHPBar(BuildContext context, PlayerGameRoomControllerV2 controller) {
    final hpPercent = controller.bossMaxHP.value > 0
        ? (controller.bossCurrentHP.value / controller.bossMaxHP.value).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
      color: Colors.red[900]!.withOpacity(0.2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.red, size: 20),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  TextConstant.subTile2(
                    context,
                    text: "BOSS HP",
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              TextConstant.subTile2(
                context,
                text: "${controller.bossCurrentHP.value} / ${controller.bossMaxHP.value}",
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: UtilsReponsive.height(8, context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hpPercent,
              backgroundColor: Colors.red[300]!.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, PlayerGameRoomControllerV2 controller) {
    final groupItem = controller.currentGroupItem.value!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audio
          if (groupItem['audioUrl'] != null || groupItem['AudioUrl'] != null)
            _buildAudioPlayer(
              context,
              groupItem['audioUrl'] ?? groupItem['AudioUrl'],
            ),

          // Image
          if (groupItem['imageUrl'] != null || groupItem['ImageUrl'] != null)
            _buildImage(context, groupItem['imageUrl'] ?? groupItem['ImageUrl']),

          // Passage text
          if (groupItem['passageText'] != null || groupItem['PassageText'] != null) ...[
            SizedBox(height: UtilsReponsive.height(12, context)),
            TextConstant.subTile2(
              context,
              text: groupItem['passageText'] ?? groupItem['PassageText'] ?? '',
              color: Colors.black87,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(BuildContext context, String audioUrl) {
    final player = AudioPlayer();
    bool isPlaying = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
          child: Row(
            children: [
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () async {
                  if (isPlaying) {
                    await player.pause();
                  } else {
                    await player.play(UrlSource(audioUrl));
                  }
                  setState(() => isPlaying = !isPlaying);
                },
              ),
              Expanded(
                child: TextConstant.subTile2(
                  context,
                  text: "Audio",
                  color: Colors.blue[700]!,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context, String imageUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  Widget _buildAnswerOptions(
    BuildContext context,
    PlayerGameRoomControllerV2 controller,
    Map<String, dynamic> question,
  ) {
    final answers = List<Map<String, dynamic>>.from(
      question['answerOptions'] ??
          question['AnswerOptions'] ??
          question['options'] ??
          question['Options'] ??
          [],
    );

    if (answers.isEmpty) {
      return Center(
        child: TextConstant.subTile1(
          context,
          text: "Không có đáp án",
          color: Colors.red,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextConstant.titleH3(
          context,
          text: "Chọn đáp án:",
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: UtilsReponsive.height(12, context)),
        ...answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          final answerId = answer['answerId']?.toString() ??
              answer['AnswerId']?.toString() ??
              answer['id']?.toString() ??
              '';
          final optionText = answer['optionText'] ??
              answer['OptionText'] ??
              answer['text'] ??
              '';

          final isSelected = controller.selectedAnswerId.value == answerId;
          final isSubmitted = controller.isAnswerSubmitted.value;

          return Container(
            margin: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSubmitted
                    ? null
                    : () {
                        // Chỉ chọn đáp án, không submit ngay
                        controller.selectedAnswerId.value = answerId;
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorsManager.primary.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? ColorsManager.primary
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: UtilsReponsive.width(32, context),
                        height: UtilsReponsive.width(32, context),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ColorsManager.primary
                              : Colors.grey[300]!,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D...
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: UtilsReponsive.width(16, context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: UtilsReponsive.width(12, context)),
                      Expanded(
                        child: TextConstant.subTile1(
                          context,
                          text: optionText.toString(),
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==================== ANSWERED PHASE ====================

  Widget _buildAnsweredPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    // Auto-request next question after 2 seconds (giống Web app renderAnsweredPhase)
    // Web app: if (autoNextTimerRef.current === null && gamePhase === 'answered') { setTimeout(...) }
    // Trigger logic mỗi lần build widget khi phase = 'answered'
    controller.requestNextQuestionAfterDelay();

    final result = controller.lastAnswerResult.value;
    if (result == null) {
      return Center(child: CircularProgressIndicator());
    }

    final isCorrect = result['isCorrect'] ?? false;
    final pointsEarned = result['pointsEarned'] ?? 0;
    final correctAnswerText = result['correctAnswerText'] ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        children: [
          // Boss HP Bar (if Boss Fight mode)
          if (controller.isBossFightMode.value) _buildBossHPBar(context, controller),

          SizedBox(height: UtilsReponsive.height(20, context)),

          // Result card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isCorrect ? '✅' : '❌',
                  style: TextStyle(fontSize: UtilsReponsive.width(80, context)),
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH1(
                  context,
                  text: isCorrect ? 'CHÍNH XÁC!' : 'SAI RỒI!',
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  size: 32,
                ),
                if (isCorrect && pointsEarned > 0) ...[
                  SizedBox(height: UtilsReponsive.height(16, context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(16, context),
                      vertical: UtilsReponsive.height(8, context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on, color: Colors.amber[700]),
                        SizedBox(width: UtilsReponsive.width(8, context)),
                        TextConstant.titleH3(
                          context,
                          text: "+$pointsEarned sát thương!",
                          color: Colors.amber[700]!,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isCorrect && correctAnswerText.isNotEmpty) ...[
                  SizedBox(height: UtilsReponsive.height(16, context)),
                  TextConstant.subTile1(
                    context,
                    text: "Đáp án đúng: $correctAnswerText",
                    color: Colors.grey[700]!,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: UtilsReponsive.height(20, context)),

          // Loading next question
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH3(
                  context,
                  text: "Đang chuyển sang câu hỏi tiếp theo...",
                  color: Colors.grey[700]!,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      label: "Điểm",
                      value: "${controller.myScore.value}",
                    ),
                    _buildStatItem(
                      context,
                      label: "Sát thương",
                      value: "${controller.myDamageDealt.value}",
                    ),
                    _buildStatItem(
                      context,
                      label: "Câu đúng",
                      value: "${controller.myCorrectAnswers.value}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String label, required String value}) {
    return Column(
      children: [
        TextConstant.titleH3(
          context,
          text: value,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: UtilsReponsive.height(4, context)),
        TextConstant.subTile2(
          context,
          text: label,
          color: Colors.grey[600]!,
        ),
      ],
    );
  }

  // ==================== FINAL RESULT PHASE ====================

  Widget _buildFinalResultPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    final result = controller.finalResult.value;
    if (result == null) {
      return Center(child: CircularProgressIndicator());
    }

    final isBossDefeated = controller.bossDefeated.value;
    final isForceEnded = result['forceEnded'] ?? false;

    return SingleChildScrollView(
      padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
      child: Column(
        children: [
          // Result banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isForceEnded
                    ? [Colors.orange.withOpacity(0.2), Colors.grey.withOpacity(0.3)]
                    : isBossDefeated
                        ? [Colors.green.withOpacity(0.2), ColorsManager.primary.withOpacity(0.2)]
                        : [Colors.red.withOpacity(0.2), Colors.red[900]!.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isForceEnded
                    ? Colors.orange
                    : isBossDefeated
                        ? Colors.green
                        : Colors.red,
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isForceEnded ? '🛑' : isBossDefeated ? '🎉' : '💀',
                  style: TextStyle(fontSize: UtilsReponsive.width(80, context)),
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                TextConstant.titleH1(
                  context,
                  text: isForceEnded
                      ? 'GAME ĐÃ KẾT THÚC'
                      : isBossDefeated
                          ? 'CHIẾN THẮNG!'
                          : 'BOSS THẮNG!',
                  color: isForceEnded
                      ? Colors.orange
                      : isBossDefeated
                          ? Colors.green
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                  size: 28,
                ),
                SizedBox(height: UtilsReponsive.height(12, context)),
                TextConstant.subTile1(
                  context,
                  text: isForceEnded
                      ? (result['message'] ?? 'Game đã được kết thúc bởi người quản lý')
                      : isBossDefeated
                          ? "Boss đã bị tiêu diệt!"
                          : "Boss còn ${controller.bossCurrentHP.value} HP",
                  color: Colors.grey[700]!,
                ),
              ],
            ),
          ),

          SizedBox(height: UtilsReponsive.height(20, context)),

          // My stats
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
            decoration: BoxDecoration(
              color: ColorsManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsManager.primary, width: 2),
            ),
            child: Column(
              children: [
                TextConstant.titleH3(
                  context,
                  text: "Thành tích của bạn",
                  color: ColorsManager.primary,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      label: "Điểm",
                      value: "${controller.myScore.value}",
                    ),
                    _buildStatItem(
                      context,
                      label: "Sát thương",
                      value: "${controller.myDamageDealt.value}",
                    ),
                    _buildStatItem(
                      context,
                      label: "Câu đúng",
                      value: "${controller.myCorrectAnswers.value}/${controller.myTotalAnswered.value}",
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: UtilsReponsive.height(20, context)),

          // Back button
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primary,
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(32, context),
                vertical: UtilsReponsive.height(16, context),
              ),
            ),
            child: TextConstant.titleH3(
              context,
              text: "Về Trang chủ",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ERROR PHASE ====================

  Widget _buildErrorPhase(BuildContext context, PlayerGameRoomControllerV2 controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: UtilsReponsive.height(16, context)),
          TextConstant.titleH2(
            context,
            text: "Đã xảy ra lỗi",
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          if (controller.errorMessage.value != null) ...[
            SizedBox(height: UtilsReponsive.height(8, context)),
            TextConstant.subTile1(
              context,
              text: controller.errorMessage.value ?? '',
              color: Colors.grey[700]!,
            ),
          ],
          SizedBox(height: UtilsReponsive.height(24, context)),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: TextConstant.subTile1(
              context,
              text: "Quay lại",
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

