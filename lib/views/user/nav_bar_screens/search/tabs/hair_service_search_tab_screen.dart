import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
class HairServiceSearchTabScreen extends StatelessWidget {
  const HairServiceSearchTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top specialist',
                        style: kHeadingStyle.copyWith(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Make it fullscreen
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),

                            builder: (context) {
                              // Core filter states
                              bool onlineNow = false;
                              bool nearby = false;
                              bool homeVisitAvailable = false;
                              bool hasSalonLocation = false;
                              RangeValues priceRange = const RangeValues(0, 500);
                              TimeOfDay selectedTime = TimeOfDay.now();
                              bool isAvailableNow = true;

                              return StatefulBuilder(
                                // To update state within the bottom sheet
                                builder: (context, setState) {
                                  return Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Filters',
                                              style: kHeadingStyle.copyWith(
                                                  fontSize: 16, fontWeight: FontWeight.w700),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // Online Now Switch
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('Online Now'),
                                          subtitle:
                                          const Text('Show specialists available for instant booking'),
                                          value: onlineNow,
                                          activeColor: Colors.white,
                                          activeTrackColor: kPrimaryColor,
                                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                          inactiveTrackColor: kGreyColor2,
                                          inactiveThumbColor: Colors.white,
                                          onChanged: (value) => setState(() => onlineNow = value),
                                        ),

                                        // Nearby Switch
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('Nearby'),
                                          subtitle: const Text('Sort by closest distance'),
                                          value: nearby,
                                          activeColor: Colors.white,
                                          activeTrackColor: kPrimaryColor,
                                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                          inactiveTrackColor: kGreyColor2,
                                          inactiveThumbColor: Colors.white,
                                          onChanged: (value) => setState(() => nearby = value),
                                        ),

                                        // Home Visit Available Switch
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('Home Visit Available'),
                                          subtitle: const Text('Specialists who can come to you'),
                                          value: homeVisitAvailable,
                                          activeColor: Colors.white,
                                          activeTrackColor: kPrimaryColor,
                                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                          inactiveTrackColor: kGreyColor2,
                                          inactiveThumbColor: Colors.white,
                                          onChanged: (value) => setState(() => homeVisitAvailable = value),
                                        ),

