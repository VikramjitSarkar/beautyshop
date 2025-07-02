import 'package:beautician_app/utils/libs.dart';

import '../../../controllers/vendors/auth/vendor_listing_controler.dart';

class FreeAndPaidListingServicesScreen extends StatefulWidget {
  const FreeAndPaidListingServicesScreen({super.key});

  @override
  State<FreeAndPaidListingServicesScreen> createState() =>
      _FreeAndPaidListingServicesScreenState();
}

class _FreeAndPaidListingServicesScreenState
    extends State<FreeAndPaidListingServicesScreen> {
  String selectedPlan = '';
  final VendorListingController _controller = Get.put(
    VendorListingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Listing plans',
                style: kHeadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your listing plan',
                style: kSubheadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 40),
              // Free listing option
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kGreyColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<String>(
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: Text(
                    'Free listing',
                    style: kSubheadingStyle.copyWith(fontSize: 16),
                  ),
                  value: 'free',
                  groupValue: selectedPlan,
                  activeColor: kPrimaryColor,
                  onChanged: (value) {
                    setState(() {
                      selectedPlan = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Paid listing option
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kGreyColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<String>(
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: Text(
                    'Paid listing',
                    style: kSubheadingStyle.copyWith(fontSize: 16),
                  ),
                  value: 'paid',
                  groupValue: selectedPlan,
                  activeColor: kPrimaryColor,
                  onChanged: (value) {
                    setState(() {
                      selectedPlan = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 40),
              Obx(
                () => CustomButton(
                  isEnabled: !_controller.isLoading.value,
                  isLoading: _controller.isLoading.value,
                  title: 'Continue',
                  onPressed: () {
                    if (selectedPlan.isEmpty) {
                      Get.snackbar('Error', 'Please select a listing plan');
                    } else {
                      _controller.updateListingPlan(selectedPlan);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
