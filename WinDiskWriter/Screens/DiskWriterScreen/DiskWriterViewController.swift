//
//  DiskWriterViewController.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

fileprivate enum Constants {
    static let groupSpacing: CGFloat = 19.0
    static let verticalSpacing: CGFloat = 6.0
    static let horizontalSpacing: CGFloat = 12.0
}

final class DiskWriterViewController: BaseViewController {
    private var viewModel: DiskWriterViewModel?

    // MARK: - Image + Target Picker
    private let groupImageTargetSelectionVerticalStackView = VerticalStackView()
    
    // MARK: Image Picker
    private let imageSelectionVerticalStackView = VerticalStackView()
    private let imageSelectionLabelView = LabelView()
    private let imageSelectionHorizontalStackView = HorizontalStackView()
    private let imageSelectionTextInputView = TextInputView()
    private let imageSelectionChooseRoundedButtonView = RoundedButtonView()
    
    // MARK: Target Device Picker
    private let targetDeviceSelectionVerticalStackView = VerticalStackView()
    private let targetDeviceLabelView = LabelView()
    private let targetDevicePickerHorizontalStackView = HorizontalStackView()
    private let targetDevicePickerView = PickerView(frame: .zero, pullsDown: false)
    private let targetDeviceUpdateRoundedButtonView = RoundedButtonView()
    
    // MARK: Options Picker
    private let optionVerticalStackView = VerticalStackView()
    private let optionPatchInstallerRequirementsCheckboxView = CheckboxView()
    private let optionInstallLegacyBootCheckboxView = CheckboxView()
    
    // MARK: Filesystem Picker
    private let filesystemVerticalStackView = VerticalStackView()
    private let filesystemLabelView = LabelView()
    private let filesystemSwitchPickerView = SwitchPickerView<Filesystem>()
    
    // MARK: - On-Screen Logs
    private let logsScrollableLinesView = ScrollableLinesView()
    
    // MARK: - Progress Block
    private let progressBlockVerticalStackView = VerticalStackView()
    
    // MARK: Current Action
    private let currentActionHorizontalStackView = HorizontalStackView()
    private let currentActionLabelView = LabelView()
    
    // MARK: Bytes Written / Total
    private let currentProgressHorizontalStackView = HorizontalStackView()
    private let fileBytesWrittenLabelView = LabelView()
    private let fileBytesSeparatorLabelView = LabelView()
    private let fileBytesTotalLabelView = LabelView()
    
    // MARK: Progress Indicators
    private let currentOperationProgressIndicator = NSProgressIndicator()
    private let overallOperationProgressIndicator = NSProgressIndicator()
    
    // MARK: - Action Buttons
    private let startStopRoundedButtonView = RoundedButtonView()
    
    // MARK: - Developer Name + Donate Me Slideshowed button
    private let animatedSlideShowedButton = SlideShowedButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrangeViews()
        setupViews()
        bindModel()

