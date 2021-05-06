PIC_LD=ld

ARCHIVE_OBJS=
ARCHIVE_OBJS += _137439_archive_1.so
_137439_archive_1.so : archive.0/_137439_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_137439_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_137439_archive_1.so $@


ARCHIVE_OBJS += _137448_archive_1.so
_137448_archive_1.so : archive.0/_137448_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_137448_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_137448_archive_1.so $@


ARCHIVE_OBJS += _137449_archive_1.so
_137449_archive_1.so : archive.0/_137449_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_137449_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_137449_archive_1.so $@


ARCHIVE_OBJS += _137450_archive_1.so
_137450_archive_1.so : archive.0/_137450_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_137450_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_137450_archive_1.so $@





O0_OBJS =

$(O0_OBJS) : %.o: %.c
	$(CC_CG) $(CFLAGS_O0) -c -o $@ $<


%.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \


CU_LVL_OBJS = \
SIM_l.o 

MAIN_OBJS = \
objs/amcQw_d.o 

CU_OBJS = $(MAIN_OBJS) $(ARCHIVE_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

