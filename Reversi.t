import GUI

View.Set ("graphics: 500;500")

const EMPTY := 0
const BLACK := 248
const WHITE := 31
const RADIUS := 25
var x, y, btnnum, btnupdown : int
var turn : int := BLACK
var boardState : array 1 .. 8, 1 .. 8 of int
var row, column : int
var numturned : int := 0
var checkmode : boolean := true
var oneplayer : boolean := true
% GUI
var scoreblacklabel, scorewhitelabel, turnlabel, onePlayerButton, twoPlayerButton, startLabel, rulebtn, backbtn : int
var scoreblack, scorewhite : int := 0
var scoreblk, scorewte : string
% files
var rulefilenum : int
var ruleline : string

proc setBoard
    cls
    var xval : int := 50
    var yval : int := 50
    if oneplayer then
	scoreblacklabel := GUI.CreateLabel (200, 480, "Black = Player")
	scorewhitelabel := GUI.CreateLabel (200, 460, "White = Computer")
    else
	scoreblacklabel := GUI.CreateLabel (200, 480, "Black = Player 1")
	scorewhitelabel := GUI.CreateLabel (200, 460, "White = Player 2")
    end if
    turnlabel := GUI.CreateLabel (200, 20, "It is Black's turn.")
    GUI.Hide (onePlayerButton)
    GUI.Hide (twoPlayerButton)
    GUI.Hide (startLabel)
    loop
	Draw.Line (xval, 50, xval, 450, 248)
	xval += 50
	exit when xval = 500
    end loop
    loop
	Draw.Line (50, yval, 450, yval, 248)
	yval += 50
	exit when yval = 500
    end loop
    Draw.FillOval (225, 225, RADIUS, RADIUS, 248)
    Draw.FillOval (275, 275, RADIUS, RADIUS, 248)
    Draw.Oval (225, 275, RADIUS, RADIUS, 248)
    Draw.Oval (275, 225, RADIUS, RADIUS, 248)
    for i : 1 .. 8
	for j : 1 .. 8
	    boardState (i, j) := EMPTY
	end for
    end for
    boardState (4, 4) := BLACK
    boardState (4, 5) := WHITE
    boardState (5, 4) := WHITE
    boardState (5, 5) := BLACK
end setBoard

proc switchside (row, column, tocolour : int)
    boardState (row, column) := tocolour
    Draw.FillBox (column * 50 + 1, row * 50 + 1, (column + 1) * 50 - 1, (row + 1) * 50 - 1, 31)
    Draw.FillOval (column * 50 + RADIUS, row * 50 + RADIUS, RADIUS, RADIUS, tocolour)
    Draw.Oval (column * 50 + RADIUS, row * 50 + RADIUS, RADIUS, RADIUS, BLACK)
end switchside

proc directioncheck (r, c, rowstep, colstep, currentcolour : int)
    var mycolour : int := currentcolour
    var othercolour : int
    var movrow : int := r + rowstep
    var movcol : int := c + colstep
    if mycolour = WHITE then
	othercolour := BLACK
    else
	othercolour := WHITE
    end if
    loop
	exit when movrow > 8 or movrow < 1 or movcol > 8 or movcol < 1
	if boardState (movrow, movcol) = othercolour then
	    movrow += rowstep
	    movcol += colstep
	elsif boardState (movrow, movcol) = EMPTY then
	    exit
	else
	    loop
		movrow -= rowstep
		movcol -= colstep
		exit when movrow = r and movcol = c
		if not checkmode then
		    switchside (movrow, movcol, mycolour)
		end if
		numturned += 1
	    end loop
	    exit
	end if
    end loop
end directioncheck

proc checker (row, column, currentcolour : int)
    %check up
    directioncheck (row, column, 1, 0, currentcolour)
    % check down
    directioncheck (row, column, -1, 0, currentcolour)
    %check right
    directioncheck (row, column, 0, 1, currentcolour)
    %check left
    directioncheck (row, column, 0, -1, currentcolour)
    % check up right
    directioncheck (row, column, 1, 1, currentcolour)
    % check up left
    directioncheck (row, column, 1, -1, currentcolour)
    %check down left
    directioncheck (row, column, -1, -1, currentcolour)
    %check down right
    directioncheck (row, column, -1, 1, currentcolour)
end checker

proc opponent % chooses next move by maximizing the number of tiles flipped for the current turn
    var row, column : int
    var maxturned : int := 0
    checkmode := true
    for i : 1 .. 8
	for j : 1 .. 8
	    if boardState (i, j) = EMPTY then
		checker (i, j, WHITE)
		if numturned > maxturned then
		    row := i
		    column := j
		    maxturned := numturned
		end if
	    end if
	end for
    end for
    checkmode := false
    delay (1000)
    switchside (row, column, WHITE)
    checker (row, column, WHITE)