        viewModel?.updateDevices()
    }

    override func viewWillAppearFirstTime() {
        viewModel?.checkMacStorage()
    }

    private func arrangeViews() {
        addImageTargetGroupSelectionControls()
        addOptionControls()
        addFilesystemControls()
        addLogsScrollableLineControls()
        addProgressBlockControls()
        addActionControls()
        addAnimatedSlideShowControls()
    }
    
    private func setupViews() {
        setupContainerVerticalStackView()
        
        setupGroupImageTargetSelectionVerticalStackView()
        
        setupImageSelectionVerticalStackView()
        setupImageSelectionLabelView()
        setupImageSelectionHorizontalStackView()
        setupImageSelectionTextInputView()
        setupImageSelectionChooseRoundedButtonView()
        
        setupTargetDeviceSelectionVerticalStackView()
        setupTargetDeviceLabelView()
        setupTargetDevicePickerHorizontalStackView()
        setupTargetDeviceUpdateRoundedButtonView()
        
        setupOptionVerticalStackView()
        setupOptionPatchInstallerRequirementsCheckboxView()
        setupOptionInstallLegacyBootCheckboxView()
        
        setupFilesystemLabelView()
        setupFilesystemSwitchPickerView()
        
        setupLogsScrollableLinesView()
        
        setupProgressBlockVerticalStackView()
        setupCurrentActionHorizontalStackView()
        setupCurrentProgressHorizontalStackView()
        setupCurrentActionLabelView()
        setupWriteProgressLabelViews()
        
        setupStartStopRoundedButtonView()
        
        setupAnimatedSlideShowedButton()
    }
    
    private func bindModel() {
        guard let viewModel = viewModel else {
            return
        }

        imageSelectionTextInputView.bind(
            .value,
            to: viewModel,
            withKeyPath: #keyPath(DiskWriterViewModel.imagePath),
            options: [
                .continuouslyUpdatesValue: true,
                .nullPlaceholder: "Disk Image File"
            ]
        )

        targetDevicePickerView.bind(
            .menuItems,
            to: viewModel,
            withKeyPath: #keyPath(DiskWriterViewModel.disksInfoList),
            options: [
                .continuouslyUpdatesValue: true,
                .valueTransformerName: NSValueTransformerName.devicePickerMenuItemsTransformerName
            ]
        )

        viewModel.selectedDiskInfo = { [weak self] in
            guard let diskMenuItem = self?.targetDevicePickerView.selectedItem as? DiskMenuItem else {
                return nil
            }

            return diskMenuItem.diskInfo
        }

        filesystemSwitchPickerView.bind(
            .selectedIndex,
            to: viewModel,
            withKeyPath: #keyPath(DiskWriterViewModel.filesystem),
            options: [.continuouslyUpdatesValue: true]
        )
        
        optionPatchInstallerRequirementsCheckboxView.bind(
            .value,
            to: viewModel,
            withKeyPath: #keyPath(DiskWriterViewModel.patchInstallerRequirements),
            options: [.continuouslyUpdatesValue: true]
        )
        
        optionInstallLegacyBootCheckboxView.bind(
            .value,
            to: viewModel,
            withKeyPath: #keyPath(DiskWriterViewModel.installLegacyBIOSBootSector),
            options: [.continuouslyUpdatesValue: true]
        )

        currentProgressHorizontalStackView.bind(
            .hidden,
            to: AppService.shared,
            withKeyPath: #keyPath(AppService.isIdle),
            options: [.continuouslyUpdatesValue: true]
        )

        startStopRoundedButtonView.bind(
            .title,
            to: AppService.shared,
            withKeyPath: #keyPath(AppService.isIdle),
            options: [.valueTransformerName: NSValueTransformerName.actionButtonTitleTransformerName]
        )
        
        for conditionallyEnabledView in [
            imageSelectionTextInputView,
            imageSelectionChooseRoundedButtonView,
            
            targetDevicePickerView,
            targetDeviceUpdateRoundedButtonView,
            
            optionPatchInstallerRequirementsCheckboxView,
            optionInstallLegacyBootCheckboxView,
            
            filesystemSwitchPickerView
        ] {
            conditionallyEnabledView.bind(
                .enabled,
                to: AppService.shared,
                withKeyPath: #keyPath(AppService.isIdle),
                options: [.continuouslyUpdatesValue: true]
            )
        }
        
        imageSelectionChooseRoundedButtonView.clickAction = { [weak self] in
            self?.viewModel?.pickImage()
        }

        targetDeviceUpdateRoundedButtonView.clickAction = { [weak self] in
            self?.viewModel?.updateDevices()
        }
        
        viewModel.appendLogLine = { [weak self] (logType, line) in
            self?.logsScrollableLinesView.appendRow(
                withContent: "[\(logType.stringRepresentation)] \(line)"
            )
        }
        
        startStopRoundedButtonView.clickAction = { [weak self] in
            self?.viewModel?.triggerAction()
        }
        
        animatedSlideShowedButton.stringArray = viewModel.slideshowStringArray
    }
    
    init(viewModel: DiskWriterViewModel) {
        self.viewModel = viewModel
        
        super.init(safeZoneViewPadding: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DiskWriterViewController {
    private func addImageTargetGroupSelectionControls() {
        containerVerticalStackView.appendView(groupImageTargetSelectionVerticalStackView)
        
        // MARK: Image Selection
        groupImageTargetSelectionVerticalStackView.appendView(imageSelectionVerticalStackView)
        imageSelectionVerticalStackView.appendView(imageSelectionLabelView)
        imageSelectionVerticalStackView.appendView(imageSelectionHorizontalStackView)
        
        let textInputMinWidth: CGFloat = 210
        let pickerButtonMinWidth: CGFloat = 85
        
        imageSelectionHorizontalStackView.appendView(imageSelectionTextInputView)
        imageSelectionTextInputView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: textInputMinWidth)
        }
        
        imageSelectionHorizontalStackView.appendView(imageSelectionChooseRoundedButtonView)
        imageSelectionChooseRoundedButtonView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: pickerButtonMinWidth)
        }
        
        // MARK: Target Selection
        groupImageTargetSelectionVerticalStackView.appendView(targetDeviceSelectionVerticalStackView)
        targetDeviceSelectionVerticalStackView.appendView(targetDeviceLabelView)
        
        targetDeviceSelectionVerticalStackView.appendView(targetDevicePickerHorizontalStackView)
        
        targetDevicePickerHorizontalStackView.appendView(targetDevicePickerView, resistsHorizontalCompression: true)
        targetDevicePickerView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: textInputMinWidth)
        }
        
        targetDevicePickerHorizontalStackView.appendView(targetDeviceUpdateRoundedButtonView, allowsWidthExpansion: false)
        targetDeviceUpdateRoundedButtonView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: pickerButtonMinWidth)
            // make.size(.lessThanOrEqual, width: 100)
        }
    }
    
    private func addOptionControls() {
        containerVerticalStackView.appendView(optionVerticalStackView)
        optionVerticalStackView.appendView(optionPatchInstallerRequirementsCheckboxView)
        optionVerticalStackView.appendView(optionInstallLegacyBootCheckboxView)
    }
    
    private func addFilesystemControls() {
        containerVerticalStackView.appendView(filesystemVerticalStackView)
        filesystemVerticalStackView.appendView(filesystemLabelView)
        filesystemVerticalStackView.appendView(filesystemSwitchPickerView)
    }
    
    private func addLogsScrollableLineControls() {
        containerVerticalStackView.appendView(logsScrollableLinesView)
        
        logsScrollableLinesView.makeConstraints { make in
            make.size(.greaterThanOrEqual, height: 140)
        }
    }
    
    private func addProgressBlockControls() {
        containerVerticalStackView.appendView(progressBlockVerticalStackView)
        
        progressBlockVerticalStackView.appendView(currentActionHorizontalStackView)
        currentActionHorizontalStackView.appendView(currentActionLabelView, resistsHorizontalCompression: true)
        
        currentActionHorizontalStackView.appendView(currentProgressHorizontalStackView)
        
        let bytesLabelViewMinWidth: CGFloat = 68
        
        currentProgressHorizontalStackView.appendView(fileBytesWrittenLabelView, allowsWidthExpansion: false, resistsHorizontalCompression: true)
        fileBytesWrittenLabelView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: bytesLabelViewMinWidth)
        }
        
        currentProgressHorizontalStackView.appendView(fileBytesSeparatorLabelView, allowsWidthExpansion: false)
        
        currentProgressHorizontalStackView.appendView(fileBytesTotalLabelView, allowsWidthExpansion: false, resistsHorizontalCompression: true)
        fileBytesTotalLabelView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: bytesLabelViewMinWidth)
        }
        
        progressBlockVerticalStackView.appendView(currentOperationProgressIndicator)
        progressBlockVerticalStackView.appendView(overallOperationProgressIndicator, customSpacing: -4)
    }
    
    private func addActionControls() {
        startStopRoundedButtonView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: 165)
        }
        
        containerVerticalStackView.appendView(startStopRoundedButtonView, allowsWidthExpansion: false)
    }
    
    private func addAnimatedSlideShowControls() {
        containerVerticalStackView.appendView(animatedSlideShowedButton)
    }
}

