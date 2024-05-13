//
//  AboutViewController.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import Cocoa

final class AboutViewController: BaseViewController {
    private var viewModel: AboutViewModel?

    private let appInfoVerticalStackView = VerticalStackView()
    private let appIconDraggableImageView = DraggableImageView()

    private let appNameVersionVerticalStackView = VerticalStackView()
    private let appNameLabelView = LabelView()
    private let appVersionLabelView = LabelView()

    private let appDescriptionLabelView = LabelView()

    private let additionInfoVerticalStackView = VerticalStackView()
    private let additionalInfoLabelView = LabelView()
    private let additionalInfoScrollableTextView = ScrollableTextView()

    private let donateDeveloperVerticalStackView = VerticalStackView()
    private let donateMeRoundedButtonView = RoundedButtonView()
    private let developerLabelView = LabelView()

    override func viewDidLoad() {
        super.viewDidLoad()

        arrangeViews()
        setupViews()
        bindModel()

        title = "About " + AppInfo.appName
    }

    init(viewModel: AboutViewModel) {
        self.viewModel = viewModel

        super.init(safeZoneViewPadding: 12)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindModel() {
        guard let viewModel = viewModel else {
            return
        }

        additionalInfoScrollableTextView.bind(
            .attributedString,
            to: viewModel,
            withKeyPath: #keyPath(AboutViewModel.licenses),
            options: [.valueTransformerName: NSValueTransformerName.licenseListTextFieldValueTransformerName]
        )
    }

    private func arrangeViews() {
        containerVerticalStackView.appendView(appInfoVerticalStackView)

        appInfoVerticalStackView.appendView(appIconDraggableImageView)
        appIconDraggableImageView.makeConstraints { make in
            let size: CGFloat = 120

            make.size(.equal, width: size, height: size)
        }

        appInfoVerticalStackView.appendView(appNameVersionVerticalStackView)
        appNameVersionVerticalStackView.appendView(appNameLabelView)
        appNameVersionVerticalStackView.appendView(appVersionLabelView)

        containerVerticalStackView.appendView(appDescriptionLabelView)

        containerVerticalStackView.appendView(additionInfoVerticalStackView)
        additionInfoVerticalStackView.appendView(additionalInfoLabelView)
        additionInfoVerticalStackView.appendView(additionalInfoScrollableTextView)
        additionalInfoScrollableTextView.makeConstraints { make in
            make.size(.greaterThanOrEqual, width: 270, height: 140)
        }

        containerVerticalStackView.appendView(donateDeveloperVerticalStackView)
        donateDeveloperVerticalStackView.appendView(donateMeRoundedButtonView, allowsWidthExpansion: false)
        donateDeveloperVerticalStackView.appendView(developerLabelView)
    }

    private func setupViews() {
        setupAppInfoVerticalStackView()
        setupContainerVerticalStackView()
        setupAppIconDraggableImageView()

        setupAppNameVersionVerticalStackView()
        setupAppNameLabelView()
        setupVersionLabelView()

        setupAppDescriptionLabelView()

        setupAdditionInfoVerticalStackView()
        setupAdditionalInfoLabelView()
        setupAdditionalInfoScrollableTextView()

        setupDonateDeveloperVerticalStackView()
        setupDonateMeRoundedButtonView()
        setupDeveloperLabelView()
    }

    private func setupContainerVerticalStackView() {
        containerVerticalStackView.spacing = 14
    }

    private func setupAppInfoVerticalStackView() {

    }

    private func setupAppIconDraggableImageView() {
        appIconDraggableImageView.image = NSApp.applicationIconImage
        appIconDraggableImageView.imageScaling = .scaleProportionallyUpOrDown
    }

    private func setupAppNameVersionVerticalStackView() {
        appNameVersionVerticalStackView.spacing = 2
    }

    private func setupAppNameLabelView() {
        let attributedString = AttributedStringBuilder(string: AppInfo.appName)
            .fontSize(NSFont.systemFontSize * 1.5)
            .horizontalAlignment(.center)
            .weight(4)
            .build()

        appNameLabelView.attributedStringValue = attributedString
    }

    private func setupVersionLabelView() {
        let string = "Version" + ": " + AppInfo.appVersion

        let attributedString = AttributedStringBuilder(string: string)
            .horizontalAlignment(.center)
            .weight(3)
            .build()

        appVersionLabelView.attributedStringValue = attributedString
    }

    private func setupAppDescriptionLabelView() {
        let attributedString = AttributedStringBuilder(string: AppInfo.appDescription )
            .weight(3)
            .horizontalAlignment(.center)
            .build()

        appDescriptionLabelView.attributedStringValue = attributedString
    }

    private func setupAdditionInfoVerticalStackView() {

    }

    private func setupAdditionalInfoLabelView() {
        let string = "Open Source Licenses"

        let attributedString = AttributedStringBuilder(string: string)
            .weight(6)
            .build()

        additionalInfoLabelView.attributedStringValue = attributedString
    }

    private func setupAdditionalInfoScrollableTextView() {

    }

    private func setupDonateDeveloperVerticalStackView() {

    }

    private func setupDonateMeRoundedButtonView() {
        donateMeRoundedButtonView.title = "❤️ Donate Me ❤️"

        donateMeRoundedButtonView.clickAction = { [weak self] in
            self?.viewModel?.openDevelopersGitHubPage()
        }
    }

    private func setupDeveloperLabelView() {
        developerLabelView.stringValue = AppInfo.developerName
        developerLabelView.alignment = .center
    }
}
