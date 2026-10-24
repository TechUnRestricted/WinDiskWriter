# Log cell regression

Run on macOS with the Xcode command-line tools and access to the desktop session:

```sh
xcrun clang -fobjc-arc -framework Cocoa \
  -I WinDiskWriter/Cells/MiddleAlignedCell \
  Tests/MiddleAlignedCellRegression.m \
  WinDiskWriter/Cells/MiddleAlignedCell/MiddleAlignedCell.m \
  -o /tmp/windiskwriter-cell-regression
/tmp/windiskwriter-cell-regression
```

The test updates a text field and renders a cell-based log table using the app's
custom cell. It reproduces the AppKit exception raised when the old `NSCell`
superclass receives text-field-specific messages during log updates, including
when Start appends its first log rows. It does not enumerate or write disks.
