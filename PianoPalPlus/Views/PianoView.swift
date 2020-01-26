//
//  PianoView.swift
//  pianopal
//
//  Created by Joshua Escribano on 7/23/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum ScrollDirection : Int {
    case rightToLeft, leftToRight
}

extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesCancelled(touches, with: event)
    }
}

class PianoView: UIView, UIScrollViewDelegate {
    var scrollView = UIScrollView()
    var contentView = UIView()
    var noteViews = [NoteView]()
    var notesState = NotesState()
    var isScrollLocked: Bool = true {
        didSet {
            scrollView.isScrollEnabled = !isScrollLocked
            if isScrollLocked {
                scrollView.setContentOffset(scrollView.contentOffset, animated: true)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setup()
    }
    
    private func setup() {
        scrollView.frame = self.frame
        scrollView.contentSize.width = scrollView.frame.width * CGFloat(Octave.max + 1)
        scrollView.contentSize.height = scrollView.frame.height
        contentView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.contentSize.width,
                                   height: scrollView.contentSize.height)
        scrollView.contentOffset = CGPoint(x: scrollView.frame.width, y: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .init(rawValue: 1)
        scrollView.bounces = false
        scrollView.delegate = self
        for i in Octave.min...(Octave.max + 1) {
            contentView.addSubview(setUpOctaveView(i))
        }
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.delaysContentTouches = false
        isScrollLocked = true
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        contentView.isMultipleTouchEnabled = true
    }
    
    private func setUpOctaveView(_ position: Int) -> UIView {
        let height = scrollView.frame.height
        let width = scrollView.frame.width
        let offset = CGFloat(position - Octave.min) * scrollView.frame.width
        let octaveView = UIView(frame: CGRect(x: offset, y: 0, width: width, height: height))
        var notes = [NoteOctave]()
        for note in Constants.orderedNotes.sorted(by: { a,b in
            if a.isWhiteKey() && b.isBlackKey() {
                return true
            }
            return false
        }) {
            let buttonFrame = CGRect(x: width * KeyProperties.x(note),
                                     y: 0,
                                     width: width * KeyProperties.width(note),
                                     height: height * KeyProperties.height(note))
            notes.append(NoteOctave(note: note, octave: position))
            let noteView = NoteView(frame: buttonFrame, note: note, octave: position)
            noteView.isUserInteractionEnabled = true
            noteView.isMultipleTouchEnabled = true
            noteView.label()
            noteViews.append(noteView)
            octaveView.addSubview(noteView)
        }
        notesState.add(notes: notes)
        octaveView.isMultipleTouchEnabled = true
        return octaveView
    }
    
    var touchedViews = [UITouch:NoteView]()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            guard let noteView = touch.view as? NoteView else { return }
            touchedViews[touch] = noteView
            noteView.touches.update(with: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isScrollLocked else { return }

        touches.forEach { touch in
            guard (touch.view as? NoteView) != nil else { return }
            let location = touch.location(in: nil)

            guard let newNoteView = noteViews.filter({ possibleNewNoteView in
                return possibleNewNoteView.superview?.convert(possibleNewNoteView.frame, to: nil).contains(location) ?? false
            }).sorted(by: { a,b in
                if a.note.isBlackKey() && b.note.isWhiteKey() {
                    return true
                }
                return false
            }).first else { return }

            if touchedViews[touch] != newNoteView {
                touchedViews[touch]?.touches.remove(touch)
                touchedViews[touch] = newNoteView
                newNoteView.touches.update(with: touch)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouches(touches)
    }
    
    private func removeTouches(_ touches: Set<UITouch>) {
        touches.forEach { touch in
            touchedViews[touch]?.touches.remove(touch)
            touchedViews[touch] = nil
        }
    }
    
}

class NotesState {
    var current = [NoteOctave: Bool]()
    
    init(notes: [NoteOctave] = [NoteOctave]()) {
        notes.forEach { current[$0] = false }
    }
    
    func add(notes: [NoteOctave]) {
        
    }
}

extension PianoView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
