//: # Diagram - noun: a drawing used to explain something that is difficult to understand

//: Stefan Wehr (wehr@cp-med.com), 25.10.2015, macoun

/*:

Funktionale Programmierung ist (oft) **deklarativ**. Für das Zeichnen von Diagrammen bedeutet das:

* Um ein Diagramm zu zeichnen, spezifiziert der Programmiere **was** gezeichnet werden soll.
* Der Programmierer muss sich nicht darum kümmern **wie** das Zeichnen geschieht.

Im folgenden stellen wir die API und die Implementierung einer einfachen Bibliothek zum Zeichnen von
Diagrammen vor. Der Code basiert auf dem Buch *Functional Programming in Swift* 
(Chris Eidhof, Florian Kugler, Wouter Swierstra; 2014) sowie auf der 
Haskell-Bibliothek [diagrams](http://projects.haskell.org/diagrams/) von Brent Yorgey.
*/

import Cocoa

//: ## Definition der Datentypen

enum Shape {
    case Ellipse
    case Rectangle}

indirect enum Diagram {
    case Primitive(CGSize, Shape)
    case Beside(Diagram, Diagram)
    case Below(Diagram, Diagram)
    case Annotated(Attribute, Diagram)
}

enum Attribute {
    case FillColor(NSColor)
    case Alignment(Align)
}

typealias Align = CGPoint

//: Bemerkung: in funktionalen Sprache heißen solche `enum`s auch **algebraische Datentypen** oder **Summentypen**.

//: Ein ersten Beispiel:

let blueSquare = Diagram.Annotated(Attribute.FillColor(.blueColor()),
    Diagram.Primitive(CGSize(width:1, height:1), Shape.Rectangle))

//: ### Smarte Konstruktoren (Kombinatoren)

//: Primitive Formen

func square(side: CGFloat) -> Diagram {
    return Diagram.Primitive(CGSize(width:side, height:side), Shape.Rectangle)
}

func circle(radius: CGFloat) -> Diagram {
    return Diagram.Primitive(CGSize(width:2*radius, height:2*radius), Shape.Ellipse)
}

func rectangle(width: CGFloat, height: CGFloat) -> Diagram {
    return Diagram.Primitive(CGSize(width:width, height:height), Shape.Rectangle)
}

//: Farben und Alignment

extension Diagram {
    func fill(color: NSColor) -> Diagram {
        return Annotated(Attribute.FillColor(color), self)
    }
    func align(x: CGFloat, y: CGFloat) -> Diagram {
        return Annotated(Attribute.Alignment(CGPoint(x:x, y:y)), self)
    }
    func alignRight() -> Diagram {
        return align(1, y:0.5)
    }
    func alignTop() -> Diagram {
        return align(0.5, y:1)
    }
    func alignBottom() -> Diagram {
        return align(0.5, y:0)
    }
}

//: Operatoren zur Platzierung nebeneinander- bzw. untereinander

infix operator ||| { associativity left }
func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(l, r)
}

infix operator --- { associativity left }
func --- (top: Diagram, bottom: Diagram) -> Diagram {
    return Diagram.Below(top, bottom)
}

//: ### Mehr Beispiele

//: ![sampleDiagram1a](diag1.png)
//: ![sampleDiagram1b](diag2.png)
//: ![sampleDiagram2](diag3.png)

let redSquare = square(2).fill(.redColor())
let greenCircle = circle(0.5).fill(.greenColor())
let sampleDiagram1a = blueSquare ||| redSquare
let sampleDiagram1b = blueSquare ||| greenCircle ||| redSquare
let sampleDiagram2 =
    sampleDiagram1b.alignBottom() ---
    rectangle(10, height:0.2).fill(.magentaColor()).alignTop()

//: ## Funktionen über algebraische Datentypen

//: Kochrezept: Fallunterscheidung

extension Diagram {
    func size() -> CGSize {
        switch self {
        case .Primitive(let sz, _):
            return sz
        case .Beside(let left, let right):
            let ls = left.size()
            let rs = right.size()
            return CGSizeMake(ls.width + rs.width, max(ls.height, rs.height))
        case .Below(let up, let down):
            let us = up.size()
            let ds = down.size()
            return CGSizeMake(max(us.width, ds.width), us.height + ds.height)
        case Annotated(_, let d):
            return d.size()
        }
    }
}

/*:

## Diskussion: Algebraische Datentype vs. Klassen

* Funktionale Sprachen: algebraischen Datentypen
  - Hinzufügen neuer Funktionen: einfach
  - Hinzufügen neuer Fälle: schwierig
* OO-Sprachen: Klassen
  - Hinzufügen neuer Funktionen: schwierig
  - Hinzufügen neuer Fälle: einfach

*/

//: ## Zeichnen

extension Diagram : Drawable {
    func draw(ctx: CGContextRef, bounds: CGRect) {
        switch (self) {
        case .Primitive(let sz, let shape):
            let frame = fit(sz, align: alignCenter, bounds: bounds)
            switch (shape) {
            case .Ellipse:
                CGContextFillEllipseInRect(ctx, frame)
            case .Rectangle:
                CGContextFillRect(ctx, frame)
            }
        case .Beside(let left, let right):
            let (leftBounds, rightBounds) = splitHorizontal(left.size(), right: right.size(), bounds: bounds)
            left.draw(ctx, bounds:leftBounds)
            right.draw(ctx, bounds:rightBounds)
        case .Below(let top, let bottom):
            let (topBounds, bottomBounds) = splitVertical(top.size(), bottom: bottom.size(), bounds: bounds)
            top.draw(ctx, bounds:topBounds)
            bottom.draw(ctx, bounds:bottomBounds)
        case .Annotated(.FillColor(let color), let diagram):
            CGContextSaveGState(ctx)
            color.set()
            diagram.draw(ctx, bounds:bounds)
            CGContextRestoreGState(ctx)
        case .Annotated(.Alignment(let align), let diagram):
            let newBounds = fit(diagram.size(), align: align, bounds: bounds)
            diagram.draw(ctx, bounds:newBounds)
        }
    }
}

//: # Beispiele
let frameWidth = 1200

func viewDiagram(diagram: Diagram) -> DiagramView {
    let frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameWidth)
    let view = DiagramView(frame:frame, drawable:diagram)
    return view
}

viewDiagram(blueSquare)
viewDiagram(redSquare)
viewDiagram(greenCircle)
viewDiagram(blueSquare ||| greenCircle)
viewDiagram(redSquare --- blueSquare)
viewDiagram(redSquare --- square(0.1).fill(.clearColor()) --- blueSquare)
viewDiagram(redSquare --- blueSquare.alignRight())
viewDiagram((redSquare --- blueSquare.alignRight()).alignRight())
viewDiagram(sampleDiagram1a)
viewDiagram(sampleDiagram1b)
viewDiagram(sampleDiagram2)
