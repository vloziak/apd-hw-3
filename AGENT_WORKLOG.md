# HW3 Agent Worklog

If no agent or AI tool was used, say so explicitly. If one was used, record
each material task, inspect the resulting diff, and record one recommendation
you rejected or revised; if none was rejectable, explain why.

| Date | Tool/task | Student review | Evidence |
| --- | --- | --- | --- |
| 2026-11-09 | Claude Code (Claude Opus 5.5): read README.md, TASKS_AND_GRADES.md, SUBMISSION.md and the starter code and explained the whole task step by step. | I asked for an explanation in Ukrainian with simple words, so I can understand every requirement myself before I start. I checked the explanation against TASKS_AND_GRADES.md. I learned that `StudentStore` already has the filter and the add/edit/delete methods, so my main work is UI, tests and documents. | Chat explanation |
| 2026-11-09 | Claude Code (Claude Opus 5.5): explained Xcode problems. The run destination was "Any iOS Device", which can only build, and the `.md` files were not visible in the project navigator. | I asked why I can't see the files and can't run the app. I changed the destination to the iPhone 17 simulator myself. I added the `.md` files to the navigator as references. Claude noticed on my screenshot that the app target was still checked, so I unchecked it, and the documents are not copied into the app. | `project.pbxproj` diff: only file references, no target membership |
| 2026-11-09 | Claude Code (Claude Opus 5.5): recommended to create my own public repository first, because `origin` points to the course repository. | Revised. I decided to fork the repository later, before the commit I submit. I asked what changes with a fork, and Claude explained that GitHub Actions are turned off in forks by default, so I have to enable them to get a CI result. | Chat explanation |
| 2026-11-09 | Claude Code (Claude Opus 5.5): explained step 2, the student list, in detail: what files to create, where to put them, the code for `StudentCell`, `StudentListViewController` and the new `SceneDelegate`, and how to check the result. | I asked for a detailed explanation of what and where to add and how to check it. I created both files in Xcode myself, pasted the code and read every line. I asked what ⌘B does. I checked why the list reads students from the store every time (no second copy of the array) and why the cell uses `preferredFont` and identifiers | Chat explanation |
| 2026-11-09 | Claude Code (Claude Opus 5.5): diagnosed "Simulator device failed to launch". | First the app ran on iPhone 17 Pro with iOS 26.5, newer than my Xcode 26.1, so I switched to iPhone 17 (26.1). It still failed, and Claude found that the simulator itself was stuck: it turned off by itself and showed a black screen even without my app. Erasing the simulator fixed it. The code was correct, the build succeeded. | `xcodebuild build` succeeded; simulator screenshot shows the `Students` list |
| 2026-11-09 | Claude Code (Claude Opus 5.5): recommended a change in `StudentDirectoryApp.swift` (set `delegateClass = SceneDelegate.self`), because it looked like the reason of the black screen. | Rejected. Claude built the app without this change and the list still showed, so the change was not needed. The file was reverted to the starter version. | Chat explanation |
| 2026-11-09 | Claude Code (Claude Opus 5.5): checked the finished step 2 against TASKS_AND_GRADES.md and ran the README test command. | I asked for a detailed review before I commit step 2 myself. Claude's first test run hung on the start of the tests, so I asked how to run tests in the terminal myself. | First run stopped, no result |
| 2026-11-09 | Claude Code (Claude Opus 5.5): explained why tests hang and a crash report from the simulator. | I asked if I need to update iOS. Claude explained that I don't: the crash was the simulator's Calendar app, which was too slow to start, not my app. The real reasons are two Xcode versions on my Mac (26.1.1 in Applications for the IDE, 26.6 in Downloads for the terminal) and only 8 GB of memory for two simulator clones. I closed other apps, booted the simulator first and ran the exact README command myself. | `** TEST SUCCEEDED **`: 2 unit tests and 2 UI tests passed |
| 2026-11-09 | Claude Code (Claude Opus 5.5): drafted the rows of this table from our chat history. | Revised. I asked for this help with the wording in simple English, with the focus that I asked for explanations. I checked every row against what really happened in the chat. | This file; chat history |

## Final review

- Agent/tool disclosure: I used Claude Code (Claude Opus 5.5) to explain the
  task, the Xcode errors and the code, to draft PLAN.md and this worklog, and
  to review my work. I created the files, pasted and read the code, ran the
  app and made the commits myself.
- Accepted and rejected/revised recommendations: accepted the list screen
  design (one shared store, reusable cell, SnapKit, Dynamic Type). Revised:
  fork the repository later instead of creating a new one now. Rejected: the
  `StudentDirectoryApp.swift` change, because the app works without it.
- Exact local test command and result:
  `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test`
  on 2026-11-09 after step 2: `** TEST SUCCEEDED **`, the 4 starter tests
  passed (my own tests are not written yet).
- CI URL/status: not run yet, the fork will be created before submission.
- Known limitation or remaining risk: work in progress. Detail screen,
  subject filter, bonus and my own tests are not done yet.
