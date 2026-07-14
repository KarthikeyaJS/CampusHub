import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/admin_users_cubit.dart/admin_users_state.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_cubit.dart';
import 'package:campus_hub/features/admin/presentation/cubit/user_action_cubit.dart/user_action_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../widgets/department_options.dart';

class AdminEditUserPage extends StatelessWidget {
  final String uid;
  const AdminEditUserPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AdminUsersCubit>()),
        BlocProvider(create: (_) => sl<UserActionCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Edit User')),
        body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is! AdminUsersLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = state.users
                .where((u) => u.uid == uid)
                .cast<UserEntity?>()
                .firstOrNull;
            if (user == null) {
              return const Center(child: Text('User not found.'));
            }
            return _EditUserBody(user: user);
          },
        ),
      ),
    );
  }
}

class _EditUserBody extends StatefulWidget {
  final UserEntity user;
  const _EditUserBody({required this.user});

  @override
  State<_EditUserBody> createState() => _EditUserBodyState();
}

class _EditUserBodyState extends State<_EditUserBody> {
  late UserRole _role;
  String? _department;

  @override
  void initState() {
    super.initState();
    _role = widget.user.role;
    _department = widget.user.department;
  }

  void _onSave() {
    if (_role == UserRole.departmentStaff && _department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }
    context.read<UserActionCubit>().updateRole(
      uid: widget.user.uid,
      role: _role,
      department: _role == UserRole.departmentStaff ? _department : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserActionCubit, UserActionState>(
      listener: (context, state) {
        if (state is UserActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is UserActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User updated.')));
          context.pop();
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user.name, style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(widget.user.email, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 24),
              Text('Role', style: AppTextStyles.caption),
              const SizedBox(height: 6),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.student,
                    child: Text('Student'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.departmentStaff,
                    child: Text('Department Staff'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.venueCoordinator,
                    child: Text('Venue Coordinator'),
                  ),
                  DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                ],
                onChanged: (value) => setState(() {
                  _role = value!;
                  if (_role != UserRole.departmentStaff) _department = null;
                }),
              ),
              if (_role == UserRole.departmentStaff) ...[
                const SizedBox(height: 16),
                Text('Department', style: AppTextStyles.caption),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _department,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select department'),
                  items: kDepartmentOptions
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (value) => setState(() => _department = value),
                ),
              ],
              const SizedBox(height: 32),
              BlocBuilder<UserActionCubit, UserActionState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Save Changes',
                    isLoading: state is UserActionLoading,
                    onPressed: _onSave,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
