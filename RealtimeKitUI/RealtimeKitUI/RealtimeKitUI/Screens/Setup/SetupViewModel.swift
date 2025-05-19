//
//  SetupViewModel.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 29/11/22.
//

import RealtimeKitCore
import UIKit

protocol MeetingDelegate: AnyObject {
    func onMeetingInitFailed(message: String?)
    func onMeetingInitCompleted()
}

public protocol ChatDelegate {
    func refreshMessages()
}

protocol PollDelegate {
    func refreshPolls(pollMessages: [RtkPoll])
}


protocol ParticipantsDelegate {
    func refreshList()
}

final class SetupViewModel {
    
    let dyteMobileClient: RealtimeKitClient
   
    private var roomJoined:((Bool)->Void)?
    private weak var delegate: MeetingDelegate?

    var participantsDelegate : ParticipantsDelegate?
    var participants = [RtkMeetingParticipant]()
    var screenshares = [RtkMeetingParticipant]()
    
    let meetingInfo: RtkMeetingInfo
    let dyteSelfListner: RtkEventSelfListner
    
    init(mobileClient: RealtimeKitClient, delegate: MeetingDelegate?, meetingInfo: RtkMeetingInfo) {
        self.dyteMobileClient = mobileClient
        self.delegate = delegate
        self.meetingInfo = meetingInfo
        self.dyteSelfListner = RtkEventSelfListner(mobileClient: dyteMobileClient)
        initialise()
    }
    
    func initialise() {
        let info = meetingInfo
        dyteSelfListner.initMeetingV2(info: info) { [weak self] success, message in
                guard let self = self else {return}

                if success {
                    self.delegate?.onMeetingInitCompleted()
                }else {
                    self.delegate?.onMeetingInitFailed(message: message)
                }
            }
    }

    func removeListner() {
        dyteSelfListner.clean()
    }
    
    deinit {
        print("SetupView Model dealloc is calling")
    }
}


