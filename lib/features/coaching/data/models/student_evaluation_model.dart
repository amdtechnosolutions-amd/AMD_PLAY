import 'package:flutter/material.dart';

/// Performance evaluation summary for a student/trainee
class EvaluationSummary {
  final double overallScore;
  final double totalPossibleScore;
  final String scoreText;
  final double percentage;
  final String grade;
  final String performanceLevel;
  final String coachRemarks;
  final String evaluationDate;
  final String coachName;
  final String batchName;
  final String sportName;

  const EvaluationSummary({
    required this.overallScore,
    required this.totalPossibleScore,
    required this.scoreText,
    required this.percentage,
    required this.grade,
    required this.performanceLevel,
    required this.coachRemarks,
    required this.evaluationDate,
    required this.coachName,
    required this.batchName,
    required this.sportName,
  });

  factory EvaluationSummary.fromJson(Map<String, dynamic> json) {
    final oScore = (json['overallScore'] ?? json['score'] ?? json['totalScore'] ?? 0).toDouble();
    final maxScore = (json['totalPossibleScore'] ?? json['maxScore'] ?? json['totalPossible'] ?? 240).toDouble();
    final pct = (json['percentage'] ?? json['overallPercentage'] ?? (maxScore > 0 ? (oScore / maxScore) * 100 : 0)).toDouble();

    return EvaluationSummary(
      overallScore: oScore,
      totalPossibleScore: maxScore,
      scoreText: json['scoreText']?.toString() ?? '${oScore.toInt()}/${maxScore.toInt()}',
      percentage: pct,
      grade: json['grade']?.toString().toUpperCase() ?? (pct >= 85 ? 'A' : pct >= 70 ? 'B' : 'C'),
      performanceLevel: json['performanceLevel']?.toString() ?? (pct >= 85 ? 'Excellent' : pct >= 70 ? 'Proficient' : 'Developing'),
      coachRemarks: json['coachRemarks']?.toString() ?? json['remarks']?.toString() ?? 'Consistent effort and positive work ethic displayed in all sessions.',
      evaluationDate: json['date']?.toString() ?? json['evaluationDate']?.toString() ?? '',
      coachName: json['coachName']?.toString() ?? (json['coachId'] is Map ? json['coachId']['name']?.toString() : null) ?? 'Head Coach',
      batchName: json['batchName']?.toString() ?? (json['batchId'] is Map ? json['batchId']['name']?.toString() : null) ?? 'Academy Batch',
      sportName: json['sportName']?.toString() ?? (json['sportId'] is Map ? json['sportId']['name']?.toString() : null) ?? 'Badminton',
    );
  }
}

/// Category breakdown point for Radar / Spider charts
class RadarCategoryData {
  final String category;
  final double score;
  final double maxScore;
  final double percentage;
  final Color color;

  const RadarCategoryData({
    required this.category,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.color,
  });

  factory RadarCategoryData.fromJson(Map<String, dynamic> json) {
    final cat = json['category']?.toString() ?? json['name']?.toString() ?? 'General';
    final sc = (json['score'] ?? json['totalScore'] ?? 0).toDouble();
    final mx = (json['maxScore'] ?? json['totalPossible'] ?? 60).toDouble();
    final pct = (json['percentage'] ?? (mx > 0 ? (sc / mx) * 100 : 0)).toDouble();

    Color resolvedColor = const Color(0xFFD4AF37);
    final lower = cat.toLowerCase();
    if (lower.contains('physical')) {
      resolvedColor = const Color(0xFF10B981);
    } else if (lower.contains('mental')) {
      resolvedColor = const Color(0xFF3B82F6);
    } else if (lower.contains('skill')) {
      resolvedColor = const Color(0xFFD4AF37);
    } else if (lower.contains('attitude')) {
      resolvedColor = const Color(0xFF8B5CF6);
    }

    return RadarCategoryData(
      category: cat,
      score: sc,
      maxScore: mx,
      percentage: pct,
      color: resolvedColor,
    );
  }
}

