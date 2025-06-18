import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/nav_bar_screens/map/tabs/base_tab_screen.dart';

class GenericTabScreen extends BaseTabScreen {
  const GenericTabScreen({
    super.key,
    required String category,
    required String categoryId,
    required String searchQuery,
  }) : super(
         category: category,
         categoryId: categoryId,
         searchQuery: searchQuery,
       );
}
