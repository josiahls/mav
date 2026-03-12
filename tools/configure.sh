#!/bin/bash
# NOTE: If we want to use the stdlib, we need to run the update_stdlib during 
# configure to make dev work convenient. Pixi supports overriding the default 
# task, but then the user gets prompted on which task they are to run every time.
if [ "$PIXI_ENVIRONMENT_NAME" = "stdlib-dev" ]; then 
    echo 'Running in stdlib-dev environment, updating stdlib...'; 
    pixi run update_stdlib; 
else 
    echo 'Running in default environment, skipping stdlib update...'; 
fi