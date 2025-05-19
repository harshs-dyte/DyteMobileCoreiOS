//
//  RtkVideoPeerViewModel.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 06/01/23.
//

import RealtimeKitCore

public class VideoPeerViewModel {
    
    public var audioUpdate: (()->Void)?
    public var videoUpdate: (()->Void)?
    public var loadNewParticipant: ((RtkMeetingParticipant)->Void)?
    
    public var nameInitialsUpdate: (()->Void)?
    public var nameUpdate: (()->Void)?
    
    let showSelfPreviewVideo: Bool
    var participant: RtkMeetingParticipant!
    private let isDebugModeOn = RealtimeKitUI.isDebugModeOn
    let mobileClient: RealtimeKitClient
    let showScreenShareVideoView: Bool
    private var participantUpdateListner: RtkParticipantUpdateEventListner?
    
    public init(meeting: RealtimeKitClient, participant: RtkMeetingParticipant, showSelfPreviewVideo: Bool, showScreenShareVideoView: Bool = false) {
        self.showSelfPreviewVideo = showSelfPreviewVideo
        self.showScreenShareVideoView = showScreenShareVideoView
        self.mobileClient = meeting
        self.participant = participant
        update()
    }
    
    public func set(participant: RtkMeetingParticipant) {
        self.participant = participant
        self.loadNewParticipant?(participant)
        update()
    }
    
    public func refreshInitialName() {
        nameInitialsUpdate?()
    }
    
    public func refreshNameTag() {
        nameUpdate?()
    }
    
    
    private func addUpdatesListner() {
        participantUpdateListner?.observeAudioState(update: { [weak self] isEnabled, observer in
            guard let self = self else {return}
            self.audioUpdate?()
        })
        participantUpdateListner?.observeVideoState(update: { [weak self] isEnabled, observer in
            guard let self = self else {return}
            self.videoUpdate?()
        })
    }
    
    private func update() {
        self.refreshNameTag()
        self.refreshInitialName()
        participantUpdateListner?.clean()
        participantUpdateListner = RtkParticipantUpdateEventListner(participant: participant)
        addUpdatesListner()
    }
}




