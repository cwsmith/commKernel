#!/bin/bash -e
unset LDFLAGS
unset THREAD_MULTIPLE
module swap mvapich2 mvapich2-mic
