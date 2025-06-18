import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/auth/vendor_listing_controler.dart';
import 'package:beautician_app/models/planodel.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../controllers/vendors/stripeController.dart/stripeController.dart'
    show StripeController;

class CancelShowPlanForMonthlyOrYearScreen extends StatefulWidget {
  const CancelShowPlanForMonthlyOrYearScreen({super.key});

  @override
  State<CancelShowPlanForMonthlyOrYearScreen> createState() =>
      _CancelShowPlanForMonthlyOrYearScreenState();
}

class _CancelShowPlanForMonthlyOrYearScreenState
    extends State<CancelShowPlanForMonthlyOrYearScreen> {
  final VendorListingController _controller = Get.put(
    VendorListingController(),
  );
  final StripeController subscriptionController = Get.put(StripeController());

  PlanModel? selectedPlan;
  late Future<List<PlanModel>> _plans;

  @override
  void initState() {
    super.initState();
    subscriptionController.fetchAndSetVendorSubscription();

    _plans = PlanService.fetchPlans().then((plans) {
      final paymentId = GlobalsVariables.paymentId;
      if (paymentId != null) {
        for (var plan in plans) {
          if (plan.id == paymentId) {
            selectedPlan = plan;
            break;
          }
        }
      }
      return plans;
    });
  }

  Widget radioPlanOption(PlanModel plan) {
    final isSelectable =
        GlobalsVariables.paymentId != null &&
        plan.id == GlobalsVariables.paymentId;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: kGreyColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        controlAffinity: ListTileControlAffinity.trailing,
        title: Row(
          children: [
            const Text(
              '\$',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              ' ${(plan.price).toStringAsFixed(2)} ',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'for ${plan.durationInDays} days',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
        value: plan.id,
        groupValue: selectedPlan?.id,
        activeColor: kPrimaryColor,
        onChanged:
            isSelectable
                ? (value) {
                  setState(() {
                    selectedPlan = plan;
                  });
                }
                : null,
      ),
    );
  }

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
              // Back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset('assets/back icon.svg'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Heading
              Text(
                'Listing plans',
                style: kHeadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Offering Premium Features for better customer engagement in:',
                style: kSubheadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Warning if no subscription
              if (GlobalsVariables.paymentId == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "⚠️ You don't have any active subscription.\nPlease activate a plan first.",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Plan List
              Expanded(
                child: FutureBuilder<List<PlanModel>>(
                  future: _plans,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No plans available.'));
                    }

                    final plans = snapshot.data!;
                    return ListView.builder(
                      itemCount: plans.length,
                      itemBuilder:
                          (context, index) => radioPlanOption(plans[index]),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Cancel Button
              Obx(() {
                final currentSub =
                    subscriptionController.currentVendorSubscription;
                final subId = currentSub?['_id'];
                final subVendorId = currentSub?['vendor'];
                final loggedInVendorId = GlobalsVariables.vendorId;

                final isEnabled =
                    subId != null &&
                    selectedPlan?.id == GlobalsVariables.paymentId &&
                    subVendorId == loggedInVendorId;

                return subscriptionController.isCancelling.value
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                      isEnabled: isEnabled,
                      title: 'Cancel',
                      onPressed: () async {
                        if (!isEnabled) return;

                        await subscriptionController.deleteSubscription(subId!);
                        Get.snackbar(
                          "Success",
                          "Subscription cancelled successfully",
                        );
                        Get.offAll(() => BottomNavBarScreen());
                      },
                    );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
