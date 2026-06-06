import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/church_group.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import 'group_detail_screen.dart';

class ChurchGroupsScreen extends StatefulWidget {
  const ChurchGroupsScreen({super.key});

  @override
  State<ChurchGroupsScreen> createState() => _ChurchGroupsScreenState();
}

class _ChurchGroupsScreenState extends State<ChurchGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _joinCodeController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Create Church Group",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                          decoration: InputDecoration(
                            hintText: "Group Name",
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                          decoration: InputDecoration(
                            hintText: "Group Description",
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: isCreating ? null : () => Navigator.of(dialogContext).pop(),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isCreating
                                    ? null
                                    : () async {
                                        final name = nameController.text.trim();
                                        final desc = descController.text.trim();
                                        if (name.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Please enter a group name.")),
                                          );
                                          return;
                                        }

                                        setDialogState(() => isCreating = true);
                                        try {
                                          final userProvider = Provider.of<UserDataProvider>(context, listen: false);
                                          final uid = userProvider.userId ?? '';
                                          final nameStr = userProvider.displayName;

                                          final group = await FirebaseService.createChurchGroup(
                                            uid,
                                            nameStr,
                                            name,
                                            desc,
                                          );

                                          if (!context.mounted) return;

                                          // Update stats locally
                                          userProvider.incrementCreatedGroups();
                                          userProvider.incrementJoinedGroups();

                                          Navigator.of(dialogContext).pop();
                                          _showGroupCreatedSuccessDialog(group);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error: $e")),
                                            );
                                          }
                                          setDialogState(() => isCreating = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF38BDF8),
                                  foregroundColor: const Color(0xFF1A1A2E),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: isCreating
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A2E)),
                                      )
                                    : const Text("Create", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGroupCreatedSuccessDialog(ChurchGroup group) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF38BDF8), size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      "Group Created Successfully!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "SHARE THIS JOIN CODE",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            group.joinCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: group.joinCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Code copied to clipboard!")),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy & Share", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _leaveGroup(ChurchGroup group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text("Leave ${group.name}?", style: const TextStyle(color: Colors.white, fontFamily: 'Outfit')),
          content: Text(
            "Are you sure you want to leave this church group?",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontFamily: 'Outfit'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontFamily: 'Outfit')),
            ),
            TextButton(
              onPressed: () async {
                final userProvider = Provider.of<UserDataProvider>(this.context, listen: false);
                final uid = userProvider.userId ?? '';
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                navigator.pop();
                try {
                  await FirebaseService.leaveChurchGroup(uid, group.id);
                  userProvider.decrementJoinedGroups();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text("Successfully left ${group.name}")),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Leave", style: TextStyle(color: Colors.red, fontFamily: 'Outfit')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final uid = userProvider.userId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Church Groups", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF38BDF8),
          labelColor: const Color(0xFF38BDF8),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "My Groups"),
            Tab(text: "Discover"),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Dark Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          // Glow effect
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF38BDF8),
                        blurRadius: 100,
                        spreadRadius: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: [
              _buildMyGroupsTab(uid),
              _buildDiscoverTab(uid),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        backgroundColor: const Color(0xFF38BDF8),
        foregroundColor: const Color(0xFF1A1A2E),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyGroupsTab(String uid) {
    return StreamBuilder<List<ChurchGroup>>(
      stream: FirebaseService.getUserGroups(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
        }

        final groups = snapshot.data ?? [];
        if (groups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    "You belong to no groups yet.",
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Outfit'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create a new group using the + button or join an existing one in the Discover tab.",
                    style: TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Outfit'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        group.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pastor: ${group.pastorName}",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontFamily: 'Outfit'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Members: ${group.totalMembers}",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontFamily: 'Outfit'),
                            ),
                          ],
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          group.joinCode,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GroupDetailScreen(groupId: group.id),
                          ),
                        );
                      },
                      onLongPress: () => _leaveGroup(group),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiscoverTab(String uid) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.group_add, color: Color(0xFF38BDF8), size: 30),
                        SizedBox(width: 12),
                        Text(
                          "Join a Group",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Enter the unique 6-character code shared by your pastor or group leader to join their community.",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _joinCodeController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 18, letterSpacing: 2),
                      maxLength: 6,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: "JOIN CODE (e.g. ABC123)",
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15, letterSpacing: 0),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isJoining
                          ? null
                          : () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final code = _joinCodeController.text.trim().toUpperCase();
                              if (code.length != 6) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text("Join code must be exactly 6 characters.")),
                                );
                                return;
                              }

                              setState(() => _isJoining = true);
                              try {
                                final userProvider = Provider.of<UserDataProvider>(context, listen: false);
                                final name = userProvider.displayName;

                                final group = await FirebaseService.joinChurchGroup(uid, name, code);

                                // Update stats
                                userProvider.incrementJoinedGroups();
                                userProvider.updateMaxGroupSize(group.totalMembers);

                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text("Successfully joined ${group.name}!")),
                                );
                                _joinCodeController.clear();
                                _tabController.animateTo(0);
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text("Failed to join: ${e.toString().replaceAll('Exception: ', '')}")),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isJoining = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isJoining
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A2E)),
                            )
                          : const Text(
                              "JOIN GROUP",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
