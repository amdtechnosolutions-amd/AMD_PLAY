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
  final String studentName;

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
    this.studentName = '',
  });

  factory EvaluationSummary.fromJson(Map<String, dynamic> json) {
    final oScore = (json['overallScore'] ?? json['score'] ?? json['totalScore'] ?? 0).toDouble();
    final maxScore = (json['overallMaxScore'] ?? json['totalPossibleScore'] ?? json['maxScore'] ?? json['totalPossible'] ?? 240).toDouble();
    final pct = (json['percentage'] ?? json['overallPercentage'] ?? (maxScore > 0 ? (oScore / maxScore) * 100 : 0)).toDouble();
    final formattedOScore = oScore % 1 == 0 ? oScore.toInt().toString() : oScore.toStringAsFixed(1);

    return EvaluationSummary(
      overallScore: oScore,
      totalPossibleScore: maxScore,
      scoreText: json['scoreText']?.toString() ?? '$formattedOScore/${maxScore.toInt()}',
      percentage: pct,
      grade: json['grade']?.toString().toUpperCase() ?? (oScore == 0 ? 'N/A' : (pct >= 85 ? 'A' : pct >= 70 ? 'B' : 'C')),
      performanceLevel: json['performanceLevel']?.toString() ?? (oScore == 0 ? 'Unassessed' : (pct >= 85 ? 'Excellent' : pct >= 70 ? 'Proficient' : 'Developing')),
      coachRemarks: json['coachRemarks']?.toString() ?? json['remarks']?.toString() ?? (oScore == 0 ? 'Evaluation pending from academy coaching staff.' : 'Consistent effort and positive work ethic displayed in all sessions.'),
      evaluationDate: json['date']?.toString() ?? json['evaluationDate']?.toString() ?? '',
      coachName: json['coachName']?.toString() ?? (json['coachId'] is Map ? json['coachId']['name']?.toString() : null) ?? 'Head Coach',
      batchName: json['batchName']?.toString() ?? (json['batchId'] is Map ? json['batchId']['name']?.toString() : null) ?? 'Academy Batch',
      sportName: json['sportName']?.toString() ?? (json['sportId'] is Map ? json['sportId']['name']?.toString() : null) ?? 'Badminton',
      studentName: (json['studentName'] != null && json['studentName'].toString().trim().isNotEmpty)
          ? json['studentName'].toString().trim()
          : (json['student'] is Map
              ? (json['student']['name'] ??
                 json['student']['fullName'] ??
                 ('${json['student']['firstName'] ?? ''} ${json['student']['lastName'] ?? ''}'.trim().isNotEmpty
                     ? '${json['student']['firstName'] ?? ''} ${json['student']['lastName'] ?? ''}'.trim()
                     : null))?.toString()
              : (json['studentId'] is Map
                  ? (json['studentId']['name'] ??
                     json['studentId']['fullName'] ??
                     ('${json['studentId']['firstName'] ?? ''} ${json['studentId']['lastName'] ?? ''}'.trim().isNotEmpty
                         ? '${json['studentId']['firstName'] ?? ''} ${json['studentId']['lastName'] ?? ''}'.trim()
                         : null))?.toString()
                  : '')) ?? '',
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
    final mx = (json['maxScore'] ?? json['max'] ?? json['totalPossible'] ?? 60).toDouble();
    final pct = (json['percentage'] ?? (mx > 0 ? (sc / mx) * 100 : 0)).toDouble();

    Color resolvedColor = const Color(0xFFD4AF37);
    final lower = cat.toLowerCase();
    if (lower.contains('physical')) {
      resolvedColor = const Color(0xFF10B981);
    } else if (lower.contains('mental')) {
      resolvedColor = const Color(0xFF3B82F6);
    } else if (lower.contains('skill') || lower.contains('technical')) {
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

/// Master catalog of the 24 standard Badminton Academy parameters
class BadmintonEvaluationParameter {
  final String key;
  final String category;
  final String header;
  final String description;
  final double defaultScore;
  final double maxScore;

  const BadmintonEvaluationParameter({
    required this.key,
    required this.category,
    required this.header,
    required this.description,
    this.defaultScore = 0.0,
    this.maxScore = 10.0,
  });

  static const List<BadmintonEvaluationParameter> standard24 = [
    // 1. Physical (5)
    BadmintonEvaluationParameter(
      key: 'agility',
      category: 'Physical',
      header: 'PHYSICAL :',
      description:
          "Agility refers to a player's ability to move quickly and change direction efficiently while maintaining balance and control. It essential for fast-paced physical activities and sports.",
    ),
    BadmintonEvaluationParameter(
      key: 'speed',
      category: 'Physical',
      header: 'PHYSICAL :',
      description:
          "Speed refers to how quickly a player can move across the court, react to opponent shots, and execute footwork mechanics during play.",
    ),
    BadmintonEvaluationParameter(
      key: 'stamina',
      category: 'Physical',
      header: 'PHYSICAL :',
      description:
          "Stamina refers to a player's ability to sustain physical and mental performance over long periods, especially during extended rallies, intense training, or multi-game matches.",
    ),
    BadmintonEvaluationParameter(
      key: 'strength',
      category: 'Physical',
      header: 'PHYSICAL :',
      description:
          "Strength refers to a player's ability to generate power and withstand physical force, particularly in explosive movements like smashing, jumping, and quickly recovered, as well as maintaining stamina throughout the game.",
    ),
    BadmintonEvaluationParameter(
      key: 'flexibility',
      category: 'Physical',
      header: 'PHYSICAL :',
      description:
          "Flexibility refers to a player's ability to move joints and muscles through a wide range of motion, allowing for quick, efficient, and injury-free movements during play.",
    ),

    // 2. mental (5)
    BadmintonEvaluationParameter(
      key: 'focus',
      category: 'mental',
      header: 'MENTAL :',
      description:
          "Focus in badminton refers to a player's mental sharpness and sustained attention during training and matches.",
    ),
    BadmintonEvaluationParameter(
      key: 'confidence',
      category: 'mental',
      header: 'MENTAL :',
      description:
          "Confidence is a player's belief in their skills, preparation, and decision-making during play.",
    ),
    BadmintonEvaluationParameter(
      key: 'composure',
      category: 'mental',
      header: 'MENTAL :',
      description:
          "Composure is the ability to stay calm, controlled, and focused under pressure, especially during high-pressure situations.",
    ),
    BadmintonEvaluationParameter(
      key: 'resilience',
      category: 'mental',
      header: 'MENTAL :',
      description:
          "Resilience is the mental toughness to bounce back from setbacks, mistakes, or lost points.",
    ),
    BadmintonEvaluationParameter(
      key: 'sportsmanship',
      category: 'mental',
      header: 'MENTAL :',
      description:
          "Sportsmanship is the spirit of fair play, respect, and integrity towards opponents, officials, and the game itself.",
    ),

    // 3. skill (8)
    BadmintonEvaluationParameter(
      key: 'forehandStrokes',
      category: 'skill',
      header: 'SKILL :',
      description:
          "Forehand strokes involve hitting the shuttle with the palm side of the hand facing the direction of the stroke, typically from the racket hand side of the body.",
    ),
    BadmintonEvaluationParameter(
      key: 'backhandStrokes',
      category: 'skill',
      header: 'SKILL :',
      description:
          "Backhand strokes are played with the back of the hand facing the shuttle, usually on the non-dominant side of the body.",
    ),
    BadmintonEvaluationParameter(
      key: 'serve',
      category: 'skill',
      header: 'SKILL :',
      description:
          "The serve starts the rally and must be hit below waist height, aimed to land in the opponent's service court.",
    ),
    BadmintonEvaluationParameter(
      key: 'smash',
      category: 'skill',
      header: 'SKILL :',
      description:
          "The smash is a fast, downward, and powerful shot, primarily used to end a rally or create a weak return.",
    ),
    BadmintonEvaluationParameter(
      key: 'dropShots',
      category: 'skill',
      header: 'SKILL :',
      description:
          "A drop shot is a soft hit that falls steep into the net and lands close to it in the opponent's front court.",
    ),
    BadmintonEvaluationParameter(
      key: 'footwork',
      category: 'skill',
      header: 'SKILL :',
      description:
          "Footwork refers to a player's movement technique on court, including steps, lunges, and directional changes.",
    ),
    BadmintonEvaluationParameter(
      key: 'netPlay',
      category: 'skill',
      header: 'SKILL :',
      description:
          "Net play involves soft and precise shots close to the net, such as tumbling net shots or net kills.",
    ),
    BadmintonEvaluationParameter(
      key: 'defensiveSkills',
      category: 'skill',
      header: 'SKILL :',
      description:
          "Defensive skills refer to a player's ability to return smashes, drives, and other aggressive shots from the opponent.",
    ),

    // 4. attitude (6)
    BadmintonEvaluationParameter(
      key: 'punctuality',
      category: 'attitude',
      header: 'ATTITUDE :',
      description:
          "Being consistently on time for training, matches, and team events.",
    ),
    BadmintonEvaluationParameter(
      key: 'effort',
      category: 'attitude',
      header: 'ATTITUDE :',
      description:
          "The physical and mental energy a player puts into training and match play.",
    ),
    BadmintonEvaluationParameter(
      key: 'teamwork',
      category: 'attitude',
      header: 'ATTITUDE :',
      description:
          "Working effectively with others, especially in doubles or team settings.",
    ),
    BadmintonEvaluationParameter(
      key: 'coachability',
      category: 'attitude',
      header: 'ATTITUDE :',
      description:
          "The willingness to listen, accept feedback, and implement suggestions for improvement.",
    ),
    BadmintonEvaluationParameter(
      key: 'discipline',
      category: 'attitude',
      header: 'ATTITUDE :',
      description:
          "Maintaining self-control, following rules, and following training guidelines.",
    ),
    BadmintonEvaluationParameter(
      key: 'positiveAttitude',
      category: 'attitude',
      header: 'ATTITUDE :',
      description:
          "Displaying optimism, enthusiasm, and a solution-focused mindset.",
    ),
  ];
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
  final String studentName;

  const StudentEvaluationReport({
    required this.summary,
    required this.radarData,
    required this.parameterCards,
    required this.trend,
    required this.latestEvaluation,
    this.studentName = '',
  });

  factory StudentEvaluationReport.fromJson(Map<String, dynamic> json) {
    // 1. Parse Summary (merge root-level fields like coachRemarks, batchId, studentId, evaluationDate)
    final Map<String, dynamic> summaryObj = <String, dynamic>{
      ...json,
      if (json['summary'] is Map) ...Map<String, dynamic>.from(json['summary'] as Map),
    };
    final summary = EvaluationSummary.fromJson(summaryObj);

    // 2. Parse Radar Data
    final List<RadarCategoryData> radarList = [];
    final rawRadar = json['radarData'];
    if (rawRadar is List) {
      for (final r in rawRadar) {
        if (r is Map<String, dynamic>) {
          radarList.add(RadarCategoryData.fromJson(r));
        } else if (r is Map) {
          radarList.add(RadarCategoryData.fromJson(Map<String, dynamic>.from(r)));
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

    // 3. Parse Parameter Cards (Exact 24 Badminton Academy parameters from design)
    final Map<String, double> liveScores = {};

    void extractScoresFromMap(Map map) {
      map.forEach((key, val) {
        final k = key.toString().trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (val is num) {
          liveScores[k] = val.toDouble();
        } else if (val is Map) {
          extractScoresFromMap(val);
        } else if (val is String) {
          final parsed = double.tryParse(val);
          if (parsed != null) liveScores[k] = parsed;
        }
      });
    }

    // Extract categoryScores from summaryObj (e.g. { physical: { score: 26, maxScore: 50 }, ... })
    if (summaryObj['categoryScores'] is Map) {
      final catScores = summaryObj['categoryScores'] as Map;
      catScores.forEach((catKey, catVal) {
        final kLower = catKey.toString().trim().toLowerCase();
        if (catVal is Map && catVal['score'] is num) {
          final sc = (catVal['score'] as num).toDouble();
          if (kLower.contains('physical')) liveScores['physicalscore'] = sc;
          if (kLower.contains('mental')) liveScores['mentalscore'] = sc;
          if (kLower.contains('skill') || kLower.contains('technical')) liveScores['skillscore'] = sc;
          if (kLower.contains('attitude')) liveScores['attitudescore'] = sc;
        }
      });
    }

    // Extract category scores from radarData if categoryScores wasn't provided
    for (final r in radarList) {
      final lower = r.category.toLowerCase();
      if (lower.contains('physical') && !liveScores.containsKey('physicalscore')) {
        liveScores['physicalscore'] = r.score;
      } else if (lower.contains('mental') && !liveScores.containsKey('mentalscore')) {
        liveScores['mentalscore'] = r.score;
      } else if ((lower.contains('skill') || lower.contains('technical')) &&
          !liveScores.containsKey('skillscore')) {
        liveScores['skillscore'] = r.score;
      } else if (lower.contains('attitude') && !liveScores.containsKey('attitudescore')) {
        liveScores['attitudescore'] = r.score;
      }
    }

    final rawCards = json['parameterCards'] ?? json['parameters'];
    if (rawCards is List) {
      for (final c in rawCards) {
        if (c is Map) {
          final name = (c['key'] ?? c['name'] ?? c['parameter'] ?? '')
              .toString()
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]'), '');
          final score = (c['score'] ?? c['value'] as num?)?.toDouble();
          if (name.isNotEmpty && score != null) {
            liveScores[name] = score;
          }
        }
      }
    } else if (rawCards is Map) {
      extractScoresFromMap(rawCards);
    }

    // 5. Latest Raw Evaluation
    final latest = json['latestEvaluation'] is Map ? json['latestEvaluation'] as Map<String, dynamic> : <String, dynamic>{};

    if (latest['parameters'] is Map) {
      extractScoresFromMap(latest['parameters'] as Map);
    }
    if (latest['scores'] is Map) {
      extractScoresFromMap(latest['scores'] as Map);
    }
    if (latest['categories'] is Map) {
      extractScoresFromMap(latest['categories'] as Map);
    }

    // Extract category-level scores from root and latest object (e.g. physicalScore, mentalScore)
    extractScoresFromMap(json);
    if (latest.isNotEmpty) {
      extractScoresFromMap(latest);
    }

    final List<ParameterCardModel> cards = [];
    for (final std in BadmintonEvaluationParameter.standard24) {
      final normalizedKey = std.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      // 1. Direct specific parameter score (e.g. agility: 8.0)
      double? score = liveScores[normalizedKey];

      // 2. If specific parameter is missing, derive from category score if available
      if (score == null) {
        final catLower = std.category.toLowerCase();
        double? catScore = liveScores['${catLower}score'] ?? liveScores[catLower];
        if (catScore != null) {
          if (catScore <= 10.0) {
            score = catScore;
          } else {
            // Category counts: Physical(5), Mental(5), Skill(8), Attitude(6)
            int count = catLower.contains('physical')
                ? 5
                : (catLower.contains('mental')
                    ? 5
                    : (catLower.contains('skill') ? 8 : 6));
            score = (catScore / count).clamp(0.0, 10.0);
          }
        }
      }

      final resolvedScore = score ?? std.defaultScore;

      cards.add(ParameterCardModel(
        id: std.key,
        name: std.key,
        category: std.category,
        description: std.description,
        score: resolvedScore,
        maxScore: std.maxScore,
        percentage: (resolvedScore / std.maxScore) * 100.0,
        rating: resolvedScore >= 8.5
            ? 'Advanced'
            : (resolvedScore >= 7.0
                ? 'Proficient'
                : (resolvedScore > 0 ? 'Developing' : 'Unassessed')),
      ));
    }

    // Populate radar data from cards if not explicitly provided
    if (radarList.isEmpty) {
      final pCards = cards.where((c) => c.category.toLowerCase().contains('physical')).toList();
      final mCards = cards.where((c) => c.category.toLowerCase().contains('mental')).toList();
      final sCards = cards.where((c) => c.category.toLowerCase().contains('skill')).toList();
      final aCards = cards.where((c) => c.category.toLowerCase().contains('attitude')).toList();

      double sum(List<ParameterCardModel> list) => list.fold(0.0, (acc, item) => acc + item.score);

      final pScore = sum(pCards);
      final mScore = sum(mCards);
      final sScore = sum(sCards);
      final aScore = sum(aCards);

      radarList.addAll([
        RadarCategoryData(
          category: 'PHYSICAL',
          score: pScore,
          maxScore: 50,
          percentage: (pScore / 50.0) * 100.0,
          color: const Color(0xFF10B981),
        ),
        RadarCategoryData(
          category: 'MENTAL',
          score: mScore,
          maxScore: 50,
          percentage: (mScore / 50.0) * 100.0,
          color: const Color(0xFF3B82F6),
        ),
        RadarCategoryData(
          category: 'SKILL',
          score: sScore,
          maxScore: 80,
          percentage: (sScore / 80.0) * 100.0,
          color: const Color(0xFFD4AF37),
        ),
        RadarCategoryData(
          category: 'ATTITUDE',
          score: aScore,
          maxScore: 60,
          percentage: (aScore / 60.0) * 100.0,
          color: const Color(0xFF8B5CF6),
        ),
      ]);
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

    String resolveName(dynamic source) {
      if (source == null) return '';
      if (source is String && source.trim().isNotEmpty) return source.trim();
      if (source is Map) {
        final f = (source['firstName'] ?? '').toString().trim();
        final l = (source['lastName'] ?? '').toString().trim();
        final full = '$f $l'.trim();
        if (full.isNotEmpty) return full;
        final n = (source['name'] ?? source['fullName'] ?? source['studentName'] ?? '').toString().trim();
        if (n.isNotEmpty) return n;
      }
      return '';
    }

    String resolvedStudentName = resolveName(json['studentName']);
    if (resolvedStudentName.isEmpty) resolvedStudentName = resolveName(json['student']);
    if (resolvedStudentName.isEmpty) resolvedStudentName = resolveName(json['studentId']);
    if (resolvedStudentName.isEmpty) resolvedStudentName = resolveName(latest['student']);
    if (resolvedStudentName.isEmpty) resolvedStudentName = resolveName(latest['studentId']);
    if (resolvedStudentName.isEmpty) resolvedStudentName = resolveName(latest['studentName']);
    if (resolvedStudentName.isEmpty) resolvedStudentName = summary.studentName;

    return StudentEvaluationReport(
      summary: summary,
      radarData: radarList,
      parameterCards: cards,
      trend: trendItems,
      latestEvaluation: latest,
      studentName: resolvedStudentName,
    );
  }

  /// Initial report with 0 scores when student has not been assessed yet
  factory StudentEvaluationReport.initialEmpty({String studentName = ''}) {
    return StudentEvaluationReport(
      summary: EvaluationSummary(
        overallScore: 0,
        totalPossibleScore: 240,
        scoreText: '0/240',
        percentage: 0,
        grade: 'N/A',
        performanceLevel: 'Unassessed',
        coachRemarks: 'Evaluation pending from academy coaching staff.',
        evaluationDate: '',
        coachName: 'Head Coach',
        batchName: 'Academy Batch',
        sportName: 'Badminton',
        studentName: studentName,
      ),
      radarData: const [
        RadarCategoryData(category: 'PHYSICAL', score: 0, maxScore: 50, percentage: 0, color: Color(0xFF10B981)),
        RadarCategoryData(category: 'MENTAL', score: 0, maxScore: 50, percentage: 0, color: Color(0xFF3B82F6)),
        RadarCategoryData(category: 'SKILL', score: 0, maxScore: 80, percentage: 0, color: Color(0xFFD4AF37)),
        RadarCategoryData(category: 'ATTITUDE', score: 0, maxScore: 60, percentage: 0, color: Color(0xFF8B5CF6)),
      ],
      parameterCards: BadmintonEvaluationParameter.standard24.map((std) {
        return ParameterCardModel(
          id: std.key,
          name: std.key,
          category: std.category,
          description: std.description,
          score: 0,
          maxScore: std.maxScore,
          percentage: 0,
          rating: 'Unassessed',
        );
      }).toList(),
      trend: const [],
      latestEvaluation: const {},
      studentName: studentName,
    );
  }
}

