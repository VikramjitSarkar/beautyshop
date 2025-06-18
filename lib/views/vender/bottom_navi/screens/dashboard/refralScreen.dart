import 'package:beautician_app/controllers/vendors/dashboard/refralControler.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../bottom_nav_bar.dart';


class ReferralCodeScreen extends StatelessWidget {
  ReferralCodeScreen({super.key});

  final ReferralCodeController controller = Get.put(ReferralCodeController());

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Row(
            children: [
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Get.back(),
                child: SvgPicture.asset('assets/back icon.svg'),
              )
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              CustomTextField(
                hintText: "Referral Code",
                controller: controller.referralCodeController,
                inputType: TextInputType.text,
                prefixIcon: Icon(Icons.real_estate_agent),
              ),
              SizedBox(height: 20),
              Obx(() => CustomButton(
                title: controller.isLoading.value ? 'Submitting...' : 'Submit',
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                  await controller.submitReferralCode();
                  Get.to(()=>BottomNavBarScreen());
                },
              )),
            ],
          ),
        ),
      );
    });
  }
}
