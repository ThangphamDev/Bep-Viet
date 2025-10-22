// Deprecated: Use community_feed_card_new.dart instead.
// This stub remains only to avoid breaking imports during cleanup.

import 'package:flutter/widgets.dart';

@Deprecated('Use CommunityFeedCardNew in community_feed_card_new.dart')
class CommunityFeedCard extends StatelessWidget {
  const CommunityFeedCard({
    super.key,
    dynamic recipe,
    VoidCallback? onTap,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onShare,
    bool isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Render nothing; this file is deprecated.
    return const SizedBox.shrink();
  }
}
