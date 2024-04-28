//
//  SlideShowedButton.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.04.2024.
//

import AppKit

class SlideShowedButton: BaseButtonView {
    var isSlideShowed: Bool = false {
        didSet {
            guard oldValue != isSlideShowed else {
                return
            }

            isSlideShowed ? startSlideShow() : stopSlideShow()
        }
    }

    var easeOutDuration: TimeInterval = 1
    var easeInDuration: TimeInterval = 1
    var delayDuration: TimeInterval = 3

    var stringArray: [String] = [] {
        didSet {
            restartSlideShowIfNeeded()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        isBordered = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var currentIndex = 0
    private var slideShowTimer: Timer?

    deinit {
        stopSlideShow()
    }

    private func restartSlideShowIfNeeded() {
        guard isSlideShowed else {
            return
        }

        startSlideShow()
    }

    private func resetState() {
        currentIndex = 0
        title = stringArray.first ?? ""
        alphaValue = 1.0
    }

    private func startSlideShow() {
        resetState()
        slideShowTimer?.invalidate()

        let proxy = WeakProxy(target: self)
        slideShowTimer = Timer.scheduledTimer(
            timeInterval: delayDuration,
            target: proxy,
            selector: #selector(SlideShowedButton.timerAction),
            userInfo: nil,
            repeats: true
        )
    }

    private func stopSlideShow() {
        slideShowTimer?.invalidate()
        slideShowTimer = nil
        layer?.removeAllAnimations()
    }

    @objc private func timerAction() {
        guard stringArray.count > 1 else {
            return
        }

        currentIndex = (currentIndex + 1) % stringArray.count

        if let currenttitle = stringArray[safe: currentIndex] {
            setAnimatedtitle(currenttitle)
        }
    }

    private func setAnimatedtitle(_ title: String) {
        animateAlpha(to: 0.0, duration: easeOutDuration, timingFunctionName: .easeOut) { [weak self] in
            guard let self = self else {
                return
            }

            self.title = title
            self.animateAlpha(to: 1.0, duration: self.easeInDuration, timingFunctionName: .easeIn)
        }
    }

    private func animateAlpha(
        to value: CGFloat,
        duration: TimeInterval,
        timingFunctionName: CAMediaTimingFunctionName,
        completion: (() -> Void)? = nil
    ) {
        NSAnimationContext.runAnimationGroup({ [weak self] context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
            self?.animator().alphaValue = value
        }, completionHandler: completion)
    }
}

