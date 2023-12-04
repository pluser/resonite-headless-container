#!/bin/bash

if [[ $(echo "${RESONITE_HEADLESS_CODE}" | sha1sum - | head -c 40) != 'd1f3ba9ef7ebd9a57c5f4792ccdd690ab81173c3' ]]; then echo 'Invalid headless code. Please get it from Resonite bot and set it as RESONITE_HEADLESS_CODE environment variable.'; exit 1; fi

mono /opt/Resonite/Headless/Resonite.exe -Invisible -HeadlessConfig /mnt/resonite/config/Config.json -Watchdog /mnt/resonite/watchdog -Data /mnt/resonite/data -Cache /mnt/resonite/cache -Logs /mnt/resonite/logs "$@"
