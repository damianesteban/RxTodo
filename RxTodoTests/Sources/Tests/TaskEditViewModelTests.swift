//
//  TaskEditViewModelTests.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 8/23/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import XCTest
@testable import RxTodo

import RxExpect
import RxCocoa
import RxSwift
import RxTests

class TaskEditViewModelTests: XCTestCase {

    func testNavigationBarTitle() {
        RxExpect { test in
            let viewModel = TaskEditViewModel(mode: .New)
            let title = viewModel.navigationBarTitle.map { $0! }
            test.assertNextEqual(title, ["New"])
        }
        RxExpect { test in
            let task = Task(title: "")
            let viewModel = TaskEditViewModel(mode: .Edit(task))
            let title = viewModel.navigationBarTitle.map { $0! }
            test.assertNextEqual(title, ["Edit"])
        }
    }

    func testTitle() {
        RxExpect { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.assertNextEqual(viewModel.title.asDriver(), [""])
        }
        RxExpect { test in
            let task = Task(title: "Release a new version")
            let viewModel = TaskEditViewModel(mode: .Edit(task))
            test.assertNextEqual(viewModel.title.asDriver(), ["Release a new version"])
        }
    }

    func testDoneButtonEnabled() {
        RxExpect { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.title, [
                next(100, "A"),
                next(200, "AB"),
                next(300, ""),
            ])
            test.assertNextEqual(viewModel.doneButtonEnabled, [false, true, false])
        }
    }

    func testPresentCancelAlert_new() {
        RxExpect("it should not present cancel alert when title is empty") { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.cancelButtonDidTap, [next(100, Void())])

            let presented = viewModel.presentCancelAlert.map { _ in true }
            test.assertNextEqual(presented, [] as [Bool])
        }

        RxExpect("it should present cancel alert when title is not empty") { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.title, [next(10, "A")])
            test.input(viewModel.cancelButtonDidTap, [next(100, Void())])

            let presented = viewModel.presentCancelAlert.map { _ in true }
            test.assertNextEqual(presented, [true] as [Bool])
        }
    }

    func testPresentCancelAlert_edit() {
        let task = Task(title: "Clean my room")

        RxExpect("it should not present cancel alert when title is not changed") { test in
            let viewModel = TaskEditViewModel(mode: .Edit(task))
            test.input(viewModel.cancelButtonDidTap, [next(100, Void())])

            let presented = viewModel.presentCancelAlert.map { _ in true }
            test.assertNextEqual(presented, [] as [Bool])
        }

        RxExpect("it should present cancel alert when title is changed") { test in
            let viewModel = TaskEditViewModel(mode: .Edit(task))
            test.input(viewModel.title, [next(10, "A")])
            test.input(viewModel.cancelButtonDidTap, [next(100, Void())])

            let presented = viewModel.presentCancelAlert.map { _ in true }
            test.assertNextEqual(presented, [true] as [Bool])
        }
    }

    func testDismissViewController_cancel() {
        RxExpect("it should not dismiss view controller when cancel button tapped while title is changed") { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.title, [next(100, "A")])
            test.input(viewModel.cancelButtonDidTap, [next(200, Void())])

            let dismissed = viewModel.dismissViewController.map { _ in true }
            test.assertNextEqual(dismissed, [] as [Bool])
        }

        RxExpect("it should dismiss view controller when cancel button tapped while title is not changed") { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.cancelButtonDidTap, [next(100, Void())])

            let dismissed = viewModel.dismissViewController.map { _ in true }
            test.assertNextEqual(dismissed, [true] as [Bool])
        }
    }

    func testDismissViewController_leave() {
        RxExpect("it should dismiss view controller when leave button tapped") { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.alertLeaveButtonDidTap, [next(100, Void())])

            let dismissed = viewModel.dismissViewController.map { _ in true }
            test.assertNextEqual(dismissed, [true] as [Bool])
        }
    }

    func testDismissViewController_done() {
        RxExpect("it should not dismiss view controller when done button tapped while title is empty") { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.doneButtonDidTap, [next(100, Void())])

            let dismissed = viewModel.dismissViewController.map { _ in true }
            test.assertNextEqual(dismissed, [] as [Bool])
        }

        RxExpect("it should dismiss view controller when done button tapped while title is not empty") { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.title, [next(100, "A")])
            test.input(viewModel.doneButtonDidTap, [next(200, Void())])

            let dismissed = viewModel.dismissViewController.map { _ in true }
            test.assertNextEqual(dismissed, [true] as [Bool])
        }
    }

    func testTaskDidCreate() {
        RxExpect { test in
            let viewModel = TaskEditViewModel(mode: .New)
            test.input(viewModel.title, [next(100, "Hi")])
            test.input(viewModel.doneButtonDidTap, [next(200, Void())])

            let didCreate = Task.didCreate.filter { $0.title == "Hi" }.map { _ in true }
            test.assertNextEqual(didCreate, [true])
        }
    }

    func testTaskDidUpdate() {
        RxExpect { test in
            let task = Task(title: "Clean my room")
            let viewModel = TaskEditViewModel(mode: .Edit(task))
            test.input(viewModel.title, [next(100, "Hi")])
            test.input(viewModel.doneButtonDidTap, [next(200, Void())])

            let didUpdate = Task.didUpdate.filter { $0.title == "Hi" }.map { _ in true }
            test.assertNextEqual(didUpdate, [true])
        }
    }

}
