import 'package:flutter/material.dart';
import 'package:portone_flutter/iamport_payment.dart';
import 'package:portone_flutter/model/payment_data.dart';

class PaymentPage extends StatelessWidget {
  final int point; // 충전할 포인트
  final int price; // 실제 결제할 금액 (₩)

  const PaymentPage({required this.point, required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    return IamportPayment(
      appBar: AppBar(title: const Text('포인트 결제')),
      userCode: 'imp05145542', // 포트원 가맹점 코드
      data: PaymentData(
        pg: 'html5_inicis',
        payMethod: 'card',
        name: '포인트 ${point} 충전',
        merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',
        amount: price.toDouble(),
        buyerName: '홍길동',
        buyerTel: '01012345678',
        buyerEmail: 'example@example.com',
        buyerAddr: '서울시 어딘가',
        buyerPostcode: '12345',
        appScheme: 'trekkit', // 딥링크 쓸 거면 등록해야 함
      ),
      callback: (Map<String, String> result) {
        // ✅ 결제 완료 후 여기서 처리
        // 여기에 이제 fetch문 써서 디비에 포인트 저장
        Navigator.pop(context, result); // 결과 반환
      },
    );
  }
}
