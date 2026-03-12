part of 'mess_screen.dart';

class _MessScreenState extends State<MessScreen> {
  final GlobalKey<FormState> _feedbackFormKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();

  int _selectedRating = 4;
  MessDay _selectedDay = _todayDay();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _toggleMealAttendance({
    required MealType mealType,
    required bool attended,
  }) async {
    try {
      await context.read<AppState>().markMealAttendance(
            day: _todayDay(),
            mealType: mealType,
            attended: attended,
          );
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to update attendance.', isError: true);
    }
  }

  Future<void> _submitFeedback() async {
    if (!_feedbackFormKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AppState>().submitFoodFeedback(
            rating: _selectedRating,
            comment: _feedbackController.text,
          );
      if (!mounted) {
        return;
      }
      _feedbackController.clear();
      setState(() {
        _selectedRating = 4;
      });
      showAppMessage(context, 'Food feedback submitted.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to submit feedback.', isError: true);
    }
  }

  Future<void> _editMenuDay(MessMenuDay menuDay) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController breakfastController = TextEditingController(
      text: menuDay.breakfast,
    );
    final TextEditingController lunchController = TextEditingController(
      text: menuDay.lunch,
    );
    final TextEditingController dinnerController = TextEditingController(
      text: menuDay.dinner,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final Brightness brightness = Theme.of(context).brightness;
        return Padding(
          padding: EdgeInsets.only(
            left: 14.w,
            right: 14.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 14.h,
            top: 24.h,
          ),
          child: Material(
            color: AppColors.tonalSurfaceFor(brightness),
            borderRadius: BorderRadius.circular(26.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Edit ${menuDay.day.label}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryTextFor(brightness),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(10),
                    CustomTextField(
                      controller: breakfastController,
                      inputHint: 'Breakfast',
                      validator: _requiredField,
                    ),
                    CustomTextField(
                      controller: lunchController,
                      inputHint: 'Lunch',
                      validator: _requiredField,
                    ),
                    CustomTextField(
                      controller: dinnerController,
                      inputHint: 'Dinner',
                      validator: _requiredField,
                    ),
                    heightSpacer(8),
                    CustomButton(
                      buttonText: 'Save Menu',
                      onTap: () async {
                        final NavigatorState navigator = Navigator.of(context);
                        final AppState appState = this.context.read<AppState>();
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        try {
                          await appState.updateMessMenuDay(
                            day: menuDay.day,
                            breakfast: breakfastController.text,
                            lunch: lunchController.text,
                            dinner: dinnerController.text,
                          );
                          if (!mounted) {
                            return;
                          }
                          navigator.pop();
                          showAppMessage(
                            this.context,
                            '${menuDay.day.label} menu updated.',
                          );
                        } on HostelRepositoryException catch (error) {
                          if (!mounted) {
                            return;
                          }
                          showAppMessage(
                            this.context,
                            error.message,
                            isError: true,
                          );
                        } catch (_) {
                          if (!mounted) {
                            return;
                          }
                          showAppMessage(
                            this.context,
                            'Unable to update the menu.',
                            isError: true,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    breakfastController.dispose();
    lunchController.dispose();
    dinnerController.dispose();
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.shrink(),
      );
    }
    if (user.role.isGuest) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Mess'),
        body: const AppEmptyState(
          icon: Icons.lock_outline,
          title: 'Access restricted',
          message:
              'Mess services are available only for resident and staff accounts.',
        ),
      );
    }
    if (!user.role.isStudent && !user.canManageMess) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Mess'),
        body: const AppEmptyState(
          icon: Icons.lock_outline,
          title: 'Access restricted',
          message: 'Only admin and warden accounts can manage mess operations.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Mess'),
      body: AppScreenBackground(
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 14, top: 8, bottomExtra: 18),
          children: user.role.isStudent
              ? <Widget>[
                  _StudentMessView(
                    state: state,
                    feedbackFormKey: _feedbackFormKey,
                    feedbackController: _feedbackController,
                    selectedRating: _selectedRating,
                    onRatingChanged: (int value) {
                      setState(() {
                        _selectedRating = value;
                      });
                    },
                    onSubmitFeedback: _submitFeedback,
                    onToggleMeal: _toggleMealAttendance,
                  ),
                ]
              : <Widget>[
                  _AdminMessView(
                    state: state,
                    selectedDay: _selectedDay,
                    onDaySelected: (MessDay value) {
                      setState(() {
                        _selectedDay = value;
                      });
                    },
                    onEditMenuDay: user.canEditMessMenu ? _editMenuDay : null,
                  ),
                ],
        ),
      ),
    );
  }
}

class _StudentBillRow {
  const _StudentBillRow({
    required this.name,
    required this.meals,
    required this.total,
  });

  final String name;
  final int meals;
  final int total;
}

MessDay _todayDay() {
  switch (DateTime.now().weekday) {
    case DateTime.monday:
      return MessDay.monday;
    case DateTime.tuesday:
      return MessDay.tuesday;
    case DateTime.wednesday:
      return MessDay.wednesday;
    case DateTime.thursday:
      return MessDay.thursday;
    case DateTime.friday:
      return MessDay.friday;
    case DateTime.saturday:
      return MessDay.saturday;
    case DateTime.sunday:
      return MessDay.sunday;
  }
  return MessDay.monday;
}

String _formatAmount(int value) {
  final String digits = value.toString();
  final RegExp groupPattern = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  return digits.replaceAllMapped(groupPattern, (Match match) {
    return '${match[1]},';
  });
}

String _formatDate(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final String day = date.day.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}';
}
