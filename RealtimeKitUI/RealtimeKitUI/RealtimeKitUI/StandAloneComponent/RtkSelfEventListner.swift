//
//  RtkSelfEventListner.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 22/02/23.
//

import RealtimeKitCore
import UIKit

public class RtkEventSelfListner  {
    private static var currentInstance = 0
    public enum Reconnection {
        case start
        case success
        case failed
    }
    private var selfAudioStateCompletion:((Bool)->Void)?
    private var selfVideoStateCompletion:((Bool)->Void)?
    private var selfObserveVideoStateCompletion:((Bool)->Void)?
    private var selfObserveAudioStateCompletion:((Bool)->Void)?
    
    private var selfObserveWebinarStageStatus:((StageStatus)->Void)?
    private var selfObserveRequestToJoinStage:(()->Void)?
    private var observeSelfPermissionChanged:(()->Void)?
    private var selfWebinarJoinedStateCompletion:((Bool)->Void)?
    private var selfWebinarLeaveStateCompletion:((Bool)->Void)?
    private var selfRequestToGetPermissionJoinedStateCompletion:((Bool)->Void)?
    private var selfCancelRequestToGetPermissionToJoinStageCompletion:((Bool)->Void)?
    private var selfMeetingInitStateCompletion:((Bool, String?)->Void)?
    private var selfLeaveStateCompletion:((Bool)->Void)?
    private var selfLeaveMeetingForAllCompletion:((Bool)->Void)?
    private var selfEndMeetingForAllCompletion:((Bool)->Void)?
    private var selfRemovedStateCompletion:((Bool)->Void)?
    private var selfTabBarSyncStateCompletion:((String)->Void)?
    private var selfObserveReconnectionStateCompletion:((Reconnection)->Void)?
    
    var waitListStatusUpdate:((WaitListStatus)->Void)?
    
    var dyteMobileClient: RealtimeKitClient
    let identifier: String
    public init(mobileClient: RealtimeKitClient, identifier: String = "Default") {
        self.identifier = identifier
        self.dyteMobileClient = mobileClient
        mobileClient.addMeetingRoomEventsListener(meetingRoomEventsListener: self)
        mobileClient.addSelfEventsListener(selfEventsListener: self)
        mobileClient.addStageEventListener(stageEventListener: self)
        Self.currentInstance += 1
    }
    
    public func clean() {
        dyteMobileClient.removeMeetingRoomEventsListener(meetingRoomEventsListener: self)
        dyteMobileClient.removeSelfEventsListener(selfEventsListener: self)
        dyteMobileClient.removeStageEventListener(stageEventListener: self)
    }
    
    private let isDebugModeOn = RealtimeKitUI.isDebugModeOn
    
    public func toggleLocalAudio(completion: @escaping(_ isEnabled: Bool)->Void) {
        self.selfAudioStateCompletion = completion
        if self.dyteMobileClient.localUser.audioEnabled == true {
            self.dyteMobileClient.localUser.disableAudio() {_ in }
        } else {
            self.dyteMobileClient.localUser.enableAudio { _ in }
        }
    }
    
    public func observeSelfVideo(update:@escaping(_ enabled: Bool)->Void) {
        selfObserveVideoStateCompletion = update
    }
    
    public func observeSelfAudio(update:@escaping(_ enabled: Bool)->Void) {
        selfObserveAudioStateCompletion = update
    }
    
    public func observeSelfRemoved(update:((_ success: Bool)->Void)?) {
        self.selfRemovedStateCompletion = update
    }
    
    public func observeSelfMeetingEndForAll(update:((_ success: Bool)->Void)?) {
        self.selfEndMeetingForAllCompletion = update
    }
    
    public func observePluginScreenShareTabSync(update:((_ id: String)->Void)?) {
        self.selfTabBarSyncStateCompletion = update
    }
    
    public func observeMeetingReconnectionState(update: @escaping(_ state: Reconnection)-> Void) {
        self.selfObserveReconnectionStateCompletion = update
    }
    
    public func toggleLocalVideo(completion: @escaping(_ isEnabled: Bool)->Void) {
        self.selfVideoStateCompletion = completion
        if self.dyteMobileClient.localUser.videoEnabled == true {
            self.dyteMobileClient.localUser.disableVideo{_ in }
        }else {
            self.dyteMobileClient.localUser.enableVideo { _ in }
        }
    }
    
