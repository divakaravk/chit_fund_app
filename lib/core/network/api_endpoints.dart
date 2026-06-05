class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://192.168.0.105/chit_fund_saas_api';

  // Companies
  static const String registerCompany = '/companies/register_company.php';
  static const String getCompany = '/companies/get_company.php';
  static const String updateCompany = '/companies/update_company.php';

  // Users
  static const String addUser = '/users/add_user.php';
  static const String getUser = '/users/get_user.php';
  static String getUserById(String id) => '/users/get_user.php?id=$id';
  static String updateUser(String id) => '/users/update_user.php?id=$id';
  static String patchUserStatus(String id) => '/users/patch_user_status.php?id=$id';
  static String deleteUser(String id) => '/users/delete_user.php?id=$id';

  // Schemes
  static const String addScheme = '/schemes/add_scheme.php';
  static const String getScheme = '/schemes/get_scheme.php';
  static String getSchemeById(String id) => '/schemes/get_scheme.php?id=$id';
  static String updateScheme(String id) => '/schemes/update_scheme.php?id=$id';
  static String patchSchemeStatus(String id) => '/schemes/patch_scheme_status.php?id=$id';
  static String deleteScheme(String id) => '/schemes/delete_scheme.php?id=$id';

  // Groups
  static const String addGroup = '/groups/add_group.php';
  static const String getGroup = '/groups/get_group.php';
  static String getGroupById(String id) => '/groups/get_group.php?id=$id';
  static String updateGroup(String id) => '/groups/update_group.php?id=$id';
  static String patchGroupStatus(String id) => '/groups/patch_group_status.php?id=$id';
  static String deleteGroup(String id) => '/groups/delete_group.php?id=$id';

  // Memberships
  static const String addMembership = '/memberships/add_membership.php';
  static const String getMembership = '/memberships/get_membership.php';
  static String getMembershipById(String id) => '/memberships/get_membership.php?id=$id';
  static String getMembershipByGroup(String groupId) => '/memberships/get_membership.php?group_id=$groupId';
  static String updateMembership(String id) => '/memberships/update_membership.php?id=$id';
  static String patchMembershipStatus(String id) => '/memberships/patch_membership_status.php?id=$id';
  static String deleteMembership(String id) => '/memberships/delete_membership.php?id=$id';

  // Auctions
  static const String addAuction = '/auctions/add_auction.php';
  static const String getAuction = '/auctions/get_auction.php';
  static String getAuctionById(String id) => '/auctions/get_auction.php?id=$id';
  static String getAuctionByGroup(String groupId) => '/auctions/get_auction.php?group_id=$groupId';
  static String closeAuction(String id) => '/auctions/close_auction.php?id=$id';
  static String deleteAuction(String id) => '/auctions/delete_auction.php?id=$id';

  // Bids
  static const String addBid = '/bids/add_bid.php';
  static String getBidsByAuction(String auctionId) => '/bids/get_bid.php?auction_id=$auctionId';
  static String updateBid(String id) => '/bids/update_bid.php?id=$id';
  static String deleteBid(String id) => '/bids/delete_bid.php?id=$id';

  // Payments
  static const String addPayment = '/payments/add_payment.php';
  static const String getPayment = '/payments/get_payment.php';
  static String getPaymentById(String id) => '/payments/get_payment.php?id=$id';
  static String getPaymentByMembership(String membershipId) => '/payments/get_payment.php?membership_id=$membershipId';
  static String markPaid(String id) => '/payments/mark_paid.php?id=$id';
  static String deletePayment(String id) => '/payments/delete_payment.php?id=$id';

  // Disbursements
  static const String addDisbursement = '/disbursements/add_disbursement.php';
  static String confirmDisbursement(String id) => '/disbursements/confirm_disbursement.php?id=$id';
  static String deleteDisbursement(String id) => '/disbursements/delete_disbursement.php?id=$id';

  // Surety Bonds
  static const String addSuretyBond = '/surety_bonds/add_surety_bond.php';
  static String updateSuretyBond(String id) => '/surety_bonds/update_surety_bond.php?id=$id';
  static String deleteSuretyBond(String id) => '/surety_bonds/delete_surety_bond.php?id=$id';

  // Notifications
  static const String addNotification = '/notifications/add_notification.php';
  static const String getNotification = '/notifications/get_notification.php';
  static String markRead(String id) => '/notifications/mark_read.php?id=$id';
  static String deleteNotification(String id) => '/notifications/delete_notification.php?id=$id';

  // Audit Logs
  static const String getAuditLogs = '/audit_logs/get_audit_logs.php';
  static String getAuditLogsByEntity(String entityType, String entityId) =>
      '/audit_logs/get_audit_logs.php?entity_type=$entityType&entity_id=$entityId';
}
