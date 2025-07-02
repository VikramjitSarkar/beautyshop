import 'package:beautician_app/controllers/shopeController.dart';
import 'package:beautician_app/utils/colors.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:beautician_app/views/user/nav_bar_screens/map/tabs/generic_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ShopController _shopController = Get.put(ShopController());
  bool _isInitialLoad = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    _loadData();
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategoryId =
            _shopController.services[_tabController.index]['_id'];
      });
    }
  }

  Future<void> _loadData() async {
    await _shopController.fetchCategories();
    _isInitialLoad = false;
    if (mounted) {
      setState(() {
        if (_shopController.services.isNotEmpty) {
          _selectedCategoryId = _shopController.services[0]['_id'];
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
              child: Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 10),
                  _buildTabBarSection(),
                ],
              ),
            ),
            Expanded(child: _buildTabViewSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search shops...',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      onSubmitted: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
    );
  }

  Widget _buildTabBarSection() {
    return Obx(() {
      if (_isInitialLoad && _shopController.isLoading.value) {
        return const CircularProgressIndicator();
      }
      if (_shopController.error.value.isNotEmpty) {
        return Text('Error: ${_shopController.error.value}');
      }
      if (_shopController.services.isEmpty) {
        return const Text('No categories available');
      }

      if (_tabController.length != _shopController.services.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _tabController = TabController(
                length: _shopController.services.length,
                vsync: this,
              );
              _tabController.addListener(_handleTabSelection);
            });
          }
        });
      }

      return TabBar(
        tabAlignment: TabAlignment.start,
        controller: _tabController,
        isScrollable: true,
        indicatorColor: kPrimaryColor,
        tabs:
            _shopController.services.map((category) {
              return Tab(
                child: Text(
                  category['name'],
                  style: TextStyle(
                    color:
                        _tabController.index ==
                                _shopController.services.indexOf(category)
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
              );
            }).toList(),
      );
    });
  }

  Widget _buildTabViewSection() {
    return Obx(() {
      if (_shopController.services.isEmpty) {
        return const Center(child: Text('No categories to display'));
      }

      if (_tabController.length != _shopController.services.length) {
        return const Center(child: CircularProgressIndicator());
      }

      return TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children:
            _shopController.services.map((category) {
              return GenericTabScreen(
                category: category['name'],
                categoryId: category['_id'],
                searchQuery: _searchQuery,
              );
            }).toList(),
      );
    });
  }
}
