import 'package:beautician_app/controllers/users/services/service_controller.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/nav_bar_screens/home/salon_list_screen.dart';
import 'package:beautician_app/views/user/nav_bar_screens/search/search_card_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final UserSubcategoryServiceController _categoryController = Get.put(
    UserSubcategoryServiceController(),
  );
  TabController? _tabController;
  bool isTabsInitialized = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  Future<void> _initializeTabs() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tabController = TabController(
          length: _categoryController.category.length,
          vsync: this,
        );
        setState(() {
          isTabsInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
              child: AppBar(
                backgroundColor: Colors.white,
                leading: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                    ),
                  ],
                ),
                titleSpacing: 0,
                title: Container(
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: const Color(0xffFFFFFF),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Color(0xFFC0C0C0),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: Color(0xFFC0C0C0),
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),


          backgroundColor: Colors.white,
          body: isTabsInitialized
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        TabBar(
                          tabAlignment: TabAlignment.start,
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: kPrimaryColor,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: List.generate(
                            _categoryController.category.length,
                            (index) => Tab(
                              child: Text(
                                _categoryController
                                        .category[index]['name'] ??
                                    '',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        _categoryController.category.length,
                        (index) {
                          final category =
                              _categoryController.category[index];
                          return SearchCardScreen(
                            title: category['name'] ?? 'Unknown',
                            categoryId: category['_id'],
                            searchQuery: _searchQuery, // ← pass query
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class SaloonCardTwo extends StatelessWidget {
  final bool isBookNow;
  final String? image;
  final String? name;

  SaloonCardTwo({Key? key, this.image, this.name, this.isBookNow = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 130,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(image!, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '4.0',
                    style: kHeadingStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                'Velvet Vanity',
                style: kHeadingStyle.copyWith(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                style: kSubheadingStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Image(image: NetworkImage(image!), height: 14),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '8.5 min (4.5 km)',
                      style: kSubheadingStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
