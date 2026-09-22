//
//  EditorViewController+Ratio.swift
//  HXPhotoPicker
//
//  Created by Silence on 2023/5/17.
//

import UIKit

extension EditorViewController: EditorRatioToolViewDelegate {
    func ratioToolView(_ ratioToolView: EditorRatioToolView, didSelectedRatioAt ratio: CGSize) {
        if ratio.width < 0 || ratio.height < 0 {
            editorView.isFixedRatio = true
            let ratio = editorView.originalAspectRatio
            let buttonType: Int
            if let selectType = scaleSwitchSelectType {
                buttonType = selectType
                if selectType == 0 {
                    if ratio.width < ratio.height {
                        editorView.setAspectRatio(ratio, animated: true)
                    }else {
                        editorView.setAspectRatio(.init(width: ratio.height, height: ratio.width), animated: true)
                    }
                }else {
                    if ratio.width < ratio.height {
                        editorView.setAspectRatio(.init(width: ratio.height, height: ratio.width), animated: true)
                    }else {
                        editorView.setAspectRatio(ratio, animated: true)
                    }
                }
            }else {
                buttonType = ratio.width < ratio.height ? 0 : 1
                scaleSwitchSelectType = buttonType
                editorView.setAspectRatio(ratio, animated: true)
            }
            scaleSwitchLeftBtn.isSelected = buttonType == 0
            scaleSwitchRightBtn.isSelected = buttonType == 1
            showScaleSwitchView(UIDevice.isPortrait)
            hideMasks()
        }else {
            hideScaleSwitchView(UIDevice.isPortrait)
            editorView.isFixedRatio = ratio != .zero
            if editorView.isFixedRatio {
                editorView.setAspectRatio(ratio, animated: true)
            }
        }
        resetButton.isEnabled = isReset
        if isLegacyCropLayout { checkFinishButtonState() }
    }
}

// The basic layout is opt-in so the upstream editor and its export/delegate
// behavior stay intact for every other picker, camera, and video configuration.
extension EditorViewController {
    var isLegacyCropLayout: Bool {
        config.usesLegacyCropLayout && config.isFixedCropSizeState && selectedAsset.contentType == .image
    }

    func configureLegacyCropControls() {
        cancelButton.accessibilityIdentifier = "hx.legacyCrop.cancel"
        finishButton.accessibilityIdentifier = "hx.legacyCrop.finish"
        resetButton.accessibilityIdentifier = "hx.legacyCrop.reset"
        leftRotateButton.accessibilityIdentifier = "hx.legacyCrop.rotate"
        cancelButton.titleLabel?.font = .systemFont(ofSize: 15)
        finishButton.titleLabel?.font = .systemFont(ofSize: 15)
        if let title = config.legacyCropFinishTitle {
            finishButton.setTitle(title, for: .normal)
        }
        finishButton.setTitleColor(config.finishButtonTitleDisableColor, for: .disabled)
        resetButton.titleLabel?.font = .systemFont(ofSize: 16)
        leftRotateButton.titleLabel?.font = .systemFont(ofSize: 16)
        leftRotateButton.setTitle("旋转".localized, for: .normal)
        leftRotateButton.setTitleColor(.white, for: .normal)
        leftRotateButton.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 0)
        resetButton.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 0)
        if #available(iOS 13.0, *) {
            resetButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
            resetButton.tintColor = .white
        }

        let ratioButton = UIButton(type: .custom)
        ratioButton.setImage(.imageResource.editor.tools.cropSize.image, for: .normal)
        ratioButton.accessibilityIdentifier = "hx.legacyCrop.ratio"
        ratioButton.accessibilityLabel = "比例".localized
        ratioButton.addTarget(self, action: #selector(didLegacyRatioButtonClick), for: .touchUpInside)
        ratioButton.alpha = 0
        ratioButton.isHidden = true
        legacyRatioButton = ratioButton
        view.addSubview(ratioButton)
    }

    func layoutLegacyCropControls() {
        let insets = view.safeAreaInsets
        let left = insets.left + 20
        let right = view.width - insets.right - 20
        let centerX = (insets.left + view.width - insets.right) / 2
        let bottomY = view.height - insets.bottom - 40
        cancelButton.frame = .init(x: left, y: bottomY, width: max(50, cancelButton.width), height: 40)
        finishButton.frame = .init(x: right - max(50, finishButton.width), y: bottomY, width: max(50, finishButton.width), height: 40)
        legacyRatioButton?.frame = .init(x: centerX - 25, y: bottomY, width: 50, height: 40)
        resetButton.frame = .init(x: centerX - 120, y: bottomY - 60, width: 100, height: 60)
        leftRotateButton.frame = .init(x: centerX + 20, y: bottomY - 60, width: 100, height: 60)
        hideAdditionalCropControls()
    }

    func showLegacyCropControls() {
        hideAdditionalCropControls()
        for button in [cancelButton, finishButton, resetButton, leftRotateButton, legacyRatioButton] {
            button?.isHidden = false
            button?.alpha = 1
        }
        legacyRatioButton?.isHidden = config.cropSize.aspectRatios.isEmpty
        layoutLegacyCropControls()
        checkFinishButtonState()
    }

    private func hideAdditionalCropControls() {
        for control in [rotateScaleView, ratioToolView, rightRotateButton,
                        mirrorHorizontallyButton, mirrorVerticallyButton,
                        maskListButton, scaleSwitchView, toolsView,
                        topMaskView, bottomMaskView] as [UIView?] {
            control?.isHidden = true
            control?.alpha = 0
        }
    }

    @objc func didLegacyRatioButtonClick() {
        guard isLegacyCropLayout, presentedViewController == nil,
              let ratioButton = legacyRatioButton else { return }
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for (index, option) in config.cropSize.aspectRatios.enumerated() {
            sheet.addAction(UIAlertAction(title: option.title.text, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.ratioToolView.scrollToIndex(at: index, animated: false)
                self.ratioToolView(self.ratioToolView, didSelectedRatioAt: option.ratio)
            })
        }
        sheet.addAction(UIAlertAction(title: .textManager.editor.tools.cancelTitle.text, style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = ratioButton
            popover.sourceRect = ratioButton.bounds
        }
        present(sheet, animated: true)
    }
}
