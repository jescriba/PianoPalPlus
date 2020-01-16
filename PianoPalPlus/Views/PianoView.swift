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

class PianoView: UIView, UIScrollViewDelegate {
    var scrollView = UIScrollView()
    var contentView = UIView()
    var noteButtons = [NoteButton]()
    var highlightedNoteButtons = [NoteButton]()
    
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
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.contentSize.width = scrollView.frame.width * CGFloat(Octave.max)
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
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        panGesture.delegate = self
        contentView.addGestureRecognizer(panGesture)
    }
    
    private func setUpOctaveView(_ position: Int) -> UIView {
        let height = scrollView.frame.height
        let width = scrollView.frame.width
        let offset = CGFloat(position - Octave.min) * scrollView.frame.width
        let octaveView = UIView(frame: CGRect(x: offset, y: 0, width: width, height: height))
        for note in Constants.orderedNotes {
            let buttonFrame = CGRect(x: width * KeyProperties.x(note),
                                     y: 0,
                                     width: width * KeyProperties.width(note),
                                     height: height * KeyProperties.height(note))
            let button = NoteButton(frame: buttonFrame, note: note, octave: position)
            button.addTarget(self, action: #selector(touchDown(button:)), for: .touchDown)
            button.label()
            noteButtons.append(button)
            octaveView.addSubview(button)
        }
        return octaveView
    }
    
    @objc func touchDown(button: NoteButton) {
        // TODO
        print("touch down")
    }
    
    @objc func didPan() {
        
//        for (UIView *row in self.rows) {
//            for (UITouch *touch in touches) {
//                if ([row pointInside:[touch locationInView:self] withEvent:event]) {
//                    // Do something here!
//                }
//            }
//        }
        
        print("didMove")
    }
    
}

extension PianoView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
