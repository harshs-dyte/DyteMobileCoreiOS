//
//  RtkParticipantEventListner.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 22/02/23.
//

import RealtimeKitCore
import UIKit

class RtkParticipantUpdateEventListner  {
    private var participantAudioStateCompletion:((Bool)->Void)?
    private var participantVideoStateCompletion:((Bool)->Void)?
    
    private var participantObserveAudioStateCompletion:((Bool,RtkParticipantUpdateEventListner)->Void)?
    private var participantObserveVideoStateCompletion:((Bool,RtkParticipantUpdateEventListner)->Void)?
    private var participantPinStateCompletion:((Bool)->Void)?
    private var participantUnPinStateCompletion:((Bool)->Void)?
    private var participantObservePinStateCompletion:((Bool,RtkParticipantUpdateEventListner)->Void)?
    private let isDebugModeOn = RealtimeKitUI.isDebugModeOn
    
    let participant: RtkMeetingParticipant
    
    init(participant: RtkMeetingParticipant) {
        self.participant = participant
        participant.addParticipantUpdateListener(participantUpdateListener: self)
    }
    
    public func observeAudioState(update:@escaping(_ isEnabled: Bool,_ observer: RtkParticipantUpdateEventListner)->Void) {
        participantObserveAudioStateCompletion = update
    }
    
    public func observePinState(update:@escaping(_ isPinned: Bool,_ observer: RtkParticipantUpdateEventListner)->Void) {
        participantObservePinStateCompletion = update
    }
    
    public func observeVideoState(update:@escaping(_ isEnabled: Bool,_ observer: RtkParticipantUpdateEventListner)->Void){
        participantObserveVideoStateCompletion = update
    }
    
    public func muteAudio(completion:@escaping(_ isEnabled: Bool)->Void) {
        self.participantAudioStateCompletion = completion
        if let remoteParticipant = self.participant as? RtkRemoteParticipant {
            remoteParticipant.disableAudio()
        }
    }
    
    public func muteVideo(completion:@escaping(_ isEnabled: Bool)->Void) {
        self.participantVideoStateCompletion = completion
        if let remoteParticipant = self.participant as? RtkRemoteParticipant {
            remoteParticipant.disableVideo()
        }
    }
    
    public func pin(completion:@escaping(Bool)->Void) {
        self.participantPinStateCompletion = completion
        self.participant.pin()
    }
    
    public func unPin(completion:@escaping(Bool)->Void) {
        self.participantUnPinStateCompletion = completion
        self.participant.unpin()
    }
    
    
    public func clean() {
        self.participant.removeParticipantUpdateListener(participantUpdateListener: self)
    }
}

extension RtkParticipantUpdateEventListner: RtkParticipantUpdateListener {
    func onAudioUpdate(participant: RtkMeetingParticipant, isEnabled: Bool) {
        self.participantObserveAudioStateCompletion?(isEnabled, self)
        self.participantAudioStateCompletion?(isEnabled)
        self.participantAudioStateCompletion = nil
    }
    
    func onPinned(participant: RtkMeetingParticipant) {
        self.participantPinStateCompletion?(true)
        self.participantPinStateCompletion = nil
        self.participantObservePinStateCompletion?(true, self)
    }
    
    func onUnpinned(participant: RtkMeetingParticipant) {
        self.participantUnPinStateCompletion?(true)
        self.participantUnPinStateCompletion = nil
        self.participantObservePinStateCompletion?(false, self)
    }
    
    func onUpdate(participant: RtkMeetingParticipant) {
        
    }
    
    func onScreenShareUpdate(participant: RtkMeetingParticipant, isEnabled: Bool) {
        
    }
    
    func onVideoUpdate(participant: RtkMeetingParticipant, isEnabled: Bool) {
        self.participantObserveVideoStateCompletion?(isEnabled,self)
        self.participantVideoStateCompletion?(isEnabled)
        self.participantVideoStateCompletion = nil
    }
}


public class RtkWaitListParticipantUpdateEventListner  {
    
    public var participantJoinedCompletion:((RtkMeetingParticipant)->Void)?
    public var participantRemovedCompletion:((RtkMeetingParticipant)->Void)?
    public var participantRequestAcceptedCompletion:((RtkMeetingParticipant)->Void)?
    public var participantRequestRejectCompletion:((RtkMeetingParticipant)->Void)?
    
    let mobileClient: RealtimeKitClient
    
    public init(mobileClient: RealtimeKitClient) {
        self.mobileClient = mobileClient
        self.mobileClient.addWaitlistEventsListener(waitlistEventsListener: self)
    }
    private let isDebugModeOn = RealtimeKitUI.isDebugModeOn
    
    public func clean() {
        removeRegisterListner()
    }
    public func acceptWaitingRequest(participant: RtkRemoteParticipant) {
        mobileClient.participants.acceptWaitingRoomRequest(id: participant.id)
    }
    
    public func rejectWaitingRequest(participant: RtkRemoteParticipant) {
        mobileClient.participants.rejectWaitingRoomRequest(id: participant.id)
    }
    
    private func removeRegisterListner() {
        self.mobileClient.removeWaitlistEventsListener(waitlistEventsListener: self)
    }
    
    deinit{
        print("RtkParticipantEventListner deallocing")
    }
}

extension RtkWaitListParticipantUpdateEventListner: RtkWaitlistEventsListener {
    public func onWaitListParticipantAccepted(participant: RtkRemoteParticipant) {
        if isDebugModeOn {
            print("Debug RtkUIKit | onWaitListParticipantAccepted \(participant.name)")
        }
        DispatchQueue.main.async {
            self.participantRequestAcceptedCompletion?(participant)
        }
    }
    
    public func onWaitListParticipantRejected(participant: RtkRemoteParticipant) {
        if isDebugModeOn {
            print("Debug RtkUIKit | onWaitListParticipantRejected \(participant.name) \(participant.id) self \(participant.id)")
        }
        self.participantRequestRejectCompletion?(participant)
    }
    
    
    public func onWaitListParticipantClosed(participant: RtkRemoteParticipant) {
        if isDebugModeOn {
            print("Debug RtkUIKit | onWaitListParticipantClosed \(participant.name)")
        }
        self.participantRemovedCompletion?(participant)
    }
    
    public func onWaitListParticipantJoined(participant: RtkRemoteParticipant) {
        if isDebugModeOn {
            print("Debug RtkUIKit | onWaitListParticipantJoined \(participant.name)")
        }
        self.participantJoinedCompletion?(participant)
        
    }
}
