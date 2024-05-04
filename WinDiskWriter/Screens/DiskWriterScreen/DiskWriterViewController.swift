//
//  DiskWriterViewController.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

final class DiskWriterViewController: BaseViewController {
    private enum Constants {
        static let groupSpacing: CGFloat = 19.0

        static let verticalSpacing: CGFloat = 6.0
        static let horizontalSpacing: CGFloat = 12.0
    }

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

    private var isInWritingProcess: Bool = false {
        didSet {
            setInWritingProcess(isInWritingProcess)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        arrangeViews()
        setupViews()
        bindModel()

        isInWritingProcess = false
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

        viewModel.imagePath = { [weak self] in
            return self?.imageSelectionTextInputView.stringValue ?? ""
        }

        viewModel.didSelectImagePath = { [weak self] selectedPath in
            self?.imageSelectionTextInputView.stringValue = selectedPath
        }

        viewModel.filesystem = { [weak self] in
            return self?.filesystemSwitchPickerView.selectedCase ?? .FAT32
        }

        viewModel.patchInstallerRequirements = { [weak self] in
            return self?.optionPatchInstallerRequirementsCheckboxView.isChecked ?? false
        }

        viewModel.installLegacyBIOSBootSector = { [weak self] in
            return self?.optionInstallLegacyBootCheckboxView.isChecked ?? false
        }

        viewModel.updateDisksList = { [weak self] diskInfoList in
            guard let self = self else {
                return
            }

            self.targetDevicePickerView.removeAllItems()

            for diskInfo in diskInfoList {
                guard let menuItem = DiskMenuItem(diskInfo: diskInfo) else {
                    continue
                }

                self.targetDevicePickerView.menu?.addItem(menuItem)
            }
        }

        viewModel.selectedDiskInfo = { [weak self] in
            let diskMenuItem = self?.targetDevicePickerView.selectedItem as? DiskMenuItem

            return diskMenuItem?.diskInfo
        }

        viewModel.appendLogLine = { [weak self] logLine in
            self?.logsScrollableLinesView.appendRow(withContent: logLine)
        }

        viewModel.isInWritingProcess = { [weak self] in
            return self?.isInWritingProcess ?? false
        }

        viewModel.setInWritingProcess = { [weak self] flag in
            self?.isInWritingProcess = flag
        }

        viewModel.scanAllWholeDrives = {
            return true
        }

        optionInstallLegacyBootCheckboxView.clickAction = { [weak self] in
            let allowsStateChange = viewModel.isInstallLegacyBIOSBootSectorAvailable

            if !allowsStateChange {
                self?.optionInstallLegacyBootCheckboxView.isChecked = false
            }
        }

        imageSelectionChooseRoundedButtonView.clickAction = viewModel.pickImage
        targetDeviceUpdateRoundedButtonView.clickAction = viewModel.updateDevices

        animatedSlideShowedButton.stringArray = viewModel.slideshowStringArray
        animatedSlideShowedButton.clickAction = viewModel.visitDevelopersPage
    }

    init(viewModel: DiskWriterViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DiskWriterViewController {
    private func setInWritingProcess(_ isInWritingProcess: Bool) {
        guard let viewModel = viewModel else {
            return
        }

        if isInWritingProcess {
            startStopRoundedButtonView.title = "Stop"
            startStopRoundedButtonView.clickAction = viewModel.startProcess
        } else {
            startStopRoundedButtonView.title = "Start"
            startStopRoundedButtonView.clickAction = viewModel.stopProcess

            // containerVerticalStackView.setEnabledStateForAllControls(false)
        }
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
        imageSelectionTextInputView.placeholderString = "Image File or Directory"
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
