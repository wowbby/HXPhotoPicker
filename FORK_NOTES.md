# wowbby fork 5.0.6

This release combines the fork's existing master (`ca5f420`) with the compatibility changes based on upstream 5.0.5. It preserves the upstream history, copyright notices, and MIT license. The version identifies this fork; it is not a release published by SilenceLove.

## Install

Use an explicit Git source so CocoaPods resolves this fork:

```ruby
pod 'HXPhotoPicker', :git => 'https://github.com/wowbby/HXPhotoPicker.git', :tag => '5.0.6'
```

For Swift Package Manager, use `https://github.com/wowbby/HXPhotoPicker.git` with the exact version `5.0.6`. Publishing the Git tag does not publish a spec to CocoaPods Trunk.

## Compatibility additions

- `EditorConfiguration.usesLegacyCropLayout` and `legacyCropFinishTitle`: optional basic crop controls, legacy icons, persistent grid lines, and safe-area-aware placement. In this mode, direct photo panning/pinching is disabled while crop-edge controls remain available.
- `PreviewViewConfiguration.usesSystemNavigationTransition`: optional UIKit page navigation from the picker to the preview.
- `PickerConfiguration.usesClassicAppearance`: optional opaque navigation and ordinary scroll-edge appearance. Pair it with `AlbumTitleView`, `PhotoToolBarView`, and ordinary button configurations to remove picker Liquid Glass styling. Live Photo preview marks also honor this option, including reused cells.
- Preview asset updates safely handle views that are not yet loaded. Toolbars without selected thumbnails ignore selected-strip offsets during preview return.

These options default to disabled. The existing upstream undo/redo, editor image-loading, and Live Photo updates on master are retained.

The retained upstream image-loading optimization downsamples large images before editing to a longest edge based on the screen size in pixels. Edited exports therefore may have fewer pixels than their originals; large animated GIF frames can also be reduced. This trades output resolution for lower editing memory use.

## Release validation

Validated on 2026-09-23 with CocoaPods and an iPhone 17 Pro simulator running iOS 26.4. The Objective-C/Swift integration harness passed all 31 XCTest cases, including legacy crop controls, picker navigation/cancellation, Live Photo appearance reuse, and a 6000 x 4000 JPEG loaded and exported as a square crop. The large-image check reads the exported file rather than the thumbnail returned in `ImageEditedResult.image`. Podspec parsing and Swift Package manifest parsing also passed. Physical-device acceptance remains separate.

## Known limitations

- Legacy crop mode does not yet support dragging inside the crop rectangle to move the whole rectangle. It supports the existing edge/corner controls.
- The upstream camera save-after-edit behavior is unchanged: with editing and album saving enabled, the edited image is saved. Applications expecting the 3.x save-original-before-edit behavior need additional adaptation.
- Actual-device edge-swipe completion/cancellation, camera permissions and saving, and iCloud failure paths still require application-level acceptance. Automated navigation and export checks do not substitute for these flows.

Downstream adapters using the fork-only configuration properties must depend on this fork's version and source, rather than the unmodified official 5.0.5 package.
