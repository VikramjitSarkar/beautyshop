import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/user/auth_screens/phone_input_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  TextEditingController phoneController = TextEditingController();
  bool isChecked = false;

  @override
  void initState() {
    super.initState();

    // Listener to update button state when text changes
    phoneController.addListener(() {
      setState(() {});
    });
  }

  bool get isButtonEnabled {
    return phoneController.text.isNotEmpty && isChecked;
  }

  @override
  Widget build(BuildContext context) {
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
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Text('Your phone!', style: kHeadingStyle),
              const SizedBox(height: 10),
              Text(
                'You will receive a 4 digit code for phone verification number',
                style: kSubheadingStyle,
              ),
              const SizedBox(height: 20),

              // Phone Number Field
              CustomTextField(
                hintText: "Phone number",
                controller: phoneController,
                inputType: TextInputType.phone,
                prefixIcon: Image.asset('assets/flag.png'),
              ),
              const SizedBox(height: 10),

              // Checkbox Row
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: Color(0xFFC0C0C0)),
                    activeColor: kPrimaryColor, // Primary color
                    checkColor: Colors.white, // Tick color
                  ),
                  const SizedBox(width: 5),

                  // "I agree with" text
                  Text("I agree with ", style: kSubheadingStyle),

                  // "Terms and Privacy" Bold Text
                  GestureDetector(
                    onTap: () {
                      // Handle Terms & Privacy navigation
                    },
                    child: Text(
                      "Terms and Privacy",
                      style: kSubheadingStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              CustomButton(
                title: "Verify",
                isEnabled: isButtonEnabled,
                onPressed: () {
                  if (isButtonEnabled) {
                    Get.to(() => PhoneNumberInputScreen());
                  }
                },
              ),
              const SizedBox(height: 30),

              // OR Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/line.png'),
                  const SizedBox(width: 5),
                  Text('or', style: kSubheadingStyle),
                  const SizedBox(width: 5),
                  Image.asset('assets/line.png'),
                ],
              ),
              const SizedBox(height: 30),

              // Continue with Google
              ActionButton(
                title: "Continue with Google",
                onPressed: () {},
                icon: 'google',
              ),
              const SizedBox(height: 10),

              // Continue with Apple
              ActionButton(
                title: "Continue with Apple",
                onPressed: () {},
                icon: 'apple',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
