//
//  AboutViewController.swift
//  WinDiskWriter
//
//  Created by Macintosh on 11.05.2024.
//

import Cocoa

final class AboutViewController: BaseViewController {
    private var viewModel: AboutViewModel?

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

    }

    private func setupViews() {
        
    }
}
