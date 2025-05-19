////
////  LivestreamViewController.swift
////  RtkUiKit
////
////  Created by Shaunak Jagtap on 16/06/23.
////
//
//import UIKit
//import RealtimeKitCore
////import AmazonIVSPlayer
//
//public class LivestreamViewController: UIViewController {
//    
//    private var gridView: GridView<RtkParticipantTileContainerView>!
//    let pluginView: RtkPluginsView
////    private var playerView: IVSPlayerView!
//    private let gridBaseView = UIView()
//    private var controlsView = UIView()
//    private let pluginBaseView = UIView()
//    private let baseContentView = UIView()
//    private var waitingView : WaitingRoomView?
//    private let isDebugModeOn = RtkUiKit.isDebugModeOn
//    private let dyteMobileClient: RealtimeKitClient
//    
//    private var isPluginOrScreenShareActive = false
//    
//    let viewModel: MeetingViewModel
//    
//    private var topBar: RtkMeetingHeaderView!
//    private var bottomBar: RtkTabbarBar!
//    private let completion: ()->Void
//    private var viewWillAppear = false
//    private var shouldStartLivestream = true
//    
//    private var moreButtonBottomBar: RtkControlBarButton?
//    private var liveButtonBottomBar: RtkControlBarButton?
//    private var layoutContraintPluginBaseZeroHeight: NSLayoutConstraint!
//    private var layoutContraintPluginBaseVariableHeight: NSLayoutConstraint!
//    
//    private let qualityButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Auto", for: .normal)
//        button.addTarget(LivestreamViewController.self, action: #selector(showQualityOptions), for: .touchUpInside)
//        return button
//    }()
//    
////    private var player: IVSPlayer? {
////        didSet {
////            playerView?.player = player
////        }
////    }
//    
//    init(dyteMobileClient: RealtimeKitClient, completion:@escaping()->Void) {
//        self.pluginView = RtkPluginsView(videoPeerViewModel:VideoPeerViewModel(meeting: dyteMobileClient, participant: dyteMobileClient.localUser, showSelfPreviewVideo: false))
//        self.completion = completion
//        self.viewModel = MeetingViewModel(dyteMobileClient: dyteMobileClient)
//        self.dyteMobileClient = dyteMobileClient
//        super.init(nibName: nil, bundle: nil)
//        dyteMobileClient.addLiveStreamEventsListener(liveStreamEventsListener: self)
//        notificationDelegate = self
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    public override func viewSafeAreaInsetsDidChange() {
//        super.viewSafeAreaInsetsDidChange()
//        topBar.set(.top(self.view, self.view.safeAreaInsets.top))
//    }
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = DesignLibrary.shared.color.background.shade1000
//        createUI()
//        createTopbar()
//        createBottomBar()
//        createSubView()
//        setInitialsConfiguration()
//        self.viewModel.delegate = self
//        
//        self.viewModel.dyteSelfListner.observeSelfRemoved { [weak self] success in
//            guard let self = self else {return}
//            
//            func showWaitingRoom(status: ParticipantMeetingStatus, time:TimeInterval, onComplete:@escaping()->Void) {
//                if status != .none {
//                    let waitingView = WaitingRoomView(automaticClose: true, onCompletion: onComplete)
//                    waitingView.backgroundColor = self.view.backgroundColor
//                    self.view.addSubview(waitingView)
//                    waitingView.set(.fillSuperView(self.view))
//                    self.view.endEditing(true)
//                    waitingView.show(status: status)
//                }
//            }
//            
//            showWaitingRoom(status: .meetingEnded, time: 2) { [weak self] in
//                guard let self = self else {return}
//                self.viewModel.clean()
//                self.completion()
//            }
//        }
//        
//        if self.dyteMobileClient.localUser.permissions.waitingRoom.canAcceptRequests {
//            self.viewModel.waitlistEventListner.participantJoinedCompletion = {[weak self] participant in
//                guard let self = self else {return}
//                self.view.showToast(toastMessage: "\(participant.name) has requested to join the call ", duration: 2.0)
//                if self.dyteMobileClient.getWaitlistCount() > 0 {
//                    self.moreButtonBottomBar?.notificationBadge.isHidden = false
//                }else {
//                    self.moreButtonBottomBar?.notificationBadge.isHidden = false
//                }
//            }
//            
//            self.viewModel.waitlistEventListner.participantRequestRejectCompletion = {[weak self] participant in
//                guard let self = self else {return}
//                if self.dyteMobileClient.getWaitlistCount() > 0 {
//                    self.moreButtonBottomBar?.notificationBadge.isHidden = false
//                }else {
//                    self.moreButtonBottomBar?.notificationBadge.isHidden = false
//                }
//            }
//            self.viewModel.waitlistEventListner.participantRequestAcceptedCompletion = {[weak self] participant in
//                guard let self = self else {return}
//                if self.dyteMobileClient.getWaitlistCount() > 0 {
//                    self.moreButtonBottomBar?.notificationBadge.isHidden = false
//                }else {
//                    self.moreButtonBottomBar?.notificationBadge.isHidden = false
//                }
//            }
//        }
//    }
//    
//    public override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        pausePlayback()
//    }
//    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if viewWillAppear == false {
//            viewWillAppear = true
//            self.viewModel.refreshActiveParticipants()
//            self.viewModel.trackOnGoingState()
//        }
//    }
//    
//    deinit {
//        if isDebugModeOn {
//            print("RtkUIKit | MeetingViewController Deinit is calling ")
//        }
//    }
//}
//
//private extension LivestreamViewController {
//    
//    private func createUI() {
////        waitingView = WaitingRoomView(automaticClose: false, onCompletion: {})
////        try?dyteMobileClient.localUser.disableAudio()
////        try?dyteMobileClient.localUser.disableVideo()
////        if let waitingView = waitingView {
////            waitingView.backgroundColor = self.view.backgroundColor
////            self.baseContentView.addSubview(waitingView)
////            waitingView.set(.fillSuperView(self.baseContentView))
////            waitingView.titleLabel.text = "Waiting to go Live..."
////            waitingView.button.isHidden = true
////        }
//////        playerView = IVSPlayerView()
////        controlsView.addSubview(qualityButton)
//    }
//    
//    private func startPlayback() {
////        player?.play()
//    }
//    
//    private func pausePlayback() {
////            player?.pause()
//        }
//    
//    private func loadStream(from url: URL) {
////        let player = IVSPlayer()
////        player.delegate = self
////        player.load(url)
////        self.player = player
//    }
//    
//    private func startLivestream() {
////        if let url = dyteMobileClient.liveStream.liveStreamUrl, let liveStreamUrl = URL(string: url) {
////            loadStream(from: liveStreamUrl)
////            startPlayback()
////            shouldStartLivestream = false
//        }
//    }
//    
//    private func onPluginTapped() {
////        let controller = RtkPluginViewController(plugins: dyteMobileClient.plugins.all)
////        let navigationController = UINavigationController(rootViewController: controller)
////        navigationController.modalPresentationStyle = .fullScreen
////        present(navigationController, animated: true, completion: nil)
//    }
//    
//    @objc private func showQualityOptions() {
////        guard let player = player else { return }
////
////        var actions = [UIAlertAction]()
////
////        let autoMode = player.autoQualityMode
////        actions.append(
////            UIAlertAction(title: "Auto \(autoMode ? "✔️" : "")", style: .default) { [weak self, weak player] _ in
////                guard let player = player, self?.player == player else {
////                    return
////                }
////                player.autoQualityMode = !autoMode
////            }
////        )
////
////        for quality in player.qualities {
////            let isCurrent = player.quality == quality
////            actions.append(
////                UIAlertAction(title: "\(quality.name) \(isCurrent ? "✔️" : "")", style: .default) { [weak self, weak player] _ in
////                    guard let player = player, self?.player == player else {
////                        return
////                    }
////                    player.quality = quality
////                }
////            )
////        }
////
////        presentActionSheet(title: "Quality options", actions: actions, sourceView: qualityButton)
//    }
//    
//    private func presentActionSheet(title: String, actions: [UIAlertAction], sourceView: UIView) {
////            let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
////            actionSheet.addAction(
////                UIAlertAction(title: "Close", style: .cancel, handler: { _ in
////                    actionSheet.dismiss(animated: true)
////                })
////            )
////            actions.forEach { actionSheet.addAction($0) }
////            actionSheet.popoverPresentationController?.sourceView = sourceView
////            actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
////            present(actionSheet, animated: true)
//        }
//    
//    private func createMoreMenu() {
////        var menus = [MenuType]()
////        
////        if dyteMobileClient.localUser.permissions.host.canMuteAudio {
////            menus.append(.muteAllAudio)
////        }
////        
////        if dyteMobileClient.localUser.permissions.host.canMuteVideo {
////            menus.append(.muteAllVideo)
////        }
////        
////        //        menus.append(.shareMeetingUrl)
////        let recordingState = self.dyteMobileClient.recording.recordingState
////        let permissions = dyteMobileClient.localUser.permissions
////        
////        let hostPermission = permissions.host
////        if hostPermission.canTriggerRecording {
////            if recordingState == .recording || recordingState == .starting {
////                menus.append(.recordingStop)
////            } else {
////                menus.append(.recordingStart)
////            }
////        }
////        let pluginPermission = permissions.plugins
////        
////        if pluginPermission.canLaunch {
////            menus.append(.plugins)
////        }
////        
////        let pollPermission = permissions.polls
////        if pollPermission.canCreate || pollPermission.canView || pollPermission.canVote {
////            let count = dyteMobileClient.polls.polls.count
////            menus.append(.poll(notificationMessage: count > 0 ? "\(count)" : ""))
////        }
////        var message = ""
////        let pending = self.dyteMobileClient.getPendingParticipantCount()
////        
////        if pending > 0 {
////            message = "\(pending)"
////        }
////        
////        menus.append(.settings)       
////        
////        let chatCount = dyteMobileClient.chat.messages.count
////        menus.append(contentsOf: [.chat(notificationMessage: chatCount > 0 ? "\(chatCount)" : ""), .particpants(notificationMessage: message), .cancel])
////        
////        let moreMenu = RtkMoreMenu(features: menus, onSelect: { [weak self] menuType in
////            guard let self = self else {return}
////            switch menuType {
////            case.muteAllAudio:
////                self.muteAllAudio()
////            case.muteAllVideo:
////                self.muteAllVideo()
////            case.shareMeetingUrl:
////                self.shareMeetingUrl()
////            case .chat:
////                self.onChatTapped()
////            case .poll:
////                self.launchPollsScreen()
////            case .recordingStart:
////                self.dyteMobileClient.recording.start()
////            case .recordingStop:
////                self.dyteMobileClient.recording.stop()
////            case .settings:
////                self.launchSettingScreen()
////            case .plugins:
////                self.onPluginTapped()
////            case .particpants:
////                self.launchLiveParticipantScreen()
////            default:
////                print("Not Supported for now")
////            }
////        })
////        moreMenu.show(on: view)
//    }
//    
//    private func setInitialsConfiguration() {
//       // self.topBar.setInitialConfiguration()
//    }
//    
//    
//    private func createSubView() {
////        self.view.addSubview(baseContentView)
////        
////        baseContentView.set(.sameLeadingTrailing(self.view),
////                            .below(topBar),
////                            .above(bottomBar))
////        
////        baseContentView.addSubview(pluginBaseView)
////        baseContentView.addSubview(gridBaseView)
////        baseContentView.addSubview(playerView)
////        baseContentView.addSubview(controlsView)
////        playerView.set(.sameLeadingTrailing(baseContentView),
////                           .top(baseContentView))
////        pluginBaseView.set(.sameLeadingTrailing(baseContentView),
////                           .top(baseContentView))
////        controlsView.set(.sameLeadingTrailing(baseContentView),
////                           .bottom(baseContentView))
////        
////        layoutContraintPluginBaseVariableHeight = NSLayoutConstraint(item: pluginBaseView, attribute: .height, relatedBy: .equal, toItem: baseContentView, attribute: .height, multiplier: 0.7, constant: 0)
////        layoutContraintPluginBaseZeroHeight = NSLayoutConstraint(item: pluginBaseView, attribute: .height, relatedBy: .equal, toItem: baseContentView, attribute: .height, multiplier: 0.0, constant: 0)
////        layoutContraintPluginBaseZeroHeight.isActive = true
////        layoutContraintPluginBaseVariableHeight.isActive = false
////        
////        gridBaseView.set(.sameLeadingTrailing(baseContentView),
////                         .below(pluginBaseView),
////                         .bottom(baseContentView))
////        
//////        gridView = GridView( showingCurrently: 9, getChildView: {
//////            [unowned self] in
//////            return RtkParticipantTileView(mobileClient: self.dyteMobileClient)
//////        })
//////        gridBaseView.addSubview(gridView)
//////        gridView.set(.fillSuperView(gridBaseView))
////        playerView.set(.fillSuperView(gridBaseView))
////        pluginBaseView.addSubview(pluginView)
////        pluginView.set(.fillSuperView(pluginBaseView))
//    }
//    
//    private func createTopbar() {
////        let topbar = RtkMeetingHeaderView(meeting: self.dyteMobileClient)
////        self.view.addSubview(topbar)
////        topbar.set(.sameLeadingTrailing(self.view))
////        self.topBar = topbar
//    }
//    
//    private func createBottomBar() {
////        let controlBar =  RtkTabbarBar(delegate: nil)
////        let moreButton = RtkControlBarButton(image: RtkImage(image: ImageProvider.image(named: "icon_more_tabbar")), title: "More")
////        moreButton.addTarget(self, action: #selector(clickMore(button:)), for: .touchUpInside)
////              
////        let liveButton = RtkControlBarButton(image: RtkImage(image: ImageProvider.image(named: "icon_go_live")), title: "Go Live")
////        liveButton.setSelected(image: RtkImage(image: ImageProvider.image(named: "icon_end_live")), title: "End Live")
////        liveButton.addTarget(self, action: #selector(clickLive(button:)), for: .touchUpInside)
////        self.moreButtonBottomBar = moreButton
////        self.liveButtonBottomBar = liveButton
////        let endCallButton = RtkEndMeetingControlBarButton(meeting: dyteMobileClient, alertViewController: self) { buttons, alertButton in
////            self.viewModel.clean()
////            self.completion()
////        }
////        
////        controlBar.setButtons([liveButton, moreButton, endCallButton])
////        self.view.addSubview(controlBar)
////        controlBar.set(.sameLeadingTrailing(self.view),
////                       .bottom(self.view))
////        
////        self.bottomBar = controlBar
//    }
//}
//
////extension LivestreamViewController: IVSPlayer.Delegate {
////    public func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
////        switch state {
////        case .ready:
////            waitingView?.isHidden = false
////            print("player state: ready")
////        case .buffering:
////            waitingView?.isHidden = false
////            print("player state: buffering")
////        case .playing:
////            self.liveButtonBottomBar?.isSelected = true
////            waitingView?.isHidden = true
////            playerView.isHidden = false
////            print("player state: playing")
////        case .ended:
////            waitingView?.isHidden = false
////            waitingView?.titleLabel.text = "Waiting to go Live..."
////            playerView.isHidden = true
////            print("player state: ended")
////        case .idle:
////            waitingView?.isHidden = false
////            print("player state: idle")
////        default:
////            break
////        }
////    }
////}
//
//extension LivestreamViewController {
//    
//    @objc func clickFlipCamera(button: RtkControlBarButton) {
//        viewModel.dyteSelfListner.toggleCamera()
//    }
//    
//    private func onChatTapped() {
//        let controller = RtkChatViewController(meeting: self.dyteMobileClient)
//        let navigationController = UINavigationController(rootViewController: controller)
//        navigationController.modalPresentationStyle = .fullScreen
//        present(navigationController, animated: true, completion: nil)
//    }
//    
//    @objc func clickMore(button: RtkControlBarButton) {
//        self.moreButtonBottomBar?.notificationBadge.isHidden = true
//        createMoreMenu()
//    }
//    
//    @objc func clickLive(button: RtkControlBarButton) {
//        if button.isSelected {
//            liveButtonBottomBar?.showActivityIndicator()
//            dyteMobileClient.liveStream.stop()
//        } else {
//            liveButtonBottomBar?.showActivityIndicator()
//            dyteMobileClient.liveStream.start()
//        }
//        button.isSelected = !button.isSelected
////        button.isSelected = !button.isSelected
////        if dyteMobileClient.liveStream.state == LiveStreamState.started {
////            dyteMobileClient.liveStream.stop()
////        } else if dyteMobileClient.liveStream.state == LiveStreamState.errored {
////
////        } else if dyteMobileClient.liveStream.state == LiveStreamState.stopped {
////            dyteMobileClient.liveStream.start()
////        } else {
////
////        }
//        
//    }
//    
//    private func launchPollsScreen() {
//        let controller = RtkShowPollsViewController(meeting: self.dyteMobileClient)
//        self.present(controller, animated: true)
//    }
//    
//    private func launchSettingScreen() {
//        let controller = RtkSettingViewController(nameTag: self.dyteMobileClient.localUser.name, meeting: self.dyteMobileClient) {
//            [weak self] in
//            guard let self = self else {return}
//            self.refreshMeetingGridTile(participant: self.dyteMobileClient.localUser)
//        }
//        controller.view.backgroundColor = self.view.backgroundColor
//        controller.modalPresentationStyle = .fullScreen
//        self.present(controller, animated: true)
//    }
//    
//    private func muteAllAudio() {
//        dyteMobileClient.participants.disableAllAudio()
//    }
//    
//    private func muteAllVideo() {
//        try?dyteMobileClient.participants.disableAllVideo()
//    }
//    
//    private func shareMeetingUrl() {
//        if let name = URL(string: "https://demo.dyte.io/v2/meeting?id=\(self.dyteMobileClient.meta.roomName)"), !name.absoluteString.isEmpty {
//            let objectsToShare = [name]
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//            self.present(activityVC, animated: true, completion: nil)
//        } else {
//            // show alert for not available
//        }
//    }
//    
//    private func launchParticipantScreen() {
//        let controller = ParticipantViewControllerFactory.getParticipantViewController(meeting: self.dyteMobileClient)
//        controller.view.backgroundColor = self.view.backgroundColor
//        controller.modalPresentationStyle = .fullScreen
//        self.present(controller, animated: true)
//    }
//    
//    private func launchLiveParticipantScreen() {
//        let controller = ParticipantViewControllerFactory.getLiveStreamParticipantViewController(meeting: self.dyteMobileClient)
//        controller.view.backgroundColor = self.view.backgroundColor
//        controller.modalPresentationStyle = .fullScreen
//        self.present(controller, animated: true)
//    }
//}
//
//extension LivestreamViewController : MeetingViewModelDelegate {
//    
//    func newPollAdded(createdBy: String) {
//        if Shared.data.notification.newPollArrived.showToast {
//            self.view.showToast(toastMessage: "New poll created by \(createdBy)", duration: 2.0, uiBlocker: false)
//        }
//    }
//    
//    func participantJoined(participant: RtkMeetingParticipant) {
//        if Shared.data.notification.participantJoined.showToast {
//            self.view.showToast(toastMessage: "\(participant.name) just joined", duration: 2.0, uiBlocker: false)
//        }
//    }
//    
//    func participantLeft(participant: RtkMeetingParticipant) {
//        if Shared.data.notification.participantLeft.showToast {
//            self.view.showToast(toastMessage: "\(participant.name) left", duration: 2.0, uiBlocker: false)
//        }
//    }
//    
//    func showWaitingRoom(status: WaitListStatus) {
//        
//    }
//    
//    func activeSpeakerChanged(participant: RtkMeetingParticipant) {
//        //For now commenting out the functionality of Active Speaker, It's Not working as per our expectation
//        // showAndHideActiveSpeaker()
//    }
//    
//    func pinnedChanged(participant: RtkJoinedMeetingParticipant) {
//        
//    }
//    
//    func activeSpeakerRemoved() {
//        //For now commenting out the functionality of Active Speaker, It's Not working as per our expectation
//        //showAndHideActiveSpeaker()
//    }
//    
//    func pinnedParticipantRemoved(participant: RtkJoinedMeetingParticipant) {
//        //showAndHideActiveSpeaker()
//        updatePin(show: false, participant: participant)
//    }
//    
//    private func showAndHideActiveSpeaker() {
//        let pluginViewIsVisible = isPluginOrScreenShareActive
//        if let pinned = self.dyteMobileClient.participants.pinned, pluginViewIsVisible {
//            self.pluginView.showPinnedView(participant: pinned)
//        }else {
//            self.pluginView.hideActiveSpeaker()
//        }
//    }
//    
//    private func getScreenShareTabButton(participants: [ParticipantsShareControl]) -> [RtkPluginScreenShareTabButton] {
//        var arrButtons = [RtkPluginScreenShareTabButton]()
//        for participant in participants {
//            var image: RtkImage?
//            if let _ = participant as? ScreenShareModel {
//                //For
//                image = RtkImage(image: ImageProvider.image(named: "icon_screen_share"))
//            }else {
//                if let strUrl = participant.image , let imageUrl = URL(string: strUrl) {
//                    image = RtkImage(url: imageUrl)
//                }
//            }
//            
//            let button = RtkPluginScreenShareTabButton(image: image, title: participant.name)
//            // TODO:Below hardcoding is not needed, We also need to scale down the image as well.
//            button.btnImageView?.set(.height(20),
//                                     .width(20))
//            arrButtons.append(button)
//        }
//        return arrButtons
//    }
//    
//    private func handleClicksOnPluginsTab(model: PluginButtonModel, at index: Int) {
//        self.pluginView.show(pluginView:  model.plugin.getPluginView())
//        self.viewModel.screenShareViewModel.selectedIndex = (UInt(index), model.id)
//    }
//    
//    func refreshPluginsButtonTab(pluginsButtonsModels: [ParticipantsShareControl], arrButtons: [RtkPluginScreenShareTabButton])  {
//        if arrButtons.count >= 1 {
//            var selectedIndex: Int?
//            if let index = self.viewModel.screenShareViewModel.selectedIndex?.0 {
//                selectedIndex = Int(index)
//            }
//            self.pluginView.setButtons(buttons: arrButtons, selectedIndex: selectedIndex) { [weak self] button, isUserClick  in
//                guard let self = self else {return}
//                if let plugin = pluginsButtonsModels[button.index] as? PluginButtonModel {
//                    self.handleClicksOnPluginsTab(model: plugin, at: button.index)
//                    
//                }
//                for (index, element) in arrButtons.enumerated() {
//                    element.isSelected = index == button.index ? true : false
//                }
//            }
//        }
//    }
//    
//    func refreshPluginsScreenShareView() {
//       
//    }
//    
//    private func showPluginView(show: Bool, animation: Bool) {
//        layoutContraintPluginBaseVariableHeight.isActive = show
//        layoutContraintPluginBaseZeroHeight.isActive = !show
//        if animation {
//            UIView.animate(withDuration: Animations.gridViewAnimationDuration) {
//                self.view.layoutIfNeeded()
//            }
//        }else {
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    private func loadGrid(fullScreen: Bool, animation: Bool, completion:@escaping()->Void) {
////        let arrModels = self.viewModel.arrGridParticipants
////        if fullScreen == false {
////            self.gridView.settingFramesForHorizontal(visibleItemCount: UInt(arrModels.count), animation: animation) { finish in
////                completion()
////            }
////        }else {
////            self.gridView.settingFrames(visibleItemCount: UInt(arrModels.count), animation: animation) { finish in
////                completion()
////            }
////        }
//    }
//    
//    private func showPlugInView() {
//        // We need to move gridview to Starting View
//        isPluginOrScreenShareActive = true
//        if self.dyteMobileClient.participants.currentPageNumber == 0 {
//            //We have to only show PluginView on page == 0 only
//            self.showPluginView(show: true, animation: true)
//            self.loadGrid(fullScreen: false, animation: true, completion: {})
//        }
//    }
//    
//    private func hidePlugInView(tab buttons: [RtkPluginScreenShareTabButton]) {
//        
//        
//        // No need to show any plugin or share view
//        isPluginOrScreenShareActive = false
//        self.pluginView.setButtons(buttons: buttons, selectedIndex: nil) {_,_  in}
//        self.showPluginView(show: false, animation: true)
//        if self.dyteMobileClient.participants.currentPageNumber == 0 {
//            self.loadGrid(fullScreen: true, animation: true, completion: {})
//        }
//    }
//    
//    
//    private func move(gridView:  GridView<RtkParticipantTileContainerView>, toView: UIView) {
//        gridView.removeFromSuperview()
//        toView.addSubview(gridView)
//        gridView.set(.fillSuperView(toView))
//    }
//    
//    func showParticpantCount(text: String) {
//        self.topBar.lblSubtitle.text = text
//    }
//    
//    private  func loadPreviousPage() {
//        if  self.dyteMobileClient.participants.canGoPreviousPage == true {
//            try?self.dyteMobileClient.participants.setPage(pageNumber: self.dyteMobileClient.participants.currentPageNumber - 1)
//        }
//    }
//    
//    private  func loadNextPage() {
//        if self.dyteMobileClient.participants.canGoNextPage == true {
//            try?self.dyteMobileClient.participants.setPage(pageNumber: self.dyteMobileClient.participants.currentPageNumber + 1)
//        }
//    }
//    
//    func updatePin(show:Bool, participant: RtkMeetingParticipant) {
//        let arrModels = self.viewModel.arrGridParticipants
//        var index = -1
//        for model in arrModels {
//            index += 1
//            if model.participant.userId == participant.userId {
//                if let peerView = self.gridView.childView(index: index)?.tileView {
//                    peerView.pinView(show: show)
//                }
//            }
//        }
//        
//    }
//    static var schedule = false
//    
//    func refreshMeetingGrid(forRotation: Bool = false) {
//        if isDebugModeOn {
//            print("Debug RtkUIKit | refreshMeetingGrid")
//        }
//        
//        self.meetingGridPageBecomeVisible()
//        let arrModels = self.viewModel.arrGridParticipants
//        
//        if isDebugModeOn {
//            print("Debug RtkUIKIt | refreshing Finished")
//        }
//        
//        if self.dyteMobileClient.participants.currentPageNumber == 0 {
//            self.showPluginView(show: isPluginOrScreenShareActive, animation: false)
//            self.loadGrid(fullScreen: !isPluginOrScreenShareActive, animation: true, completion: {
//                populateGridChildViews(models: arrModels)
//            })
//        }else {
//            self.showPluginView(show: false, animation: false)
//            self.loadGrid(fullScreen: true, animation: true, completion: {
//                populateGridChildViews(models: arrModels)
//            })
//        }
//        
//        func populateGridChildViews(models: [GridCellViewModel]) {
//            for i in 0..<models.count {
//                if let peerContainerView = self.gridView.childView(index: i) {
//                    peerContainerView.setParticipant(meeting: self.dyteMobileClient, participant: models[i].participant)
//                }
//            }
//        }
//    }
//    
//    func refreshMeetingGridTile(participant: RtkMeetingParticipant) {
//        let arrModels = self.viewModel.arrGridParticipants
//        var index = -1
//        for model in arrModels {
//            index += 1
//            if model.participant.userId == participant.userId {
//                if let peerContainerView = self.gridView.childView(index: index) {
//                    peerContainerView.setParticipant(meeting: self.dyteMobileClient, participant: arrModels[index].participant)
//                    return
//                }
//            }
//        }
//    }
//    
//    private func meetingGridPageBecomeVisible() {
//        
//        if let participant = dyteMobileClient.participants.pinned {
//            self.refreshMeetingGridTile(participant: participant)
//        }
//        self.topBar.refreshNextPreviouButtonState()
//    }
//}
//
//extension LivestreamViewController: RtkLiveStreamEventsListener {
//
//    
//    public func onLiveStreamEnded() {
//        liveButtonBottomBar?.hideActivityIndicator()
//        self.liveButtonBottomBar?.isSelected = false
//        shouldStartLivestream = true
//        print("player state: onLiveStreamEnded")
//
//    }
//    
//    public func onLiveStreamEnding() {
//        waitingView?.isHidden = false
////        playerView.isHidden = true
//        waitingView?.titleLabel.text = "Ending Livestream..."
//
//    }
//    
//    public func onLiveStreamErrored() {
//        liveButtonBottomBar?.hideActivityIndicator()
//        self.liveButtonBottomBar?.isSelected = false
//        shouldStartLivestream = true
//        print("player state: onLiveStreamErrored")
//
//    }
//    
//    public func onLiveStreamStarted() {
//        liveButtonBottomBar?.hideActivityIndicator()
//        self.liveButtonBottomBar?.isSelected = true
//        if shouldStartLivestream {
//            startLivestream()
//        }
//
//    }
//    
//    public func onLiveStreamStarting() {
//        waitingView?.titleLabel.text = "Starting Livestream..."
//    }
//    
//    public func onLiveStreamStateUpdate(data: RtkLivestreamData) {
//        print("player state: onLiveStreamStateUpdate stage  \(data.description())")
//
//    }
//    
//    public func onStageCountUpdated(count: Int32) {
//        if dyteMobileClient.stage.stageStatus == StageStatus.onStage {
//            let controller = MeetingViewController(meeting: dyteMobileClient, completion: self.completion)
//            controller.view.backgroundColor = self.view.backgroundColor
//            controller.modalPresentationStyle = .fullScreen
//            self.present(controller, animated: true)
//        }
//    }
//    
//    public func onViewerCountUpdated(count: Int32) {
//        print("player state: onViewerCountUpdated count \(count)")
//        if shouldStartLivestream {
//            startLivestream()
//        }
//
//    }
//    
//}
//
//extension LivestreamViewController: RtkNotificationDelegate {
//    public func clearChatNotification() {
//        self.moreButtonBottomBar?.notificationBadge.isHidden = true
//    }
//    
//    public  func didReceiveNotification(type: RtkNotificationType) {
//        switch type {
//        case .Chat, .Poll:
//            self.moreButtonBottomBar?.notificationBadge.isHidden = false
//            viewModel.dyteNotification.playNotificationSound(type: .Poll)
//        case .Joined, .Leave:
//            viewModel.dyteNotification.playNotificationSound(type: .Joined)
//        }
//    }
//}