extension DiskWriterViewController {
    private func setupContainerVerticalStackView() {
        containerVerticalStackView.spacing = Constants.groupSpacing
    }
    
    private func setupGroupImageTargetSelectionVerticalStackView() {
        groupImageTargetSelectionVerticalStackView.spacing = Constants.verticalSpacing
    }
    
    private func setupImageSelectionVerticalStackView() {
        imageSelectionVerticalStackView.spacing = Constants.verticalSpacing
        
        // imageSelectionVerticalStackView.wantsLayer = true
        // imageSelectionVerticalStackView.layer?.backgroundColor = NSColor.green.cgColor
    }
    
    private func setupImageSelectionLabelView() {
        imageSelectionLabelView.stringValue = "Windows Image"
    }
    
    private func setupImageSelectionHorizontalStackView() {
        imageSelectionHorizontalStackView.spacing = Constants.horizontalSpacing
    }
    
    private func setupImageSelectionTextInputView() {
        
    }
    
    private func setupImageSelectionChooseRoundedButtonView() {
        imageSelectionChooseRoundedButtonView.title = "Choose"
    }
    
    private func setupTargetDeviceSelectionVerticalStackView() {
        targetDeviceSelectionVerticalStackView.spacing = Constants.verticalSpacing
    }
    
    private func setupTargetDeviceLabelView() {
        targetDeviceLabelView.stringValue = "Target Device"
    }
    
