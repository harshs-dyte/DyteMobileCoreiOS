//
//  RtkEndMeetingButton.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 30/06/23.
//
import UIKit
import RealtimeKitCore

open class RtkEndMeetingControlBarButton: RtkControlBarButton {
    private let meeting: RealtimeKitClient
    private var dyteSelfListner: RtkEventSelfListner
    private let onClick: ((RtkEndMeetingControlBarButton,RtkLeaveDialog.RtkLeaveDialogAlertButtonType)->Void)?
    public var shouldShowAlertOnClick = true
    private let alertPresentingController: UIViewController
   
    public init(meeting: RealtimeKitClient, alertViewController: UIViewController , onClick:((RtkEndMeetingControlBarButton, RtkLeaveDialog.RtkLeaveDialogAlertButtonType)->Void)? = nil, appearance: RtkControlBarButtonAppearance = AppTheme.shared.controlBarButtonAppearance) {
        self.meeting = meeting
        self.alertPresentingController = alertViewController
        self.onClick = onClick
        self.dyteSelfListner = RtkEventSelfListner(mobileClient: meeting)
        super.init(image: RtkImage(image: ImageProvider.image(named: "icon_end_meeting_tabbar")), title: "", appearance: appearance)
        self.addTarget(self, action: #selector(onClick(button:)), for: .touchUpInside)
        DispatchQueue.main.async() {
            self.backgroundColor = appearance.desingLibrary.color.status.danger
            self.set(.width(48),
                     .height(48))
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     @objc open func onClick(button: RtkEndMeetingControlBarButton) {
        if shouldShowAlertOnClick {
            let dialog = RtkLeaveDialog(meeting: self.meeting) { alertAction in
                if alertAction == .willLeaveMeeting || alertAction == .willEndMeetingForAll {
                    self.showActivityIndicator()
                }else if alertAction == .didLeaveMeeting || alertAction == .didEndMeetingForAll {
                    self.hideActivityIndicator()
                    if alertAction == .didLeaveMeeting {
                        self.onClick?(self , .didLeaveMeeting)
                    }else if alertAction == .didEndMeetingForAll {
                        self.onClick?(self, .didEndMeetingForAll)
                    }
                }
            }
            dialog.show(on: self.alertPresentingController)
        }else {
            //When we are not showing alert then on clicking we can directly end call
            self.showActivityIndicator()
            self.dyteSelfListner.leaveMeeting(kickAll: false, completion: { [weak self] success in
                guard let self = self else {return}
                self.hideActivityIndicator()
                self.onClick?(button,.nothing)
            })
        }
    }
    
    deinit {
        self.dyteSelfListner.clean()
    }
}

