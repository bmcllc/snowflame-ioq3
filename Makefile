# snowflame-ioq3: ioquake3 (Quake 3 / OpenArena) no SF-100. O emulador (runtime port/rt, sf100_run, sf100_mkdvd, sf100_play,
# libsnowflame.a) fica em SF100_DIR, por padrão ../snowflame. Ver README.md.
# relativo e sem espaços: o make não lida com espaços em nomes de alvo (os caminhos absolutos daqui têm)
SF100_DIR ?= ../snowflame
export SF100_DIR
SF100_MAKE := $(MAKE) -C $(SF100_DIR)

# testes do port: compilados contra a libsnowflame.a e o mini-framework de testes do emulador (rodam da raiz deste repositório)
build/test_ioq3: tests/test_ioq3.cpp $(SF100_DIR)/build/libsnowflame.a
	@mkdir -p build
	g++ -std=c++17 -O2 -ffp-contract=off -pthread -I$(SF100_DIR)/src -I$(SF100_DIR)/tests -I$(SF100_DIR)/demo $< $(SF100_DIR)/tests/test_main.cpp $(SF100_DIR)/build/libsnowflame.a -o $@
$(SF100_DIR)/build/libsnowflame.a:
	$(SF100_MAKE) build/libsnowflame.a
test: build/test_ioq3
	env -u CC -u CXX ./build/test_ioq3

# OpenArena: motor (VM interpretada) + pk3 enxuto de OA_BASE em out/oa
OA_DIR ?= out/oa
oa:
	./make_oa.sh $(OA_DIR)
dvd-oa: oa
	$(SF100_MAKE) dvd MORE_GAMES="--bin openarena=$$(realpath --relative-to=$(SF100_DIR) $(OA_DIR)/oa.bin) --data baseoa/pak0.pk3=$$(realpath --relative-to=$(SF100_DIR) $(OA_DIR)/pak0.pk3)"
play-oa: dvd-oa
	$(SF100_MAKE) build/sf100_play && $(SF100_DIR)/build/sf100_play $(SF100_DIR)/out/snowflame.dvd

# Quake 3 (qagame/cgame/ui nativos): os seus pak0..pak8.pk3 em Q3_BASE (não vêm no repositório); os pk3 viram um só, com os
# arquivos na ordem em que o jogo os lê (q3order.txt): menos saltos da cabeça do DVD
Q3_DIR ?= out/q3
Q3_BASE ?= baseq3
q3:
	env -u CC -u CXX NATIVE=1 OBJ=$(Q3_DIR)/obj ./build_ioq3.sh $(Q3_DIR)/q3.bin
$(Q3_DIR)/pak0.pk3: tools/mkq3.py q3order.txt $(wildcard $(Q3_BASE)/*.pk3)
	python3 tools/mkq3.py $(Q3_BASE) $@ q3order.txt
dvd-q3: q3 $(Q3_DIR)/pak0.pk3
	$(SF100_MAKE) dvd MORE_GAMES="--bin quake3=$$(realpath --relative-to=$(SF100_DIR) $(Q3_DIR)/q3.bin) --data baseq3/pak0.pk3=$$(realpath --relative-to=$(SF100_DIR) $(Q3_DIR)/pak0.pk3)"
play-q3: dvd-q3
	$(SF100_MAKE) build/sf100_play && $(SF100_DIR)/build/sf100_play $(SF100_DIR)/out/snowflame.dvd

clean:
	rm -rf build out

.PHONY: test oa dvd-oa play-oa q3 dvd-q3 play-q3 clean
