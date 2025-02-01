import 'dart:async';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'package:client_flutter/services/user/user_service.dart';
import 'package:client_flutter/services/email/email_service.dart';
import 'package:client_flutter/widgets/custom_text_field.dart';
import 'package:client_flutter/widgets/custom_text_form_field.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _userService = UserService();
  final _emailService = EmailService();

  int _currentStep = 0;

  Timer? _timer;
  int _remainingTime = 180;

  final Map<String, bool> _agreementStatus = {
    'all': false,
    'terms': false,
    'privacy': false,
  };

  final Map<String, bool> _verificationStatus = {
    'username': false,
    'password': false,
    'nickname': false,
    'email': false,
  };

  final _controllers = {
    'username': TextEditingController(),
    'password': TextEditingController(),
    'nickname': TextEditingController(),
    'email': TextEditingController(),
    'certificationNumber': TextEditingController(),
  };

  final ValueNotifier<Map<String, bool>> _isButtonEnabled = ValueNotifier({
    'username': false,
    'nickname': false,
    'email': false,
    'emailSend': false,
    'certificationNumber': false,
  });

  @override
  void initState() {
    super.initState();
    _initializeListeners();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });

    _isButtonEnabled.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Column(
            children: [
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                    dividerColor: Colors.transparent
                  ),
                  child: Stepper(
                    elevation: 0,
                    currentStep: _currentStep,
                    onStepContinue: _nextStep,
                    onStepCancel: _prevStep,
                    controlsBuilder: (context, details) => const SizedBox.shrink(),
                    type: StepperType.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    steps: _buildSteps(),
                  ),
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    setState(() {
      _currentStep += 1;
    });
  }

  void _prevStep() {
    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _onFinish() async {
    try {
      await _userService.registerUser(
        username: _controllers['username']!.text,
        password: _controllers['password']!.text,
        nickname: _controllers['nickname']!.text,
        email: _controllers['email']!.text,
      );
      Navigator.of(context).pop();
    } on DioException catch (error) {
      _showSnackBar(error.message!);
    }
  }

  Future<void> _checkUsernameAvailability() async {
    await _userService.isUsernameTaken(username: _controllers['username']!.text).then((isTaken) {
      _showSnackBar(isTaken ? '이미 사용 중인 아이디입니다.' : '사용 가능한 아이디입니다.');
      setState(() {
        _verificationStatus['username'] = !isTaken;
        _verificationStatus['password'] = !isTaken;
      });
    }).catchError((error) {
      if (error is DioException) {
        _showSnackBar(error.message!);
      }
    });
  }

  Future<void> _checkNicknameAvailability() async {
    await _userService.isNicknameTaken(nickname: _controllers['nickname']!.text).then((isTaken) {
      _showSnackBar(isTaken ? '이미 사용 중인 닉네임입니다.' : '사용 가능한 닉네임입니다.');
      setState(() => _verificationStatus['nickname'] = !isTaken);
    }).catchError((error) {
      if (error is DioException) {
        _showSnackBar(error.message!);
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    await _emailService.sendCertificationEmail(email: _controllers['email']!.text).then((_) {
      _showSnackBar('인증 코드가 전송되었습니다.');
      _isButtonEnabled.value['emailSend'] = true;
      _isButtonEnabled.value = Map.from(_isButtonEnabled.value);
      _startTimer();
    }).catchError((error) {
      if (error is DioException) {
        _showSnackBar(error.message!);
      }
    });
  }

  Future<void> _checkCertificationNumber() async {
    await _emailService.checkCertificationNumber(
      email: _controllers['email']!.text,
      certificationNumber: _controllers['certificationNumber']!.text,
    ).then((value) {
      _showSnackBar('인증이 완료되었습니다.');
      setState(() => _verificationStatus['email'] = true);
      _timer?.cancel();
    }).catchError((error) {
      if (error is DioException) {
        _showSnackBar(error.message!);
      }
    });
  }

  void _initializeListeners() {
    _controllers['username']!.addListener(() => _updateButtonEnabled('username'));
    _controllers['nickname']!.addListener(() => _updateButtonEnabled('nickname'));
    _controllers['email']!.addListener(() => _updateButtonEnabled('email'));
  }

  void _updateButtonEnabled(String key) {
    _isButtonEnabled.value[key] = _controllers[key]!.text.isNotEmpty;
    _isButtonEnabled.value = Map.from(_isButtonEnabled.value);
  }

  void _startTimer() {
    _remainingTime = 180;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1), 
      (timer) {
        if (_remainingTime > 0) {
          setState(() {
            _remainingTime--;
          });
        } else {
          timer.cancel();
          setState(() {
            _isButtonEnabled.value['emailSend'] = false;
          });
        }
      }
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(milliseconds: 500)),
    );
  }

  bool _isNextButtonEnabled() {
    switch (_currentStep) {
      case 0:
        return _agreementStatus['terms']! && _agreementStatus['privacy']!;
      case 1:
        return _verificationStatus['username']! && _verificationStatus['password']!;
      case 2:
        return _verificationStatus['nickname']!;
      case 3:
        return _isButtonEnabled.value['emailSend']! && _verificationStatus['email']!;
      default:
        return false;
    }
  }

  List<Step> _buildSteps() {
    return [
      _buildStep(
        content: _buildAgreementSection(),
        index: 0,
      ),
      _buildStep(
        content: _buildAccountInfoSection(),
        index: 1,
      ),
      _buildStep(
        content: _buildProfileSection(),
        index: 2,
      ),
      _buildStep(
        content: _buildEmailVerificationSection(),
        index: 3,
      ),
    ];
  }

  Step _buildStep({
    required Widget content,
    required int index,
  }) {
    return Step(
      stepStyle: StepStyle(
        color: Colors.blue
      ),
      title: const SizedBox.shrink(),
      content: content,
      isActive: _currentStep >= index,
      state: _currentStep == index ? StepState.editing : StepState.complete,
    );
  }

  Widget _buildAgreementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '환영합니다!\n우선, 약관 동의가 필요해요',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ..._buildCheckboxRows(),
      ],
    );
  }

  List<Widget> _buildCheckboxRows() {
    return [
      _buildCheckboxRow('all', '전체 동의', _toggleAllAgreements),
      _buildCheckboxRow('terms', '이용약관 동의(필수)', _toggleSingleAgreement),
      _buildCheckboxRow('privacy', '개인정보 수집 동의(필수)', _toggleSingleAgreement),
    ];
  }

  Widget _buildCheckboxRow(String key, String label, void Function(String, bool) onChanged) {
    return Row(
      children: [
        Checkbox(
          activeColor: Colors.blue,
          value: _agreementStatus[key],
          onChanged: (value) => onChanged(key, value!),
        ),
        GestureDetector(onTap: () => onChanged(key, !_agreementStatus[key]!), child: Text(label)),
      ],
    );
  }

  void _toggleAllAgreements(String key, bool value) {
    setState(() {
      _agreementStatus['all'] = value;
      _agreementStatus['terms'] = value;
      _agreementStatus['privacy'] = value;
    });
  }

  void _toggleSingleAgreement(String key, bool value) {
    setState(() {
      _agreementStatus[key] = value;
      _agreementStatus['all'] = _agreementStatus['terms']! && _agreementStatus['privacy']!;
    });
  }

  Widget _buildAccountInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '계정 정보를\n입력해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _controllers['username']!, 
          keyboardType: TextInputType.text, 
          textInputAction: TextInputAction.next,
          hintText: '아이디',
          onButtonPressed: _checkUsernameAvailability,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          hintText: '비밀번호', 
          controller: _controllers['password']!,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '나머지 정보도\n입력해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _controllers['nickname']!, 
          keyboardType: TextInputType.text, 
          textInputAction: TextInputAction.done,
          hintText: '닉네임',
          onButtonPressed: _checkNicknameAvailability,
        ),
      ],
    );
  }

  Widget _buildEmailVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일을\n인증해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _controllers['email']!, 
          keyboardType: TextInputType.emailAddress, 
          textInputAction: TextInputAction.next,
          hintText: '이메일',
          onButtonPressed: _sendVerificationEmail,
        ),
        const SizedBox(height: 16),
        Visibility(
          visible: _isButtonEnabled.value['emailSend']!,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: Column(
            children: [
              CustomTextField(
                controller: _controllers['certificationNumber']!, 
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done, 
                hintText: '인증번호',
                onButtonPressed: _checkCertificationNumber,
              ),
              const SizedBox(height: 16),
              if (!_verificationStatus['email']!) 
                Text(
                  '남은 시간: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    bool isNextDisabled = !_isNextButtonEnabled();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: IconButton(
                iconSize: 32,
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
            ),
          const Spacer(),
          if (_currentStep < 3)
            CircleAvatar(
              radius: 30,
              backgroundColor: isNextDisabled ? Colors.grey : Colors.blue,
              child: IconButton(
                iconSize: 32,
                onPressed: isNextDisabled ? null : _nextStep,
                icon: const Icon(Icons.arrow_forward),
                color: Colors.white,
              ),
            ),
          if (_currentStep == 3)
            CircleAvatar(
              radius: 30,
              backgroundColor: isNextDisabled ? Colors.grey : Colors.blue,
              child: IconButton(
                iconSize: 32,
                onPressed: isNextDisabled ? null : _onFinish,
                icon: const Icon(Icons.check),
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

}
