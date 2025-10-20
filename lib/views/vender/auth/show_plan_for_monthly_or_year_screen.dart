import 'package:beautician_app/controllers/vendors/auth/vendor_listing_controler.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/bottom_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/vendors/stripeController.dart/stripeController.dart';
import '../../../models/planodel.dart';

class ShowPlanForMonthlyOrYearScreen extends StatefulWidget {
  const ShowPlanForMonthlyOrYearScreen({super.key});

  @override
  State<ShowPlanForMonthlyOrYearScreen> createState() =>
      _ShowPlanForMonthlyOrYearScreenState();
}

class _ShowPlanForMonthlyOrYearScreenState
    extends State<ShowPlanForMonthlyOrYearScreen> {
  final VendorListingController _controller = Get.put(
    VendorListingController(),
  );
  PlanModel? selectedPlan;
  late Future<List<PlanModel>> _plans;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _plans = PlanService.fetchPlans();
  }

  Widget radioPlanOption(PlanModel plan) {
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
        onChanged: (value) {
          setState(() {
            selectedPlan = plan;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stripeController = Get.put(StripeController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                'Listing plans',
                style: kHeadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Offering Premium Features for better customer engagement in:',
                style: kSubheadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 30),
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
              CustomButton(
                isEnabled: selectedPlan != null,
                title: 'Continue',
                onPressed: () async {
                  await stripeController.makePayment(
                    context: context,
                    amountInDollars:
                        selectedPlan!.price.toDouble(), // Already in dollars
                    planId: selectedPlan!.id,
                  );
                  print(
                    "Printing Data: ${selectedPlan!.price} Selected plan ID is ${selectedPlan!.id}",
                  );
                  await _controller.updateListingPlan('paid', false);

                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
