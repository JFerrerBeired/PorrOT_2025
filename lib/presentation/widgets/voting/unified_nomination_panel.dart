import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/contestant.dart';
import '../../providers/prediction_provider.dart';

class UnifiedNominationPanel extends StatelessWidget {
  const UnifiedNominationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PredictionProvider>(context);
    final selectedNominees = provider.selectedNomineeProposals;

    // Create a list of 4 items, filling with selected nominees first
    final List<Contestant?> panelSlots = List.generate(4, (index) {
      return index < selectedNominees.length ? selectedNominees[index] : null;
    });

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5, // Adjust for a more "pill" like shape
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final contestant = panelSlots[index];
            return contestant == null
                ? _buildEmptySlot(context, provider, index)
                : _buildContestantPill(context, provider, contestant);
          },
        ),
      ],
    );
  }

  Widget _buildEmptySlot(
    BuildContext context,
    PredictionProvider provider,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showContestantSelectionDialog(context, provider),
      child: DashedBorderCard(
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.grey),
              SizedBox(width: 8),
              Text('Nominado', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContestantPill(
    BuildContext context,
    PredictionProvider provider,
    Contestant contestant,
  ) {
    final theme = Theme.of(context);
    final bool isSavedByProf = provider.savedByProfessors == contestant;
    final bool isSavedByPeers = provider.savedByPeers == contestant;

    Color? borderColor;
    if (isSavedByProf) {
      borderColor = theme.primaryColor;
    } else if (isSavedByPeers) {
      borderColor = theme.colorScheme.secondary;
    }

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: borderColor != null
            ? BorderSide(color: borderColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Avatar and Name
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: ClipOval(
                child: contestant.photoUrl != null && contestant.photoUrl!.isNotEmpty
                    ? Image.network(
                        contestant.photoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Show initial if image fails to load
                          return Center(
                            child: Text(
                              contestant.name[0],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Show initial while loading
                          return Center(
                            child: Text(
                              contestant.name[0],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          contestant.name[0],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                contestant.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Action Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.school,
                  isSelected: isSavedByProf,
                  onTap: () {
                    if (isSavedByProf) {
                      provider.setSavedByProfessors(null);
                    } else {
                      provider.setSavedByProfessors(contestant);
                    }
                  },
                  selectedColor: theme.primaryColor,
                ),
                const SizedBox(height: 4),
                _buildActionButton(
                  context,
                  icon: Icons.people,
                  isSelected: isSavedByPeers,
                  onTap: () {
                    if (isSavedByPeers) {
                      provider.setSavedByPeers(null);
                    } else {
                      provider.setSavedByPeers(contestant);
                    }
                  },
                  selectedColor: theme.colorScheme.secondary,
                ),
              ],
            ),
            // Modify/Remove Button
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => provider.toggleNomineeProposal(contestant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  void _showContestantSelectionDialog(
    BuildContext context,
    PredictionProvider provider,
  ) {
    final availableContestants = provider.activeContestants
        .where((c) => !provider.selectedNomineeProposals.contains(c))
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Seleccionar Nominado'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableContestants.length,
              itemBuilder: (context, index) {
                final contestant = availableContestants[index];
                return ListTile(
                  title: Text(contestant.name),
                  onTap: () {
                    provider.toggleNomineeProposal(contestant);
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Helper widget for the dashed border card
class DashedBorderCard extends StatelessWidget {
  final Widget child;
  const DashedBorderCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedRectPainter(
        color: Colors.grey.shade400,
        strokeWidth: 2.0,
        gap: 4.0,
      ),
      child: child,
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16.0),
      ),
    );

    final dashPath = Path();
    double distance = 0.0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
