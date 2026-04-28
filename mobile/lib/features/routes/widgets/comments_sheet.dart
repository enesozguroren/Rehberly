import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../data/route_comment.dart';
import '../data/travel_route.dart';
import '../presentation/route_feed_controller.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.route,
  });

  final TravelRoute route;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _commentController = TextEditingController();
  late Future<List<RouteComment>> _future;
  List<RouteComment> _comments = [];
  bool _hasLoadedComments = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = context.read<RouteFeedController>().loadComments(widget.route.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.route.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: FutureBuilder<List<RouteComment>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  if (!_hasLoadedComments) {
                    _comments = snapshot.data ?? [];
                    _hasLoadedComments = true;
                  }

                  if (_comments.isEmpty) {
                    return const Center(
                      child: Text('İlk yorumu sen yaz.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) => const Divider(height: 18),
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.12),
                          child: Text(
                            comment.username.isEmpty
                                ? '?'
                                : comment.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        title: Text(
                          comment.username,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(comment.text),
                      );
                    },
                  );
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Yorum yaz',
                      prefixIcon: Icon(Icons.mode_comment_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Gönder',
                  onPressed: _isSending ? null : _send,
                  icon: _isSending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final comment = await context.read<RouteFeedController>().addComment(
            routeId: widget.route.id,
            text: text,
          );
      if (!mounted) return;
      setState(() {
        _comments = [comment, ..._comments];
        _commentController.clear();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