    public func isCameraPermissionGranted(alertPresentingController: UIViewController? = RtkUIUTility.getTopViewController()) -> Bool {
        if !self.dyteMobileClient.localUser.isCameraPermissionGranted {
            
            if let alertContoller = alertPresentingController {
                let alert = UIAlertController(title: "Camera", message: "Camera access is necessary to use this app.\n Please click settings to change the permission.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    // Handle cancel action if needed
                }))
                
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }))
                
                alertContoller.present(alert, animated: true, completion: nil)
            }
            
            return false
        } else {
            return true
        }
    }
    
    public func isMicrophonePermissionGranted(alertPresentingController: UIViewController? = RtkUIUTility.getTopViewController() ) -> Bool {
        if !self.dyteMobileClient.localUser.isMicrophonePermissionGranted {
            if let alertController = alertPresentingController {
                let alert = UIAlertController(title: "Microphone", message: "Microphone access is necessary to use this app.\n Please click settings to change the permission.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    // Handle cancel action if needed
                }))
                
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }))
                
                alertController.present(alert, animated: true, completion: nil)
            }
            return false
        } else {
            return true
        }
    }
    
    func toggleCamera() {
        DispatchQueue.main.async {
            self.toggleCamera(mobileClient: self.dyteMobileClient)
        }
    }
    
    private func toggleCamera(mobileClient: RealtimeKitClient) {
        let videoDevices = mobileClient.localUser.getVideoDevices()
        if mobileClient.localUser.getSelectedVideoDevice()?.type == .front {
            if let device = getVideoDevice(type: .rear) {
                mobileClient.localUser.setVideoDevice(rtkVideoDevice: device)
            }
        } else if mobileClient.localUser.getSelectedVideoDevice()?.type == .rear {
            if let device = getVideoDevice(type: .front) {
                mobileClient.localUser.setVideoDevice(rtkVideoDevice: device)
            }
        }
        
        func getVideoDevice(type: VideoDeviceType) -> RtkVideoDevice? {
            for device in videoDevices {
                if device.type == type {
                    return device
                }
            }
            return nil
        }
    }
    
    func initMeetingV2(info: RtkMeetingInfo,completion:@escaping (_ success: Bool, _ message: String?) -> Void) {
        self.selfMeetingInitStateCompletion = completion
        self.dyteMobileClient.doInit(realtimeKitMeetingInfo: info)
    }
    
    func leaveMeeting(kickAll: Bool, completion:@escaping(_ success: Bool)->Void) {
        if kickAll {
            self.dyteMobileClient.participants.kickAll()
            self.selfLeaveMeetingForAllCompletion = completion
        }else {
            self.dyteMobileClient.leaveRoom()
            self.selfLeaveStateCompletion = completion
        }
    }
    
    func joinWebinarStage(completion:@escaping (_ success: Bool) -> Void) {
        self.selfWebinarJoinedStateCompletion = completion
        self.dyteMobileClient.stage.join()
    }
    
    func leaveWebinarStage(completion:@escaping (_ success: Bool) -> Void) {
        self.selfWebinarLeaveStateCompletion = completion
        self.dyteMobileClient.stage.leave()
    }
    
    func requestForPermissionToJoinWebinarStage(completion:@escaping (_ success: Bool) -> Void) {
        self.selfRequestToGetPermissionJoinedStateCompletion = completion
        self.dyteMobileClient.stage.requestAccess()
    }
    
    func cancelRequestForPermissionToJoinWebinarStage(completion:@escaping (_ success: Bool) -> Void) {
        self.selfCancelRequestToGetPermissionToJoinStageCompletion = completion
        self.dyteMobileClient.stage.cancelRequestAccess()
    }
    
    public func observeWebinarStageStatus(update:@escaping(_ status: StageStatus)->Void) {
        self.selfObserveWebinarStageStatus = update
    }
    
    public func observeRequestToJoinStage(update:@escaping()->Void) {
        self.selfObserveRequestToJoinStage = update
    }
    
    public func observeSelfPermissionChanged(update:@escaping()->Void) {
        self.observeSelfPermissionChanged = update
    }
    
    deinit{
        Self.currentInstance -= 1
        if isDebugModeOn {
            print("RtkEventSelfListner deallocing identifier \(self.identifier) \(Self.currentInstance)")
        }
    }
}

extension RtkEventSelfListner: RtkStageEventListener {
    public func onNewStageAccessRequest(participant: RtkRemoteParticipant) {
        
    }
    
    public func onPeerStageStatusUpdated(participant: RtkRemoteParticipant, oldStatus: RealtimeKitCore.StageStatus, newStatus: RealtimeKitCore.StageStatus) {
        
    }
    
    public func onStageAccessRequestAccepted() {
        //This is called when host allow me to join stage but its depends on user action whether he want to join or not.
        if let update = self.selfObserveRequestToJoinStage {
            update()
        }
    }
    
    public func onStageAccessRequestRejected() {
        
    }
    
    public func onStageAccessRequestsUpdated(accessRequests: [RtkRemoteParticipant]) {
        
    }
    
