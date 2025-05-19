//
//  WaitingRoomView.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 24/02/23.
//

import UIKit
import RealtimeKitCore


public enum ParticipantMeetingStatus {
    case waiting
    case rejected
    case accepted
    case kicked
    case meetingEnded
    case none
}

extension ParticipantMeetingStatus {
   static func getStatus(status: WaitListStatus) -> ParticipantMeetingStatus {
        switch status {
        case .accepted:
            return .accepted
        case .waiting:
            return .waiting
        case .rejected:
            return .rejected
        default:
            return .none
        }
    }
}


public class WaitingRoomView: UIView {
    
    var titleLabel: RtkLabel = {
        let label = RtkUIUTility.createLabel()
        label.numberOfLines = 0
        return label
    }()
    
    public var button: RtkButton = {
        return RtkUIUTility.createButton(text: "Leave")
    }()
    
    private let automaticClose: Bool
    
    private let automaticCloseTime = 2
    private let onComplete: ()->Void
   
    public init(automaticClose: Bool, onCompletion:@escaping()->Void) {
         self.automaticClose = automaticClose
         self.onComplete = onCompletion
         super.init(frame: .zero)
         createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func createSubviews() {
        let baseView = UIView()
        if automaticClose {
            baseView.addSubview(titleLabel)
            titleLabel.set(.sameLeadingTrailing(baseView),
                           .sameTopBottom(baseView))
            Timer.scheduledTimer(withTimeInterval: TimeInterval(automaticCloseTime), repeats: false) { timer in
                self.onComplete()
            }
        }else {
            let buttonBaseView = RtkUIUTility.wrapped(view: button)
            button.set(.centerX(buttonBaseView),
                       .leading(buttonBaseView, dyteSharedTokenSpace.space2, .greaterThanOrEqual),
                       .sameTopBottom(buttonBaseView))
            baseView.addSubViews(titleLabel,buttonBaseView)
            titleLabel.set(.sameLeadingTrailing(baseView),
                           .top(baseView))
            buttonBaseView.set(.sameLeadingTrailing(baseView), .below(titleLabel, dyteSharedTokenSpace.space2),
                               .bottom(baseView))
        }
        
        self.addSubview(baseView)
        baseView.set(.centerView(self),
                          .leading(self, dyteSharedTokenSpace.space4, .greaterThanOrEqual),
                          .top(self, dyteSharedTokenSpace.space4, .greaterThanOrEqual))
        self.button.addTarget(self, action: #selector(clickBottom(button:)), for: .touchUpInside)
    }
    
    @objc func clickBottom(button: RtkButton) {
        self.removeFromSuperview()
        self.onComplete()
    }
    
    public func show(status: ParticipantMeetingStatus) {
        if status == .waiting {
            self.titleLabel.text = "You are in the waiting room, the host will let you in soon."
            self.titleLabel.textColor = dyteSharedTokenColor.textColor.onBackground.shade1000

        }else if status == .accepted {
            self.removeFromSuperview()
        }else if status == .rejected {
            self.titleLabel.text = "Your request to join the meeting was denied."
            self.titleLabel.textColor = dyteSharedTokenColor.status.danger
        }
        else if status == .kicked {
            self.titleLabel.text = "Your were removed from the meeting"
            self.titleLabel.textColor = dyteSharedTokenColor.status.danger
        }
        else if status == .meetingEnded {
            self.titleLabel.text = "The meeting ended."
            self.titleLabel.textColor = dyteSharedTokenColor.textColor.onBackground.shade1000
        }

    }
    
    public func show(message: String) {
        self.titleLabel.text = message
    }
}
