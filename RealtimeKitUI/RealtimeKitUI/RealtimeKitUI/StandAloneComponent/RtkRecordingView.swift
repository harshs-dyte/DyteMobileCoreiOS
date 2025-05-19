//
//  RtkRecordingView.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 14/07/23.
//

import UIKit
import RealtimeKitCore

public protocol RtkRecordingViewAppearance: BaseAppearance {
    var textColor: StatusColor.Shade {get set}
    var font: UIFont {get set}
    var imageBackGroundColor: StatusColor.Shade {get set}
}

public class RtkRecordingViewAppearanceModel: RtkRecordingViewAppearance {
    public var textColor: StatusColor.Shade
    
    public var font: UIFont
    
    public var imageBackGroundColor: StatusColor.Shade
    
    public var desingLibrary: RtkDesignTokens
    
    public required init(designLibrary: RtkDesignTokens) {
        self.desingLibrary = designLibrary
        self.font =  UIFont.boldSystemFont(ofSize: 12)
        self.textColor =  designLibrary.color.status.danger
        self.imageBackGroundColor = designLibrary.color.status.danger
    }
}

public class RtkRecordingView: UIView {
    private let tokenSpace = DesignLibrary.shared.space

    private var title: String
    private var image: RtkImage?
    private let appearance: RtkRecordingViewAppearance
    private let meeting: RealtimeKitClient
    
    public init(meeting: RealtimeKitClient, title: String = "Rec", image: RtkImage? = nil, appearance: RtkRecordingViewAppearance = RtkRecordingViewAppearanceModel(designLibrary: DesignLibrary.shared)) {
        self.title = title
        self.image = image
        self.appearance = appearance
        self.meeting = meeting
        super.init(frame: .zero)
        createSubViews()
        meeting.addRecordingEventsListener(recordingEventsListener: self)
        if meeting.recording.recordingState == .recording || meeting.recording.recordingState == .starting {
           self.blinking(start: true)
        }else if meeting.recording.recordingState == .stopping || meeting.recording.recordingState == .idle {
            self.blinking(start: false)
        }
        self.accessibilityIdentifier = "Recording_Red_Dot"
    }
    
    deinit {
        self.meeting.removeRecordingEventsListener(recordingEventsListener: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubViews() {
        let stackView = RtkUIUTility.createStackView(axis: .horizontal, spacing: 4)
        var imageView = BaseImageView()
        if let image = self.image {
            imageView = RtkUIUTility.createImageView(image: image)
        }
        let title = RtkUIUTility.createLabel(text: self.title)
        title.font = appearance.font
        title.textColor = appearance.textColor
        stackView.addArrangedSubviews(imageView,title)
        if self.image == nil {
            imageView.set(.width(tokenSpace.space2),
                          .height(tokenSpace.space2))
            imageView.layer.cornerRadius = tokenSpace.space1
        }
        imageView.backgroundColor = appearance.imageBackGroundColor
        self.addSubview(stackView)
        stackView.set(.fillSuperView(self))
    }
    
    public func blinking(start: Bool) {
        self.isHidden = !start
        if start {
            // I have to use DispatchQueue here because recording view didn't blink, and by doing so its start working
            DispatchQueue.main.async {
                self.blink()
            }
        }else {
            self.stopBlink()
        }
    }
}

extension  RtkRecordingView: RtkRecordingEventsListener {
    public func onRecordingStateChanged(oldState: RealtimeKitCore.RtkRecordingState, newState: RealtimeKitCore.RtkRecordingState) {
        if(oldState != newState){
            switch newState {
            case .idle:
                onMeetingRecordingEnded()
            case .recording:
                onMeetingRecordingStarted()
            default:
                break
            }
        }
    }
    
    private func onMeetingRecordingEnded() {
        self.blinking(start: false)
        NotificationCenter.default.post(name: Notification.Name("Notify_RecordingUpdate"), object: nil, userInfo: nil)
    }
    
    private func onMeetingRecordingStarted() {
        self.blinking(start: true)
        NotificationCenter.default.post(name: Notification.Name("Notify_RecordingUpdate"), object: nil, userInfo: nil)
    }
}
