
// the caller should feed the target xor pad byte reversed as two uint64_t
// the ctr from emmc_cid_sha1 byte reversed as 4 uint32_t
__kernel void test_console_id(
	u64 xor_l, u64 xor_h,
	u64 console_id_template,
	u32 ctr0, u32 ctr1, u32 ctr2, u32 ctr3,
	__global int *success,
	__global u64 *console_id_out)
{
	if(success){
		return;
	}
	// TODO: BCD conversion
	u64 console_id = get_global_id(0) | console_id_template;
	u64 dsi_key[2];
	dsi_make_key(dsi_key, console_id);

	u32 aes_rk[RK_LEN];
	byte_reverse_16((u8*)aes_rk, (u8*)dsi_key);
	aes_set_key_enc_128(aes_rk);

	u32 ctr[4] = {ctr0, ctr1, ctr2, ctr3};
	u64 xor[2];
	aes_encrypt_128(aes_rk, ctr, (u32*)xor);

	if(xor[0] == xor_l && xor[1] == xor_h){
		*success = 1;
		*console_id_out = console_id;
	}
}