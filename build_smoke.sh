#!/bin/bash
# build_smoke.sh - compila o q3smoke (código real do ioq3) para o SF-100: ./build_smoke.sh saida.bin
source "$(dirname "$0")/modules.sh"
OUT=$1; TMP=$(mktemp -d)
for f in "$RT/crt0.S" "$RT/libc.c" "$RT/libc2.c" "$RT/setjmp.S" "$RT/libm.c" "$RT/libgcc.c" "$IOQ/q3smoke.c" "$CODE/qcommon/q_shared.c" "$CODE/qcommon/q_math.c"; do
  $CC "${CFLAGS_COMMON[@]}" "-I$CODE/qcommon" -c "$f" -o "$TMP/$(basename "$f").o"
done
$CC "${CFLAGS_COMMON[@]}" -nostdlib -nostartfiles -nodefaultlibs -static -Wl,--no-warn-rwx-segments -Wl,--build-id=none -T "$RT/link.ld" -o "${OUT%.bin}.elf" "$TMP"/*.o
${OBJCOPY:-m68k-linux-gnu-objcopy} -O binary "${OUT%.bin}.elf" "$OUT"; rm -rf "$TMP"; echo "$OUT: $(wc -c < "$OUT") bytes"
