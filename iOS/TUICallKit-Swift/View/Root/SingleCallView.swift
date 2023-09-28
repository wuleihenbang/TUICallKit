//
//  SingleCallView.swift
//  Alamofire
//
//  Created by vincepzhang on 2022/12/30.
//
import SnapKit

class SingleCallView: UIView {
    
    let viewModel: SingleCallViewModel = SingleCallViewModel()
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    private var isViewReady: Bool = false
    
    let userInfoAudioView = {
        return AudioCallUserInfoView(frame: CGRect.zero)
    }()
    
    let userInfoVideoView = {
        return VideoCallUserInfoView(frame: CGRect.zero)
    }()
    
    let audioFunctionView = {
        return AudioCallerWaitingAndAcceptedView(frame: CGRect.zero)
    }()
    
    let videoFunctionView =  {
        return VideoCallerAndCalleeAcceptedView(frame: CGRect.zero)
    }()
    
    let videoInviteFunctionView = {
        return VideoCallerWaitingView(frame: CGRect.zero)
    }()
    
    let inviteeWaitFunctionView = {
        return AudioAndVideoCalleeWaitingView(frame: CGRect.zero)
    }()
    
    let renderBackgroundView = {
        return SingleCallVideoLayout(frame: CGRect.zero)
    }()
    
    let switchToAudioView = {
        return SwitchAudioView(frame: CGRect.zero)
    }()
    
    let timerView = {
        return TimerView(frame: CGRect.zero)
    }()
    
    let floatingWindowBtn = {
        return FloatingWindowButton(frame: CGRect.zero)
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        let screenSize = UIScreen.main.bounds.size
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        backgroundColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        
        createView()
        registerObserveState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.mediaType.removeObserver(mediaTypeObserver)
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    //MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }

    func constructViewHierarchy() {
        addSubview(renderBackgroundView)
        addSubview(userInfoAudioView)
        addSubview(userInfoVideoView)
        addSubview(audioFunctionView)
        addSubview(videoFunctionView)
        addSubview(videoInviteFunctionView)
        addSubview(inviteeWaitFunctionView)
        addSubview(switchToAudioView)
        addSubview(timerView)
        addSubview(floatingWindowBtn)
        
    }
    
    func activateConstraints() {
        let isAuidoCall: Bool = TUICallState.instance.mediaType.value == .audio ? true : false

        renderBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(self)
        }
        
        userInfoAudioView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(StatusBar_Height + 75.0)
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(200)
        }
        
        userInfoVideoView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(StatusBar_Height + 20.0)
            make.leading.equalTo(self).offset(20)
            make.trailing.equalTo(self).offset(-20)
        }

        audioFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
            make.height.equalTo(92.0)
            make.width.equalTo(self.snp.width)
        })
        
        videoFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
            make.height.equalTo(200.0)
            make.width.equalTo(self.snp.width)
        })

        videoInviteFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
            make.height.equalTo(92.0)
            make.width.equalTo(self.snp.width)
        })

        inviteeWaitFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
            make.height.equalTo(92.0)
            make.width.equalTo(self.snp.width)
        })


        switchToAudioView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.height.equalTo(30)
            make.width.equalTo(self.snp.width)
            make.bottom.equalTo(self.videoFunctionView.snp.top).offset(-10)

        }

        timerView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.height.equalTo(30)
            make.width.equalTo(snp.width)
            make.bottom.equalTo(isAuidoCall ? self.audioFunctionView.snp.top : self.switchToAudioView.snp.top).offset(-10)
        }

        floatingWindowBtn.snp.makeConstraints { make in
            make.size.equalTo(kFloatWindowButtonSize)
            make.top.equalToSuperview().offset(StatusBar_Height + 10)
            make.leading.equalToSuperview().offset(20)
        }
    }
    
    //MARK: View Create & Manage
    func createView() {
        cleanView()
        
        if viewModel.enableFloatWindow {
            floatingWindowBtn.isHidden = false
        } else {
            floatingWindowBtn.isHidden = true
        }
        
        if viewModel.selfCallStatus.value == .waiting {
            createWaitingView()
        } else if viewModel.selfCallStatus.value == .accept {
            createAcctepView()
        }
    }
    
    func createWaitingView() {
        switch TUICallState.instance.mediaType.value {
            case .audio:
                createAudioWaitingView()
            case .video:
                createVideoWaitingView()
            case .unknown:
                break
            default:
                break
        }
    }
    
    func createAudioWaitingView() {
        userInfoAudioView.isHidden = false
        if viewModel.selfCallRole.value == .call {
            audioFunctionView.isHidden = false
        } else {
            inviteeWaitFunctionView.isHidden = false
        }
    }
    
    func createVideoWaitingView() {
        renderBackgroundView.isHidden = false
        userInfoVideoView.isHidden = false
        switchToAudioView.isHidden = false
        if viewModel.selfCallRole.value == .call {
            videoInviteFunctionView.isHidden = false
        } else {
            inviteeWaitFunctionView.isHidden = false
        }
    }
    
    func createAcctepView() {
        switch viewModel.mediaType.value {
            case .audio:
                createAudioAcceptView()
            case .video:
                createVideoAcceptView()
            case .unknown:
                break
            default:
                break
        }
    }
    
    func createAudioAcceptView() {
        userInfoAudioView.isHidden = false
        timerView.isHidden = false
        audioFunctionView.isHidden = false
    }
    
    func createVideoAcceptView() {
        renderBackgroundView.isHidden = false
        timerView.isHidden = false
        switchToAudioView.isHidden = false
        videoFunctionView.isHidden = false
    }
    

    func cleanView() {
        userInfoVideoView.isHidden = true
        userInfoAudioView.isHidden = true
        audioFunctionView.isHidden = true
        videoFunctionView.isHidden = true
        videoInviteFunctionView.isHidden = true
        inviteeWaitFunctionView.isHidden = true
        renderBackgroundView.isHidden = true
        timerView.isHidden = true
        switchToAudioView.isHidden = true
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        mediaTypeChanged()
    }
    
    func callStatusChanged() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.createView()
        })
    }
    
    func mediaTypeChanged() {
        viewModel.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            self.createView()
        }
    }
}
