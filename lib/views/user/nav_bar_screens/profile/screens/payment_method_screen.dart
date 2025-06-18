import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/nav_bar_screens/profile/screens/add_card_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/back icon.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              children: [
                _PaymentMethodItem(
                  icon: 'assets/paypal.png',
                  title: 'PayPal',
                  onTap: () {
                    // Handle PayPal selection
                  },
                ),
                const SizedBox(height: 12),
                _PaymentMethodItem(
                  icon: 'assets/master_card.png',
                  title: 'Master card',
                  onTap: () {
                    // Handle Mastercard selection
                  },
                ),
                const SizedBox(height: 12),
                _PaymentMethodItem(
                  icon: 'assets/visa.png',
                  title: 'Visa',
                  onTap: () {
                    // Handle Visa selection
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ElevatedButton(
              onPressed: () {
                Get.to(()=> AddCardScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add payment method',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodItem extends StatelessWidget {
  final String icon;
  final String title;
  final void Function()? onTap;

  const _PaymentMethodItem({
    required this.icon,
    required this.title,
     this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: kGreyColor2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}