PIC_LD=ld

ARCHIVE_OBJS=
ARCHIVE_OBJS += _2166803_archive_1.so
_2166803_archive_1.so : archive.0/_2166803_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_2166803_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_2166803_archive_1.so $@


ARCHIVE_OBJS += _2166830_archive_1.so
_2166830_archive_1.so : archive.0/_2166830_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_2166830_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_2166830_archive_1.so $@


ARCHIVE_OBJS += _2166831_archive_1.so
_2166831_archive_1.so : archive.0/_2166831_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_2166831_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_2166831_archive_1.so $@


ARCHIVE_OBJS += _2166832_archive_1.so
_2166832_archive_1.so : archive.0/_2166832_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../work/ase_simv.daidir//_2166832_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../work/ase_simv.daidir//_2166832_archive_1.so $@





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

