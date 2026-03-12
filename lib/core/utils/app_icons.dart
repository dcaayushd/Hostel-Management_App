import 'package:flutter/cupertino.dart';

import '../models/app_notification.dart';

class AppIcons {
  const AppIcons._();

  static const IconData home = CupertinoIcons.house;
  static const IconData homeFilled = CupertinoIcons.house_fill;
  static const IconData search = CupertinoIcons.search;
  static const IconData searchFilled = CupertinoIcons.search_circle_fill;
  static const IconData notice = CupertinoIcons.news;
  static const IconData noticeFilled = CupertinoIcons.news_solid;
  static const IconData fees = CupertinoIcons.money_dollar_circle;
  static const IconData feesFilled = CupertinoIcons.money_dollar_circle_fill;
  static const IconData chat = CupertinoIcons.chat_bubble_2;
  static const IconData chatFilled = CupertinoIcons.chat_bubble_2_fill;
  static const IconData settings = CupertinoIcons.gear;
  static const IconData settingsFilled = CupertinoIcons.gear_solid;
  static const IconData notifications = CupertinoIcons.bell;
  static const IconData notificationsFilled = CupertinoIcons.bell_fill;
  static const IconData profile = CupertinoIcons.person_crop_circle;
  static const IconData profileFilled = CupertinoIcons.person_crop_circle_fill;
  static const IconData room = CupertinoIcons.bed_double;
  static const IconData roomFilled = CupertinoIcons.bed_double_fill;
  static const IconData residents = CupertinoIcons.person_3;
  static const IconData residentsFilled = CupertinoIcons.person_3_fill;
  static const IconData staff = CupertinoIcons.person_2_square_stack;
  static const IconData staffFilled = CupertinoIcons.person_2_square_stack_fill;
  static const IconData addStaff = CupertinoIcons.person_badge_plus;
  static const IconData issue = CupertinoIcons.exclamationmark_bubble;
  static const IconData issueFilled =
      CupertinoIcons.exclamationmark_bubble_fill;
  static const IconData request = CupertinoIcons.arrow_right_arrow_left_circle;
  static const IconData requestFilled =
      CupertinoIcons.arrow_right_arrow_left_circle_fill;
  static const IconData laundry = CupertinoIcons.sparkles;
  static const IconData gatePass = CupertinoIcons.qrcode_viewfinder;
  static const IconData mess = CupertinoIcons.tray_full;
  static const IconData parcel = CupertinoIcons.archivebox;
  static const IconData logout = CupertinoIcons.square_arrow_right;
  static const IconData phone = CupertinoIcons.phone;
  static const IconData email = CupertinoIcons.mail;
  static const IconData verified = CupertinoIcons.checkmark_seal;
  static const IconData pendingEmail = CupertinoIcons.mail;
  static const IconData userId = CupertinoIcons.person_crop_rectangle;
  static const IconData person = CupertinoIcons.person;
  static const IconData personFilled = CupertinoIcons.person_fill;
  static const IconData role = CupertinoIcons.person_2;
  static const IconData block = CupertinoIcons.building_2_fill;
  static const IconData beds = CupertinoIcons.bed_double;
  static const IconData availability = CupertinoIcons.checkmark_circle;
  static const IconData payment = CupertinoIcons.creditcard;
  static const IconData paymentFilled = CupertinoIcons.creditcard_fill;
  static const IconData receipt = CupertinoIcons.doc_text;
  static const IconData receiptFilled = CupertinoIcons.doc_text_fill;
  static const IconData refresh = CupertinoIcons.arrow_clockwise_circle;
  static const IconData reset = CupertinoIcons.arrow_counterclockwise_circle;
  static const IconData themeSystem = CupertinoIcons.slider_horizontal_3;
  static const IconData themeLight = CupertinoIcons.sun_max;
  static const IconData themeDark = CupertinoIcons.moon_stars;
  static const IconData support = CupertinoIcons.question_circle;
  static const IconData open = CupertinoIcons.arrow_up_right;
  static const IconData forward = CupertinoIcons.chevron_right;
  static const IconData close = CupertinoIcons.xmark;
  static const IconData dropdown = CupertinoIcons.chevron_down;
  static const IconData visibility = CupertinoIcons.eye;
  static const IconData visibilityOff = CupertinoIcons.eye_slash;
  static const IconData lock = CupertinoIcons.padlock;
  static const IconData emptySearch = CupertinoIcons.search_circle;
  static const IconData about = CupertinoIcons.square_grid_2x2;
  static const IconData app = CupertinoIcons.square_grid_2x2_fill;
  static const IconData workspace = CupertinoIcons.wand_stars;
  static const IconData alert = CupertinoIcons.bell_circle;
  static const IconData category = CupertinoIcons.square_list;
  static const IconData menu = CupertinoIcons.list_bullet;
  static const IconData adminCatalog = CupertinoIcons.slider_horizontal_3;

  static IconData forNotificationType(HostelNotificationType type) {
    switch (type) {
      case HostelNotificationType.fee:
        return fees;
      case HostelNotificationType.notice:
        return notice;
      case HostelNotificationType.chat:
        return chat;
      case HostelNotificationType.complaint:
        return issue;
      case HostelNotificationType.roomChange:
        return request;
      case HostelNotificationType.parcel:
        return parcel;
      case HostelNotificationType.gatePass:
        return gatePass;
    }
  }

  static IconData forNoticeCategory(String category) {
    final String normalized = category.trim().toLowerCase();
    if (normalized.contains('event') || normalized.contains('program')) {
      return CupertinoIcons.calendar;
    }
    if (normalized.contains('rule') ||
        normalized.contains('policy') ||
        normalized.contains('guideline')) {
      return CupertinoIcons.book;
    }
    if (normalized.contains('alert') ||
        normalized.contains('urgent') ||
        normalized.contains('emergency')) {
      return CupertinoIcons.exclamationmark_triangle;
    }
    return notice;
  }

  static IconData byKey(String key) {
    switch (key) {
      case 'room':
        return room;
      case 'fees':
        return fees;
      case 'issue':
        return issue;
      case 'request':
        return request;
      case 'laundry':
        return laundry;
      case 'gatePass':
        return gatePass;
      case 'mess':
        return mess;
      case 'parcel':
        return parcel;
      case 'notice':
        return notice;
      case 'notifications':
        return notifications;
      case 'chat':
        return chat;
      case 'residents':
        return residents;
      case 'staff':
        return staff;
      case 'settings':
        return settings;
      default:
        return open;
    }
  }
}
