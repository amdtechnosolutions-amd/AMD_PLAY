import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app/features/coaching/data/models/student_evaluation_model.dart';

/// Clean, horizontal evaluation parameter card matching the Academy Report UI:
/// - Rounded light-silver/grey container (Color 0xFFE2E4E8)
/// - Left: Illustration / icon container
/// - Center: Parameter name (bold) & description
/// - Right: Big, bold score number (e.g. 10)
class ParameterCardWidget extends StatelessWidget {
  final ParameterCardModel parameter;

  const ParameterCardWidget({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E4E8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Parameter Illustration / Icon on the Left
          ParameterIconWidget(parameterKey: parameter.name),
          SizedBox(width: 12.w),

          // 2. Middle: Parameter Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  parameter.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  parameter.description,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.2.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // 3. Right: Large Bold Score Number
          Text(
            parameter.score % 1 == 0
                ? parameter.score.toInt().toString()
                : parameter.score.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Illustrative Icon badge matching the 24 Badminton parameters
class ParameterIconWidget extends StatelessWidget {
  final String parameterKey;

  const ParameterIconWidget({super.key, required this.parameterKey});

  @override
  Widget build(BuildContext context) {
    final keyLower = parameterKey.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    IconData iconData = Icons.sports_tennis_rounded;
    Color iconColor = const Color(0xFFD4AF37);
    Color bgColor = const Color(0xFFFFFBEB);
    Color borderColor = const Color(0xFFFDE68A);

    // Physical (5)
    if (keyLower.contains('agility')) {
      iconData = Icons.directions_run_rounded;
      iconColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFFCD34D);
    } else if (keyLower.contains('speed')) {
      iconData = Icons.bolt_rounded;
      iconColor = const Color(0xFFEA580C);
      bgColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFFEDD5);
    } else if (keyLower.contains('stamina')) {
      iconData = Icons.fitness_center_rounded;
      iconColor = const Color(0xFF0284C7);
      bgColor = const Color(0xFFE0F2FE);
      borderColor = const Color(0xFFBAE6FD);
    } else if (keyLower.contains('strength')) {
      iconData = Icons.sports_gymnastics_rounded;
      iconColor = const Color(0xFFBE185D);
      bgColor = const Color(0xFFFDF2F8);
      borderColor = const Color(0xFFFCE7F3);
    } else if (keyLower.contains('flexibility')) {
      iconData = Icons.accessibility_new_rounded;
      iconColor = const Color(0xFF7E22CE);
      bgColor = const Color(0xFFFAF5FF);
      borderColor = const Color(0xFFF3E8FF);
    }
    // mental (5)
    else if (keyLower.contains('focus')) {
      iconData = Icons.filter_center_focus_rounded;
      iconColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
    } else if (keyLower.contains('confidence')) {
      iconData = Icons.thumb_up_alt_rounded;
      iconColor = const Color(0xFF2563EB);
      bgColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFFBFDBFE);
    } else if (keyLower.contains('composure')) {
      iconData = Icons.self_improvement_rounded;
      iconColor = const Color(0xFF16A34A);
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFBBF7D0);
    } else if (keyLower.contains('resilience')) {
      iconData = Icons.spa_rounded;
      iconColor = const Color(0xFF6D28D9);
      bgColor = const Color(0xFFF5F3FF);
      borderColor = const Color(0xFFDDD6FE);
    } else if (keyLower.contains('sportsmanship')) {
      iconData = Icons.handshake_rounded;
      iconColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
    }
    // skill (8)
    else if (keyLower.contains('forehand')) {
      iconData = Icons.sports_tennis_rounded;
      iconColor = const Color(0xFFD4AF37);
      bgColor = const Color(0xFFFFFDF5);
      borderColor = const Color(0xFFFDE68A);
    } else if (keyLower.contains('backhand')) {
      iconData = Icons.sports_tennis_rounded;
      iconColor = const Color(0xFF0284C7);
      bgColor = const Color(0xFFF0F9FF);
      borderColor = const Color(0xFFBAE6FD);
    } else if (keyLower.contains('serve')) {
      iconData = Icons.sports_handball_rounded;
      iconColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFFCD34D);
    } else if (keyLower.contains('smash')) {
      iconData = Icons.flash_on_rounded;
      iconColor = const Color(0xFFE11D48);
      bgColor = const Color(0xFFFFF1F2);
      borderColor = const Color(0xFFFECDD3);
    } else if (keyLower.contains('dropshot')) {
      iconData = Icons.arrow_downward_rounded;
      iconColor = const Color(0xFF0891B2);
      bgColor = const Color(0xFFECFEFF);
      borderColor = const Color(0xFFCFFAFE);
    } else if (keyLower.contains('footwork')) {
      iconData = Icons.directions_walk_rounded;
      iconColor = const Color(0xFF334155);
      bgColor = const Color(0xFFF1F5F9);
      borderColor = const Color(0xFFCBD5E1);
    } else if (keyLower.contains('netplay')) {
      iconData = Icons.grid_4x4_rounded;
      iconColor = const Color(0xFF1D4ED8);
      bgColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFFBFDBFE);
    } else if (keyLower.contains('defensive')) {
      iconData = Icons.shield_rounded;
      iconColor = const Color(0xFFDB2777);
      bgColor = const Color(0xFFFDF2F8);
      borderColor = const Color(0xFFFBCFE8);
    }
    // attitude (6)
    else if (keyLower.contains('punctuality')) {
      iconData = Icons.schedule_rounded;
      iconColor = const Color(0xFF1E293B);
      bgColor = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFCBD5E1);
    } else if (keyLower.contains('effort')) {
      iconData = Icons.local_fire_department_rounded;
      iconColor = const Color(0xFFC2410C);
      bgColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFFEDD5);
    } else if (keyLower.contains('teamwork')) {
      iconData = Icons.groups_rounded;
      iconColor = const Color(0xFF2563EB);
      bgColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFFBFDBFE);
    } else if (keyLower.contains('coachability')) {
      iconData = Icons.co_present_rounded;
      iconColor = const Color(0xFF15803D);
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFBBF7D0);
    } else if (keyLower.contains('discipline')) {
      iconData = Icons.verified_user_rounded;
      iconColor = const Color(0xFFB45309);
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
    } else if (keyLower.contains('attitude') || keyLower.contains('positive')) {
      iconData = Icons.sentiment_very_satisfied_rounded;
      iconColor = const Color(0xFF7C3AED);
      bgColor = const Color(0xFFFAF5FF);
      borderColor = const Color(0xFFE9D5FF);
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          iconData,
          size: 22.sp,
          color: iconColor,
        ),
      ),
    );
  }
}
