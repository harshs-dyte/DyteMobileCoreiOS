//
//  ParticipantViewModel.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 15/02/23.
//

import RealtimeKitCore
import Foundation

public class WebinarParticipantViewControllerModel {
    
    let mobileClient: RealtimeKitClient
    let waitlistEventListner: RtkWaitListParticipantUpdateEventListner
    let dyteSelfListner: RtkEventSelfListner
    private let isDebugModeOn = RealtimeKitUI.isDebugModeOn
    private let searchControllerMinimumParticipant = 5
    
    required init(mobileClient: RealtimeKitClient) {
        self.mobileClient = mobileClient
        self.waitlistEventListner = RtkWaitListParticipantUpdateEventListner(mobileClient: mobileClient)
        self.dyteSelfListner = RtkEventSelfListner(mobileClient: mobileClient)
        
        mobileClient.addParticipantsEventListener(participantsEventListener: self)
        mobileClient.addStageEventListener(stageEventListener: self)
        addObserver()
    }
    
    private func addObserver() {
        self.waitlistEventListner.participantJoinedCompletion = { [weak self] partipant in
            guard let self = self, let completion = self.completion else {return}
            self.refresh(completion: completion)
        }
        self.waitlistEventListner.participantRemovedCompletion = { [weak self] partipant in
            guard let self = self, let completion = self.completion else {return}
            self.refresh(completion: completion)
        }
        self.waitlistEventListner.participantRequestAcceptedCompletion = { [weak self] partipant in
            guard let self = self, let completion = self.completion else {return}
            self.refresh(completion: completion)
        }
        self.waitlistEventListner.participantRequestRejectCompletion = { [weak self] partipant in
            guard let self = self, let completion = self.completion else {return}
            self.refresh(completion: completion)
        }
    }
    
    func acceptAll() {
        let userId = self.mobileClient.stage.accessRequests.map {  return $0.userId }
        self.mobileClient.stage.grantAccess(userIds: userId)
    }
    
    func acceptAllWaitingRoomRequest() {
        self.mobileClient.participants.acceptAllWaitingRoomRequests()
    }
    
    func rejectAll() {
        let userId = self.mobileClient.stage.accessRequests.map {  return $0.userId }
        self.mobileClient.stage.denyAccess(userIds: userId)
    }
    
    private func revokeInvitationToJoinStage(participant: RtkMeetingParticipant) {
        if let completion = self.completion {
            refresh(completion: completion)
        }
    }
    
    private func participantInviteToJoinStage(participant: RtkMeetingParticipant) {
        if let completion = self.completion {
            refresh(completion: completion)
        }
    }
    
    var dataSourceTableView = DataSourceStandard<BaseConfiguratorSection<CollectionTableConfigurator>>()
    
    private var completion: ((Bool)->Void)?
    
    public func load(completion:@escaping(Bool)->Void) {
        self.completion = completion
        refresh(completion: completion)
    }
    
    private func refresh(completion:@escaping(Bool)->Void) {
        self.dataSourceTableView.sections.removeAll()
        let minimumParticpantCountToShowSearchBar = searchControllerMinimumParticipant
        
        let sectionZero = self.getWaitlistSection()
        let sectionOne = self.getJoinStageRequestSection()
        let sectionTwo = self.getOnStageSection(minimumParticpantCountToShowSearchBar: minimumParticpantCountToShowSearchBar)
        let sectionThree = self.getInCallViewers(minimumParticpantCountToShowSearchBar: minimumParticpantCountToShowSearchBar)
        
        self.dataSourceTableView.sections.append(sectionZero)
        self.dataSourceTableView.sections.append(sectionOne)
        self.dataSourceTableView.sections.append(sectionTwo)
        self.dataSourceTableView.sections.append(sectionThree)
        completion(true)
    }
    
