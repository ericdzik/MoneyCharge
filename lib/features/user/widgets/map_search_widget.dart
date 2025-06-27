import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class MapSearchWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final List<String> availableFilters;
  final String? selectedFilter;

  const MapSearchWidget({
    super.key,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.availableFilters,
    this.selectedFilter,
  });

  @override
  State<MapSearchWidget> createState() => _MapSearchWidgetState();
}

class _MapSearchWidgetState extends State<MapSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche principale
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un point de service...',
                      hintStyle: AppTextStyles.body2.copyWith(
                        color: Colors.grey[400],
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Filtres (affichés quand étendu)
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtres',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Filtre "Tous"
                      _buildFilterChip(
                        'Tous',
                        widget.selectedFilter == null,
                        () => widget.onFilterChanged(''),
                      ),
                      // Filtres disponibles
                      ...widget.availableFilters.map(
                        (filter) => _buildFilterChip(
                          filter,
                          widget.selectedFilter == filter,
                          () => widget.onFilterChanged(filter),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class MapQuickActions extends StatelessWidget {
  final VoidCallback onMyLocation;
  final VoidCallback onShowAll;
  final VoidCallback onRefresh;

  const MapQuickActions({
    super.key,
    required this.onMyLocation,
    required this.onShowAll,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      right: 16,
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.my_location,
            onTap: onMyLocation,
            tooltip: 'Ma position',
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.zoom_out_map,
            onTap: onShowAll,
            tooltip: 'Voir tout',
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.refresh,
            onTap: onRefresh,
            tooltip: 'Actualiser',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
