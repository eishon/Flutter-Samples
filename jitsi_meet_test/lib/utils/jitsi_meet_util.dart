import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';

class JitsiMeetUtil {
  final String serverText = 'https://meet.jit.si/http-pre-bind';

  String roomName = '';
  String subject = '';
  String name = '';
  String email = '';
  bool isAudioOnly = true;
  bool isAudioMuted = true;
  bool isVideoMuted = true;

  void initListeners(JitsiMeetUtilListener listener) {
    JitsiMeet.addListener(
      JitsiMeetingListener(
        onConferenceWillJoin: listener.onConferenceWillJoin,
        onConferenceJoined: listener.onConferenceJoined,
        onConferenceTerminated: listener.onConferenceTerminated,
        onPictureInPictureWillEnter: listener.onPictureInPictureWillEnter,
        onPictureInPictureTerminated: listener.onPictureInPictureTerminated,
        onError: listener.onError,
      ),
    );
  }

  void config({
    @required roomName,
    subjectText = 'remoshot',
    name = 'User',
    email = 'user@email.com',
    isAudioOnly = true,
    isAudioMuted = true,
    isVideoMuted = false,
  }) {
    this.roomName = roomName;
    this.subject = subject;
    this.name = name;
    this.email = email;
    this.isAudioOnly = true;
    this.isAudioMuted = true;
    this.isVideoMuted = true;
  }

  Future<void> joinMeeting() async {
    String serverUrl = serverText?.trim()?.isEmpty ?? "" ? null : serverText;

    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.addPeopleEnabled = false;
      featureFlag.inviteEnabled = false;
      featureFlag.chatEnabled = false;
      featureFlag.calendarEnabled = false;
      featureFlag.closeCaptionsEnabled = false;
      featureFlag.liveStreamingEnabled = false;
      featureFlag.raiseHandEnabled = false;
      featureFlag.recordingEnabled = false;
      featureFlag.toolboxAlwaysVisible = false;

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
      }

      //uncomment to modify video resolution
      //featureFlag.resolution = FeatureFlagVideoResolution.MD_RESOLUTION;

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = roomName
        ..serverURL = serverUrl
        ..subject = subject
        ..userDisplayName = name
        ..userEmail = email
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlag = featureFlag;

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
          debugPrint("${options.room} will join with message: $message");
        }, onConferenceJoined: ({message}) {
          debugPrint("${options.room} joined with message: $message");
        }, onConferenceTerminated: ({message}) {
          debugPrint("${options.room} terminated with message: $message");
        }, onPictureInPictureWillEnter: ({message}) {
          debugPrint("${options.room} entered PIP mode with message: $message");
        }, onPictureInPictureTerminated: ({message}) {
          debugPrint("${options.room} exited PIP mode with message: $message");
        }),
        // by default, plugin default constraints are used
        //roomNameConstraints: new Map(), // to disable all constraints
        //roomNameConstraints: customContraints, // to use your own constraint(s)
      );
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  void dispose() {
    JitsiMeet.removeAllListeners();
  }

  static final Map<RoomNameConstraintType, RoomNameConstraint>
      customContraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
              .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };
}

abstract class JitsiMeetUtilListener {
  void onConferenceWillJoin({message});

  void onConferenceJoined({message});

  void onConferenceTerminated({message});

  void onPictureInPictureWillEnter({message});

  void onPictureInPictureTerminated({message});

  onError(error);
}
