import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_company_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/users/users_list_screen.dart';
import '../../screens/users/add_user_screen.dart';
import '../../screens/users/user_detail_screen.dart';
import '../../screens/schemes/schemes_list_screen.dart';
import '../../screens/schemes/add_scheme_screen.dart';
import '../../screens/schemes/scheme_detail_screen.dart';
import '../../screens/groups/groups_list_screen.dart';
import '../../screens/groups/add_group_screen.dart';
import '../../screens/groups/group_detail_screen.dart';
import '../../screens/memberships/memberships_list_screen.dart';
import '../../screens/memberships/add_membership_screen.dart';
import '../../screens/auctions/auctions_list_screen.dart';
import '../../screens/auctions/add_auction_screen.dart';
import '../../screens/auctions/auction_detail_screen.dart';
import '../../screens/payments/payments_list_screen.dart';
import '../../screens/payments/add_payment_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/profile_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const users = '/users';
  static const addUser = '/users/add';
  static const userDetail = '/users/:id';
  static const schemes = '/schemes';
  static const addScheme = '/schemes/add';
  static const schemeDetail = '/schemes/:id';
  static const groups = '/groups';
  static const addGroup = '/groups/add';
  static const groupDetail = '/groups/:id';
  static const memberships = '/memberships';
  static const addMembership = '/memberships/add';
  static const auctions = '/auctions';
  static const addAuction = '/auctions/add';
  static const auctionDetail = '/auctions/:id';
  static const payments = '/payments';
  static const addPayment = '/payments/add';
  static const notifications = '/notifications';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterCompanyScreen()),
      GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
      GoRoute(path: AppRoutes.users, builder: (_, __) => const UsersListScreen()),
      GoRoute(path: AppRoutes.addUser, builder: (_, __) => const AddUserScreen()),
      GoRoute(
        path: AppRoutes.userDetail,
        builder: (_, state) => UserDetailScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.schemes, builder: (_, __) => const SchemesListScreen()),
      GoRoute(path: AppRoutes.addScheme, builder: (_, __) => const AddSchemeScreen()),
      GoRoute(
        path: AppRoutes.schemeDetail,
        builder: (_, state) => SchemeDetailScreen(schemeId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.groups, builder: (_, __) => const GroupsListScreen()),
      GoRoute(path: AppRoutes.addGroup, builder: (_, __) => const AddGroupScreen()),
      GoRoute(
        path: AppRoutes.groupDetail,
        builder: (_, state) => GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.memberships, builder: (_, __) => const MembershipsListScreen()),
      GoRoute(
        path: AppRoutes.addMembership,
        builder: (_, state) => AddMembershipScreen(
          groupId: state.uri.queryParameters['group_id'],
        ),
      ),
      GoRoute(path: AppRoutes.auctions, builder: (_, __) => const AuctionsListScreen()),
      GoRoute(
        path: AppRoutes.addAuction,
        builder: (_, state) => AddAuctionScreen(
          groupId: state.uri.queryParameters['group_id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.auctionDetail,
        builder: (_, state) => AuctionDetailScreen(auctionId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.payments, builder: (_, __) => const PaymentsListScreen()),
      GoRoute(path: AppRoutes.addPayment, builder: (_, __) => const AddPaymentScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
