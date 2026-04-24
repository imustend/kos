// This program works for 2 stage orbital rockets with boosters.
// First stage takes the rocket to 100km suborbital flight,
// while the second one performs a circularization burn.
// This is how the staging should look like from bottom to top:
// Stage 1 - Main engine and boosters start
// Stage 2 - Booster separation
// Stage 3 - Main stage separation and secondary engine start

parameter upper_stage_isp.
parameter angle_of_gravity_turn.

clearScreen.

set radius to 100000.


print "Orbit set at: " + radius +"m (" + round(radius/1000, 1) + "km)".

lock throttle to 0.75.

wait 0.5.
print "Liftoff!!".

stage.

wait 0.5.

when stage:solidfuel < 0.1 then {
    lock throttle to 1.
    wait 0.5.
    print "Booster fuel depleted! Staging.".
    stage.
}

set mysteer to heading(90,90).
lock steering to mysteer.

wait until ship:airspeed > 200.
print "Starting gravity turn".
set mysteer to heading(90,90 - angle_of_gravity_turn).

wait until vAng(ship:srfprograde:vector, ship:up:vector) > angle_of_gravity_turn.

lock steering to srfPrograde.

wait until apoapsis > radius.
lock throttle to 0.
wait until ship:thrust = 0.
wait 0.5.

print "Staging".
stage.

wait until ship:altitude > 70000.

if ship.apoapsis < radius {
    print "Starting correction burn".
    lock steering to prograde.
    lock throttle to 0.2.
}.
wait until ship:apoapsis > radius.
lock throttle to 0.

set time_at_apoapsis to time:seconds + eta:apoapsis.
set velocity_at_apoapsis to velocityAt(ship, time_at_apoapsis):orbit:mag.
set body_mu to ship:body:mu.
set orbital_radius to ship:body:radius + radius.
set target_velocity to sqrt(body_mu / orbital_radius).
set dv to target_velocity - velocity_at_apoapsis.

print "Adding maneuver node".
set cric_node to node(time_at_apoapsis, 0, 0, dv).
add cric_node.

set g0 to 9.80665.
set m0 to ship:mass.
set f to ship:availablethrust.

set e_term to constant:e ^ (-dv / (upper_stage_isp*g0)).
set burn_time to (m0 * upper_stage_isp * g0 / F) * (1-e_term).
set node_in to burn_time/2.

print "Calculated maneuver:".
print "         dV: " + round(dv, 1) + "m/s,".
print "          t: " + round(burn_time, 1) + "s,".
print "   target v: " + round(target_velocity, 1) + "m/s,".

lock steering to cric_node:deltav.

wait until eta:apoapsis <= node_in.
print "Starting circulization burn".
lock throttle to 1.

wait burn_time - 3.
lock throttle to 0.2.

wait until ship:velocity:orbit:mag >= target_velocity.
lock throttle to 0.