wait until ship:unpacked. 

clearscreen.
print "Boot sequence initiated.".
print "Downloading flight software...".

copypath("0:/orbit.ks", "1:/").

print "Software Downloaded.".
print "Fly safe.".
switch to 1.

wait 10.

PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}


runpath("orbit.ks", 350, 15).