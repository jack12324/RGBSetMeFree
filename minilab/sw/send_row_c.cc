// To 554 students:
// Please copy this function into main.cc or create a corresponding header file

void send_row_C(uint16_t row, C_TYPE* vals, AFU& afu)
{ // can easily genericize send_row_X further. TODO: do that

	uint64_t wds[2] = {0};

	uint64_t base_addr = 0x300;
	uint64_t lw_addr = base_addr + row * 0x10;
	uint64_t hw_addr = lw_addr + 0x8;

	// Read the two words;
	unsigned bitind = 0;


	// Partition the words into their respective rows
	for(ptrdiff_t ind = 0; ind < DIM; ++ind)
	{
		uint64_t base_mask = 0x0FFFF;

		// TODO: unhardcode 16-bit
		bitind = (ind / 4);
		uint64_t shift_count = (ind * 16) % 64;

		// Mask and store
		wds[bitind] |= ((vals[ind] & (base_mask)) << shift_count);
	}

	if(DEBUG)
		fprintf(stdout, "CWRITE: low word, high word, address %lx | %lx @%lx @%lx\n", wds[0], wds[1], lw_addr, hw_addr);

	afu.write(lw_addr, wds[0]);
	afu.write(hw_addr, wds[1]);
}

