import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/user_status.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/responsive_repo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/accounts/account_filter_chip.dart';
import '../../widgets/accounts/account_stat_card.dart';
import '../../widgets/accounts/account_user_tile.dart';
import '../../widgets/accounts/credentials_dialog.dart';
import '../../widgets/common/app_text_widget.dart';
import '../../widgets/dashboard/app_drawer_widget.dart';
import 'create_user_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  int _selectedFilter = 0;
  bool _isSearchActive = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch team members on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchTeamMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Filtered list ───
  List<UserModel> _filteredUsers(List<UserModel> users) {
    var list = users;
    if (_selectedFilter == 1) {
      list = users.where((u) => u.role == UserRole.admin).toList();
    } else if (_selectedFilter == 2) {
      list = users.where((u) => u.role == UserRole.manager).toList();
    } else if (_selectedFilter == 3) {
      list = users.where((u) => u.role == UserRole.user).toList();
    } else if (_selectedFilter == 4) {
      list = users.where((u) => u.status == UserStatus.pending).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      list = list
          .where((u) =>
      u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<void> _handleCreateUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateUserScreen(),
      ),
    );

    if (result == true && mounted) {
      // Refresh list
      await context.read<AuthProvider>().fetchTeamMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveRepo(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final team = auth.teamMembers;

    // Count stats
    final totalCount = team.length + (user != null ? 1 : 0);
    final activeCount =
        team.where((u) => u.status == UserStatus.approved).length +
            (user?.status == UserStatus.approved ? 1 : 0);
    final pendingCount =
        team.where((u) => u.status == UserStatus.pending).length;

    // Build "all users" list including self
    final allUsers = <UserModel>[
      if (user != null) user,
      ...team.where((u) => u.uid != user?.uid),
    ];

    final filters = [
      _AccountFilter('All', Icons.apps_rounded, totalCount),
      _AccountFilter(
          'Admins',
          Icons.shield_rounded,
          allUsers.where((u) => u.role == UserRole.admin).length),
      _AccountFilter(
          'Managers',
          Icons.supervisor_account_rounded,
          allUsers.where((u) => u.role == UserRole.manager).length),
      _AccountFilter(
          'Users',
          Icons.person_rounded,
          allUsers.where((u) => u.role == UserRole.user).length),
      _AccountFilter('Pending', Icons.schedule_rounded, pendingCount),
    ];

    final filtered = _filteredUsers(allUsers);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: AppRoutes.accounts),
      appBar: _buildAppBar(user?.fullName ?? 'Owner'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: r.horizontalPadding,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search
            if (_isSearchActive) ...[
              _buildSearchBar(),
              SizedBox(height: r.spacing(14)),
            ],

            // Mini stats
            Row(
              children: [
                Expanded(
                  child: AccountStatCard(
                    label: 'Total',
                    value: '$totalCount',
                    icon: Icons.people_alt_outlined,
                    accent: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AccountStatCard(
                    label: 'Active',
                    value: '$activeCount',
                    icon: Icons.check_circle_outline_rounded,
                    accent: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AccountStatCard(
                    label: 'Pending',
                    value: '$pendingCount',
                    icon: Icons.access_time_rounded,
                    accent: AppColors.warning,
                  ),
                ),
              ],
            ),

            SizedBox(height: r.spacing(18)),

            // Filter chips
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final f = filters[index];
                  return AccountFilterChip(
                    label: f.label,
                    icon: f.icon,
                    count: f.count,
                    isSelected: _selectedFilter == index,
                    onTap: () =>
                        setState(() => _selectedFilter = index),
                  );
                },
              ),
            ),

            SizedBox(height: r.spacing(16)),

            _buildSectionLabel('TEAM MEMBERS'),
            SizedBox(height: r.spacing(12)),

            if (filtered.isEmpty)
              _buildEmptyState(r)
            else
              ...filtered.map((u) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AccountUserTile(
                  name: u.fullName,
                  email: u.email,
                  role: u.role.name[0].toUpperCase() +
                      u.role.name.substring(1),
                  status: u.status.name[0].toUpperCase() +
                      u.status.name.substring(1),
                  accent: u.role == UserRole.admin
                      ? AppColors.primary
                      : u.role == UserRole.manager
                      ? AppColors.accent
                      : AppColors.info,
                  onTap: () {},
                  onMore: () => _showUserOptions(context, u),
                ),
              )),

            SizedBox(height: r.spacing(90)),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(ResponsiveRepo r) {
    return Container(
      padding: EdgeInsets.all(r.spacing(32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            'No team members yet',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          const AppText(
            'Tap "Create User" to add your first team member.',
            fontSize: 12.5,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String name) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Manage',
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              AppText(
                'Accounts',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => setState(
                  () => _isSearchActive = !_isSearchActive),
          icon: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isSearchActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isSearchActive
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.inputBorder,
              ),
            ),
            child: Icon(
              _isSearchActive
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              color: _isSearchActive
                  ? AppColors.primary
                  : AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: AppText(
              name.substring(0, 1).toUpperCase(),
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 1.4,
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _handleCreateUser,
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                AppText(
                  'Create User',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserOptions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              AppText(
                user.fullName,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 4),
              AppText(
                user.email,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 20),
              if (user.passwordPlain != null) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => CredentialsDialog(
                        fullName: user.fullName,
                        email: user.email,
                        password: user.passwordPlain!,
                        role: user.role.name.toUpperCase(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.key_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    title: const AppText(
                      'View Credentials',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    onTap: null,
                  ),
                ),
              ],
              _optionTile(
                Icons.delete_outline_rounded,
                'Delete User',
                AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(IconData icon, String label, Color color) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: AppText(
        label,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

class _AccountFilter {
  final String label;
  final IconData icon;
  final int count;
  const _AccountFilter(this.label, this.icon, this.count);
}