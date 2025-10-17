import 'package:flutter/material.dart';
import '../../../domain/entities/contestant.dart';

class ContestantCard extends StatelessWidget {
  final Contestant contestant;
  final bool isSelected;
  final VoidCallback onTap;
  final String? role; // e.g., "Profesores", "Compañeros"

  const ContestantCard({
    super.key,
    required this.contestant,
    this.isSelected = false,
    required this.onTap,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? cardColor;
    Color? borderColor;

    if (isSelected) {
      cardColor = theme.primaryColor.withAlpha(25);
      borderColor = theme.primaryColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4.0 : 1.0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: ClipOval(
                child:
                    contestant.photoUrl != null &&
                        contestant.photoUrl!.isNotEmpty
                    ? Image.network(
                        contestant.photoUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Show initial if image fails to load
                          return Center(
                            child: Text(
                              contestant.name.isNotEmpty
                                  ? contestant.name[0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
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
                              contestant.name.isNotEmpty
                                  ? contestant.name[0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          contestant.name.isNotEmpty ? contestant.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                contestant.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (role != null) ...[
              const SizedBox(height: 4),
              Text(
                role!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
