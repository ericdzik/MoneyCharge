import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }

    context.read<MerchantProvider>().applyFilters(
          searchQuery: _searchController.text,
          searchQueryIsSet: true,
        );
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Rechercher un commerçant...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black54),
                  onPressed: _clearSearch,
                  splashRadius: 20,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: const BorderSide(color: Colors.black26, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}