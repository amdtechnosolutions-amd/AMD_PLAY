import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/coaching/data/models/student_evaluation_model.dart';

void main() {
  test('Initial unassessed evaluation gives 0 for all 24 parameters', () {
    final report = StudentEvaluationReport.fromJson({
      'overallScore': 0,
      'totalPossibleScore': 240,
      'score': 0,
      'grade': 'N/A',
      'studentName': 'RUTHVI PANDIAN',
      'parameters': <String, dynamic>{},
    });

    expect(report.summary.overallScore, 0.0);
    expect(report.summary.grade, 'N/A');
    expect(report.parameterCards.length, 24);

    for (final card in report.parameterCards) {
      expect(card.score, 0.0, reason: 'Card ${card.name} should be 0.0 initially, not 10.0');
    }
  });

  test('Evaluation with live parameter scores preserves exact API values', () {
    final report = StudentEvaluationReport.fromJson({
      'overallScore': 180,
      'totalPossibleScore': 240,
      'grade': 'B',
      'parameters': {
        'agility': 8.5,
        'speed': 7.0,
        'stamina': 9.0,
      },
    });

    final agilityCard = report.parameterCards.firstWhere((c) => c.name.toLowerCase() == 'agility');
    expect(agilityCard.score, 8.5);

    final speedCard = report.parameterCards.firstWhere((c) => c.name.toLowerCase() == 'speed');
    expect(speedCard.score, 7.0);

    final staminaCard = report.parameterCards.firstWhere((c) => c.name.toLowerCase() == 'stamina');
    expect(staminaCard.score, 9.0);

    final unratedCard = report.parameterCards.firstWhere((c) => c.name.toLowerCase() == 'smash');
    expect(unratedCard.score, 0.0);
  });
}
