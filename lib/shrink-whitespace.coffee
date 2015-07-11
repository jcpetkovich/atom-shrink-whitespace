{CompositeDisposable} = require 'atom'
{Range} = require 'text-buffer'

module.exports = ShrinkWhitespace =
  subscriptions: null

  shrink: ->
    editor = atom.workspace.getActiveTextEditor()
    editor.getLastCursor()
    for cursor in editor.getCursors()
      @shrinkAtCursor(cursor)

  shrinkAtCursor: (cursor) ->
    if @justOneSpace(cursor)
      @deleteHorizontalSpace(cursor)
    else if not @lineHasMeat(cursor)
      @deleteBlankLines(cursor)
    else if @lineHasMeat(cursor) and (@spaceForward(cursor) or @spaceBackward(cursor))
      @setJustOneSpace cursor

  lineHasMeat: (cursor) ->
    lineText = cursor.getCurrentBufferLine()
    /\S/.test lineText

  getMeatlesLineRange: (cursor) ->
    oldPosition = cursor.getBufferPosition()
    range = cursor.marker.getBufferRange()
    rowmin = 0
    rowmax = cursor.editor.getLastBufferRow()

    while not (cursor.getBufferRow() == rowmin or @lineHasMeat(cursor))
      cursor.moveUp()

    start = cursor.getBufferPosition()
    if @lineHasMeat(cursor)
      start.row = start.row + 1
    start.column = 0

    cursor.setBufferPosition(oldPosition)

    while not (cursor.getBufferRow() == rowmax or @lineHasMeat(cursor))
      cursor.moveDown()

    end = cursor.getBufferPosition()
    if @lineHasMeat(cursor)
      end.row = end.row - 1
    end.column = Infinity

    cursor.setBufferPosition(oldPosition)

    new Range(start, end)

  getMeatlessWordBoundary: (cursor) ->
    {row, column} = cursor.getBufferPosition()
    range = [[row, column - 1], [row, column + 1]]
    before = cursor.editor.getTextInBufferRange([[row, column - 1], [row, column]])
    after = cursor.editor.getTextInBufferRange([[row, column], [row, column + 1]])

    # if space before, expand
    if /\s/.test(before)
      start = cursor.getPreviousWordBoundaryBufferPosition(
        {wordRegex: /\S+/}
      )
    else
      start = cursor.getBufferPosition()

    # if space after, expand
    if /\s/.test(after)
      end = cursor.getNextWordBoundaryBufferPosition(
        {wordRegex: /\S+/}
      )
    else
      end = cursor.getBufferPosition()

    new Range(start, end)

  justOneSpace:(cursor) ->
    range = @getMeatlessWordBoundary(cursor)
    text = cursor.editor.getTextInBufferRange(range)
    /\s/.test(text) and text.length == 1

  spaceForward: (cursor) ->
    pos = cursor.getBufferPosition()
    /^\s.*$/.test cursor.editor.getTextInBufferRange([[pos.row, pos.column], [pos.row, Infinity]])

  spaceBackward: (cursor) ->
    pos = cursor.getBufferPosition()
    /^.*\s$/.test cursor.editor.getTextInBufferRange([[pos.row, 0], [pos.row, pos.column]])

  deleteHorizontalSpace: (cursor) ->
    range = @getMeatlessWordBoundary(cursor)
    cursor.editor.setTextInBufferRange(range, "")

  deleteBlankLines: (cursor) ->
    range = @getMeatlesLineRange(cursor)
    if range.isSingleLine()
      cursor.editor.deleteLine()
    else
      cursor.editor.setTextInBufferRange(range, "")

  setJustOneSpace: (cursor) ->
    range = @getMeatlessWordBoundary(cursor)
    cursor.editor.setTextInBufferRange(range, " ")

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'shrink-whitespace:shrink': => @shrink()

  deactivate: ->
    @subscriptions.dispose()
