import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/message/tabs/vendor_message_tab_Screen.dart'
    show VendorMessageTabScreen;

class VendorMsgScreen extends StatelessWidget {
  const VendorMsgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Text(
            'Messages',
            style: kHeadingStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: TabBarView(children: [VendorMessageTabScreen()]),
        ),
      ),
    );
  }
}
