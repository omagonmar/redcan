
if [ -n "$CONDA_PREFIX" ]; then
    . $CONDA_PREFIX/bin/forget_iraf.sh
else
    . $CONDA_ENV_PATH/bin/forget_iraf.sh
fi

