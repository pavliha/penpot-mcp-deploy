#!/bin/sh
exec open -na "Google Chrome" --args \
  --user-data-dir="$HOME/.penpot-chrome" \
  --remote-debugging-port=9333 \
  --no-first-run \
  --disable-background-timer-throttling \
  --disable-renderer-backgrounding \
  --disable-backgrounding-occluded-windows \
  --disable-features=IntensiveWakeUpThrottling,CalculateNativeWinOcclusion \
  https://design.penpot.app/