/// Individual parameter evaluation card (e.g., Stamina, Footwork, Focus)
class ParameterCardModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double score;
  final double maxScore;
  final double percentage;
  final String rating;

  const ParameterCardModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.rating,
  });

  factory ParameterCardModel.fromJson(Map<String, dynamic> json) {
    final sc = (json['score'] ?? json['value'] ?? 0).toDouble();
    final mx = (json['maxScore'] ?? json['outOf'] ?? 10).toDouble();
    final pct = (json['percentage'] ?? (mx > 0 ? (sc / mx) * 100 : 0)).toDouble();

    return ParameterCardModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['parameter']?.toString() ?? 'Parameter',
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      score: sc,
      maxScore: mx,
      percentage: pct,
      rating: json['rating']?.toString() ?? (pct >= 85 ? 'Advanced' : pct >= 70 ? 'Proficient' : 'Developing'),
    );
  }
}

/// Historical trend point for line charts
class EvaluationTrendItem {
  final String date;
  final double overallPercentage;
  final double overallScore;
  final double physicalScore;
  final double mentalScore;
  final double skillScore;
  final double attitudeScore;

  const EvaluationTrendItem({
    required this.date,
    required this.overallPercentage,
    required this.overallScore,
    this.physicalScore = 0,
    this.mentalScore = 0,
    this.skillScore = 0,
    this.attitudeScore = 0,
  });

  factory EvaluationTrendItem.fromJson(Map<String, dynamic> json) {
    return EvaluationTrendItem(
      date: json['date']?.toString() ?? '',
      overallPercentage: (json['overallPercentage'] ?? json['percentage'] ?? 0).toDouble(),
      overallScore: (json['overallScore'] ?? json['score'] ?? 0).toDouble(),
      physicalScore: (json['physicalScore'] ?? json['physical'] ?? 0).toDouble(),
      mentalScore: (json['mentalScore'] ?? json['mental'] ?? 0).toDouble(),
      skillScore: (json['skillScore'] ?? json['skill'] ?? 0).toDouble(),
      attitudeScore: (json['attitudeScore'] ?? json['attitude'] ?? 0).toDouble(),
    );
  }
}

/// Root Student Evaluation Report aggregating all modules
class StudentEvaluationReport {
  final EvaluationSummary summary;
  final List<RadarCategoryData> radarData;
  final List<ParameterCardModel> parameterCards;
  final List<EvaluationTrendItem> trend;
  final Map<String, dynamic> latestEvaluation;

  const StudentEvaluationReport({
    required this.summary,
    required this.radarData,
    required this.parameterCards,
    required this.trend,
    required this.latestEvaluation,
  });

  factory StudentEvaluationReport.fromJson(Map<String, dynamic> json) {
    // 1. Parse Summary
    final summaryObj = json['summary'] is Map ? json['summary'] as Map<String, dynamic> : json;
    final summary = EvaluationSummary.fromJson(summaryObj);

    // 2. Parse Radar Data
    final List<RadarCategoryData> radarList = [];
    final rawRadar = json['radarData'];
    if (rawRadar is List) {
      for (final r in rawRadar) {
        if (r is Map<String, dynamic>) {
          radarList.add(RadarCategoryData.fromJson(r));
        }
      }
    } else if (rawRadar is Map<String, dynamic>) {
      rawRadar.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          radarList.add(RadarCategoryData.fromJson(v));
        } else if (v is num) {
          radarList.add(RadarCategoryData(
            category: k.toUpperCase(),
            score: v.toDouble(),
            maxScore: 100,
            percentage: v.toDouble(),
            color: const Color(0xFFD4AF37),
          ));
        }
      });
    }

    // 3. Parse Parameter Cards (24 items or formatted parameters)
    final List<ParameterCardModel> cards = [];
    final rawCards = json['parameterCards'] ?? json['parameters'];
    if (rawCards is List) {
      for (final c in rawCards) {
        if (c is Map<String, dynamic>) {
          cards.add(ParameterCardModel.fromJson(c));
        }
      }
    }

    // 4. Parse Trend
    final List<EvaluationTrendItem> trendItems = [];
    final rawTrend = json['trend'] ?? json['historical'] ?? json['history'];
    if (rawTrend is List) {
      for (final t in rawTrend) {
        if (t is Map<String, dynamic>) {
          trendItems.add(EvaluationTrendItem.fromJson(t));
        }
      }
    }

    // 5. Latest Raw Evaluation
    final latest = json['latestEvaluation'] is Map ? json['latestEvaluation'] as Map<String, dynamic> : <String, dynamic>{};

    return StudentEvaluationReport(
      summary: summary,
      radarData: radarList,
      parameterCards: cards,
      trend: trendItems,
      latestEvaluation: latest,
    );
  }
}
