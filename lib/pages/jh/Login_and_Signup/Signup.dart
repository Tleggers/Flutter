import 'dart:io';

import 'package:flutter/material.dart';
import '../../../services/jh/Signup/CheckDupEmail.dart';
import '../../../services/jh/Signup/CheckDupId.dart';
import '../../../services/jh/Signup/CheckDupNickName.dart';
import '../../../services/jh/Signup/Signup.dart';
import '../../../services/jh/Signup/VerifyAuthCode.dart';
import '../../../widgets/jh/Signup/SignupAuthCodeInput.dart';
import '../../../widgets/jh/Signup/SignupConfirmPwInput.dart';
import '../../../widgets/jh/Signup/SignupEmailInput.dart';
import '../../../widgets/jh/Signup/SignupIdInput.dart';
import '../../../widgets/jh/Signup/SignupNickNameInput.dart';
import '../../../widgets/jh/Signup/SignupProfile.dart';
import '../../../widgets/jh/Signup/SignupPwInput.dart';

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

  // 선택한 이미지를 백엔드로 전달하기 위해 선언한 변수
  File? _profileImage;

  // id 정규식
  void validateId(String input) {
    final regex = RegExp(r'^[a-zA-Z0-9]{1,16}$');
    setState(() {
      isValidId = regex.hasMatch(input);
      idCheckMessage = null;
      isCheckDupId = false; // 아이디 변경 시 중복 확인 초기화
    });
  }

  // 비밀번호 정규식
  void validatePw(String input) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#%^&*])[A-Za-z\d!@#%^&*]{1,16}$');

    final isValid = regex.hasMatch(input);

    setState(() {
      isValidPw = isValid;
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
      emailCheckMessage = input.isEmpty
          ? null
          : (isValid ? null : '이메일 형식이 올바르지 않습니다.');
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

              // 중복확인 버튼을 눌렀을 때
              // 서버쪽으로 입력값 전달 -> DB 비교 -> 사용 가능하면 true리턴, 아니면 false리턴
              // 그 리턴 값을 isAvailable에 넣기 -> isAvailable이 true나 false일 때 각각의 메시지 출력
              onCheckDupId: (id) async {
                try {
                  final isAvailable = await checkDupId(id);
                  setState(() {
                    isCheckDupId = isAvailable;
                    idCheckMessage = isAvailable
                        ? '사용 가능한 아이디입니다.'
                        : '이미 사용 중인 아이디입니다.';
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
              pwCheckMessage: _pwController.text.isNotEmpty
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
              pwCheckMessage: _pwCheckController.text.isNotEmpty
                  ? (isSamePw
                  ? '*비밀번호가 일치합니다.'
                  : '*비밀번호가 일치하지 않습니다.')
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
                  nicknameCheckMessage = trimmed.isEmpty
                      ? null
                      : (isValid ? null : '닉네임 형식이 올바르지 않습니다.');
                  nicknameCheckColor = isValid ? null : Colors.red;
                });

                return isValid;
              },
              onCheckDupNickName: (nickname) async {
                try {
                  final isAvailable = await checkDupNickName(nickname);
                  setState(() {
                    isCheckDupNickName = isAvailable;
                    nicknameCheckMessage = isAvailable
                        ? '사용 가능한 닉네임입니다.'
                        : '이미 사용 중인 닉네임입니다.';
                    nicknameCheckColor = isAvailable ? Colors.green : Colors.red;
                  });
                  return isAvailable;
                } catch (e) {
                  setState(() {
                    nicknameCheckMessage = '서버 오류가 발생했습니다.';
                    nicknameCheckColor = Colors.orange;
                  });
                  return false;
                }
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
                  final success = await signUp(
                    id: _idController.text.trim(),
                    pw: _pwController.text,
                    nickname: _nicknameController.text.trim(),
                    email: _emailController.text.trim(),
                    profileImage: _profileImage, // 여기 전달
                  );

                  if (success) {
                    // 회원가입 성공 처리
                    if (!mounted) return;
                    
                    // 성공 시 snakebar 띄우기 + 로그인 페이지로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원가입이 완료되었습니다!')),
                    );
                    Navigator.pop(context);
                  } else {
                    // 실패 처리
                    if (!mounted) return;
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
                    fontSize: screenWidth*0.06,
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