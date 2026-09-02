//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:campus_api/src/date_serializer.dart';
import 'package:campus_api/src/model/date.dart';

import 'package:campus_api/src/model/app_schemas_auth_message_response.dart';
import 'package:campus_api/src/model/app_schemas_conversation_message_response.dart';
import 'package:campus_api/src/model/ban_request.dart';
import 'package:campus_api/src/model/chat_create_request.dart';
import 'package:campus_api/src/model/chat_membership_response.dart';
import 'package:campus_api/src/model/chat_message_create_request.dart';
import 'package:campus_api/src/model/chat_message_delete_request.dart';
import 'package:campus_api/src/model/chat_message_page_response.dart';
import 'package:campus_api/src/model/chat_message_response.dart';
import 'package:campus_api/src/model/chat_page_response.dart';
import 'package:campus_api/src/model/chat_response.dart';
import 'package:campus_api/src/model/chat_role.dart';
import 'package:campus_api/src/model/chat_visibility.dart';
import 'package:campus_api/src/model/conversation_context.dart';
import 'package:campus_api/src/model/conversation_create_request.dart';
import 'package:campus_api/src/model/conversation_page_response.dart';
import 'package:campus_api/src/model/conversation_response.dart';
import 'package:campus_api/src/model/course_response.dart';
import 'package:campus_api/src/model/daily_metric_item.dart';
import 'package:campus_api/src/model/flag_item.dart';
import 'package:campus_api/src/model/food_spot_category.dart';
import 'package:campus_api/src/model/food_spot_response.dart';
import 'package:campus_api/src/model/forgot_password_request.dart';
import 'package:campus_api/src/model/http_validation_error.dart';
import 'package:campus_api/src/model/health_response.dart';
import 'package:campus_api/src/model/image_upload_url_request.dart';
import 'package:campus_api/src/model/image_upload_url_response.dart';
import 'package:campus_api/src/model/listing_category.dart';
import 'package:campus_api/src/model/listing_condition.dart';
import 'package:campus_api/src/model/listing_create_request.dart';
import 'package:campus_api/src/model/listing_image_response.dart';
import 'package:campus_api/src/model/listing_page_response.dart';
import 'package:campus_api/src/model/listing_response.dart';
import 'package:campus_api/src/model/listing_status.dart';
import 'package:campus_api/src/model/listing_update_request.dart';
import 'package:campus_api/src/model/location_inner.dart';
import 'package:campus_api/src/model/login_request.dart';
import 'package:campus_api/src/model/logout_request.dart';
import 'package:campus_api/src/model/message_create_request.dart';
import 'package:campus_api/src/model/message_page_response.dart';
import 'package:campus_api/src/model/metrics_response.dart';
import 'package:campus_api/src/model/moderation_status.dart';
import 'package:campus_api/src/model/mute_request.dart';
import 'package:campus_api/src/model/notification_page_response.dart';
import 'package:campus_api/src/model/notification_preference_item.dart';
import 'package:campus_api/src/model/notification_preferences_update_request.dart';
import 'package:campus_api/src/model/notification_response.dart';
import 'package:campus_api/src/model/notifications_read_request.dart';
import 'package:campus_api/src/model/offering_create_request.dart';
import 'package:campus_api/src/model/offering_response.dart';
import 'package:campus_api/src/model/payment_method.dart';
import 'package:campus_api/src/model/payment_method_type.dart';
import 'package:campus_api/src/model/ranked_tutor_response.dart';
import 'package:campus_api/src/model/rating_context.dart';
import 'package:campus_api/src/model/rating_create_request.dart';
import 'package:campus_api/src/model/rating_page_response.dart';
import 'package:campus_api/src/model/rating_response.dart';
import 'package:campus_api/src/model/ready_response.dart';
import 'package:campus_api/src/model/refresh_request.dart';
import 'package:campus_api/src/model/register_request.dart';
import 'package:campus_api/src/model/register_response.dart';
import 'package:campus_api/src/model/report_create_request.dart';
import 'package:campus_api/src/model/report_page_response.dart';
import 'package:campus_api/src/model/report_response.dart';
import 'package:campus_api/src/model/report_status.dart';
import 'package:campus_api/src/model/report_target_type.dart';
import 'package:campus_api/src/model/report_update_request.dart';
import 'package:campus_api/src/model/resend_code_request.dart';
import 'package:campus_api/src/model/reset_password_request.dart';
import 'package:campus_api/src/model/run_create_request.dart';
import 'package:campus_api/src/model/run_location.dart';
import 'package:campus_api/src/model/run_location_update_request.dart';
import 'package:campus_api/src/model/run_order_create_request.dart';
import 'package:campus_api/src/model/run_order_response.dart';
import 'package:campus_api/src/model/run_order_status.dart';
import 'package:campus_api/src/model/run_page_response.dart';
import 'package:campus_api/src/model/run_response.dart';
import 'package:campus_api/src/model/run_status.dart';
import 'package:campus_api/src/model/run_status_update_request.dart';
import 'package:campus_api/src/model/run_user_summary.dart';
import 'package:campus_api/src/model/subscription_response.dart';
import 'package:campus_api/src/model/token_response.dart';
import 'package:campus_api/src/model/tutor_search_response.dart';
import 'package:campus_api/src/model/user_me_response.dart';
import 'package:campus_api/src/model/user_public_response.dart';
import 'package:campus_api/src/model/user_role.dart';
import 'package:campus_api/src/model/user_update_request.dart';
import 'package:campus_api/src/model/validation_error.dart';
import 'package:campus_api/src/model/verify_request.dart';

