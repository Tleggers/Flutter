import 'dart:io';

import 'package:flutter/material.dart';
import '../../../services/jh/Signup/checkdupemail.dart';
import '../../../services/jh/Signup/checkdupid.dart';
import '../../../services/jh/Signup/signup.dart';
import '../../../services/jh/Signup/verifyauthcode.dart';
import '../../../widgets/jh/Signup/signupauthcodeinput.dart';
import '../../../widgets/jh/Signup/signupconfirmpwinput.dart';
import '../../../widgets/jh/Signup/signupemailinput.dart';
import '../../../widgets/jh/Signup/signupidinput.dart';
import '../../../widgets/jh/Signup/signupnicknameinput.dart';
import '../../../widgets/jh/Signup/signupprofile.dart';
import '../../../widgets/jh/Signup/signuppwinput.dart';

// 회원가입 페이지
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // 각 요소들 입력 컨트롤러
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwCheckController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();

  // 정규식 통과 확인용 변수
  bool isValidId = false; // id 정규식이 통과하면 true 아니면 false
  bool isValidPw = false; // 비밀번호 정규식이 통과하면 true 아니면 false
  bool isSamePw = false; // 비밀번호랑 비밀번호 확인이랑 똑같으면 true 아니면 false
  bool isValidNickname = false; // 닉네임 정규식 확인
  bool isValidEmail = false; // 이메일 정규식 확인

  // 인증 통과 확인용 변수
  bool isCheckDupId = false; // id 중복 확인이 성공하면 true, 아니면 false
  bool isCheckDupEmail = false; // 이메일 중복 확인이 성공하면 true, 아니면 false
  bool isCheckDupNickName = false; // 닉네임 중복 확인이 성공하면 true, 아니면 false

  // id 확인용 변수
  String? idCheckMessage; // 메시지 띄울 때 사용할 변수
  Color? idCheckColor; // 그 메시지의 색깔

  // nickname 확인용 변수
  String? nicknameCheckMessage; // 출력 메시지
  Color? nicknameCheckColor; // 메시지 색깔

  // email 확인용 변수
  String? emailCheckMessage; // 출력 메시지
  Color? emailCheckColor; // 메시지 색깔
  bool isCheckEmail = false; // 이메일 인증 확인

  // 선택한 이미지를 백엔드로 전달하기 위해 선언한 변수
  File? _profileImage;

  // id 정규식
  void validateId(String input) {
    final regex = RegExp(r'^[a-zA-Z0-9]{1,16}$');
    final isValidFormat = regex.hasMatch(input);
    final isAdminBlocked = input.toLowerCase() == 'admin'; // admin은 사용 불가

    setState(() {
      isValidId = isValidFormat && !isAdminBlocked;
      isCheckDupId = false;
      idCheckMessage =
          input.isEmpty
              ? null
              : (!isValidFormat
                  ? '아이디 형식이 올바르지 않습니다.'
                  : (isAdminBlocked ? '사용할 수 없는 아이디입니다.' : null));
      idCheckColor = isValidFormat ? null : Colors.red;
    });
  }

  // 비밀번호 정규식
  void validatePw(String input) {
    final regex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#%^&*])[A-Za-z\d!@#%^&*]{1,16}$',
    );
    final isValid = regex.hasMatch(input);
    final isAdminBlocked = input.toLowerCase() == 'admin'; // admin은 사용 불가

    setState(() {
      isValidPw = isValid && !isAdminBlocked;
      isSamePw = _pwCheckController.text == input;
    });
  }

  // 비밀번호 확인 -> 비밀번호랑 비밀번호 확인이랑 동일하면 true
  void validatePwCheck(String input) {
    setState(() {
      isSamePw = _pwController.text == input;
    });
  }

  // 이메일 정규식 확인
  bool validateEmail(String input) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final isValid = regex.hasMatch(input);

    setState(() {
      isValidEmail = isValid;
      emailCheckMessage =
          input.isEmpty ? null : (isValid ? null : '이메일 형식이 올바르지 않습니다.');
      emailCheckColor = isValid ? null : Colors.red;
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close), // X 아이콘
          onPressed: () {
            Navigator.pop(context); // <- 이전 페이지로 돌아가기
          },
        ),
        title: const Text("회원가입"),
      ),

      // singleChildScrollView쓰는 이유 -> 입력창을 클릭했을 때 밑에가 짤릴 수 있어서
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            // 아이디 입력창
            SignupIdInput(
              idController: _idController, // 아이디 입력 컨트롤러
              isValidId: isValidId, // 정규식 통과 여부
              idCheckMessage: idCheckMessage, // 메세지 출력
              idCheckColor: idCheckColor, // 메세지 색깔
              onChanged: validateId, // onChange 될 때마다 정규식 비교 진행
              // 서버쪽으로 입력값 전달 -> DB 비교 -> 사용 가능하면 true리턴, 아니면 false리턴
              // 그 리턴 값을 isAvailable에 넣기 -> isAvailable이 true나 false일 때 각각의 메시지 출력
              onCheckDupId: (id) async {
                // 만약 값이 비어있으면 snakeBar 띄우고 return(서버 과부화 방지)
                if (id.trim().isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('값이 입력되지 않았습니다.')),
                    );
                  }
                  return false; // 바로 종료
                }

                try {
                  final isAvailable = await checkDupId(id);
                  setState(() {
                    isCheckDupId = isAvailable;
                    idCheckMessage =
                        isAvailable ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.';
                    idCheckColor = isAvailable ? Colors.green : Colors.red;
                  });
                  return isAvailable; // onCheckDupId가 bool 타입이라 리턴 필요
                } catch (e) {
                  setState(() {
                    idCheckMessage = '서버 오류가 발생했습니다';
                    idCheckColor = Colors.orange;
                  });
                  return false;
                }
              },
            ),

            SizedBox(height: screenHeight * 0.02),

            // 비밀번호
            SignupPwInput(
              pwController: _pwController, // 입력 컨트롤러
              isValidPw: isValidPw, // 정규식 체크
              onChanged: validatePw, // onChange 될 때마다 정규식 비교
              // 입력값이 있을 때만 메세지가 나오고 아니면 안 나오게
              pwCheckMessage:
                  _pwController.text.isNotEmpty
                      ? (isValidPw
                          ? '*사용 가능한 비밀번호입니다.'
                          : '*영문+숫자+특수문자 조합, 16자이하여야 합니다.')
                      : '',
              pwCheckColor: isValidPw ? Colors.green : Colors.red,
            ),

            SizedBox(height: screenHeight * 0.015),

            // 비밀번호 확인
            SignupPwCheckInput(
              pwCheckController: _pwCheckController,
              isSamePw: isSamePw,
              onChanged: validatePwCheck,
              pwCheckMessage:
                  _pwCheckController.text.isNotEmpty
                      ? (isSamePw ? '*비밀번호가 일치합니다.' : '*비밀번호가 일치하지 않습니다.')
                      : '',
              pwCheckColor: isSamePw ? Colors.green : Colors.red,
            ),

            SizedBox(height: screenHeight * 0.02),

            // 닉네임
            SignupNicknameInput(
              nicknameController: _nicknameController,
              nicknameCheckMessage: nicknameCheckMessage,
              nicknameCheckColor: nicknameCheckColor,
              validateNickname: (input) {
                final regex = RegExp(r'^[a-zA-Z0-9가-힣]{1,16}$');
                final trimmed = input.trim();
                final isValid = trimmed.isEmpty || regex.hasMatch(trimmed);

                setState(() {
                  isValidNickname = isValid;
                  nicknameCheckMessage =
                      trimmed.isEmpty
                          ? null
                          : (isValid ? null : '닉네임 형식이 올바르지 않습니다.');
                  nicknameCheckColor = isValid ? null : Colors.red;
                });

                return isValid;
              },
            ),

            SizedBox(height: screenHeight * 0.02),

            // 이메일
            SignupEmailInput(
              emailController: _emailController,
              onRequestVerification: (email) async {
                final result = await checkDupEmail(email); // <- bool 반환
                return result;
              },
              validateEmail: validateEmail,
              emailCheckMessage: emailCheckMessage,
              emailCheckColor: emailCheckColor,
            ),

            SizedBox(height: screenHeight * 0.02),

            // 이메일 인증코드
            SignupAuthCodeInput(
              emailCodeController: _emailCodeController,
              emailController: _emailController,
              onConfirm: (email, code) async {
                return await verifyAuthCode(email, code); // bool 반환
              },
              onVerificationResult: (isVerified) {
                setState(() {
                  isCheckEmail = isVerified;
                });
              },
            ),

            SizedBox(height: screenHeight * 0.02),

            // 프로필 사진 위치
            Column(
              children: [
                ProfileImagePicker(
                  onImageSelected: (image) {
                    setState(() {
                      _profileImage = image;
                    });
                  },
                ),
              ],
            ),

            // 가입 버튼
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: OutlinedButton(
                onPressed: () async {
                  final id = _idController.text.trim(); // 아이디
                  final pw = _pwController.text; // 비밀번호
                  final nickname = _nicknameController.text.trim(); // 닉네임
                  final email = _emailController.text.trim(); // 이메일

                  // 1. 입력값 비어 있는지 확인
                  if (id.isEmpty || pw.isEmpty || email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('모든 정보를 입력하십시오.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  if (!isValidId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('해당 아이디는 사용 불가능합니다.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  // 2. 아이디 중복 확인 실패
                  if (!isCheckDupId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('해당 아이디는 사용 불가능합니다.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  if (!isValidPw) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('해당 비밀번호는 사용 불가능합니다.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  // 3. 비밀번호 불일치
                  if (!isSamePw) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('해당 비밀번호는 사용 불가능합니다.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  // 4. 이메일 인증 실패
                  if (!isCheckEmail) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('이메일 인증을 받으십시오.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  // 만약 사진이 있을 때
                  // 사진 크기를 체크 -> 10MB 이상이면 사용 불가능
                  if (_profileImage != null) {
                    final fileSizeInBytes = await _profileImage!.length();
                    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

                    if (fileSizeInMB > 10) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이미지 크기가 10MB를 초과합니다.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                  }

                  // 5. 모든 조건 통과 시 회원가입 진행
                  final success = await signUp(
                    id: id,
                    pw: pw,
                    nickname: nickname,
                    email: email,
                    profileImage: _profileImage,
                  );

                  if (!mounted) return;

                  if (success) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원가입이 완료되었습니다!')),
                    );
                    Navigator.pop(context);
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.blue),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
