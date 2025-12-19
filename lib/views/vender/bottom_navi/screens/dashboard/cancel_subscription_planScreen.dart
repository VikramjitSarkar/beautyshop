import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/controllers/vendors/auth/vendor_listing_controler.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/models/planodel.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/auth/show_plan_for_monthly_or_year_screen.dart';
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
  final DashBoardController dashCtrl = Get.put(DashBoardController());

  PlanModel? selectedPlan;
  late Future<List<PlanModel>> _plans;
  bool hasActiveSubscription = false;

  @override
  void initState() {
    super.initState();
    subscriptionController.fetchAndSetVendorSubscription().then((_) {
      setState(() {
        hasActiveSubscription = subscriptionController.currentVendorSubscription?.isNotEmpty ?? false;
      });
    });

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

  Widget _buildPlanCard(PlanModel plan, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? kPrimaryColor.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isActive ? kPrimaryColor : kGreyColor.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                    ' ${(plan.price).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Valid for ${plan.durationInDays} days',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset('assets/back icon.svg', height: 50),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                'Subscription Plans',
                style: kHeadingStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 10),

              Obx(() {
                final listing = dashCtrl.listing.value;
                final currentSub = subscriptionController.currentVendorSubscription;
                
                // Calculate days remaining
                int daysRemaining = 0;
                String planName = '';
                if (currentSub != null && currentSub.isNotEmpty) {
                  final endDate = currentSub['endDate'];
                  final planData = currentSub['planId'];
                  
                  if (endDate != null) {
                    final end = DateTime.parse(endDate);
                    final now = DateTime.now();
                    daysRemaining = end.difference(now).inDays;
                  }
                  
                  if (planData is Map) {
                    planName = '\$${planData['price']} for ${planData['durationInDays']} days';
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: listing == 'paid' ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: listing == 'paid' ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            listing == 'paid' ? Icons.verified : Icons.info_outline,
                            color: listing == 'paid' ? Colors.green : Colors.orange,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              listing == 'paid'
                                  ? 'Active Premium Subscription'
                                  : 'Free Plan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: listing == 'paid' ? Colors.green.shade900 : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (listing == 'paid' && planName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.card_membership, size: 20, color: Colors.black87),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Plan: $planName',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 20,
                                    color: daysRemaining < 7 ? Colors.red : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    daysRemaining > 0
                                        ? '$daysRemaining days remaining'
                                        : 'Expired',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: daysRemaining < 7 ? Colors.red : Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

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
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        final isActive = plan.id == GlobalsVariables.paymentId;
                        return _buildPlanCard(plan, isActive);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Obx(() {
                final listing = dashCtrl.listing.value;
                final currentSub = subscriptionController.currentVendorSubscription;
                final subId = currentSub?['_id'];

                if (listing == 'paid' && subId != null) {
                  // Show cancel button if has active subscription
                  return subscriptionController.isCancelling.value
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          isEnabled: true,
                          title: 'Cancel Subscription',
                          onPressed: () async {
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Cancel Subscription'),
                                content: const Text(
                                  'Are you sure you want to cancel your subscription? You will lose access to premium features.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Yes, Cancel'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await subscriptionController.deleteSubscription(subId!);
                              await GlobalsVariables.savePaymentId('');
                              dashCtrl.listing.value = 'free';
                              Get.snackbar('Success', 'Subscription cancelled successfully');
                            }
                          },
                        );
                } else {
                  // Show subscribe button if no active subscription
                  return CustomButton(
                    isEnabled: true,
                    title: 'Upgrade to Premium',
                    onPressed: () {
                      Get.to(() => ShowPlanForMonthlyOrYearScreen());
                    },
                  );
                }
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
