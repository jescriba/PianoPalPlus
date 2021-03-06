//
//  PianoView.swift
//  pianopal
//
//  Created by Joshua Escribano on 7/23/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit
import Combine

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
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var noteViews = [NoteView]()
    private var isScrollLocked: Bool = true {
        didSet {
            scrollView.isScrollEnabled = !isScrollLocked
            if isScrollLocked {
                scrollView.setContentOffset(scrollView.contentOffset, animated: true)
            }
        }
    }
    weak var viewModel: PianoViewModel? {
        didSet {
            bindViewModel()
            bindNoteViewModels()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.background
        setupView()
        setupSubscriptions()
    }
    
    var cancellables = Set<AnyCancellable>()
    
    private func setupView() {
        scrollView.frame = self.bounds
        scrollView.contentSize.width = scrollView.bounds.width * CGFloat(Octave.max + 1)
        scrollView.contentSize.height = scrollView.bounds.height
        contentView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.contentSize.width,
                                   height: scrollView.contentSize.height)
        scrollView.contentOffset = CGPoint(x: scrollView.bounds.width, y: 0)
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
        scrollView.setContentOffset(CGPoint(x: 3 * scrollView.frame.width, y: 0), animated: false)
        contentView.isMultipleTouchEnabled = true
    }
    
    private func setupSubscriptions() {
        for noteView in noteViews {
            noteView.$hasTouch
                .sink(receiveValue: { [weak self] hasTouch in
                    self?.hasTouch(hasTouch, noteView: noteView)
                }).store(in: &cancellables)
        }
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.$scrollLocked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scrollLocked in
                self?.isScrollLocked = scrollLocked
            }).store(in: &cancellables)
        viewModel.$scrollLocked
            .combineLatest(viewModel.$delaysContentTouches)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (scrollLocked, delayTouches) in
                self?.isScrollLocked = scrollLocked
                self?.scrollView.delaysContentTouches = delayTouches
            }).store(in: &cancellables)
        viewModel.$scrollNote
            .filter({ $0 != nil })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scrollNote in
                guard let scrollView = self?.scrollView,
                    let lowestView = self?.noteViews.first(where: { $0.viewModel?.noteOctave == scrollNote }) else {
                    return
                }
                let x = scrollView.convert(lowestView.frame.origin, from: lowestView.superview).x
                scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }).store(in: &cancellables)
    }
    
    private func bindNoteViewModels() {
        guard noteViews.count == viewModel?.noteViewModels.count else { return }
        
        noteViews.enumerated().forEach({ [weak self] index, noteView in
            guard let vm = self?.viewModel?.noteViewModels[index] else { return }
            noteView.viewModel = vm
        })
    }
    
    private func setUpOctaveView(_ position: Int) -> UIView {
        let height = scrollView.bounds.height
        let width = scrollView.bounds.width
        let offset = CGFloat(position - Octave.min) * scrollView.bounds.width
        let octaveView = UIView(frame: CGRect(x: offset, y: 0, width: width, height: height))
        var notes = [NoteOctave]()
        for note in Notes.all.sorted(by: { a,b in
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
            let noteView = NoteView(frame: buttonFrame)
            noteView.isUserInteractionEnabled = true
            noteView.isMultipleTouchEnabled = true
            noteViews.append(noteView)
            octaveView.addSubview(noteView)
        }
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
                // DRY
                if (a.viewModel?.isBlackKey ?? false) && (b.viewModel?.isWhiteKey ?? false) {
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
    
    func hasTouch(_ hasTouch: Bool, noteView: NoteView) {
        guard let noteOctave = noteView.viewModel?.noteOctave else { return }
        viewModel?.hasTouch(hasTouch, noteOctave: noteOctave)
    }
    
}

extension PianoView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