    public func onStageStatusUpdated(oldStatus: RealtimeKitCore.StageStatus, newStatus: RealtimeKitCore.StageStatus) {
        if newStatus == .onStage {
            self.selfWebinarJoinedStateCompletion?(true)
        }
        self.selfObserveWebinarStageStatus?(newStatus)
    }
    
    
    public func onAddedToStage() {
        self.selfWebinarJoinedStateCompletion?(true)
    }
    
    
    private func onStageRequestWithdrawn(participant: RtkSelfParticipant) {
        self.selfCancelRequestToGetPermissionToJoinStageCompletion?(true)
    }
    
    public func onRemovedFromStage() {
        self.selfWebinarLeaveStateCompletion?(true)
    }
    
    public func onStageRequestsUpdated(accessRequests: [RtkRemoteParticipant]) {}
}

extension RtkEventSelfListner: RtkSelfEventsListener {
    public func onAudioDevicesUpdated() {
        
    }
    
    public func onMeetingRoomJoinedWithoutCameraPermission() {
        
    }
    
    public func onMeetingRoomJoinedWithoutMicPermission() {
        
    }
    
    public func onPinned() {
        
    }
    
    public func onScreenShareStartFailed(reason: String) {
        
    }
    
    public func onScreenShareUpdate(isEnabled: Bool) {
        
    }
    
    public func onUnpinned() {
        
    }
    
    public func onUpdate(participant_ participant: RtkSelfParticipant) {
    }
    
    public func onVideoDeviceChanged(videoDevice: RtkVideoDevice) {
        
    }
    
    public func onPermissionsUpdated(permission: SelfPermissions) {
        self.observeSelfPermissionChanged?()
    }
    
    public  func onAudioUpdate(isEnabled: Bool) {
        self.selfAudioStateCompletion?(isEnabled)
        self.selfObserveAudioStateCompletion?(isEnabled)
    }
    
    public func onRemovedFromMeeting() {
        self.selfRemovedStateCompletion?(true)
    }
    
    public func onVideoUpdate(isEnabled: Bool) {
        self.selfVideoStateCompletion?(isEnabled)
        self.selfObserveVideoStateCompletion?(isEnabled)
    }
    
    public func onWaitListStatusUpdate(waitListStatus: WaitListStatus) {
        self.waitListStatusUpdate?(waitListStatus)
    }
}

extension  RtkEventSelfListner: RtkMeetingRoomEventsListener {
    public func onMeetingInitStarted() {
        
    }
    
    public func onMeetingRoomJoinCompleted(meeting: RealtimeKitClient) {
        
    }
    
    public func onMeetingRoomJoinFailed(error: MeetingError) {
        
    }
    
    public func onMeetingRoomJoinStarted() {
        
    }
    
    public func onMeetingRoomLeaveStarted() {
        
    }
    
    public func onMediaConnectionUpdate(update: MediaConnectionUpdate) {
        
    }
    
    public func onSocketConnectionUpdate(newState: SocketConnectionState) {
        switch newState.socketState {
        case .connected:
            onReconnectedToMeetingRoom()
        case .reconnecting:
            onReconnectingToMeetingRoom()
        case .failed:
            onMeetingRoomReconnectionFailed()
        case .disconnected:
            break
        default:
            break
        }
    }
    
    private func onMeetingRoomReconnectionFailed() {
        if isDebugModeOn {
            print("Debug RtkUIKit | RtkEventSelfListner \(Self.currentInstance)  onMeetingRoomReconnectionFailed")
        }
        self.selfObserveReconnectionStateCompletion?(.failed)
    }
    
    private func onReconnectedToMeetingRoom() {
        if isDebugModeOn {
            print("Debug RtkUIKit | RtkEventSelfListner \(Self.currentInstance)  onReconnectedToMeetingRoom")
        }
        
        self.selfObserveReconnectionStateCompletion?(.success)
    }
    
    private func onReconnectingToMeetingRoom() {
        if isDebugModeOn {
            print("Debug RtkUIKit | RtkEventSelfListner \(Self.currentInstance) onReconnectingToMeetingRoom")
        }
        
        self.selfObserveReconnectionStateCompletion?(.start)
    }
    
    public func onActiveTabUpdate(meeting: RealtimeKitClient, activeTab: ActiveTab) {
        self.selfTabBarSyncStateCompletion?(activeTab.id)
    }
    
    public func onMeetingEnded() {
        if let completion = self.selfLeaveMeetingForAllCompletion {
            completion(true)
        }
        
        if let completion = self.selfEndMeetingForAllCompletion {
            completion(true)
        }
    }
    
    public func onMeetingInitCompleted(meeting: RealtimeKitClient) {
        dyteMobileClient.setUiKitInfo(name: "ios-ui-kit", version: Constants.sdkVersion)
        self.selfMeetingInitStateCompletion?(true, "")
    }
    
    public  func onMeetingInitFailed(error: MeetingError) {
        self.selfMeetingInitStateCompletion?(false, error.message)
    }
    
    public func onMeetingRoomLeaveCompleted() {
        if let completion = self.selfLeaveStateCompletion {
            completion(true)
        }
    }
}


