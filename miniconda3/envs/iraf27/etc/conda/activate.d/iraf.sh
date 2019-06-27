
if [ -n "$CONDA_PREFIX" ]; then
    . $CONDA_PREFIX/bin/setup_iraf.sh
else
    . $CONDA_ENV_PATH/bin/setup_iraf.sh
fi

