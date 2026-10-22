#!/bin/bash
# build_rtest.sh - compila o harness do renderer (sem o motor):  ./build_rtest.sh saida.bin
source "$(dirname "$0")/modules.sh"
OUT=$1; T=$(mktemp -d); objs=()
b() { local o="$T/$(basename "$1").$RANDOM.o"; $CC "${CFLAGS_COMMON[@]}" "-I$CODE/renderercommon" "-I$CODE/thirdparty/jpeg-9f" "-I$IOQ" "-I$IOQ/sfr" -DSFR_STANDALONE $2 -c "$1" -o "$o" || exit 1; objs+=("$o"); }
"$(dirname "$0")/apply_patches.sh" >/dev/null
for f in "$RT/crt0.S" "$RT/libc.c" "$RT/libc2.c" "$RT/setjmp.S" "$RT/libm.c" "$RT/libgcc.c"; do b "$f"; done
for f in "${SFR[@]}"; do b "$IOQ/$f"; done
for f in "${RCOMMON[@]}"; do b "$CODE/$f"; done
for j in "${JPEG[@]}"; do b "$CODE/thirdparty/jpeg-9f/$j.c" "-w"; done
b "$IOQ/rtest.c" "$RT_DEFS"; b "$CODE/qcommon/q_shared.c"; b "$CODE/qcommon/q_math.c"
$CC "${CFLAGS_COMMON[@]}" -nostdlib -nostartfiles -nodefaultlibs -static -Wl,--no-warn-rwx-segments -Wl,--build-id=none -Wl,--defsym,__stack_top=0x03F00000 -Wl,-Map,"${OUT%.bin}.map" -T "$RT/link.ld" -o "${OUT%.bin}.elf" "${objs[@]}" || exit 1
${OBJCOPY:-m68k-linux-gnu-objcopy} -O binary "${OUT%.bin}.elf" "$OUT"; rm -rf "$T"; echo "$OUT: $(wc -c < "$OUT") bytes"
