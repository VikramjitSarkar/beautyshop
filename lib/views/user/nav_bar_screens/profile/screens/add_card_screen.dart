import 'package:beautician_app/utils/libs.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _setAsDefault = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

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
          'Add card',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            CustomTextField(
                controller: _cardNumberController,
                hintText: 'Card number',
                inputType: TextInputType.number,
                prefixIcon: Icon(Icons.credit_card)
            ),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _cardHolderController,
                hintText: 'Card holder name',
                inputType: TextInputType.name,
                prefixIcon: Icon(Icons.person_outline)
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                      controller: _expiryController,
                      hintText: 'Exp. date',
                      inputType: TextInputType.datetime,
                      prefixIcon: Icon(Icons.calendar_today)
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _cvvController,
                    hintText: 'CVV',
                    inputType: TextInputType.number,
                    prefixIcon: Icon(Icons.lock_outline),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Checkbox(
                  value: _setAsDefault,
                  onChanged: (value) {
                    setState(() {
                      _setAsDefault = value ?? false;
                    });
                  },
                  activeColor: kPrimaryColor,
                ),
                const Text(
                  'Set as default payment method',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Handle card addition
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
                  'Add card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}