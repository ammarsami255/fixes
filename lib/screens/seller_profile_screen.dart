import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:el_moza3/core/constants/app_constants.dart';
import 'package:el_moza3/infrastructure/di/injection.dart';
import 'package:el_moza3/features/chat/domain/repositories/chat_repository.dart';
import 'package:el_moza3/features/listings/domain/repositories/listing_repository.dart';
import 'package:el_moza3/features/listings/domain/entities/listing_entity.dart' show Listing;
import 'package:el_moza3/features/user_profile/domain/repositories/user_repository.dart';
import 'package:el_moza3/screens/chat_screen.dart';
import 'package:el_moza3/screens/service_detail_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  bool _isLoading = true;
  String _sellerName = '';
  DateTime? _memberSince;
  int _listingsCount = 0;
  List<Listing> _listings = [];
  bool _isLoadingChat = false;
  StreamSubscription? _listingsSub;

  @override
  void initState() {
    super.initState();
    _sellerName = widget.sellerName;
    _loadSellerData();
  }

  @override
  void dispose() {
    _listingsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadSellerData() async {
    try {
      final userResult = await getIt<UserRepository>().getUserProfile(widget.sellerId);
      if (userResult.user != null) {
        if (mounted) {
          setState(() {
            _sellerName = userResult.user!.name.isNotEmpty
                ? userResult.user!.name
                : widget.sellerName;
            _memberSince = userResult.user!.createdAt;
          });
        }
      }

      _listingsSub = getIt<ListingRepository>()
          .getListings(userId: widget.sellerId)
          .listen((listings) {
        if (mounted) {
          setState(() {
            _listings = listings;
            _listingsCount = listings.length;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatMemberSince() {
    if (_memberSince == null) return '';
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${_memberSince!.day} ${months[_memberSince!.month - 1]} ${_memberSince!.year}';
  }

  Future<void> _openChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (user.uid == widget.sellerId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكنك مراسلة نفسك'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoadingChat = true);

    try {
      final result = await getIt<ChatRepository>().getOrCreateChat(
        otherUserId: widget.sellerId,
        otherUserName: _sellerName,
      );
      if (result.failure != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.failure!.message)),
        );
        return;
      }
      final chatId = result.chatId;
      if (chatId == null || !mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(chatId: chatId, otherUserId: widget.sellerId),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح المحادثة'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingChat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppBorders.radiusMedium,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          _buildAvatar(),
                          const SizedBox(height: 16),
                          Text(
                            _sellerName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_memberSince != null)
                            Text(
                              'عضو منذ $_memberSince',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          const SizedBox(height: 24),
                          _buildStats(),
                          const SizedBox(height: 24),
                          if (_listings.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'إعلانات البائع',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildListingsGrid(),
                          ] else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppBorders.radiusMedium,
                              ),
                              child: const Text(
                                'لا توجد إعلانات حالياً',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoadingChat ? null : _openChat,
              icon: _isLoadingChat
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                    ),
              label: const Text(
                'مراسلة البائع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorders.radiusMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = _sellerName.isNotEmpty ? _sellerName[0].toUpperCase() : '?';
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorders.radiusMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('$_listingsCount', 'إعلانات'),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          _buildStatItem(_formatMemberSince(), 'عضو منذ'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildListingsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        return _buildListingCard(_listings[index]);
      },
    );
  }

  Widget _buildListingCard(Listing listing) {
    final title = listing.title;
    final category = listing.category ?? '';
    final price = listing.price.toString();
    final location = listing.location ?? '';
    final imageUrl = listing.imageUrl;

    return GestureDetector(
      onTap: () async {
        final result = await getIt<ListingRepository>().getListing(listing.id);
        if (result.listing != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(
                item: result.listing!.toMap(),
                onRequireLogin: () async {},
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorders.radiusMedium,
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (price.isNotEmpty && price != '0')
                      Text(
                        '$price ج.م',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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
}