part 'serializers.g.dart';

@SerializersFor([
  AppSchemasAuthMessageResponse,
  AppSchemasConversationMessageResponse,
  BanRequest,
  ChatCreateRequest,
  ChatMembershipResponse,
  ChatMessageCreateRequest,
  ChatMessageDeleteRequest,
  ChatMessagePageResponse,
  ChatMessageResponse,
  ChatPageResponse,
  ChatResponse,
  ChatRole,
  ChatVisibility,
  ConversationContext,
  ConversationCreateRequest,
  ConversationPageResponse,
  ConversationResponse,
  CourseResponse,
  DailyMetricItem,
  FlagItem,
  FoodSpotCategory,
  FoodSpotResponse,
  ForgotPasswordRequest,
  HTTPValidationError,
  HealthResponse,
  ImageUploadUrlRequest,
  ImageUploadUrlResponse,
  ListingCategory,
  ListingCondition,
  ListingCreateRequest,
  ListingImageResponse,
  ListingPageResponse,
  ListingResponse,
  ListingStatus,
  ListingUpdateRequest,
  LocationInner,
  LoginRequest,
  LogoutRequest,
  MessageCreateRequest,
  MessagePageResponse,
  MetricsResponse,
  ModerationStatus,
  MuteRequest,
  NotificationPageResponse,
  NotificationPreferenceItem,
  NotificationPreferencesUpdateRequest,
  NotificationResponse,
  NotificationsReadRequest,
  OfferingCreateRequest,
  OfferingResponse,
  PaymentMethod,
  PaymentMethodType,
  RankedTutorResponse,
  RatingContext,
  RatingCreateRequest,
  RatingPageResponse,
  RatingResponse,
  ReadyResponse,
  RefreshRequest,
  RegisterRequest,
  RegisterResponse,
  ReportCreateRequest,
  ReportPageResponse,
  ReportResponse,
  ReportStatus,
  ReportTargetType,
  ReportUpdateRequest,
  ResendCodeRequest,
  ResetPasswordRequest,
  RunCreateRequest,
  RunLocation,
  RunLocationUpdateRequest,
  RunOrderCreateRequest,
  RunOrderResponse,
  RunOrderStatus,
  RunPageResponse,
  RunResponse,
  RunStatus,
  RunStatusUpdateRequest,
  RunUserSummary,
  SubscriptionResponse,
  TokenResponse,
  TutorSearchResponse,
  UserMeResponse,
  UserPublicResponse,
  UserRole,
  UserUpdateRequest,
  ValidationError,
  VerifyRequest,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(NotificationPreferenceItem)]),
        () => ListBuilder<NotificationPreferenceItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(FoodSpotResponse)]),
        () => ListBuilder<FoodSpotResponse>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CourseResponse)]),
        () => ListBuilder<CourseResponse>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(FlagItem)]),
        () => ListBuilder<FlagItem>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
