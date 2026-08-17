import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_data.freezed.dart';
part 'post_data.g.dart';

mixin PostDataMixin {
  Map<String, dynamic> toJson();
}

@Freezed(fromJson: false, toJson: true)
abstract class RegisterPostData with _$RegisterPostData, PostDataMixin {
  RegisterPostData._();

  factory RegisterPostData({
    required String acct,
    required String pw,
    required String creating,
    required String goto,
  }) = _RegisterPostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class LoginPostData with _$LoginPostData, PostDataMixin {
  LoginPostData._();

  factory LoginPostData({
    required String acct,
    required String pw,
    required String goto,
  }) = _LoginPostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class FavoritePostData with _$FavoritePostData, PostDataMixin {
  FavoritePostData._();

  factory FavoritePostData({
    required String acct,
    required String pw,
    required int id,
    String? un,
  }) = _FavoritePostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class VotePostData with _$VotePostData, PostDataMixin {
  VotePostData._();

  factory VotePostData({
    required String acct,
    required String pw,
    required int id,
    required String how,
  }) = _VotePostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class FlagPostData with _$FlagPostData, PostDataMixin {
  FlagPostData._();

  factory FlagPostData({
    required String acct,
    required String pw,
    required int id,
    String? un,
  }) = _FlagPostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class CommentPostData with _$CommentPostData, PostDataMixin {
  CommentPostData._();

  factory CommentPostData({
    required String acct,
    required String pw,
    required int parent,
    required String text,
  }) = _CommentPostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class EditPostData with _$EditPostData, PostDataMixin {
  EditPostData._();

  factory EditPostData({
    required String hmac,
    required int id,
    String? title,
    String? text,
  }) = _EditPostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class DeletePostData with _$DeletePostData, PostDataMixin {
  DeletePostData._();

  factory DeletePostData({
    required String hmac,
    required int id,
    required String d,
  }) = _DeletePostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class SubmitPostData with _$SubmitPostData, PostDataMixin {
  SubmitPostData._();

  factory SubmitPostData({
    required String fnid,
    required String fnop,
    required String title,
    String? url,
    String? text,
  }) = _SubmitPostData;
}

@Freezed(fromJson: false, toJson: true)
abstract class FormPostData with _$FormPostData, PostDataMixin {
  FormPostData._();

  factory FormPostData({
    required String acct,
    required String pw,
    int? id,
  }) = _FormPostData;
}
