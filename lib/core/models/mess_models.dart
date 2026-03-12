enum MessDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

extension MessDayX on MessDay {
  String get label {
    switch (this) {
      case MessDay.monday:
        return 'Monday';
      case MessDay.tuesday:
        return 'Tuesday';
      case MessDay.wednesday:
        return 'Wednesday';
      case MessDay.thursday:
        return 'Thursday';
      case MessDay.friday:
        return 'Friday';
      case MessDay.saturday:
        return 'Saturday';
      case MessDay.sunday:
        return 'Sunday';
    }
  }

  String get shortLabel => label.substring(0, 3);
}

enum MealType { breakfast, lunch, dinner }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}

class MessMenuDay {
  const MessMenuDay({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  final MessDay day;
  final String breakfast;
  final String lunch;
  final String dinner;

  bool get isPublished {
    return breakfast.trim().isNotEmpty ||
        lunch.trim().isNotEmpty ||
        dinner.trim().isNotEmpty;
  }

  MessMenuDay copyWith({
    MessDay? day,
    String? breakfast,
    String? lunch,
    String? dinner,
  }) {
    return MessMenuDay(
      day: day ?? this.day,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
  }
}

class MealAttendanceDay {
  const MealAttendanceDay({
    required this.id,
    required this.userId,
    required this.day,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  final String id;
  final String userId;
  final MessDay day;
  final DateTime date;
  final bool breakfast;
  final bool lunch;
  final bool dinner;

  int get mealCount {
    int count = 0;
    if (breakfast) {
      count += 1;
    }
    if (lunch) {
      count += 1;
    }
    if (dinner) {
      count += 1;
    }
    return count;
  }

  MealAttendanceDay copyWith({
    String? id,
    String? userId,
    MessDay? day,
    DateTime? date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) {
    return MealAttendanceDay(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      day: day ?? this.day,
      date: date ?? this.date,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
  }
}

class FoodFeedback {
  const FoodFeedback({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.submittedAt,
  });

  final String id;
  final String userId;
  final int rating;
  final String comment;
  final DateTime submittedAt;

  FoodFeedback copyWith({
    String? id,
    String? userId,
    int? rating,
    String? comment,
    DateTime? submittedAt,
  }) {
    return FoodFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

class MessBillSummary {
  const MessBillSummary({
    required this.monthLabel,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.breakfastRate,
    required this.lunchRate,
    required this.dinnerRate,
  });

  final String monthLabel;
  final int breakfastCount;
  final int lunchCount;
  final int dinnerCount;
  final int breakfastRate;
  final int lunchRate;
  final int dinnerRate;

  int get mealCount => breakfastCount + lunchCount + dinnerCount;

  int get totalAmount =>
      (breakfastCount * breakfastRate) +
      (lunchCount * lunchRate) +
      (dinnerCount * dinnerRate);

  MessBillSummary copyWith({
    String? monthLabel,
    int? breakfastCount,
    int? lunchCount,
    int? dinnerCount,
    int? breakfastRate,
    int? lunchRate,
    int? dinnerRate,
  }) {
    return MessBillSummary(
      monthLabel: monthLabel ?? this.monthLabel,
      breakfastCount: breakfastCount ?? this.breakfastCount,
      lunchCount: lunchCount ?? this.lunchCount,
      dinnerCount: dinnerCount ?? this.dinnerCount,
      breakfastRate: breakfastRate ?? this.breakfastRate,
      lunchRate: lunchRate ?? this.lunchRate,
      dinnerRate: dinnerRate ?? this.dinnerRate,
    );
  }
}