                                        // Has Salon Location Switch
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('Has Salon/Location'),
                                          subtitle: const Text('Specialists with their own location'),
                                          value: hasSalonLocation,
                                          activeColor: Colors.white,
                                          activeTrackColor: kPrimaryColor,
                                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                          inactiveTrackColor: kGreyColor2,
                                          inactiveThumbColor: Colors.white,
                                          onChanged: (value) => setState(() => hasSalonLocation = value),
                                        ),

                                        // Price Range Slider
                                        Text(
                                          'Price Range',
                                          style: TextStyle(color: kBlackColor),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${priceRange.start.toInt()}',
                                              style: TextStyle(color: kBlackColor),
                                            ),
                                            Text(
                                              '\$${priceRange.end.toInt()}',
                                              style: TextStyle(color: kBlackColor),
                                            ),
                                          ],
                                        ),
                                        RangeSlider(
                                          values: priceRange,
                                          min: 0,
                                          max: 500,
                                          divisions: 50,
                                          activeColor: kPrimaryColor,
                                          inactiveColor: kGreyColor2,
                                          labels: RangeLabels(
                                            '\$${priceRange.start.toInt()}',
                                            '\$${priceRange.end.toInt()}',
                                          ),
                                          onChanged: (values) => setState(() => priceRange = values),
                                        ),

                                        // Time Availability Section
                                        Text(
                                          'Time Availability',
                                          style: TextStyle(
                                            color: kBlackColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => setState(() => isAvailableNow = true),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: isAvailableNow ? kPrimaryColor : Colors.transparent,
                                                    border: Border.all(
                                                        color: isAvailableNow ? kPrimaryColor : kBlackColor),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Available Now',
                                                      style: TextStyle(
                                                        color: isAvailableNow ? Colors.white : kBlackColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final TimeOfDay? time = await showTimePicker(
                                                    context: context,
                                                    initialTime: selectedTime,
                                                  );
                                                  if (time != null) {
                                                    setState(() {
                                                      selectedTime = time;
                                                      isAvailableNow = false;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: !isAvailableNow ? kPrimaryColor : Colors.transparent,
                                                    border: Border.all(
                                                        color: !isAvailableNow ? kPrimaryColor : kBlackColor),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      !isAvailableNow
                                                          ? 'After ${selectedTime.format(context)}'
                                                          : 'Choose Time',
                                                      style: TextStyle(
                                                        color: !isAvailableNow ? Colors.white : kBlackColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 15),
                                        // Apply Button
                                        ElevatedButton(
                                          onPressed: () {
                                            // TODO: Implement filter application
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor,
                                            minimumSize: const Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Apply Filters',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Color(0xffF8F8F8),
                            shape: BoxShape.circle,
                            image: DecorationImage(image: AssetImage('assets/filter1.png'), scale: 4),
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: specialistImages2.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TopSpecialistCardTwo(
                            imagePath: specialistImages2[index],
                            onBook: () {},
                            specialistName: specialistNames2[index],
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(
                    color: kGreyColor2,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // ہر صف میں دو آئٹمز ہوں گے
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 400
                    ),
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: AssetImage('assets/saloon.png'),fit: BoxFit.fill)
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset('assets/star.png'),
                                    SizedBox(width: 3),
                                    Image.asset('assets/star.png'),
                                    SizedBox(width: 3),
                                    Image.asset('assets/star.png'),
                                    SizedBox(width: 3),
                                    Image.asset('assets/star.png'),
                                    SizedBox(width: 3),
                                    Image.asset('assets/star2.png'),
                                    SizedBox(width: 3),
                                    Text(
                                      '4.0',
                                      style: kHeadingStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
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
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Image(
                                        image: AssetImage('assets/timer.png'),
                                        height: 14),
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
                                SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 27,
                                    width: 58,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(30)),
                                      onPressed: () {},
                                      child: FittedBox(
                                        child: Text(
                                          'Book',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top specialist',
                      style: kHeadingStyle.copyWith(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Make it fullscreen
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),

                          builder: (context) {
                            // Core filter states
                            bool onlineNow = false;
                            bool nearby = false;
                            bool homeVisitAvailable = false;
                            bool hasSalonLocation = false;
                            RangeValues priceRange = const RangeValues(0, 500);
                            TimeOfDay selectedTime = TimeOfDay.now();
                            bool isAvailableNow = true;

                            return StatefulBuilder(
                              // To update state within the bottom sheet
                              builder: (context, setState) {
                                return Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Filters',
                                            style: kHeadingStyle.copyWith(
                                                fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      // Online Now Switch
                                      SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text('Online Now'),
                                        subtitle:
                                        const Text('Show specialists available for instant booking'),
                                        value: onlineNow,
                                        activeColor: Colors.white,
                                        activeTrackColor: kPrimaryColor,
                                        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                        inactiveTrackColor: kGreyColor2,
                                        inactiveThumbColor: Colors.white,
                                        onChanged: (value) => setState(() => onlineNow = value),
                                      ),

                                      // Nearby Switch
                                      SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text('Nearby'),
                                        subtitle: const Text('Sort by closest distance'),
                                        value: nearby,
                                        activeColor: Colors.white,
                                        activeTrackColor: kPrimaryColor,
                                        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                        inactiveTrackColor: kGreyColor2,
                                        inactiveThumbColor: Colors.white,
                                        onChanged: (value) => setState(() => nearby = value),
                                      ),

                                      // Home Visit Available Switch
                                      SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text('Home Visit Available'),
                                        subtitle: const Text('Specialists who can come to you'),
                                        value: homeVisitAvailable,
                                        activeColor: Colors.white,
                                        activeTrackColor: kPrimaryColor,
                                        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                        inactiveTrackColor: kGreyColor2,
                                        inactiveThumbColor: Colors.white,
                                        onChanged: (value) => setState(() => homeVisitAvailable = value),
                                      ),

                                      // Has Salon Location Switch
                                      SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text('Has Salon/Location'),
                                        subtitle: const Text('Specialists with their own location'),
                                        value: hasSalonLocation,
                                        activeColor: Colors.white,
                                        activeTrackColor: kPrimaryColor,
                                        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                                        inactiveTrackColor: kGreyColor2,
                                        inactiveThumbColor: Colors.white,
                                        onChanged: (value) => setState(() => hasSalonLocation = value),
                                      ),

                                      // Price Range Slider
                                      Text(
                                        'Price Range',
                                        style: TextStyle(color: kBlackColor),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${priceRange.start.toInt()}',
                                            style: TextStyle(color: kBlackColor),
                                          ),
                                          Text(
                                            '\$${priceRange.end.toInt()}',
                                            style: TextStyle(color: kBlackColor),
                                          ),
                                        ],
                                      ),
                                      RangeSlider(
                                        values: priceRange,
                                        min: 0,
                                        max: 500,
                                        divisions: 50,
                                        activeColor: kPrimaryColor,
                                        inactiveColor: kGreyColor2,
                                        labels: RangeLabels(
                                          '\$${priceRange.start.toInt()}',
                                          '\$${priceRange.end.toInt()}',
                                        ),
                                        onChanged: (values) => setState(() => priceRange = values),
                                      ),

                                      // Time Availability Section
                                      Text(
                                        'Time Availability',
                                        style: TextStyle(
                                          color: kBlackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(() => isAvailableNow = true),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: isAvailableNow ? kPrimaryColor : Colors.transparent,
                                                  border: Border.all(
                                                      color: isAvailableNow ? kPrimaryColor : kBlackColor),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Available Now',
                                                    style: TextStyle(
                                                      color: isAvailableNow ? Colors.white : kBlackColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                final TimeOfDay? time = await showTimePicker(
                                                  context: context,
                                                  initialTime: selectedTime,
                                                );
                                                if (time != null) {
                                                  setState(() {
                                                    selectedTime = time;
                                                    isAvailableNow = false;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: !isAvailableNow ? kPrimaryColor : Colors.transparent,
                                                  border: Border.all(
                                                      color: !isAvailableNow ? kPrimaryColor : kBlackColor),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    !isAvailableNow
                                                        ? 'After ${selectedTime.format(context)}'
                                                        : 'Choose Time',
                                                    style: TextStyle(
                                                      color: !isAvailableNow ? Colors.white : kBlackColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 15),
                                      // Apply Button
                                      ElevatedButton(
                                        onPressed: () {
                                          // TODO: Implement filter application
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimaryColor,
                                          minimumSize: const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Apply Filters',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Color(0xffF8F8F8),
                          shape: BoxShape.circle,
                          image: DecorationImage(image: AssetImage('assets/filter1.png'), scale: 4),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: specialistImages2.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TopSpecialistCardTwo(
                          imagePath: specialistImages2[index],
                          onBook: () {},
                          specialistName: specialistNames2[index],
                        ),
                      );
                    },
                  ),
                ),
                Divider(
                  color: kGreyColor2,
                ),
                SizedBox(
                  height: 15,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SaloonCardTwo(),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