    func clean() {
        mobileClient.removeParticipantsEventListener(participantsEventListener: self)
        mobileClient.removeStageEventListener(stageEventListener: self)
        waitlistEventListner.clean()
    }
    
    deinit {
        
    }
}

extension WebinarParticipantViewControllerModel {
    
    private func getWaitlistSection() -> BaseConfiguratorSection<CollectionTableConfigurator> {
        let sectionOne = BaseConfiguratorSection<CollectionTableConfigurator>()
        let waitListedParticipants = self.mobileClient.participants.waitlisted
        if waitListedParticipants.count > 0 {
            var participantCount = ""
            if waitListedParticipants.count > 1 {
                participantCount = " (\(waitListedParticipants.count))"
            }
            sectionOne.insert(TableItemConfigurator<TitleTableViewCell,TitleTableViewCellModel>(model:TitleTableViewCellModel(title: "Waiting\(participantCount)")))
            
            for (index, participant) in waitListedParticipants.enumerated() {
                var image: RtkImage? = nil
                if let imageUrl = participant.picture, let url = URL(string: imageUrl) {
                    image = RtkImage(url: url)
                }
                var showBottomSeparator = true
                if index == waitListedParticipants.count - 1 {
                    showBottomSeparator = false
                }
                sectionOne.insert(TableItemConfigurator<ParticipantWaitingTableViewCell,ParticipantWaitingTableViewCellModel>(model:ParticipantWaitingTableViewCellModel(title: participant.name, image: image, showBottomSeparator: showBottomSeparator, showTopSeparator: false, participant: participant)))
            }
            
            if waitListedParticipants.count > 1 {
                sectionOne.insert(TableItemConfigurator<AcceptButtonWaitingTableViewCell,ButtonTableViewCellModel>(model:ButtonTableViewCellModel(buttonTitle: "Accept All")))
            }
        }
        
        return sectionOne
    }
    
    private func getJoinStageRequestSection() -> BaseConfiguratorSection<CollectionTableConfigurator> {
        let sectionOne = BaseConfiguratorSection<CollectionTableConfigurator>()
        let waitListedParticipants = self.mobileClient.stage.accessRequests
        if waitListedParticipants.count > 0 {
            var participantCount = ""
            if waitListedParticipants.count > 1 {
                participantCount = " (\(waitListedParticipants.count))"
            }
            sectionOne.insert(TableItemConfigurator<TitleTableViewCell,TitleTableViewCellModel>(model:TitleTableViewCellModel(title: "Join stage requests\(participantCount)")))
            
            for (index, participant) in waitListedParticipants.enumerated() {
                let image: RtkImage? = nil
                var showBottomSeparator = true
                if index == waitListedParticipants.count - 1 {
                    showBottomSeparator = false
                }
                
                sectionOne.insert(TableItemConfigurator<OnStageWaitingRequestTableViewCell,OnStageParticipantWaitingRequestTableViewCellModel>(model:OnStageParticipantWaitingRequestTableViewCellModel(title: participant.name, image: image, showBottomSeparator: showBottomSeparator, showTopSeparator: false, participant: participant)))
            }
            
            if waitListedParticipants.count > 1 {
                sectionOne.insert(TableItemConfigurator<AcceptButtonJoinStageRequestTableViewCell,ButtonTableViewCellModel>(model:ButtonTableViewCellModel(buttonTitle: "Accept All")))
                sectionOne.insert(TableItemConfigurator<RejectButtonJoinStageRequestTableViewCell,ButtonTableViewCellModel>(model:ButtonTableViewCellModel(buttonTitle: "Reject All")))
            }
        }
        return sectionOne
    }
    
