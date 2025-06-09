import 'package:flutter/material.dart';
import '../../../widgets/jh/FindIdAndPassword/FindIdForm.dart';
import '../Login_and_Signup/Login.dart';
import 'FindPwPage.dart';

// 아이디 찾기 페이지
class FindIdPage extends StatefulWidget {

  const FindIdPage({super.key});

  @override
  State<FindIdPage> createState() => _FindIdPageState();

}

class _FindIdPageState extends State<FindIdPage> {

  String? _resultMessage = ''; // 결과 메시지를 출력할 때 사용할 변수

  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      // AppBar
      appBar: AppBar(
        title: Text('아이디 찾기', style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            
            Text('Find your ID', style: TextStyle(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold)),
            
            SizedBox(height: screenHeight * 0.01),
            
            Text('소셜 로그인은 찾을 수 없습니다.', style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035)),
            
            SizedBox(height: screenHeight * 0.04),
            
            FindIdForm(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              onResult: (msg) => setState(() => _resultMessage = msg),
            ),
            
            // 결과 메세지 출력하는 함수
            if (_resultMessage != null && _resultMessage!.isNotEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
                  child: Text(_resultMessage!, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500)),
                ),
              ),
            
            // 밑에 로그인 및 비밀번호 찾기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                  child: Text('로그인', style: TextStyle(fontSize: screenWidth * 0.035)),
                ),
                SizedBox(width: screenWidth * 0.06),
                TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FindPwPage())),
                    child: Text('비밀번호 찾기', style: TextStyle(fontSize: screenWidth * 0.035))
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}