import Cocoa

public func +(s1: CGSize, s2: CGSize) -> CGSize {
    return CGSizeMake(s1.width + s2.width, s1.height + s2.height)
}

public func -(s1: CGSize, s2: CGSize) -> CGSize {
    return CGSizeMake(s1.width - s2.width, s1.height - s2.height)
}

public func *(s1: CGSize, s2: CGSize) -> CGSize {
    return CGSizeMake(s1.width * s2.width, s1.height * s2.height)
}

public func /(s1: CGSize, s2: CGSize) -> CGSize {
    return CGSizeMake(s1.width / s2.width, s1.height / s2.height)
}

public func +(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPointMake(p1.x + p2.x, p1.y + p2.y)
}

public func -(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPointMake(p1.x - p2.x, p1.y - p2.y)
}

public func *(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPointMake(p1.x * p2.x, p1.y * p2.y)
}

public func /(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPointMake(p1.x / p2.x, p1.y / p2.y)
}

public func *(d: CGFloat, s: CGSize) -> CGSize {
    return CGSizeMake(d * s.width, d * s.height)
}

public func *(p: CGPoint, s: CGSize) -> CGPoint {
    return CGPointMake(p.x * s.width, p.y * s.height)
}

/*:
`fit(size, align, bounds)` berechnet innerhalb von `bounds` ein Rechteck, in das ein Diagram der virtuellen
Größe `size` mit Alignment `align` passt.
*/
public func fit(size: CGSize, align: CGPoint, bounds: CGRect) -> CGRect {
    let scaledSize: CGSize = bounds.size / size
    let scale = min(scaledSize.width, scaledSize.height)
    let fittedSize = scale * size
    let offset = align * (bounds.size - fittedSize)
    return CGRect(origin: bounds.origin + offset, size: fittedSize)
}

enum AssertionError: ErrorType {
    case AssertionFailed(message: String)
}
//: Der Import von `XCTest` führt zum Abbruch des Playgrounds. Daher hier eine eigene Definition von `assertEqual`.
public func assertEqual<T : Equatable>(expected: T, actual: T) {
    if (expected != actual) {
        print("assertEqual failed! expected: \(expected), actual: \(actual)")
    }
}

func testFit() {
    assertEqual(
        CGRect(x: 0, y: 0, width: 100, height: 200),
        actual: fit(CGSize(width: 100, height: 200), align: CGPoint(x: 0, y: 0),
            bounds: CGRect(x: 0, y: 0, width: 200, height: 200))
    )

    assertEqual(
        CGRect(x: 50, y: 0, width: 100, height: 200),
        actual: fit(CGSize(width: 100, height: 200), align: CGPoint(x: 0.5, y: 1),
            bounds: CGRect(x: 0, y: 0, width: 200, height: 200))
    )

    assertEqual(
        CGRect(x: 75, y: 0, width: 150, height: 300),
        actual: fit(CGSize(width: 100, height: 200), align: CGPoint(x: 0.5, y: 1),
            bounds: CGRect(x: 0, y: 0, width: 300, height: 300))
    )

    assertEqual(
        CGRect(x: -20, y: -30, width: 50, height: 100),
        actual: fit(CGSize(width: 100, height: 200), align: CGPoint(x: 0, y: 0),
            bounds: CGRect(x: -20, y: -30, width: 100, height: 100))
    )
}


public let alignCenter = CGPoint(x: 0.5, y: 0.5)

/*:
`splitHorizontal(left, right, bounds)` teilt `bounds` so auf, dass Diagramme mit realen Größen `left` und `right`
nebeneinander hineinpassen.
*/
public func splitHorizontal(left: CGSize, right: CGSize, bounds: CGRect) -> (CGRect, CGRect) {
    let totalWidth = left.width + right.width
    let leftShare = left.width / totalWidth
    let leftWidth = leftShare * bounds.width
    let leftBounds = CGRect(origin: bounds.origin, size: CGSize(width: leftWidth, height: bounds.height))
    let rightWidth = bounds.width - leftWidth
    let rightBounds =
    CGRect(x: bounds.origin.x + leftWidth, y: bounds.origin.y,
        width: rightWidth, height: bounds.height)
    return (leftBounds, rightBounds)
}

func testSplitHorizontal() {
    let (sampleLeft, sampleRight) =
    splitHorizontal(CGSize(width: 10, height: 10),
        right: CGSize(width: 20, height: 20),
        bounds: CGRect(x: 0, y: 0, width: 300, height: 200))

    assertEqual(CGRect(x: 0, y: 0, width: 100, height: 200), actual: sampleLeft)
    assertEqual(CGRect(x: 100, y: 0, width: 200, height: 200), actual: sampleRight)
}


/*:
`splitVertical(top, bottom, bounds)` teilt `bounds` so auf, dass Diagramme mit realen Größen `top` und
`bottom` untereinander hineinpassen.
*/
public func splitVertical(top: CGSize, bottom: CGSize, bounds: CGRect) -> (CGRect, CGRect) {
    let totalHeight = top.height + bottom.height
    let topShare = top.height / totalHeight
    let topHeight = topShare * bounds.height
    let bottomHeight = bounds.height - topHeight
    let bottomBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: bottomHeight))
    let topBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y + bottomHeight, width: bounds.width, height: topHeight)
    return (topBounds, bottomBounds)
}

func testSplitVertical() {
    let (sampleTop, sampleBottom) =
    splitVertical(CGSize(width: 10, height: 10),
        bottom: CGSize(width: 20, height: 20),
        bounds: CGRect(x: 0, y: 0, width: 300, height: 300))

    assertEqual(CGRect(x: 0, y: 200, width: 300, height: 100), actual:sampleTop)
    assertEqual(CGRect(x: 0, y: 0, width: 300, height: 200), actual:sampleBottom)
}

public func testAuxiliaries() {
    print("Running tests...")
    testFit()
    testSplitHorizontal()
    testSplitVertical()
    print("Done running tests")
}