end opponent

fcn markPossibleMoves (colournow : int) : int
    var possiblemoves : int := 0
    checkmode := true
    for i : 1 .. 8
	for j : 1 .. 8
	    if boardState (j, i) = EMPTY then
		numturned := 0
		checker (j, i, colournow)
		if numturned > 0 then
		    Draw.FillBox (i * 50 + 1, j * 50 + 1, (i + 1) * 50 - 1, (j + 1) * 50 - 1, 28)
		    possiblemoves += 1
		end if
	    end if
	end for
    end for
    result possiblemoves
end markPossibleMoves

proc clearemptyboxes
    for i : 1 .. 8
	for j : 1 .. 8
	    if boardState (j, i) = EMPTY then
		Draw.FillBox (i * 50 + 1, j * 50 + 1, (i + 1) * 50 - 1, (j + 1) * 50 - 1, 31)
	    end if
	end for
    end for
end clearemptyboxes

proc changeturn
    if turn = BLACK then
	turn := WHITE
    else
	turn := BLACK
    end if
end changeturn

proc twoplayer
    GUI.Quit
    oneplayer := false
end twoplayer

proc setturnlabel
    if turn = BLACK then
	GUI.SetLabel (turnlabel, "It is Black's turn.")
    else
	GUI.SetLabel (turnlabel, "It is White's turn.")
    end if
end setturnlabel

proc calcscore
    for i : 1 .. 8
	for j : 1 .. 8
	    if boardState (i, j) = WHITE then
		scorewhite += 1
	    elsif boardState (i, j) = BLACK then
		scoreblack += 1
	    end if
	end for
    end for
    scoreblk := "Black = " + intstr (scoreblack)
    scorewte := "White = " + intstr (scorewhite)
    GUI.SetLabel (scoreblacklabel, scoreblk)
    GUI.SetLabel (scorewhitelabel, scorewte)
end calcscore

proc rules
GUI.Hide (onePlayerButton)
GUI.Hide (twoPlayerButton)
GUI.Hide (rulebtn)
GUI.Hide (startLabel)
GUI.Show (backbtn)
open : rulefilenum, "reversi-rules.txt", get
if rulefilenum > 0 then
    loop
	exit when eof (rulefilenum)
	get : rulefilenum, ruleline : *
	put ruleline
    end loop
    close : rulefilenum
else
    put "File not found."
end if
end rules

proc home
cls
GUI.Show (onePlayerButton)
GUI.Show (twoPlayerButton)
GUI.Show (rulebtn)
GUI.Show (startLabel)
GUI.Hide (backbtn)
end home

onePlayerButton := GUI.CreateButton (200, 240, 100, "1 Player", GUI.Quit)
twoPlayerButton := GUI.CreateButton (200, 210, 100, "2 Player", twoplayer)
rulebtn := GUI.CreateButton (200, 180, 100, "Rules", rules)
backbtn := GUI.CreateButton (30, 30, 100, "Back", home)
startLabel := GUI.CreateLabel (225, 270, "Reversi")
home
loop
    exit when GUI.ProcessEvent
end loop
% start game
setBoard
loop
    clearemptyboxes
    % check for possible moves
    if markPossibleMoves (turn) > 0 then
	if turn = WHITE and oneplayer then % only for single-player mode. The computer will always be white while the player is black.
	    opponent
	    calcscore
	    changeturn
	    setturnlabel
	else % Either two-player mode or user's turn.
	    Mouse.ButtonWait ("up", x, y, btnnum, btnupdown)
	    row := y div 50
	    column := x div 50
	    x := column * 50 + RADIUS
	    y := row * 50 + RADIUS
	    % check if click is valid and in-bounds.
	    if (x > 25 and y > 25) and (x < 475 and y < 475) and boardState (row, column) = EMPTY then
		checkmode := false
		numturned := 0
		checker (row, column, turn)
		if numturned > 0 then
		    switchside (row, column, turn)
		    changeturn
		end if
		calcscore
	    end if
	end if
    else % no possible moves so switch sides
	changeturn
    end if
    % the game is over when the entire board is taken up or possible moves are left
    exit when scorewhite + scoreblack = 64
    exit when markPossibleMoves (BLACK) = 0 and markPossibleMoves (WHITE) = 0
    setturnlabel
    scoreblack := 0
    scorewhite := 0
end loop

GUI.SetLabel (turnlabel, "Game over.")
if scorewhite > scoreblack then
    put "Congratulations White! You won!"
    put scoreblk
    put scorewte
elsif scoreblack > scorewhite then
    put "Congratulations Black! You won!"
    put scoreblk
    put scorewte
else
    put "Draw"
    put scoreblk
    put scorewte
end if