    private func getOnStageSection(minimumParticpantCountToShowSearchBar: Int) ->  BaseConfiguratorSection<CollectionTableConfigurator> {
        let arrJoinedParticipants = self.mobileClient.participants.joined
        let selfIsOnStage = self.mobileClient.localUser.stageStatus==StageStatus.onStage
        
        var onStageRemoteParticipants = [RtkRemoteParticipant]()
        
        for participant in arrJoinedParticipants {
            if participant.stageStatus == StageStatus.onStage {
                onStageRemoteParticipants.append(participant)
            }
        }
        let sectionTwo =  BaseConfiguratorSection<CollectionTableConfigurator>()
        
        var onStageParticipants = [RtkMeetingParticipant]()
        if(selfIsOnStage){
            onStageParticipants.append(self.mobileClient.localUser)
        }
        
        onStageRemoteParticipants.forEach { onStageParticipants.append($0) }
        
        if onStageParticipants.count > 0 {
            var participantCount = ""
            if onStageParticipants.count > 1 {
                participantCount = " (\(onStageParticipants.count))"
            }
            sectionTwo.insert(TableItemConfigurator<TitleTableViewCell,TitleTableViewCellModel>(model:TitleTableViewCellModel(title: "On stage\(participantCount)")))
            
            if onStageParticipants.count > minimumParticpantCountToShowSearchBar {
                sectionTwo.insert(TableItemConfigurator<SearchTableViewCell,SearchTableViewCellModel>(model:SearchTableViewCellModel(placeHolder: "Search Participant")))
            }
            
            for (index, participant) in onStageParticipants.enumerated() {
                var showBottomSeparator = true
                if index == onStageParticipants.count - 1 {
                    showBottomSeparator = false
                }
                func showMoreButton() -> Bool {
                    var canShow = false
                    let hostPermission = self.mobileClient.localUser.permissions.host
                    
                    if hostPermission.canPinParticipant && participant.isPinned == false {
                        canShow = true
                    }
                    
                    if hostPermission.canMuteAudio && participant.audioEnabled == true {
                        canShow = true
                    }
                    
                    if hostPermission.canMuteVideo && participant.videoEnabled == true {
                        canShow = true
                    }
                    
                    if hostPermission.canKickParticipant {
                        canShow = true
                    }
                    
                    return canShow
                }
                
                var name = participant.name
                if participant.userId == mobileClient.localUser.userId {
                    name = "\(participant.name) (you)"
                }
                var image: RtkImage? = nil
                if let imageUrl = participant.picture, let url = URL(string: imageUrl) {
                    image = RtkImage(url: url)
                }
                
                
                sectionTwo.insert(TableItemSearchableConfigurator<ParticipantInCallTableViewCell,ParticipantInCallTableViewCellModel>(model:ParticipantInCallTableViewCellModel(image: image, title: name, showBottomSeparator: showBottomSeparator, showTopSeparator: false, participantUpdateEventListner: RtkParticipantUpdateEventListner(participant: participant), showMoreButton: showMoreButton())))
            }
        }
        return sectionTwo
    }
    
