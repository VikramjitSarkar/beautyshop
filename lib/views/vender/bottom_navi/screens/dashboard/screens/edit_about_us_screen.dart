import 'package:beautician_app/utils/libs.dart';
import 'package:intl/intl.dart';
import '../../../../../../controllers/vendors/dashboard/dashboardController.dart';
import '../../../../../../controllers/vendors/dashboard/editAboutUsController.dart';

class EditAboutUsScreen extends StatelessWidget {
  const EditAboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditAboutUsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset('assets/back icon.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit About Us',
          style: kHeadingStyle.copyWith(fontSize: 16),
        ),
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: controller.isLoading.value,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Description',
                        style: kHeadingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Enter description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Time', style: kHeadingStyle.copyWith(fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kGreyColor2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/timer2.png'),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Opening Hours',
                                        style: kHeadingStyle.copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Set your business hours',
                                        style: kSubheadingStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: kGreyColor2),
                            const SizedBox(height: 16),
                            ...List.generate(controller.openingHours.length, (
                              index,
                            ) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.openingHours[index]['day'],
                                        style: kSubheadingStyle,
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              String? time = await controller
                                                  .pickTime(context);
                                              if (time != null) {
                                                controller.updateOpenCloseTime(
                                                  index,
                                                  time,
                                                  true,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                controller
                                                    .openingHours[index]['open'],
                                                style: kHeadingStyle.copyWith(
                                                  fontSize: 12,
                                                  color: kPrimaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('to', style: kSubheadingStyle),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () async {
                                              String? time = await controller
                                                  .pickTime(context);
                                              if (time != null) {
                                                controller.updateOpenCloseTime(
                                                  index,
                                                  time,
                                                  false,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                controller
                                                    .openingHours[index]['close'],
                                                style: kHeadingStyle.copyWith(
                                                  fontSize: 14,
                                                  color: kPrimaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (index <
                                      controller.openingHours.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => MaterialButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () async {
                                    await controller.updateOpenningime();

                                    // ✅ Refresh data for AboutUsScreen
                                    if (Get.isRegistered<
                                      DashBoardController
                                    >()) {
                                      final dashCtrl =
                                          Get.find<DashBoardController>();
                                      await dashCtrl.fetchVendor();
                                    }

                                    Navigator.pop(context);
                                  },

                          height: 50,
                          minWidth: double.infinity,
                          color:
                              controller.isLoading.value
                                  ? kGreyColor2
                                  : kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              controller.isLoading.value
                                  ? CircularProgressIndicator(
                                    color: kPrimaryColor,
                                  )
                                  : Text(
                                    'Update',
                                    style: kHeadingStyle.copyWith(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
