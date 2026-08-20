import 'package:flutter_test/flutter_test.dart';
import 'package:musicbye/main.dart';

void main(){
  testWidgets('muestra musicbye', (tester) async {
    await tester.pumpWidget(const MusicByeApp());

    expect(find.text('MusicBye'), findsOneWidget);
  });
}