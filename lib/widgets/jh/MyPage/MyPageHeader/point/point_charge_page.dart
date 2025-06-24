import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../../api/payment_api.dart';
import '../../../../../functions/jh/userprovider.dart';

class PointChargePage extends StatelessWidget {
  final List<int> chargeOptions = [100, 500, 1000, 3000, 5000, 10000];

  PointChargePage({super.key});

  @override
  Widget build(BuildContext context) {

    final baseUrl = dotenv.env['API_URL']!; // 백엔드 url
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final userProvider = Provider.of<UserProvider>(context);
    final point = userProvider.point ?? 0; // 포인트
    final userid = userProvider.index; // 유저 인덱스
    final token = userProvider.token; // 토큰

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '포인트 충전소',
          style: TextStyle(fontSize: screenWidth * 0.05),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 내 포인트 표시
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Text(
                  '내 포인트: $point',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // 포인트 충전 항목
              Column(
                children: chargeOptions.map((amount) {
                  final price = amount * 11;
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            point: amount,
                            price: price,
                          ),
                        ),
                      );

                      final success = result['imp_success'] ?? result['success'];

                      // 결제가 성공이면 밑에 실행
                      if (success == true || success == 'true') {
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('포인트 $amount 충전 성공')),
                        );

                        // 포인트 지급 로직
                        try {
                          final response = await http.post(
                            Uri.parse('$baseUrl/pay/add'),
                            headers: {
                              'Content-Type': 'application/json',
                              "Authorization": "Bearer $token",
                              "X-Client-Type": "app",
                            },
                            body: jsonEncode({
                              'point': amount, // 충전할 포인트
                              'id': userid, // 유저 인덱스
                            }),
                          );

                          if (response.statusCode == 200) {
                            final body = jsonDecode(response.body);
                            final message = body['result'] ?? '포인트 지급 성공';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                            // provider에 최신 포인트 반영
                            userProvider.updatePoint(userProvider.point + amount);
                          } else {
                            final body = jsonDecode(response.body);
                            final message = body['result'] ?? '포인트 지급 중 오류 발생';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        } catch(e) {
                          const SnackBar(content: Text('서버 오류가 발생했습니다.'));
                        }
                        
                        // 결제가 실패하게 될 경우 실행되는 코드
                      } else {
                        final errorMsg = result['error_msg'] ?? '결제 실패 또는 취소됨';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMsg)),
                        );
                      }

                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '포인트 $amount',
                            style: TextStyle(fontSize: screenWidth * 0.045),
                          ),
                          Text(
                            '₩$price',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: screenHeight * 0.04),

              // 설명 문구
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...[
                    '포인트 충전 후 7일 이내, 사용하지 않은 포인트만 결제 취소가 가능합니다.',
                    '포인트 충전 후 보너스포인트만 사용한 경우에도 결제 취소가 되지 않습니다.',
                    '법정대리인의 동의 없는 미성년자의 결제는 취소될 수 있습니다.',
                    '위 금액은 부가가치세(10%)가 포함된 금액입니다.',
                  ].map((text) => Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.008),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ",
                            style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: Colors.grey[600])),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: screenWidth * 0.028,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
