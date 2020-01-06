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
    var noteButtons = [NoteButton]()
    var highlightedNoteButtons = [NoteButton]()
    var lastContentOffset: CGFloat?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addScrollView()
    }
    
    private func addScrollView() {
        scrollView.frame = UIScreen.main.bounds
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.contentSize.width = scrollView.frame.width * 3
        scrollView.contentSize.height = scrollView.frame.height
        scrollView.contentOffset = CGPoint(x: scrollView.frame.width, y: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.98)
        scrollView.bounces = false
        scrollView.delegate = self
        
        scrollView.addSubview(setUpOctaveView(2))
        scrollView.addSubview(setUpOctaveView(1))
        scrollView.addSubview(setUpOctaveView(0))
        addSubview(scrollView)
    }
    
    private func setUpOctaveView(_ position: Int) -> UIView {
        let height = scrollView.frame.height
        let width = scrollView.frame.width
        let offset = CGFloat(position) * scrollView.frame.width
        let octaveView = UIView(frame: CGRect(x: offset, y: 0, width: width, height: height))
        for note in Constants.orderedNotes {
            let buttonFrame = CGRect(x: width * KeyProperties.x(note),
                                     y: 0,
                                     width: width * KeyProperties.width(note),
                                     height: height * KeyProperties.height(note))
            let button = NoteButton(frame: buttonFrame, note: note, octave: position + 2)
            noteButtons.append(button)
            octaveView.addSubview(button)
        }
        return octaveView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var scrollDirection: ScrollDirection?
        if (lastContentOffset != nil) {
            if scrollView.contentOffset.x > lastContentOffset {
                scrollDirection = ScrollDirection.rightToLeft
            } else {
                scrollDirection = ScrollDirection.leftToRight
            }
        }
        lastContentOffset = scrollView.contentOffset.x
        if scrollView.contentOffset.x > scrollView.frame.width * 2 || scrollView.contentOffset.x < 0 {
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            updateOctave(scrollDirection)
        }
    }
    
    private func updateOctave(_ scrollDirection: ScrollDirection?) {
        if scrollDirection == nil {
            return
        }
        for noteButton in noteButtons {
            if scrollDirection == ScrollDirection.leftToRight {
                if (noteButton.octave > 1) {
                    noteButton.noteOctave.octave -= 1
                }
            } else if scrollDirection == ScrollDirection.rightToLeft {
                if (noteButton.octave < 4) {
                    noteButton.noteOctave.octave += 1
                }
            }
        }
    }
}
