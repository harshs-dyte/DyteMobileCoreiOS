//
//  RtkJoinButton.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 08/02/23.
//

import UIKit
import RealtimeKitCore

open class RtkJoinButton: RtkButton {
    
    let completion: ((RtkJoinButton,Bool)->Void)?
    private let meeting: RealtimeKitClient
    
    public init(meeting: RealtimeKitClient, onClick:((RtkJoinButton, Bool)->Void)? = nil, appearance: RtkButtonAppearance = AppTheme.shared.buttonAppearance) {
        self.meeting = meeting
        self.completion = onClick
        super.init(appearance: appearance)
        self.setTitle("  Join  ", for: .normal)
        self.addTarget(self, action: #selector(onClick(button:)), for: .touchUpInside)
    }

    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func onClick(button: RtkJoinButton) {
        let userName = meeting.localUser.name
        if userName.trimmingCharacters(in: .whitespaces).isEmpty || userName == "Join as XYZ" {
            RtkUIUTility.displayAlert(alertTitle: "Error", message: "Name Required")
        } else {
            button.showActivityIndicator()
            self.meeting.joinRoom {[weak self]  in
                   guard let self = self else {return}
                   button.hideActivityIndicator()
                   self.completion?(button,true)
            } onRoomJoinFailed: { [weak self]  in
                       guard let self = self else {return}
                       button.hideActivityIndicator()
                       self.completion?(button,false)
            }
        }
    }
}