    private func setupTargetDevicePickerHorizontalStackView() {
        targetDevicePickerHorizontalStackView.spacing = Constants.horizontalSpacing
    }
    
    private func setupTargetDeviceUpdateRoundedButtonView() {
        targetDeviceUpdateRoundedButtonView.title = "Update"
    }
    
    private func setupOptionVerticalStackView() {
        
    }
    
    private func setupOptionPatchInstallerRequirementsCheckboxView() {
        optionPatchInstallerRequirementsCheckboxView.title = "Patch Installer Requirements"
    }
    
    private func setupOptionInstallLegacyBootCheckboxView() {
        optionInstallLegacyBootCheckboxView.title = "Install Legacy BIOS Boot Sector"
        optionInstallLegacyBootCheckboxView.isChecked = AppService.hasElevatedRights

        optionInstallLegacyBootCheckboxView.clickAction = { [weak self] in
            guard let viewModel = self?.viewModel else {
                return
            }

            if !viewModel.isInstallLegacyBIOSBootSectorAvailable {
                self?.optionInstallLegacyBootCheckboxView.isChecked = false

                viewModel.showRestartWithEscalatedPermissionsAlert()
            }
        }
    }
    
    private func setupFilesystemLabelView() {
        filesystemLabelView.stringValue = "File System"
    }
    
    private func setupFilesystemSwitchPickerView() {
        filesystemSwitchPickerView.addSegment(title: "FAT32", identifier: .FAT32, makeDefault: true) { [weak self] _ in
            self?.optionInstallLegacyBootCheckboxView.isEnabled = true
        }
        
        filesystemSwitchPickerView.addSegment(title: "ExFAT", identifier: .exFAT) { [weak self] _ in
            self?.optionInstallLegacyBootCheckboxView.isEnabled = false
            self?.optionInstallLegacyBootCheckboxView.isChecked = false
        }
    }
    
    private func setupLogsScrollableLinesView() {
        logsScrollableLinesView.wantsLayer = true
        logsScrollableLinesView.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    private func setupProgressBlockVerticalStackView() {
        progressBlockVerticalStackView.spacing = 0
    }
    
    private func setupCurrentActionHorizontalStackView() {
        currentActionHorizontalStackView.alphaValue = 0.75
        currentActionHorizontalStackView.edgeInsets = NSEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
    }
    
    private func setupCurrentActionLabelView() {
        currentActionLabelView.stringValue = "Ready for action"
    }
    
    private func setupCurrentProgressHorizontalStackView() {
        currentProgressHorizontalStackView.spacing = 0
    }
    
    private func setupWriteProgressLabelViews() {
        for currentLabelView in [fileBytesWrittenLabelView, fileBytesSeparatorLabelView, fileBytesTotalLabelView] {
            currentLabelView.alignment = .center
            
            currentLabelView.wantsLayer = true
            currentLabelView.layer!.backgroundColor = NSColor.orange.cgColor
        }
        
        fileBytesSeparatorLabelView.stringValue = "/"
    }
    
    private func setupStartStopRoundedButtonView() {
        
    }
    
    private func setupAnimatedSlideShowedButton() {
        animatedSlideShowedButton.alignment = .center
        animatedSlideShowedButton.delayDuration = 8
        
        animatedSlideShowedButton.isSlideShowed = true
    }
}
