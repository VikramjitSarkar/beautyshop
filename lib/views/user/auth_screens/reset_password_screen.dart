import 'package:beautician_app/utils/libs.dart';
import '../../../controllers/users/auth/resetPasswordController.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ResetPasswordController controller = Get.put(ResetPasswordController());

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
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset Password', style: kHeadingStyle),
              const SizedBox(height: 10),
              Text(
                'Enter the token from your email and your new password.',
                style: kSubheadingStyle,
              ),
              const SizedBox(height: 25),
              CustomTextField(
                hintText: "Reset Token",
                controller: controller.tokenController,
                inputType: TextInputType.text,
                prefixIcon: Icon(Icons.vpn_key),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: "New Password",
                controller: controller.newPasswordController,
                inputType: TextInputType.text,
                prefixIcon: Image.asset('assets/password.png'),
              ),
              const SizedBox(height: 25),
              Obx(
                () =>
                    controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator(color: Colors.white,))
                        : CustomButton(
                          isEnabled: true,
                          title: "Continue",
                          onPressed: controller.resetPassword,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
