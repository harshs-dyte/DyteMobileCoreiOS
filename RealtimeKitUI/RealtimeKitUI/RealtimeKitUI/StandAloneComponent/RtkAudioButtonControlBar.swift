//
//  RtkAudioButton.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 13/06/23.
//

import RealtimeKitCore
import Foundation

open class  RtkAudioButtonControlBar: RtkControlBarButton {
    private let mobileClient: RealtimeKitClient
    private var dyteSelfListner: RtkEventSelfListner
    private let onClick: ((RtkAudioButtonControlBar)->Void)?

    public init(meeting: RealtimeKitClient, onClick:((RtkAudioButtonControlBar)->Void)? = nil, appearance: RtkControlBarButtonAppearance = AppTheme.shared.controlBarButtonAppearance) {
        self.mobileClient = meeting
        self.onClick = onClick
        self.dyteSelfListner = RtkEventSelfListner(mobileClient: mobileClient)
        super.init(image: RtkImage(image: ImageProvider.image(named: "icon_mic_enabled")), title: "Mic on", appearance: appearance)
        self.setSelected(image: RtkImage(image: ImageProvider.image(named: "icon_mic_disabled")), title: "Mic off")
        self.selectedStateTintColor = dyteSharedTokenColor.status.danger
        self.addTarget(self, action: #selector(onClick(button:)), for: .touchUpInside)
        self.isSelected = !mobileClient.localUser.audioEnabled

        self.dyteSelfListner.observeSelfAudio { [weak self] enabled in
            guard let self = self else {return}
            self.isSelected = !enabled
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            if isSelected == true {
                self.accessibilityIdentifier = "Mic_ControlBarButton_Selected"
            }else {
                self.accessibilityIdentifier = "Mic_ControlBarButton_UnSelected"
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc open func onClick(button: RtkAudioButtonControlBar) {
        if dyteSelfListner.isMicrophonePermissionGranted() {
            button.showActivityIndicator()
            self.accessibilityIdentifier = "ControlBar_Audio_"
            self.dyteSelfListner.toggleLocalAudio(completion: { enableAudio in
                button.hideActivityIndicator()
                button.isSelected = !enableAudio
                self.onClick?(button)
            })
        }
    }
    
    deinit {
        self.dyteSelfListner.clean()
    }
  
}
