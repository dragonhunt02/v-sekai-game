#!/usr/bin/env bash

# Head position (constant)
PX=0.0
PY=1.5
PZ=0.2

# Output directory
OUTDIR="./screenshots-rotate"
mkdir -p "$OUTDIR"
CLIENT_MONADO=$1

# Loop over 0, 90, 180, 270 degrees
for i in {0..3}; do
  ANGLE=$(( i * 90 ))
  
  # Convert angle to radians
  RAD=$(awk "BEGIN { printf \"%f\", $ANGLE * 3.141592653589793 / 180 }")
  
  # Compute quaternion for rotation about Y-axis:
  #   qx = 0
  #   qy = sin(angle/2)
  #   qz = 0
  #   qw = cos(angle/2)
  QY=$(awk "BEGIN { printf \"%f\", sin($RAD/2) }")
  QW=$(awk "BEGIN { printf \"%f\", cos($RAD/2) }")

  # Inject head pose into Monado
  ${CLIENT_MONADO} <<EOF
set head position ${PX} ${PY} ${PZ}
set head rotation 0.0 ${QY} 0.0 ${QW}
EOF

  # Allow the system to stabilize
  sleep 1

  # Capture the composited window (adjust geometry as needed)
  grim -g "0,0 960x1080" "${OUTDIR}/screenshot-yaw-${ANGLE}deg.png"

  # Small pause before next iteration
  sleep 1
done

for i in {0..3}; do
  ANGLE=$(( i * 90 ))
  
  # Convert angle to radians
  RAD=$(awk "BEGIN { printf \"%f\", $ANGLE * 3.141592653589793 / 180 }")
  
  # Compute quaternion for rotation about X-axis:
  #   qx = sin(angle/2)
  #   qy = 0
  #   qz = 0
  #   qw = cos(angle/2)
  QX=$(awk "BEGIN { printf \"%f\", sin($RAD/2) }")
  QW=$(awk "BEGIN { printf \"%f\", cos($RAD/2) }")

  # Inject head pose into Monado
  ${CLIENT_MONADO} <<EOF
set head position ${PX} ${PY} ${PZ}
set head rotation ${QX} 0.0 0.0 ${QW}
EOF

  # Allow the system to stabilize
  sleep 1

  # Capture the composited window (adjust geometry as needed)
  grim -g "0,0 960x1080" "${OUTDIR}/screenshot-pitch-${ANGLE}deg.png"

  # Small pause before next iteration
  sleep 1
done

echo "Screenshots saved in ${OUTDIR}/"
