import 'package:flutter/material.dart';
import '../../../functions/jh/timer.dart';
import '../../../services/jh/FindIdAndPassword/findpwservice.dart';
import '../../../widgets/jh/FindIdAndPassword/findpwauthcodeinput.dart';
import '../../../widgets/jh/FindIdAndPassword/findpwemailinput.dart';
import '../../../widgets/jh/FindIdAndPassword/findpwform.dart';
import '../../../widgets/jh/FindIdAndPassword/findpwidinput.dart';
import '../Login_and_Signup/login.dart';
import 'findidpage.dart';

class FindPwPage extends StatefulWidget {
  const FindPwPage({super.key});

  @override
  State<FindPwPage> createState() => _FindPwPageState();
}

class _FindPwPageState extends State<FindPwPage> {
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  final _authTimer = AuthTimer();

  bool _isValidId = false;
  bool _isValidEmail = false;
  bool _isValidPw = false;
  bool _isSamePw = false;

  String? _idCheckMessage;
  String? _emailCheckMessage;

  bool _showCodeField = false;
  bool _showResetPwFields = false;

  bool _obscureNewPw = true;
  bool _obscureConfirmPw = true;

  void validateId(String input) {
    final regex = RegExp(r'^[a-zA-Z0-9]{1,16}$');
    final isValidFormat = regex.hasMatch(input);
    final isAdminBlocked = input.toLowerCase() == 'admin';

    setState(() {
      _isValidId = isValidFormat && !isAdminBlocked;
      _idCheckMessage = input.isEmpty
          ? null
          : (!isValidFormat
          ? '아이디 형식이 올바르지 않습니다.'
          : (isAdminBlocked ? '사용할 수 없는 아이디입니다.' : null));
    });
  }

  void validateEmail(String input) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final isValid = regex.hasMatch(input);

    setState(() {
      _isValidEmail = isValid;
      _emailCheckMessage = input.isEmpty
          ? null
          : (isValid ? null : '이메일 형식이 올바르지 않습니다.');
    });
  }

  void validatePw(String input) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#%^&*])[A-Za-z\d!@#%^&*]{1,16}$');
    final isValid = regex.hasMatch(input);
    final isAdminBlocked = input.toLowerCase() == 'admin';

    setState(() {
      _isValidPw = isValid && !isAdminBlocked;
      _isSamePw = _confirmPwController.text == input;
    });
  }

  void validatePwCheck(String input) {
    setState(() {
      _isSamePw = _newPwController.text == input;
    });
  }

  @override
  void dispose() {
    _authTimer.cancel();
    _idController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 찾기', style: TextStyle(fontSize: screenWidth * 0.045)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(), // ← LoginPage로 이동
              ),
                  (Route<dynamic> route) => false, // 모든 이전 스택 제거
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find your Password', style: TextStyle(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold)),
            SizedBox(height: screenHeight * 0.04),

            Text('아이디', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035)),
            SizedBox(height: screenHeight * 0.005),
            IdInput(
              controller: _idController,
              onChanged: validateId,
              isValid: _isValidId,
              errorText: _idCheckMessage,
            ),
            SizedBox(height: screenHeight * 0.03),

            Text('이메일', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035)),
            SizedBox(height: screenHeight * 0.005),
            EmailInput(
              controller: _emailController,
              errorText: _emailCheckMessage,
              onChanged: validateEmail,
            ),
            SizedBox(height: screenHeight * 0.01),

            /// ✅ 인증번호 전송 버튼 & 타이머 한 줄로 정렬
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_showCodeField)
                  Text(
                    '남은 시간: ${_authTimer.formattedTime}',
                    style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.035),
                  )
                else
                  const SizedBox(), // 자리 차지용

                TextButton(
                  onPressed: (_isValidId && _isValidEmail)
                      ? () async {
                    setState(() => _showCodeField = true);
                    _authTimer.start(() => setState(() {}));
                    await sendMail(context, _emailController.text.trim(), _idController.text.trim());
                  }
                      : null,
                  child: const Text('인증번호전송', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),

            if (_showCodeField) ...[
              SizedBox(height: screenHeight * 0.02),
              Text('인증번호', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035)),
              SizedBox(height: screenHeight * 0.005),
              AuthCodeInput(
                controller: _codeController,
                email: _emailController.text.trim(),
                onVerified: () {
                  _authTimer.cancel();
                  setState(() => _showResetPwFields = true);
                },
              ),
              SizedBox(height: screenHeight * 0.03),
            ],

            if (_showResetPwFields)
              ResetPasswordFields(
                newPwController: _newPwController,
                confirmPwController: _confirmPwController,
                isValidPw: _isValidPw,
                isSamePw: _isSamePw,
                obscureNewPw: _obscureNewPw,
                obscureConfirmPw: _obscureConfirmPw,
                toggleNewPw: () => setState(() => _obscureNewPw = !_obscureNewPw),
                toggleConfirmPw: () => setState(() => _obscureConfirmPw = !_obscureConfirmPw),
                onPwChanged: (val) {
                  validatePw(val);
                  validatePwCheck(_confirmPwController.text);
                },
                onPwCheckChanged: validatePwCheck,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onSubmit: () async {
                  final success = await resetPassword(
                    _idController.text.trim(),
                    _newPwController.text.trim(),
                    context,
                  );

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),

            SizedBox(height: screenHeight * 0.03),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                  child: Text('로그인', style: TextStyle(fontSize: screenWidth * 0.035)),
                ),
                SizedBox(width: screenWidth * 0.06),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FindIdPage())),
                  child: Text('아이디 찾기', style: TextStyle(fontSize: screenWidth * 0.035)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}