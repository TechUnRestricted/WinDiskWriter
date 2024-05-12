//
//  BaseViewController.swift
//  WinDiskWriter
//
//  Created by Macintosh on 21.04.2024.
//

import Cocoa

class BaseViewController: NSViewController {
    let safeZoneViewPadding: CGFloat

    let safeZoneView = NSView()
    let containerVerticalStackView = VerticalStackView()

    private var didAppearBefore: Bool = false

    init(safeZoneViewPadding: CGFloat = 0) {
        self.safeZoneViewPadding = safeZoneViewPadding

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active

        view = visualEffectView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        title = AppInfo.appName
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        
        guard !didAppearBefore else {
            return
        }

        arrangeSubviews()
    }

    private func arrangeSubviews() {
        addSafeZoneView()
        addContainerVerticalStackView()
    }

    private func setupViews() {
        setupSafeZoneView()
        setupContainerVerticalStackView()
    }
}

extension BaseViewController {
    private func setupSafeZoneView() {
        // safeZoneView.wantsLayer = true
        // safeZoneView.layer?.backgroundColor = NSColor.purple.cgColor
    }

    private func setupContainerVerticalStackView() {
        // containerVerticalStackView.wantsLayer = true
        // containerVerticalStackView.layer?.backgroundColor = NSColor.orange.cgColor
    }
}

extension BaseViewController {
    private func addSafeZoneView() {
        view.addSubview(safeZoneView)

        let baseWindow = view.window as? BaseWindow
        let titlebarHeight = baseWindow?.titleBarHeight ?? 0

        let doubledSafeZoneViewPadding: CGFloat = safeZoneViewPadding * 2
        safeZoneView.makeConstraints { make in
            make.constraint(with: .width, to: .width, of: view, constant: -doubledSafeZoneViewPadding)

            make.constraint(with: .top, to: .top, of: view, constant: titlebarHeight)
            make.constraint(with: .bottom, to: .bottom, of: view, constant: -doubledSafeZoneViewPadding / 2)

            make.constraint(with: .centerX, to: .centerX, of: view)
        }
    }

    private func addContainerVerticalStackView() {
        safeZoneView.addSubview(containerVerticalStackView)

        containerVerticalStackView.makeConstraints { make in
            make.constraint(with: .top, to: .top, of: safeZoneView)
            make.constraint(with: .leading, to: .leading, of: safeZoneView)
            make.constraint(with: .trailing, to: .trailing, of: safeZoneView)
            make.constraint(.lessThanOrEqual, with: .bottom, to: .bottom, of: safeZoneView)
        }
    }
}