    private func getInCallViewers(minimumParticpantCountToShowSearchBar: Int) ->  BaseConfiguratorSection<CollectionTableConfigurator> {
        var viewerRemoteParticipants = [RtkRemoteParticipant]()
        viewerRemoteParticipants.append(contentsOf: self.mobileClient.stage.viewers)
        let shouldShowSelfInViewers = self.mobileClient.localUser.stageStatus != StageStatus.onStage
        let sectionTwo =  BaseConfiguratorSection<CollectionTableConfigurator>()
        
        var allViewerParticipants = [RtkMeetingParticipant]()
        if(shouldShowSelfInViewers){
            allViewerParticipants.append(self.mobileClient.localUser)
        }
        
        viewerRemoteParticipants.forEach { allViewerParticipants.append($0) }
        
        if allViewerParticipants.count > 0 {
            var participantCount = ""
            if allViewerParticipants.count > 1 {
                participantCount = " (\(allViewerParticipants.count))"
            }
            sectionTwo.insert(TableItemConfigurator<TitleTableViewCell,TitleTableViewCellModel>(model:TitleTableViewCellModel(title: "Viewers\(participantCount)")))
            
            if allViewerParticipants.count > minimumParticpantCountToShowSearchBar {
                sectionTwo.insert(TableItemConfigurator<SearchTableViewCell,SearchTableViewCellModel>(model:SearchTableViewCellModel(placeHolder: "Search Viewers")))
                
            }
            
            for (index, participant) in allViewerParticipants.enumerated() {
                var showBottomSeparator = true
                if index == allViewerParticipants.count - 1 {
                    showBottomSeparator = false
                }
                
                func showMoreButton() -> Bool {
                    var canShow = false
                    let hostPermission = self.mobileClient.localUser.permissions.host
                    
                    if self.mobileClient.localUser.canDoParticipantHostControls() || hostPermission.canAcceptRequests == true {
                        canShow = true
                    }
                    return canShow
                }
                
                var name = participant.name
                if participant.userId == mobileClient.localUser.userId {
                    name = "\(participant.name) (you)"
                }
                var image: RtkImage? = nil
                if let imageUrl = participant.picture, let url = URL(string: imageUrl) {
                    image = RtkImage(url: url)
                }
                sectionTwo.insert(TableItemSearchableConfigurator<WebinarViewersTableViewCell,WebinarViewersTableViewCellModel>(model:WebinarViewersTableViewCellModel(image: image, title: name, showBottomSeparator: showBottomSeparator, showTopSeparator: false,  participantUpdateEventListner: RtkParticipantUpdateEventListner(participant: participant), showMoreButton: showMoreButton())))
            }
        }
        return sectionTwo
    }
}

extension WebinarParticipantViewControllerModel: RtkParticipantsEventListener {
    
    public func onActiveParticipantsChanged(active: [RtkRemoteParticipant]) {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
    
    public func onParticipantJoin(participant: RtkRemoteParticipant) {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
    public func onParticipantLeave(participant: RtkRemoteParticipant) {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
    public func onActiveSpeakerChanged(participant: RtkRemoteParticipant?) {
        
    }
    
    public func onAllParticipantsUpdated(allParticipants: [RtkParticipant]) {
        
    }
    
    public func onAudioUpdate(participant: RtkRemoteParticipant, isEnabled_ isEnabled: Bool) {
        
    }
    
    public func onNewBroadcastMessage(type: String, payload: [String : Any]) {
        
    }
    
    public func onParticipantPinned(participant: RtkRemoteParticipant) {
        
    }
    
    public func onParticipantUnpinned(participant: RtkRemoteParticipant) {
        
    }
    
    public func onScreenShareUpdate(participant: RtkRemoteParticipant, isEnabled_ isEnabled: Bool) {
        
    }
    
    public func onUpdate(participants: RtkParticipants) {
        
    }
    
    public func onVideoUpdate(participant: RtkRemoteParticipant, isEnabled_ isEnabled: Bool) {
        
    }
}

extension WebinarParticipantViewControllerModel: RtkStageEventListener {
    public func onNewStageAccessRequest(participant: RtkRemoteParticipant) {
        
    }
    
    public func onPeerStageStatusUpdated(participant: RtkRemoteParticipant, oldStatus: RealtimeKitCore.StageStatus, newStatus: RealtimeKitCore.StageStatus) {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }

    }
    
    public func onStageAccessRequestRejected() {

    }
    
    public func onStageAccessRequestsUpdated(accessRequests: [RtkRemoteParticipant]) {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
    public func onStageStatusUpdated(oldStatus: RealtimeKitCore.StageStatus, newStatus: RealtimeKitCore.StageStatus) {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
        
    public func onStageAccessRequestAccepted() {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
    public func onRemovedFromStage() {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
    public func onStageRequestsUpdated(accessRequests: [RtkRemoteParticipant]) {
        if let completion = self.completion {
            self.refresh(completion: completion)
        }
    }
    
    
}
