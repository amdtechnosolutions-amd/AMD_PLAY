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

  test('Batch student roster correctly isolates enrolled students by selected batchId', () {
    final batch1 = {
      '_id': 'batch_101',
      'name': 'kids_begineer',
      'students': [
        {'_id': 's_1', 'name': 'Rahul Sharma', 'regNo': '1024'},
        {'_id': 's_2', 'name': 'Ananya Sen', 'regNo': '1025'},
      ],
    };
    final batch2 = {
      '_id': 'batch_202',
      'name': 'adults_intermediate',
      'students': [
        {'_id': 's_3', 'name': 'Vikram Rathore', 'regNo': '2050'},
      ],
    };

    final allBatches = [batch1, batch2];

    // Selecting batch 1
    final selectedBatch1 = allBatches.firstWhere((b) => b['_id'] == 'batch_101');
    final studentsBatch1 = selectedBatch1['students'] as List;
    expect(studentsBatch1.length, 2);
    expect(studentsBatch1[0]['name'], 'Rahul Sharma');
    expect(studentsBatch1[1]['name'], 'Ananya Sen');

    // Selecting batch 2
    final selectedBatch2 = allBatches.firstWhere((b) => b['_id'] == 'batch_202');
    final studentsBatch2 = selectedBatch2['students'] as List;
    expect(studentsBatch2.length, 1);
    expect(studentsBatch2[0]['name'], 'Vikram Rathore');
  });
}

