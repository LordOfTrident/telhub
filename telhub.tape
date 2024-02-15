# vhs < telhub.tape

Output res/telhub.gif

# Set Margin 60
# Set MarginFill "#6B50FF"
# Set BorderRadius 20
# Set WindowBar Colorful
Set TypingSpeed 80ms
Set FontSize 22
Set Width 1300
Set Height 650

Type "tmux"
Enter
Sleep 100ms
Type "mix run --no-halt -- 4040"
Enter
Sleep 2000ms

Ctrl+B
Type "c"
Ctrl+B
Type "%"
Ctrl+B
Type "o"

Type "telnet localhost 4040"
Enter
Sleep 2000ms
Type "FooBar123"
Enter

Sleep 1000ms
Type "/scan on"
Enter
Sleep 500ms

Ctrl+B
Type "o"

Type "telnet localhost 4040"
Enter
Sleep 1000ms
Type "Bazooka49"
Enter

Sleep 1000ms
Type "/scan on"
Enter
Sleep 1000ms

Type "Hello, world!"
Enter
Sleep 2000ms

Ctrl+B
Type "o"

Type "Hey how are you doing"
Enter
Sleep 2000ms

Type "Wait, lets go to a custom channel"
Enter
Sleep 500ms

Type "Follow me!"
Enter
Sleep 1000ms

Type "/join friends"
Enter
Sleep 2000ms

Ctrl+B
Type "o"

Type "Alright."
Enter
Sleep 1000ms

Type "/users"
Enter
Sleep 500ms

Type "/join friends"
Enter
Sleep 2000ms

Type "Hi!!!"
Enter
Sleep 1000ms

Type "Also im doing good, what about you?"
Enter
Sleep 2000ms

Ctrl+B
Type "o"

Type "Im fine"
Enter
Sleep 1000ms

Type "Wait, gotta go!"
Enter
Sleep 2000ms

Ctrl+B
Type "o"

Type "Alright, cya"
Enter
Sleep 1000ms

Ctrl+B
Type "o"

Type "Bye"
Enter
Sleep 1000ms

Type "/exit"
Enter
Sleep 4000ms
