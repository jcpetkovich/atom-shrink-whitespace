ShrinkWhitespace = require '../lib/shrink-whitespace'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ShrinkWhitespace", ->
  [workspaceElement, activationPromise, editor, editorView] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('shrink-whitespace')

    waitsForPromise ->
      atom.workspace.open()

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)

  describe "when the shrink-whitespace:shrink event is triggered", ->
    it "Changes a sequence of blank lines into a single blank line", ->
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      waitsForPromise ->
        activationPromise

      editor.setText("one\n\n\ntwo\n\n\nthree\n")
      editor.setCursorBufferPosition([2, 0])
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      expect(editor.getText()).toBe("one\n\ntwo\n\n\nthree\n")
      expect(editor.getCursorBufferPosition()).toEqual({row: 1, column: 0})

    it "Changes a single blank line into no blank lines", ->
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      waitsForPromise ->
        activationPromise

      editor.setText("one\n\ntwo\n\nthree\n")
      editor.setCursorBufferPosition([1, 0])
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      expect(editor.getText()).toBe("one\ntwo\n\nthree\n")
      expect(editor.getCursorBufferPosition()).toEqual({row: 1, column: 0})

    it "Changes a sequence of horizontal space into a single space", ->
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      waitsForPromise ->
        activationPromise

      editor.setText("one\t   \t two\n\nthree\n")
      editor.setCursorBufferPosition([0, 5])
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      expect(editor.getText()).toBe("one two\n\nthree\n")
      expect(editor.getCursorBufferPosition()).toEqual({row: 0, column: 4})

      # Check boundary condition
      editor.setText("one\t   \t two\n\nthree\n")
      editor.setCursorBufferPosition([0, 3])
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      expect(editor.getText()).toBe("one two\n\nthree\n")
      expect(editor.getCursorBufferPosition()).toEqual({row: 0, column: 4})


    it "Changes a single space into no spaces", ->
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      waitsForPromise ->
        activationPromise

      editor.setText("one two\n\nthree\n")
      editor.setCursorBufferPosition([0, 4])
      atom.commands.dispatch editorView, 'shrink-whitespace:shrink'
      expect(editor.getText()).toBe("onetwo\n\nthree\n")
      expect(editor.getCursorBufferPosition()).toEqual({row: 0, column: 3})
