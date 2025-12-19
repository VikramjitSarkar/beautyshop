import 'dart:io';
import 'package:beautician_app/utils/libs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../controllers/vendors/auth/profile_setup_Controller.dart'
    show ProfileSetupController;
import '../../../services/auths_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _otpController = TextEditingController();

  String? _selectedGender;
  File? _certificationImage;
  File? _idImage;

  DateTime? _selectedDob;
  int? _calculatedAge;

  String _fullPhoneNumber = '';
  String _fullWhatsappNumber = '';
  bool _isOtpSent = false;
  bool _isPhoneVerified = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  
  final AuthService _authService = AuthService();

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20), // default 20 years old
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _calculatedAge = _calculateAge(picked);
        _ageController.text = _calculatedAge.toString(); // store internally
      });
    }
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }


  final ImagePicker _picker = ImagePicker();
  final ProfileSetupController _controller = Get.put(ProfileSetupController());

  Future<void> _sendOtp() async {
    if (_fullPhoneNumber.isEmpty || _phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    final success = await _authService.sendOtp(_fullPhoneNumber);
    
    setState(() => _isSendingOtp = false);

    if (success) {
      setState(() => _isOtpSent = true);
      Get.snackbar(
        'Success',
        'OTP sent to your phone number',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    
    if (code.isEmpty || code.length < 4) {
      Get.snackbar(
        'Error',
        'Please enter the 4-digit code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    final success = await _authService.verifyOtp(_fullPhoneNumber, code);
    
    setState(() => _isVerifyingOtp = false);

    if (success) {
      setState(() => _isPhoneVerified = true);
      Get.snackbar(
        'Success',
        'Phone number verified successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickIdImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _idImage = File(image.path));
      Get.snackbar('Success', 'ID image uploaded successfully');
    }
  }

  Future<void> _pickCertificationImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _certificationImage = File(image.path));
      Get.snackbar('Success', 'Certification uploaded successfully');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<bool> _handleBackPressed() async {
    if (_phoneController.text.trim().isEmpty ||
        _whatsappController.text.trim().isEmpty) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Discard Application?'),
              content: const Text(
                'Are you sure you want to discard the application?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes, Discard'),
                ),
              ],
            ),
      );
      return shouldExit ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: const Text('Profile Setup'),
              leading: Row(
                children: [
                  GestureDetector(
                    child: SvgPicture.asset('assets/back icon.svg', height: 50,),
                    onTap: () async {
                      final shouldPop = await _handleBackPressed();
                      if (shouldPop) Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Name',
                  radius: 20,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your name'
                              : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _surnameController,
                  hintText: 'Surname',
                  radius: 20,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your surname'
                              : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFFC0C0C0),
                        width: 1.5,
                      ),
                    ),
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFFC0C0C0),
                        width: 1.5,
                      ),
                    ),
                  ),
                  value: _selectedGender,
                  items:
                      ['Male', 'Female', 'Other']
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select your gender'
                              : null,
                ),
                const SizedBox(height: 16),
                
                // Phone Number Section with Country Code
                Text(
                  'Phone Number *',
                  style: kHeadingStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Required)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: _isPhoneVerified ? Colors.green : const Color(0xFFC0C0C0),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: _isPhoneVerified ? Colors.green : const Color(0xFFC0C0C0),
                        width: 1.5,
                      ),
                    ),
                  ),
                  initialCountryCode: 'PK',
                  enabled: !_isPhoneVerified,
                  onChanged: (phone) {
                    setState(() {
                      _fullPhoneNumber = phone.completeNumber;
                      _phoneController.text = phone.number;
                      _isOtpSent = false;
                      _isPhoneVerified = false;
                    });
                  },
                  validator: (value) {
                    if (_phoneController.text.isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                
                if (!_isPhoneVerified) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSendingOtp || _phoneController.text.isEmpty) 
                          ? null 
                          : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isSendingOtp
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Send Code',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],

                if (_isOtpSent && !_isPhoneVerified) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _otpController,
                    hintText: 'Enter 4-digit code',
                    inputType: TextInputType.number,
                    radius: 20,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifyingOtp ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifyingOtp
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],

                if (_isPhoneVerified)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Phone number verified',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // WhatsApp Number Section with Country Code (Optional)
                Text(
                  'WhatsApp Number (Optional)',
                  style: kHeadingStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'WhatsApp Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFFC0C0C0),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFFC0C0C0),
                        width: 1.5,
                      ),
                    ),
                  ),
                  initialCountryCode: 'PK',
                  onChanged: (phone) {
                    setState(() {
                      _fullWhatsappNumber = phone.completeNumber;
                      _whatsappController.text = phone.number;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _pickDateOfBirth(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: TextEditingController(
                        text: _selectedDob != null
                            ? "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}"
                            : '',
                      ),
                      hintText: 'Select Date of Birth',
                      radius: 20,
                      validator: (value) {
                        if (_selectedDob == null) return 'Please select your date of birth';
                        return null;
                      },
                      suffixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // ID Upload Section
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kGreyColor2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Upload ID'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: _pickIdImage,
                      ),
                      if (_idImage != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _idImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Certification Upload Section
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kGreyColor2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Upload Certification'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: _pickCertificationImage,
                      ),
                      if (_certificationImage != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _certificationImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Obx(
                  () => CustomButton(
                    title: 'Continue',
                    isEnabled: !_controller.isLoading.value && _isPhoneVerified,
                    isLoading: _controller.isLoading.value,
                    onPressed: () {
                      if (!_isPhoneVerified) {
                        Get.snackbar(
                          'Verification Required',
                          'Please verify your phone number before continuing.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        if (_certificationImage == null) {
                          Get.snackbar(
                            'Missing Certification',
                            'Please upload your certification image.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        _controller.submitProfile(
                          name: _nameController.text.trim(),
                          surname: _surnameController.text.trim(),
                          age: _calculatedAge?.toString() ?? '', // computed age
                          gender: _selectedGender!.toLowerCase(),
                          cnic: _idImage!, // optional
                          license: _certificationImage!,
                          phone: _fullPhoneNumber,
                          whatsapp: _fullWhatsappNumber.isEmpty 
                              ? _whatsappController.text.trim() 
                              : _fullWhatsappNumber,
                        );

                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
