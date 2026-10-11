# Debug walkthrough template

The walkthrough teaches the user how the bug was found. Write it as a developer who explains the debugging process to a senior developer: natural, short, in the order that the work happened.

## Contents

- Template
- Rules
- Worked example: autosave sends old text

## Template

```markdown
# Walkthrough: <the bug in plain words>

## 1. The symptom
<What we saw. 1 to 2 sentences. Expected behavior and actual behavior.>

## 2. How we reproduced it
<The steps, or the failing test with its name and its result.>

## 3. How we narrowed it down
1. Hypothesis: <...>. Check: <what I did>. Result: <ruled out | confirmed>, because <evidence>.
2. Hypothesis: <...>. Check: <...>. Result: <...>.

## 4. The root cause
<1 to 2 plain sentences.>
Where: `<file>`, lines <from> to <to>.
<The code with the problem, maximum about 10 lines.>

## 5. The concept behind it
**Concept: <name>**
<What it is, in 2 to 3 simple sentences.>
<A generic example, 3 to 8 lines of code, with no relation to the project.>
**In this code:** <why the concept causes this bug, 1 to 2 sentences.>

## 6. The fix and why it works
<What changed. The code after the fix, maximum about 10 lines.>
**Why it works:** <how the change removes the root cause.>
**Not changed:** <what I left alone, and why.>

## 7. How to catch it next time
- Warning signs: <what to look for in the code or in the behavior>
- Quick check: <1 fast action that shows this type of bug>
- Tool: <a lint rule or a test that catches it>
- Habit: <1 habit to build>

## 8. Check question
<One question about the concept.>
```

## Rules

- Keep all 8 parts, in this order. For a small bug, write 1 to 2 lines for each part.
- Part 3 shows the real path. Include each dead end that taught something. Do not invent a hypothesis that you did not test.
- Part 4 separates the symptom from the cause. Give the file and the lines.
- Part 5: the generic example must not use names or code from the project. Then connect the concept to the project in "In this code".
- Part 6: say what you did not change. The user must see that the fix is small on purpose.
- Part 7 gives things that the user can do. Do not write general advice such as "be careful".
- Part 8 has exactly 1 question. The question tests the concept, not the memory of this bug. Do not give the answer in the same message.
- If you did not confirm the cause, write "likely" in part 4 and say what evidence confirms it.
- Use the writing style file. No filler and no praise.

## Worked example: autosave sends old text

```markdown
# Walkthrough: autosave saves an empty note

## 1. The symptom
The note editor saves the draft every 5 seconds. After a page reload, the note was empty.
Expected: the reload shows the last text. Actual: the reload shows the text from the moment the editor opened.

## 2. How we reproduced it
1. Open a new note.
2. Type "hello".
3. Wait 6 seconds.
4. Reload the page. The note is empty.

I also wrote a failing test, `useAutosave.test.ts`: "saves the latest text". It used fake timers. It expected `saveDraft` to get "hello" and it got "".

## 3. How we narrowed it down
1. Hypothesis: the server ignores the save request. Check: I read the request in the network tab. Result: ruled out. The server returned 200, and the request body already had `"text": ""`. The wrong value comes from the client.
2. Hypothesis: the `text` state does not update when the user types. Check: I logged `text` during render. Result: ruled out. Each render had the new text.
3. Hypothesis: the timer callback reads an old value of `text`. Check: I logged `text` inside the callback. Result: confirmed. The callback logged "" each time, while the render logged "hello".

Hypothesis 1 was a dead end, but it was useful. The request body showed that the problem was on the client, before the request.

## 4. The root cause
The effect creates the timer callback 1 time, when the editor opens. The callback keeps the `text` value of that first render and never sees a newer value.
Where: `src/features/notes/useAutosave.ts`, lines 8 to 14.

    useEffect(() => {
      const timer = setInterval(() => {
        saveDraft(noteId, text);
      }, AUTOSAVE_INTERVAL_MS);
      return () => clearInterval(timer);
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [noteId]);

The symptom was an empty note after a reload. The cause is that `text` is not in the dependency list, so the effect does not run again when `text` changes.

## 5. The concept behind it
**Concept: stale closure**
A function keeps the variables that existed when the function was created. If the function lives for a long time, it continues to use those old values. Each React render creates new variables, so a callback from an old render reads old state.

    function makeGreeter(name) {
      return () => console.log("Hello " + name);
    }
    let name = "Ana";
    const greet = makeGreeter(name);
    name = "Ben";
    greet(); // "Hello Ana"

**In this code:** the timer callback is `greet`. It was created in the first render, when `text` was "". The later renders have a new `text`, but the timer still calls the first callback.

## 6. The fix and why it works
The hook now keeps the latest text in a ref. The timer callback reads the ref.

    const latestText = useRef(text);
    useEffect(() => {
      latestText.current = text;
    });

    useEffect(() => {
      const timer = setInterval(() => {
        saveDraft(noteId, latestText.current);
      }, AUTOSAVE_INTERVAL_MS);
      return () => clearInterval(timer);
    }, [noteId]);

**Why it works:** a ref is 1 object that stays the same for all renders. The callback keeps the ref, not the value, so it reads the current text each time. The lint rule is active again, and it reports no missing dependency.
**Not changed:** I did not add `text` to the dependency list. That restarts the timer on each key press, so a user who types without a pause of 5 seconds gets no save. I did not change the interval or the save function.

## 7. How to catch it next time
- Warning signs: a callback that runs later (`setInterval`, `setTimeout`, an event listener, a subscription) and reads state or props. A disabled `react-hooks/exhaustive-deps` rule.
- Quick check: log the value in the render and in the callback. If the 2 values are different, the closure is stale.
- Tool: keep `react-hooks/exhaustive-deps` as an error. Search the project for `eslint-disable` comments on that rule.
- Habit: for each effect, ask "which render created this callback, and how long does the callback live?"

## 8. Check question
I rejected the fix "add `text` to the dependency list". With that fix, what happens to the timer each time the user types a character?
```
