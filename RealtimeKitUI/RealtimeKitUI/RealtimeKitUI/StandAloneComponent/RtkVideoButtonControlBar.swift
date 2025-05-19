//
//  RtkVideoButton.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 10/04/23.
//

import RealtimeKitCore
import UIKit

open class  RtkVideoButtonControlBar: RtkControlBarButton {
    private let mobileClient: RealtimeKitClient
    private var dyteSelfListner: RtkEventSelfListner
    
    public init(mobileClient: RealtimeKitClient) {
        self.mobileClient = mobileClient
        self.dyteSelfListner = RtkEventSelfListner(mobileClient: mobileClient)
        super.init(image: RtkImage(image: ImageProvider.image(named: "icon_video_enabled")), title: "Video On")
        self.setSelected(image: RtkImage(image: ImageProvider.image(named: "icon_video_disabled")), title: "Video off")
        self.selectedStateTintColor = dyteSharedTokenColor.status.danger
        self.addTarget(self, action: #selector(onClick(button:)), for: .touchUpInside)
        self.isSelected = !mobileClient.localUser.videoEnabled
        self.dyteSelfListner.observeSelfVideo { [weak self] enabled in
            guard let self = self else {return}
            self.isSelected = !enabled
        }
       
    }
    
    public override var isSelected: Bool {
        didSet {
            if isSelected == true {
                self.accessibilityIdentifier = "Video_ControlBarButton_Selected"
            }else {
                self.accessibilityIdentifier = "Video_ControlBarButton_UnSelected"
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    @objc open func onClick(button: RtkControlBarButton) {
        if dyteSelfListner.isCameraPermissionGranted() {
            button.showActivityIndicator()
            dyteSelfListner.toggleLocalVideo(completion: { enableVideo in
                button.isSelected = !enableVideo
                button.hideActivityIndicator()
            })
        }
    }
    deinit {
        self.dyteSelfListner.clean()
    }
}

