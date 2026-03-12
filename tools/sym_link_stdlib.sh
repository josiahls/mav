#!/bin/bash
if [ ! -L third_party/modular ] && [ -d $PIXI_PROJECT_ROOT/../modular ]; then 
    ln -s $PIXI_PROJECT_ROOT/../modular third_party/modular
else 
    echo 'Modular directory already exists.'
fi