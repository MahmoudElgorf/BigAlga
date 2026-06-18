/// Bottom sheet for selecting algae types to compare
import 'package:flutter/material.dart';
import 'package:bioalga/core/constants/constants.dart';

class ComparisonSelectionSheet extends StatefulWidget {
  final String mainType;
  final List<String> availableTypes;
  final Function(List<String>) onCompare;

  const ComparisonSelectionSheet({
    super.key,
    required this.mainType,
    required this.availableTypes,
    required this.onCompare,
  });

  @override
  State<ComparisonSelectionSheet> createState() =>
      _ComparisonSelectionSheetState();
}

class _ComparisonSelectionSheetState extends State<ComparisonSelectionSheet> {
  final List<String> _selectedTypes = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'Compare Algae Species',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select species to compare with ${widget.mainType}. Choose up to 3.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.availableTypes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final type = widget.availableTypes[index];
                final isSelected = _selectedTypes.contains(type);
                final isDisabled = _selectedTypes.length >= 3 && !isSelected;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: isDisabled
                        ? null
                        : (_) {
                      setState(() {
                        if (isSelected) {
                          _selectedTypes.remove(type);
                        } else {
                          _selectedTypes.add(type);
                        }
                      });
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                  title: Text(
                    type,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                      : null,
                  onTap: isDisabled
                      ? null
                      : () {
                    setState(() {
                      if (isSelected) {
                        _selectedTypes.remove(type);
                      } else {
                        _selectedTypes.add(type);
                      }
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${_selectedTypes.length} species selected',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _selectedTypes.isEmpty
                    ? null
                    : () {
                  Navigator.pop(context);
                  widget.onCompare(_selectedTypes);
                },
                icon: const Icon(Icons.compare_arrows),
                label: Text(
                  'Compare (${_selectedTypes.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}