//
//  AboutViewController.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import Cocoa

final class AboutViewController: BaseViewController {
    private var viewModel: AboutViewModel?

    private let appIconDraggableImageView = DraggableImageView()

    private let appNameVersionVerticalStackView = VerticalStackView()
    private let appNameLabelView = LabelView()
    private let appVersionLabelView = LabelView()

    override func viewDidLoad() {
        super.viewDidLoad()

        arrangeViews()
        setupViews()

        title = "About " + AppInfo.appName
    }

    init(viewModel: AboutViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func arrangeViews() {
        containerVerticalStackView.appendView(appIconDraggableImageView)
        appIconDraggableImageView.makeConstraints { make in
            let size: CGFloat = 120

            make.size(.equal, width: size, height: size)
        }

        containerVerticalStackView.appendView(appNameVersionVerticalStackView)
        appNameVersionVerticalStackView.appendView(appNameLabelView)
        appNameVersionVerticalStackView.appendView(appVersionLabelView)
    }

    private func setupViews() {
        setupContainerVerticalStackView()
        setupAppIconDraggableImageView()

        setupAppNameVersionVerticalStackView()
        setupAppNameLabelView()
        setupVersionLabelView()
    }

    private func setupContainerVerticalStackView() {
        containerVerticalStackView.spacing = 8
    }

    private func setupAppIconDraggableImageView() {
        appIconDraggableImageView.image = NSApp.applicationIconImage
        appIconDraggableImageView.imageScaling = .scaleProportionallyUpOrDown
    }

    private func setupAppNameVersionVerticalStackView() {
        appNameVersionVerticalStackView.spacing = 2

        appNameVersionVerticalStackView.wantsLayer = true
        //appNameVersionVerticalStackView.layer?.backgroundColor = NSColor.red.cgColor
    }

    private func setupAppNameLabelView() {
        let attributedString = AttributedStringBuilder(string: AppInfo.appName)
            .weight(4)
            .fontSize(NSFont.systemFontSize * 1.5)
            .build()

        appNameLabelView.attributedStringValue = attributedString
        appNameLabelView.alignment = .center
        appNameLabelView.cell!.alignment = .center

        appNameLabelView.wantsLayer = true
        appNameLabelView.layer?.backgroundColor = NSColor.orange.cgColor
    }

    private func setupVersionLabelView() {
        let string = "Version" + ": " + AppInfo.appVersion

        let attributedString = AttributedStringBuilder(string: string)
            .weight(3)
            .build()

        appVersionLabelView.attributedStringValue = attributedString
        appVersionLabelView.alignment = .center

        appVersionLabelView.wantsLayer = true
        appVersionLabelView.layer?.backgroundColor = NSColor.purple.cgColor
    }
}
