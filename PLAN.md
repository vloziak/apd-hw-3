# HW3 Student Plan

## Approach

In this homework I build StudentDirectory app with UIKit and SnapKit. I don't
change `Student` model, seed data or starter tests. I use MVC (Model, View,
Controller), so each part has its own job.

**Model** is `Student` and `StudentStore`. Store is the only place that keeps
the list of students and it already has `students(matchingSubject:)`, and
`addStudent`, `updateStudent`, `deleteStudent` with validation. **View** is my
reusable `StudentCell` (one table row with avatar and text) and the labels and
buttons on the detail screen. Views only show data, they don't change it.
**Controllers** are `StudentListViewController`, `StudentDetailViewController`
and `StudentFormViewController` for the bonus. They take data from store, give
it to views and react on taps.

### One shared store

I create one `StudentStore` in `SceneDelegate` and pass it into the first
controller through its `init`. Every next screen gets the same object from
the screen before it, so all screens look at the same data. I don't keep my
own copy of students array in controllers. List asks store for students every
time it reloads, and detail screen keeps only the student `id` and finds the
current student in store by this id. So after edit or delete, every screen
shows the new state and there is no old copy that can be wrong.

### Student list

`StudentListViewController` has `UITableView` and navigation title
`Students`. Each row is `StudentCell`, I register it once and reuse it with
`dequeueReusableCell`. The cell shows avatar, name, age, average grade and
scholarship status. All layout is made with SnapKit (`snp.makeConstraints`),
I don't use `NSLayoutConstraint` in my code.

### Details and navigation

Tap on row pushes `StudentDetailViewController` with
`navigationController?.pushViewController`, so standard back button works by
itself. Detail screen shows every field: id, name, age, average grade,
scholarship, subjects and avatar. I put content in `UIScrollView`, because
with big Dynamic Type text it may not fit on screen.

### Subject filtering

Every subject on detail screen is `UIButton`. Tap on it pushes the same
`StudentListViewController` again, but in "subject mode" with the subject
string. In this mode the list gets students from
`store.students(matchingSubject:)`, which uses `contains`, so the match is
exact and case sensitive (`Math` is not `math`). `filter` keeps store order,
and the title of the screen is the subject. I reuse one list controller
instead of making second one, so the cell and tap logic are written only once.

### Accessibility

I use the required identifiers (names that UI tests use to find elements):
`studentList` on table, `studentCell.<student-id>` on each cell,
`studentDetails` on detail screen, `subjectButton.<subject>` on each subject
button, and `addStudentButton`, `editStudentButton` for the bonus. All text
uses `preferredFont(forTextStyle:)` with
`adjustsFontForContentSizeCategory = true`, so it grows with Dynamic Type
(text size from iPhone settings), and labels can go to many lines. Cell gets
one `accessibilityLabel` that VoiceOver reads, like "Ada Lovelace, age 20,
grade 97.5, scholarship holder". Avatar images are decorative, so VoiceOver
skips them. I don't force unwrap user input, for age I use `Int(text)` with
`guard`.

## Bonus task

For the bonus I don't write new logic in store, because `addStudent`,
`updateStudent` and `deleteStudent` already exist and throw
`StudentStoreError`. I only build UI around them.

**Add.** List has "+" button `addStudentButton` in navigation bar. It opens
`StudentFormViewController` with two text fields, name and age. On Save I
call `store.addStudent`. If it throws (blank name, or age is 0, negative or
not a number) I show alert with error message and nothing changes. New
student gets new UUID, grade `0`, no scholarship, no subjects and
`avatar-default`, store already does this.

**Edit.** Detail screen has Edit button `editStudentButton`. It opens the same
form, but fields are already filled with current name and age, and Save calls
`store.updateStudent`. Only name and age can change, other fields stay the
same.

**Delete.** Swipe left on row in the list calls `store.deleteStudent` with
student id, and the row is removed from the table.

**Refresh.** After every successful change I reload what is on screen. Lists
reload in `viewWillAppear`, so when I go back from detail or form screen, the
list already shows new data. Detail screen also reloads its labels after
edit. If store throws, I don't reload anything, because nothing changed.

One case is not described in rules - in subject list I can also swipe to
delete. I allow it, because it deletes from the same shared store, so the
student disappears from all lists. New students have no subjects, so they
never show up in a subject list.

## Milestones

- [x] Student list and reusable cell
- [x] Detail screen and navigation
- [x] Subject-filtered list
- [ ] Unit and UI tests
- [x] Optional add/edit/delete bonus, if attempted
- [ ] Local verification and CI review
- [ ] Final diff and evidence review

## Risks and checks

- **Two copies of students:** if a controller keeps its own array, it can
  show old data after edit or delete. I always read from the store, and
  detail screen finds student by id.
- **Wrong subject match:** `"math"` must return nothing, because filter is
  case sensitive. I check it in unit test.
- **Wrong order in subject list:** for `Algorithms` I expect Ada Lovelace,
  Alan Turing, Grace Hopper, Edsger Dijkstra, Donald Knuth, in store order.
- **Invalid input changes data:** blank name, name of only spaces, age `0`
  and negative age must throw and leave store the same. Unknown id in update
  or delete must throw `unknownID` and change nothing.
- **Text does not fit:** with large Dynamic Type labels must wrap, not cut,
  so I use `numberOfLines = 0` and scroll view on detail screen.
- **UI tests can't find elements:** I set identifiers on the real elements
  that tests tap, not on wrappers around them.

## Verification plan

**Unit tests** (`StudentDirectoryTests`):
- subject filter returns right students in store order;
- subject filter is case sensitive and unknown subject gives empty list;
- add student with valid data uses default values (grade `0`, no
  scholarship, no subjects, `avatar-default`);
- add or update with blank name or `age <= 0` throws and doesn't change store;
- update changes only name and age;
- delete removes student, and unknown id throws `unknownID`.

**UI tests** (`StudentDirectoryUITests`):
- list opens with title `Students` and shows student cells;
- tap on cell opens `studentDetails` with right name, back button returns;
- tap on `subjectButton.Physics` opens list with title `Physics` and only
  Physics students;
- add student through form and see new row in list;
- edit student name and see new name on detail screen and in list;
- swipe to delete removes row.

My tests don't use `sleep`, time, random values or network. In UI tests I
wait for elements with `waitForExistence(timeout:)`, which only waits until
element appears.

While working I run single tests from Xcode with ⌘U or the diamond next to
the test. Final command is exactly the one from README:

```
xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test
```

I also check that GitHub Actions run is green after push, because local pass
doesn't prove that CI passed.
