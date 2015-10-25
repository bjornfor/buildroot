#!/usr/bin/env bash

GENIMAGE_CFG="board/wandboard/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

genimage \
  --rootpath "${TARGET_DIR}" \
  --tmppath "${GENIMAGE_TMP}" \
  --inputpath "${BINARIES_DIR}" \
  --outputpath "${BINARIES_DIR}" \
  --config "${GENIMAGE_CFG}"

RET=${?}
test ${RET} -ne 0 && exit 1

./board/wandboard/create-swupdate-image.sh

RET=${?}
exit ${RET}
