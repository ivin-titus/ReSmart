// guest user screen
import 'package:flutter/material.dart';
import 'package:resmart/widgets/navbar.dart';

class GuestWarningDialog extends StatefulWidget {
  final VoidCallback onContinue;

  const GuestWarningDialog({
    super.key,
    required this.onContinue,
  });

  static Future<void> show(BuildContext context, VoidCallback onContinue) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => GuestWarningDialog(onContinue: onContinue),
    );
  }

  @override
  State<GuestWarningDialog> createState() => _GuestWarningDialogState();
}

class _GuestWarningDialogState extends State<GuestWarningDialog> {
  final _scrollController = ScrollController();

  Widget _buildFeatureList() {
    final features = [
      'Advanced AI Assistant capabilities',
      'Widgets on the Always-On display',
      'Companion device section in the Device tab',
      'Shared notifications across devices',
      'Some tools in the Tools tab',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text('•',
                              style: TextStyle(fontSize: 16, height: 1)),
                        ),
                      ),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.close, color: colorScheme.onSurface),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Proceed as a Guest',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'Limited Access to Features',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'By proceeding as a guest, some features will be unavailable until you create an account:',
                                  style: textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 16),
                                _buildFeatureList(),
                                const SizedBox(height: 16),
                                Text(
                                  'You can unlock all features by signing up, but if you choose to proceed without an account, you\'ll still be able to use basic functionality.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const NavBar(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return colorScheme.primary
                                            .withOpacity(0.3);
                                      }
                                      return colorScheme.primary;
                                    }),
                                    foregroundColor: MaterialStateProperty.all(
                                        colorScheme.onPrimary),
                                    minimumSize: MaterialStateProperty.all(
                                      const Size(double.infinity, 45),
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  child: const Text('Continue as Guest'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
