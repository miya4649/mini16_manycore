// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

import java.lang.Math;

public class BootProgram extends AsmLib
{
  public void f_program_loader()
  {
    // input: R3:data_offset R4:data_size
    /*
    addr_reset = MASTER_W_BANK_IO_REG;
    addr_reset <<= DEPTH_B_M_W;
    addr_reset += IO_REG_W_RESET_PE;
    mem[addr_reset] = 1;
    size = R4;
    addr_memi = M2S_BANK_MEM_I;
    addr_memi <<= DEPTH_B_M2S;
    addr_pe = MASTER_W_BANK_BC;
    addr_pe <<= DEPTH_B_M_W;
    addr_pe += addr_memi;
    addr_u2m = MASTER_R_BANK_U2M;
    addr_u2m <<= DEPTH_B_U;
    addr_u2m += R3;
    do
    {
      size -= 1;
      data = mem[addr_u2m];
      mem[addr_pe] = data;
      addr_u2m++;
      addr_pe++;
    } while (size != 0)
    mem[addr_reset] = 0;
    */
    int size = 5;
    int addr_pe = 6;
    int addr_u2m = 7;
    int data = 8;
    int addr_memi = 9;
    int addr_reset = 10;
    int compare = 11;

    label("f_program_loader");
    lib_push(SP_REG_LINK);
    as_mvi(addr_reset, MASTER_W_BANK_IO_REG);
    as_sli(addr_reset, DEPTH_B_M_W);
    lib_nop(2);
    as_mvsi(addr_reset, MVS_SL);
    as_addi(addr_reset, IO_REG_W_RESET_PE);
    as_sti(addr_reset, 1);
    as_mv(size, R4);
    as_mvi(addr_memi, M2S_BANK_MEM_I);
    as_mvi(addr_u2m, MASTER_R_BANK_U2M);
    lib_set_im(addr_pe, MASTER_W_BANK_BC);
    as_sli(addr_memi, DEPTH_B_M2S);
    as_sli(addr_u2m, DEPTH_B_U);
    as_sli(addr_pe, DEPTH_B_M_W);
    as_mvsi(addr_memi, MVS_SL);
    as_mvsi(addr_u2m, MVS_SL);
    as_mvsi(addr_pe, MVS_SL);
    as_add(addr_u2m, R3);
    as_add(addr_pe, addr_memi);
    label("f_program_loader_L_0");
    as_ld(data, addr_u2m);
    as_subi(size, 1);
    as_addi(addr_u2m, 1);
    as_ld(data, addr_u2m);
    as_st(addr_pe, data);
    as_cnz(compare, size);
    as_addi(addr_pe, 1);
    lib_bc(compare, "f_program_loader_L_0");
    as_sti(addr_reset, 0);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  @Override
  public void init(String[] args)
  {
    super.init(args);
  }

  @Override
  public void program()
  {
    set_filename("boot_code");
    set_rom_width(WIDTH_I);
    set_rom_depth(DEPTH_M_I);
    // load PE code
    as_nop();
    lib_init_stack();
    as_mvi(R4, 1);
    as_mvi(R3, 0);
    as_sli(R4, DEPTH_P_I);
    lib_nop(2);
    as_mvsi(R4, MVS_SL);
    lib_call("f_program_loader");
    lib_call("f_halt");
    // link library
    f_halt();
    f_program_loader();
  }

  @Override
  public void data()
  {
    set_filename("boot_data");
    set_rom_width(WIDTH_M_D);
    set_rom_depth(DEPTH_M_D);
    dat(0);
  }
}
