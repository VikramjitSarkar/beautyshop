import 'package:beautician_app/utils/libs.dart';
class GroupTabScreen extends StatelessWidget {
  const GroupTabScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      shrinkWrap: true,
      itemCount: 10, // Added a placeholder count
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Container(
            height: 64,
            child: Row(
              children: [
                // Profile Image with Indicator
                Container(
                  height: 66,
                  width: 66,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black
                  ),
                ),
                const SizedBox(width: 10),

                // Name & Message Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Bessie Cooper',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Sed ut perspiciatis unde omnis iste natus error sit voluptatem',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: kGreyColor, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 4),

                      // Avatar Stack
                      SizedBox(
                        height: 22, // Adjusted height to fit avatars
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(image: AssetImage('assets/layers.png'),fit: BoxFit.fill)
                                ),
                              ),
                            ),
                            Positioned(
                              left: 15,
                              child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: AssetImage('assets/layers.png'),fit: BoxFit.fill)
                                ),
                              ),
                            ),
                            Positioned(
                              left: 30,
                              child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: AssetImage('assets/layers.png'),fit: BoxFit.fill)
                                ),
                              ),
                            ),
                            Positioned(
                              left: 45,
                              child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: AssetImage('assets/layers.png'),fit: BoxFit.fill)
                                ),
                              ),
                            ),
                            Positioned(
                              left: 60,
                              child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  color: Colors.black
                                ),
                                alignment: Alignment.center,
                                child: Text('1k+',style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 8,
                                ),),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Time & Notification Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '3:50 pm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kGreyColor),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 18,
                      width: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '1',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}