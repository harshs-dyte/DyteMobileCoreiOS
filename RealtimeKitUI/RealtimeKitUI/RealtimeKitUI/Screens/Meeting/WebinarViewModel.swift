//
//  WebinarViewModel.swift
//  RealtimeKitUI
//
//  Created by Shaunak Jagtap on 07/03/24.
//

import Foundation
import RealtimeKitCore


protocol RtkStageDelegate: AnyObject {
    func onPresentRequestAdded(participant: RtkRemoteParticipant)
    func onPresentRequestWithdrawn(participant: RtkRemoteParticipant)
}

class WebinarViewModel {
    var stageDelegate: RtkStageDelegate?
    private let dyteMobileClient: RealtimeKitClient
    
    public init(dyteMobileClient: RealtimeKitClient) {
        self.dyteMobileClient = dyteMobileClient
        dyteMobileClient.addStageEventListener(stageEventListener: self)
    }
}

extension WebinarViewModel: RtkStageEventListener {
    func onNewStageAccessRequest(participant: RtkRemoteParticipant) {
        
    }
    
    func onPeerStageStatusUpdated(participant: RtkRemoteParticipant, oldStatus: RealtimeKitCore.StageStatus, newStatus: RealtimeKitCore.StageStatus) {
        
    }
    
    func onRemovedFromStage() {
        
    }
    
    func onStageAccessRequestAccepted() {
        
    }
    
    func onStageAccessRequestRejected() {
        
    }
    
    func onStageAccessRequestsUpdated(accessRequests: [RtkRemoteParticipant]) {
        
    }
    
    func onStageStatusUpdated(oldStatus: RealtimeKitCore.StageStatus, newStatus: RealtimeKitCore.StageStatus) {
        
    }
    
    func onPresentRequestWithdrawn(participant: RtkRemoteParticipant) {
        stageDelegate?.onPresentRequestWithdrawn(participant: participant)
    }
    
    func onPresentRequestAdded(participant: RtkRemoteParticipant) {
        stageDelegate?.onPresentRequestAdded(participant: participant)
    }
    
}
